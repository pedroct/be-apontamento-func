-- ==========================================
-- RESET: DROP TABLES IF EXIST
-- ==========================================
DROP TABLE IF EXISTS public."AprovacoesApontamentos" CASCADE;
DROP TABLE IF EXISTS public."LogApontamentos" CASCADE;
DROP TABLE IF EXISTS public."Apontamentos" CASCADE;
DROP TABLE IF EXISTS public."Atividades" CASCADE;

-- ==========================================
-- TABELA ATIVIDADES
-- ==========================================
CREATE TABLE public."Atividades" (
    "Id" SERIAL PRIMARY KEY,
    "Nome" VARCHAR(200) NOT NULL,
    "Descricao" VARCHAR(500),
    "Ativo" BOOLEAN NOT NULL DEFAULT TRUE,
    "CriadoEm" TIMESTAMP DEFAULT NOW()
);

-- Inserts de exemplo de atividades
INSERT INTO public."Atividades" ("Nome")
VALUES
('Análise Técnica'),
('Reunião Diária'),
('Reunião de Planejamento'),
('Reunião de Demonstração'),
('Reunião de Estimativa'),
('Implementação'),
('Revisão de Código');

-- ==========================================
-- TABELA APONTAMENTOS
-- ==========================================
CREATE TABLE public."Apontamentos" (
    "Id" SERIAL PRIMARY KEY,

    -- Organização
    "OrganizacaoDevOpsId" VARCHAR(100) NOT NULL,

    -- Projeto
    "ProjetoDevOpsId" VARCHAR(100) NOT NULL,
    "ProjetoDevOpsNome" VARCHAR(200) NOT NULL,

    -- Work Item
    "WorkItemId" INT NOT NULL,
    "WorkItemTipo" VARCHAR(100) NOT NULL,
    "WorkItemTitulo" VARCHAR(300) NOT NULL,
    "WorkItemParentId" INT,
    "WorkItemParentTitulo" VARCHAR(300),
    "RemainingWork" DECIMAL(5,2),
    "OriginalEstimate" DECIMAL(5,2),
    "CompletedWork" DECIMAL(5,2),

    -- Usuário do DevOps
    "DevOpsUserDescriptor" VARCHAR(300) NOT NULL,
    "DevOpsUserDisplayName" VARCHAR(200) NOT NULL,

    -- Apontamento
    "AtividadeId" INT NOT NULL REFERENCES public."Atividades"("Id"),
    "DataApontamento" DATE NOT NULL,
    "DuracaoMinutos" INT NOT NULL CHECK ("DuracaoMinutos" BETWEEN 0 AND 420),
    "Comentario" VARCHAR(500),
    "Status" VARCHAR(50) NOT NULL DEFAULT 'PENDENTE'
        CHECK ("Status" IN ('PENDENTE', 'APROVADO', 'REJEITADO')),

    -- Auditoria
    "CriadoEm" TIMESTAMP DEFAULT NOW(),
    "CriadoPor" VARCHAR(100),
    "AlteradoEm" TIMESTAMP,
    "AlteradoPor" VARCHAR(100),

    CONSTRAINT "CK_Apontamentos_DataApontamento" CHECK ("DataApontamento" <= CURRENT_DATE)
);

-- ==========================================
-- TRIGGER PARA IMPEDIR APONTAMENTO FUTURO
-- ==========================================
CREATE OR REPLACE FUNCTION public."BloqueiaApontamentoFuturo"()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW."DataApontamento" > CURRENT_DATE THEN
        RAISE EXCEPTION 'Não é permitido apontamento para data futura.';
    END IF;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER "TRG_BloqueiaApontamentoFuturo"
BEFORE INSERT OR UPDATE ON public."Apontamentos"
FOR EACH ROW
EXECUTE FUNCTION public."BloqueiaApontamentoFuturo"();

