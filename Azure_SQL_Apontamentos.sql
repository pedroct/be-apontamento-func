-- ==========================================
-- RESET: DROP TABELAS SE EXISTIREM
-- ==========================================
IF OBJECT_ID('dbo.AprovacoesApontamentos') IS NOT NULL
    DROP TABLE dbo.AprovacoesApontamentos;

IF OBJECT_ID('dbo.LogApontamentos') IS NOT NULL
    DROP TABLE dbo.LogApontamentos;

IF OBJECT_ID('dbo.Apontamentos') IS NOT NULL
    DROP TABLE dbo.Apontamentos;

IF OBJECT_ID('dbo.Atividades') IS NOT NULL
    DROP TABLE dbo.Atividades;
GO

-- ==========================================
-- TABELA ATIVIDADES
-- ==========================================
CREATE TABLE dbo.Atividades (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(200) NOT NULL,
    Descricao NVARCHAR(500) NULL,
    Ativo BIT NOT NULL DEFAULT 1,
    CriadoEm DATETIME DEFAULT GETDATE()
);
GO

-- Inserts de exemplo de atividades
INSERT INTO dbo.Atividades (Nome)
VALUES
('Análise Técnica'),
('Reunião Diária'),
('Reunião de Planejamento'),
('Reunião de Demonstração'),
('Reunião de Estimativa'),
('Implementação'),
('Revisão de Código');
GO

-- ==========================================
-- TABELA APONTAMENTOS
-- ==========================================
CREATE TABLE dbo.Apontamentos (
    Id INT IDENTITY(1,1) PRIMARY KEY,

    -- Organização
    OrganizacaoDevOpsId NVARCHAR(100) NOT NULL,             -- ex: sefaz-ce-demo

    -- Projeto
    ProjetoDevOpsId NVARCHAR(100) NOT NULL,                 -- ex: GUID
    ProjetoDevOpsNome NVARCHAR(200) NOT NULL,               -- ex: Desenvolvimento

    -- Work Item
    WorkItemId INT NOT NULL,                                -- ex: 33
    WorkItemTipo NVARCHAR(100) NOT NULL,                    -- ex: Task
    WorkItemTitulo NVARCHAR(300) NOT NULL,                  -- ex: Revisar Código
    WorkItemParentId INT NULL,                              -- ex: 32
    WorkItemParentTitulo NVARCHAR(300) NULL,                -- ex: HU modelo
    RemainingWork DECIMAL(5,2) NULL,
    OriginalEstimate DECIMAL(5,2) NULL,
    CompletedWork DECIMAL(5,2) NULL,

    -- Usuário do DevOps
    DevOpsUserDescriptor NVARCHAR(300) NOT NULL,            -- ex: pedro@sefaz
    DevOpsUserDisplayName NVARCHAR(200) NOT NULL,           -- ex: Pedro Teixeira

    -- Apontamento
    AtividadeId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Atividades(Id),
    DataApontamento DATE NOT NULL,
    DuracaoMinutos INT NOT NULL
        CHECK (DuracaoMinutos BETWEEN 0 AND 420),
    Comentario NVARCHAR(500) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'PENDENTE'
        CHECK (Status IN ('PENDENTE', 'APROVADO', 'REJEITADO')),

    -- Auditoria
    CriadoEm DATETIME DEFAULT GETDATE(),
    CriadoPor NVARCHAR(100) NULL,
    AlteradoEm DATETIME NULL,
    AlteradoPor NVARCHAR(100) NULL
);
GO

-- Constraint para data
ALTER TABLE dbo.Apontamentos
  ADD CONSTRAINT CK_Apontamentos_DataApontamento
    CHECK (DataApontamento <= CAST(GETDATE() AS DATE));
GO

-- Trigger para impedir apontamento futuro
CREATE TRIGGER TRG_BloqueiaApontamentoFuturo
ON dbo.Apontamentos
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted WHERE DataApontamento > CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR('Não é permitido apontamento para data futura.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ==========================================
-- TABELA APROVAÇÕES
-- ==========================================
CREATE TABLE dbo.AprovacoesApontamentos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ApontamentoId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Apontamentos(Id),
    AprovadorDevOpsUserId NVARCHAR(300) NOT NULL,
    Status NVARCHAR(50) NOT NULL
        CHECK (Status IN ('PENDENTE','APROVADO','REJEITADO')),
    DataAprovacao DATETIME NULL,
    Comentario NVARCHAR(500) NULL
);
GO

-- ==========================================
-- TABELA LOG (AUDITORIA)
-- ==========================================
CREATE TABLE dbo.LogApontamentos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ApontamentoId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Apontamentos(Id),
    Operacao NVARCHAR(50) NOT NULL,
    DataOperacao DATETIME DEFAULT GETDATE(),
    UsuarioOperacao NVARCHAR(300) NULL,
    ConteudoAnterior NVARCHAR(MAX) NULL,
    ConteudoNovo NVARCHAR(MAX) NULL
);
GO

-- ==========================================
-- ÍNDICES
-- ==========================================
CREATE INDEX IDX_Apontamentos_OrgProjData
    ON dbo.Apontamentos (OrganizacaoDevOpsId, ProjetoDevOpsId, DataApontamento);

CREATE INDEX IDX_Apontamentos_WorkItem
    ON dbo.Apontamentos (WorkItemId);

CREATE INDEX IDX_Apontamentos_ProjetoUsuario
    ON dbo.Apontamentos (ProjetoDevOpsId, DevOpsUserDescriptor, DataApontamento);

CREATE INDEX IDX_Apontamentos_Status
    ON dbo.Apontamentos (Status);

CREATE INDEX IDX_Apontamentos_Atividade
    ON dbo.Apontamentos (AtividadeId);
GO

-- ==========================================
-- VIEW PARA RELATÓRIOS
-- ==========================================
CREATE VIEW dbo.vw_Apontamentos_HHMM AS
SELECT
    a.Id,
    a.OrganizacaoDevOpsId,
    a.ProjetoDevOpsId,
    a.ProjetoDevOpsNome,
    a.WorkItemId,
    a.WorkItemTitulo,
    a.WorkItemTipo,
    a.WorkItemParentId,
    a.WorkItemParentTitulo,
    a.RemainingWork,
    a.OriginalEstimate,
    a.CompletedWork,
    a.DevOpsUserDescriptor,
    a.DevOpsUserDisplayName,
    act.Nome AS Atividade,
    a.DataApontamento,
    FORMAT(a.DuracaoMinutos / 60, '00') + ':' + FORMAT(a.DuracaoMinutos % 60, '00') AS DuracaoHHMM,
    a.Status,
    a.Comentario,
    a.CriadoEm,
    a.AlteradoEm
FROM dbo.Apontamentos a
JOIN dbo.Atividades act ON act.Id = a.AtividadeId;
GO

CREATE OR ALTER VIEW dbo.vw_AtividadesAtivas AS
SELECT
    Id,
    Nome
FROM dbo.Atividades
WHERE Ativo = 1;
GO