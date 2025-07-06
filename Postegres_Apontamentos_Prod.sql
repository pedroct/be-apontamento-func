CREATE DATABASE "apontamentos_db_dev"
  WITH
  OWNER = apontamentos_user
  ENCODING = 'UTF8'
  LC_COLLATE = 'pt_BR.UTF-8'
  LC_CTYPE   = 'pt_BR.UTF-8'
  TEMPLATE = template0
  CONNECTION LIMIT = -1;

-- Table: public.Apontamentos
-- DROP TABLE IF EXISTS public."Apontamentos";
CREATE TABLE IF NOT EXISTS public."Apontamentos"
(
    "Id" integer NOT NULL DEFAULT nextval('"Apontamentos_Id_seq"'::regclass),
    "OrganizacaoDevOpsId" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "ProjetoDevOpsId" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "ProjetoDevOpsNome" character varying(200) COLLATE pg_catalog."default" NOT NULL,
    "WorkItemId" integer NOT NULL,
    "WorkItemTipo" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "WorkItemTitulo" character varying(300) COLLATE pg_catalog."default" NOT NULL,
    "WorkItemParentId" integer,
    "WorkItemParentTitulo" character varying(300) COLLATE pg_catalog."default",
    "RemainingWork" numeric(5,2),
    "OriginalEstimate" numeric(5,2),
    "CompletedWork" numeric(5,2),
    "DevOpsUserDescriptor" character varying(300) COLLATE pg_catalog."default" NOT NULL,
    "DevOpsUserDisplayName" character varying(200) COLLATE pg_catalog."default" NOT NULL,
    "AtividadeId" integer NOT NULL,
    "DataApontamento" date NOT NULL,
    "DuracaoMinutos" integer NOT NULL,
    "Comentario" character varying(500) COLLATE pg_catalog."default",
    "Status" character varying(50) COLLATE pg_catalog."default" NOT NULL DEFAULT 'PENDENTE'::character varying,
    "CriadoEm" timestamp without time zone DEFAULT now(),
    "CriadoPor" character varying(100) COLLATE pg_catalog."default",
    "AlteradoEm" timestamp without time zone,
    "AlteradoPor" character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT "Apontamentos_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Apontamentos_AtividadeId_fkey" FOREIGN KEY ("AtividadeId")
        REFERENCES public."Atividades" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Apontamentos_DuracaoMinutos_check" CHECK ("DuracaoMinutos" >= 0 AND "DuracaoMinutos" <= 420),
    CONSTRAINT "Apontamentos_Status_check" CHECK ("Status"::text = ANY (ARRAY['PENDENTE'::character varying, 'APROVADO'::character varying, 'REJEITADO'::character varying]::text[])),
    CONSTRAINT "CK_Apontamentos_DataApontamento" CHECK ("DataApontamento" <= CURRENT_DATE)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Apontamentos"
    OWNER to postgres;

REVOKE ALL ON TABLE public."Apontamentos" FROM apontamentos_user;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Apontamentos" TO apontamentos_user;

GRANT ALL ON TABLE public."Apontamentos" TO postgres;
-- Index: IDX_Apontamentos_Atividade
-- DROP INDEX IF EXISTS public."IDX_Apontamentos_Atividade";

CREATE INDEX IF NOT EXISTS "IDX_Apontamentos_Atividade"
    ON public."Apontamentos" USING btree
    ("AtividadeId" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: IDX_Apontamentos_OrgProjData
-- DROP INDEX IF EXISTS public."IDX_Apontamentos_OrgProjData";

CREATE INDEX IF NOT EXISTS "IDX_Apontamentos_OrgProjData"
    ON public."Apontamentos" USING btree
    ("OrganizacaoDevOpsId" COLLATE pg_catalog."default" ASC NULLS LAST, "ProjetoDevOpsId" COLLATE pg_catalog."default" ASC NULLS LAST, "DataApontamento" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: IDX_Apontamentos_ProjetoUsuario
-- DROP INDEX IF EXISTS public."IDX_Apontamentos_ProjetoUsuario";

CREATE INDEX IF NOT EXISTS "IDX_Apontamentos_ProjetoUsuario"
    ON public."Apontamentos" USING btree
    ("ProjetoDevOpsId" COLLATE pg_catalog."default" ASC NULLS LAST, "DevOpsUserDescriptor" COLLATE pg_catalog."default" ASC NULLS LAST, "DataApontamento" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: IDX_Apontamentos_Status
-- DROP INDEX IF EXISTS public."IDX_Apontamentos_Status";

CREATE INDEX IF NOT EXISTS "IDX_Apontamentos_Status"
    ON public."Apontamentos" USING btree
    ("Status" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: IDX_Apontamentos_WorkItem
-- DROP INDEX IF EXISTS public."IDX_Apontamentos_WorkItem";

CREATE INDEX IF NOT EXISTS "IDX_Apontamentos_WorkItem"
    ON public."Apontamentos" USING btree
    ("WorkItemId" ASC NULLS LAST)
    TABLESPACE pg_default;

-- Trigger: TRG_BloqueiaApontamentoFuturo
-- DROP TRIGGER IF EXISTS "TRG_BloqueiaApontamentoFuturo" ON public."Apontamentos";

CREATE OR REPLACE TRIGGER "TRG_BloqueiaApontamentoFuturo"
    BEFORE INSERT OR UPDATE 
    ON public."Apontamentos"
    FOR EACH ROW
    EXECUTE FUNCTION public."BloqueiaApontamentoFuturo"();

-- Table: public.Atividades
-- DROP TABLE IF EXISTS public."Atividades";
CREATE TABLE IF NOT EXISTS public."Atividades"
(
    "Id" integer NOT NULL DEFAULT nextval('"Atividades_Id_seq"'::regclass),
    "Nome" character varying(200) COLLATE pg_catalog."default" NOT NULL,
    "Descricao" character varying(500) COLLATE pg_catalog."default",
    "Ativo" boolean NOT NULL DEFAULT true,
    "CriadoEm" timestamp without time zone DEFAULT now(),
    CONSTRAINT "Atividades_pkey" PRIMARY KEY ("Id")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Atividades"
    OWNER to postgres;

REVOKE ALL ON TABLE public."Atividades" FROM apontamentos_user;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Atividades" TO apontamentos_user;

GRANT ALL ON TABLE public."Atividades" TO postgres;

-- Table: public.AprovacoesApontamentos
-- DROP TABLE IF EXISTS public."AprovacoesApontamentos";
CREATE TABLE IF NOT EXISTS public."AprovacoesApontamentos"
(
    "Id" integer NOT NULL DEFAULT nextval('"AprovacoesApontamentos_Id_seq"'::regclass),
    "ApontamentoId" integer NOT NULL,
    "AprovadorDevOpsUserId" character varying(300) COLLATE pg_catalog."default" NOT NULL,
    "Status" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "DataAprovacao" timestamp without time zone,
    "Comentario" character varying(500) COLLATE pg_catalog."default",
    CONSTRAINT "AprovacoesApontamentos_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "AprovacoesApontamentos_ApontamentoId_fkey" FOREIGN KEY ("ApontamentoId")
        REFERENCES public."Apontamentos" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "AprovacoesApontamentos_Status_check" CHECK ("Status"::text = ANY (ARRAY['PENDENTE'::character varying, 'APROVADO'::character varying, 'REJEITADO'::character varying]::text[]))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."AprovacoesApontamentos"
    OWNER to postgres;

REVOKE ALL ON TABLE public."AprovacoesApontamentos" FROM apontamentos_user;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."AprovacoesApontamentos" TO apontamentos_user;

GRANT ALL ON TABLE public."AprovacoesApontamentos" TO postgres;

-- Table: public.LogApontamentos
-- DROP TABLE IF EXISTS public."LogApontamentos";
CREATE TABLE IF NOT EXISTS public."LogApontamentos"
(
    "Id" integer NOT NULL DEFAULT nextval('"LogApontamentos_Id_seq"'::regclass),
    "ApontamentoId" integer NOT NULL,
    "Operacao" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "DataOperacao" timestamp without time zone DEFAULT now(),
    "UsuarioOperacao" character varying(300) COLLATE pg_catalog."default",
    "ConteudoAnterior" text COLLATE pg_catalog."default",
    "ConteudoNovo" text COLLATE pg_catalog."default",
    CONSTRAINT "LogApontamentos_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "LogApontamentos_ApontamentoId_fkey" FOREIGN KEY ("ApontamentoId")
        REFERENCES public."Apontamentos" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."LogApontamentos"
    OWNER to postgres;

REVOKE ALL ON TABLE public."LogApontamentos" FROM apontamentos_user;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."LogApontamentos" TO apontamentos_user;

GRANT ALL ON TABLE public."LogApontamentos" TO postgres;

-- FUNCTION: public.BloqueiaApontamentoFuturo()
-- DROP FUNCTION IF EXISTS public."BloqueiaApontamentoFuturo"();
CREATE OR REPLACE FUNCTION public."BloqueiaApontamentoFuturo"()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW."DataApontamento" > CURRENT_DATE THEN
        RAISE EXCEPTION 'NÆo ‚ permitido apontamento para data futura.';
    END IF;
    RETURN NEW;
END
$BODY$;

ALTER FUNCTION public."BloqueiaApontamentoFuturo"()
    OWNER TO postgres;

-- SEQUENCE: public.Apontamentos_Id_seq
-- DROP SEQUENCE IF EXISTS public."Apontamentos_Id_seq";
CREATE SEQUENCE IF NOT EXISTS public."Apontamentos_Id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public."Apontamentos_Id_seq"
    OWNED BY public."Apontamentos"."Id";

ALTER SEQUENCE public."Apontamentos_Id_seq"
    OWNER TO postgres;

GRANT SELECT, USAGE ON SEQUENCE public."Apontamentos_Id_seq" TO apontamentos_user;

GRANT ALL ON SEQUENCE public."Apontamentos_Id_seq" TO postgres;

-- SEQUENCE: public.AprovacoesApontamentos_Id_seq
-- DROP SEQUENCE IF EXISTS public."AprovacoesApontamentos_Id_seq";
CREATE SEQUENCE IF NOT EXISTS public."AprovacoesApontamentos_Id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public."AprovacoesApontamentos_Id_seq"
    OWNED BY public."AprovacoesApontamentos"."Id";

ALTER SEQUENCE public."AprovacoesApontamentos_Id_seq"
    OWNER TO postgres;

GRANT SELECT, USAGE ON SEQUENCE public."AprovacoesApontamentos_Id_seq" TO apontamentos_user;

GRANT ALL ON SEQUENCE public."AprovacoesApontamentos_Id_seq" TO postgres;

-- SEQUENCE: public.Atividades_Id_seq
-- DROP SEQUENCE IF EXISTS public."Atividades_Id_seq";
CREATE SEQUENCE IF NOT EXISTS public."Atividades_Id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public."Atividades_Id_seq"
    OWNED BY public."Atividades"."Id";

ALTER SEQUENCE public."Atividades_Id_seq"
    OWNER TO postgres;

GRANT SELECT, USAGE ON SEQUENCE public."Atividades_Id_seq" TO apontamentos_user;

GRANT ALL ON SEQUENCE public."Atividades_Id_seq" TO postgres;

-- SEQUENCE: public.LogApontamentos_Id_seq
-- DROP SEQUENCE IF EXISTS public."LogApontamentos_Id_seq";
CREATE SEQUENCE IF NOT EXISTS public."LogApontamentos_Id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public."LogApontamentos_Id_seq"
    OWNED BY public."LogApontamentos"."Id";

ALTER SEQUENCE public."LogApontamentos_Id_seq"
    OWNER TO postgres;

GRANT SELECT, USAGE ON SEQUENCE public."LogApontamentos_Id_seq" TO apontamentos_user;

GRANT ALL ON SEQUENCE public."LogApontamentos_Id_seq" TO postgres;

-- View: public.vw_Apontamentos_Detalhes
-- DROP VIEW public."vw_Apontamentos_Detalhes";
CREATE OR REPLACE VIEW public."vw_Apontamentos_Detalhes"
 AS
 SELECT a."Id" AS id,
    a."DevOpsUserDisplayName" AS usuario,
    a."DataApontamento" AS data,
    a."DuracaoMinutos" AS "duracaoMinutos",
    act."Nome" AS atividade,
    a."Comentario" AS comentario,
    a."WorkItemId" AS "workItemId",
    a."WorkItemTitulo" AS workitemtitulo,
    a."OriginalEstimate" AS "originalEstimate",
    a."RemainingWork" AS "remainingWork",
    a."DevOpsUserDescriptor" AS "devOpsUserDescriptor"
   FROM "Apontamentos" a
     JOIN "Atividades" act ON act."Id" = a."AtividadeId";

ALTER TABLE public."vw_Apontamentos_Detalhes"
    OWNER TO postgres;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."vw_Apontamentos_Detalhes" TO apontamentos_user;
GRANT ALL ON TABLE public."vw_Apontamentos_Detalhes" TO postgres;


-- View: public.vw_Apontamentos_HHMM
-- DROP VIEW public."vw_Apontamentos_HHMM";
CREATE OR REPLACE VIEW public."vw_Apontamentos_HHMM"
 AS
 SELECT a."Id",
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
    (lpad(floor((a."DuracaoMinutos" / 60)::double precision)::text, 2, '0'::text) || ':'::text) || lpad((a."DuracaoMinutos" % 60)::text, 2, '0'::text) AS "DuracaoHHMM",
    a."Status",
    a."Comentario",
    a."CriadoEm",
    a."AlteradoEm"
   FROM "Apontamentos" a
     JOIN "Atividades" act ON act."Id" = a."AtividadeId";

ALTER TABLE public."vw_Apontamentos_HHMM"
    OWNER TO postgres;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."vw_Apontamentos_HHMM" TO apontamentos_user;
GRANT ALL ON TABLE public."vw_Apontamentos_HHMM" TO postgres;

-- View: public.vw_Apontamentos_PainelGestor
-- DROP VIEW public."vw_Apontamentos_PainelGestor";
CREATE OR REPLACE VIEW public."vw_Apontamentos_PainelGestor"
 AS
 SELECT a."Id" AS id,
    a."DevOpsUserDisplayName" AS usuario,
    a."DataApontamento" AS data,
    a."DuracaoMinutos" AS duracaominutos,
    at."Nome" AS atividade,
    a."Comentario" AS comentario,
    a."Status" AS status
   FROM "Apontamentos" a
     LEFT JOIN "Atividades" at ON at."Id" = a."AtividadeId";

ALTER TABLE public."vw_Apontamentos_PainelGestor"
    OWNER TO postgres;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."vw_Apontamentos_PainelGestor" TO apontamentos_user;
GRANT ALL ON TABLE public."vw_Apontamentos_PainelGestor" TO postgres;

-- View: public.vw_Apontamentos_Usuario
-- DROP VIEW public."vw_Apontamentos_Usuario";
CREATE OR REPLACE VIEW public."vw_Apontamentos_Usuario"
 AS
 SELECT a."Id" AS id,
    a."DevOpsUserDisplayName" AS usuario,
    a."DataApontamento" AS data,
    a."DuracaoMinutos" AS "duracaoMinutos",
    act."Nome" AS atividade,
    a."Comentario" AS comentario,
    a."WorkItemId" AS "workItemId",
    a."WorkItemTitulo" AS workitemtitulo,
    a."OriginalEstimate" AS "originalEstimate",
    a."RemainingWork" AS "remainingWork",
    a."DevOpsUserDescriptor" AS "devOpsUserDescriptor",
    a."Status" AS status
   FROM "Apontamentos" a
     JOIN "Atividades" act ON act."Id" = a."AtividadeId";

ALTER TABLE public."vw_Apontamentos_Usuario"
    OWNER TO postgres;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."vw_Apontamentos_Usuario" TO apontamentos_user;
GRANT ALL ON TABLE public."vw_Apontamentos_Usuario" TO postgres;

-- View: public.vw_AtividadesAtivas
-- DROP VIEW public."vw_AtividadesAtivas";
CREATE OR REPLACE VIEW public."vw_AtividadesAtivas"
 AS
 SELECT "Atividades"."Id",
    "Atividades"."Nome"
   FROM "Atividades"
  WHERE "Atividades"."Ativo" = true;

ALTER TABLE public."vw_AtividadesAtivas"
    OWNER TO postgres;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."vw_AtividadesAtivas" TO apontamentos_user;
GRANT ALL ON TABLE public."vw_AtividadesAtivas" TO postgres;