-- ==========================================
-- TABELA APROVAÇÕES
-- ==========================================
CREATE TABLE public."AprovacoesApontamentos" (
    "Id" SERIAL PRIMARY KEY,
    "ApontamentoId" INT NOT NULL REFERENCES public."Apontamentos"("Id"),
    "AprovadorDevOpsUserId" VARCHAR(300) NOT NULL,
    "Status" VARCHAR(50) NOT NULL
        CHECK ("Status" IN ('PENDENTE','APROVADO','REJEITADO')),
    "DataAprovacao" TIMESTAMP,
    "Comentario" VARCHAR(500)
);

-- ==========================================
-- TABELA LOG (AUDITORIA)
-- ==========================================
CREATE TABLE public."LogApontamentos" (
    "Id" SERIAL PRIMARY KEY,
    "ApontamentoId" INT NOT NULL REFERENCES public."Apontamentos"("Id"),
    "Operacao" VARCHAR(50) NOT NULL,
    "DataOperacao" TIMESTAMP DEFAULT NOW(),
    "UsuarioOperacao" VARCHAR(300),
    "ConteudoAnterior" TEXT,
    "ConteudoNovo" TEXT
);

-- ==========================================
-- ÍNDICES
-- ==========================================
CREATE INDEX "IDX_Apontamentos_OrgProjData"
    ON public."Apontamentos" ("OrganizacaoDevOpsId", "ProjetoDevOpsId", "DataApontamento");

CREATE INDEX "IDX_Apontamentos_WorkItem"
    ON public."Apontamentos" ("WorkItemId");

CREATE INDEX "IDX_Apontamentos_ProjetoUsuario"
    ON public."Apontamentos" ("ProjetoDevOpsId", "DevOpsUserDescriptor", "DataApontamento");

CREATE INDEX "IDX_Apontamentos_Status"
    ON public."Apontamentos" ("Status");

CREATE INDEX "IDX_Apontamentos_Atividade"
    ON public."Apontamentos" ("AtividadeId");

-- ==========================================
-- VIEW PARA RELATÓRIOS
-- ==========================================
CREATE OR REPLACE VIEW public."vw_Apontamentos_HHMM" AS
SELECT
    a."Id",
    a."OrganizacaoDevOpsId",
    a."ProjetoDevOpsId",
    a."ProjetoDevOpsNome",
    a."WorkItemId",
    a."WorkItemTitulo",
    a."WorkItemTipo",
    a."WorkItemParentId",
    a."WorkItemParentTitulo",
    a."RemainingWork",
    a."OriginalEstimate",
    a."CompletedWork",
    a."DevOpsUserDescriptor",
    a."DevOpsUserDisplayName",
    act."Nome" AS "Atividade",
    a."DataApontamento",
    LPAD(FLOOR(a."DuracaoMinutos" / 60)::TEXT, 2, '0') || ':' ||
    LPAD((a."DuracaoMinutos" % 60)::TEXT, 2, '0') AS "DuracaoHHMM",
    a."Status",
    a."Comentario",
    a."CriadoEm",
    a."AlteradoEm"
FROM public."Apontamentos" a
JOIN public."Atividades" act
  ON act."Id" = a."AtividadeId";

CREATE OR REPLACE VIEW public."vw_AtividadesAtivas" AS
SELECT
    "Id",
    "Nome"
FROM public."Atividades"
WHERE "Ativo" = TRUE;

CREATE OR REPLACE VIEW public."vw_Apontamentos_Detalhes" AS
SELECT
    a."Id" AS id,
    a."DevOpsUserDisplayName" AS usuario,
    a."DataApontamento" AS data,
    a."DuracaoMinutos" AS duracaoMinutos,
    act."Nome" AS atividade,
    a."Comentario" AS comentario,
    a."WorkItemId" AS "workItemId"
FROM public."Apontamentos" a
INNER JOIN public."Atividades" act ON act."Id" = a."AtividadeId";

-- comandos abaixo para liberar as permissões:
GRANT SELECT ON public."vw_AtividadesAtivas" TO apontamentos_user;
GRANT SELECT ON public."vw_Apontamentos_Detalhes" TO apontamentos_user;

