const pool = require("../shared/db");

module.exports = async function (context, req) {
  const apontamento = req.body;

  if (!apontamento) {
    context.res = {
      status: 400,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: "Corpo da requisição vazio ou inválido.",
    };
    return;
  }

  // validações básicas
  if (
    !apontamento.organizacaoDevOpsId ||
    !apontamento.projetoDevOpsId ||
    !apontamento.projetoDevOpsNome ||
    !apontamento.workItemId ||
    !apontamento.workItemTipo ||
    !apontamento.workItemTitulo ||
    !apontamento.devOpsUserDescriptor ||
    !apontamento.devOpsUserDisplayName ||
    !apontamento.atividadeId ||
    !apontamento.dataApontamento ||
    !apontamento.duracaoMinutos
  ) {
    context.res = {
      status: 400,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: "Campos obrigatórios não foram preenchidos.",
    };
    return;
  }

  try {
    const query = `
      INSERT INTO public."Apontamentos" (
        "OrganizacaoDevOpsId",
        "ProjetoDevOpsId",
        "ProjetoDevOpsNome",
        "WorkItemId",
        "WorkItemTipo",
        "WorkItemTitulo",
        "WorkItemParentId",
        "WorkItemParentTitulo",
        "RemainingWork",
        "OriginalEstimate",
        "CompletedWork",
        "DevOpsUserDescriptor",
        "DevOpsUserDisplayName",
        "AtividadeId",
        "DataApontamento",
        "DuracaoMinutos",
        "Comentario",
        "CriadoPor"
      )
      VALUES (
        $1, $2, $3, $4, $5, $6,
        $7, $8, $9, $10, $11, $12,
        $13, $14, $15, $16, $17, $18
      )
      RETURNING "Id" as id
    `;

    const values = [
      apontamento.organizacaoDevOpsId,
      apontamento.projetoDevOpsId,
      apontamento.projetoDevOpsNome,
      apontamento.workItemId,
      apontamento.workItemTipo,
      apontamento.workItemTitulo,
      apontamento.workItemParentId || null,
      apontamento.workItemParentTitulo || null,
      apontamento.remainingWork || null,
      apontamento.originalEstimate || null,
      apontamento.completedWork || null,
      apontamento.devOpsUserDescriptor,
      apontamento.devOpsUserDisplayName,
      apontamento.atividadeId,
      apontamento.dataApontamento,
      apontamento.duracaoMinutos,
      apontamento.comentario || null,
      apontamento.devOpsUserDescriptor,
    ];

    const result = await pool.query(query, values);

    const id = result.rows[0].id;

    context.res = {
      status: 200,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: {
        success: true,
        id,
        message: "Apontamento registrado com sucesso.",
      },
    };
  } catch (err) {
    context.log.error("Erro ao inserir apontamento", err);
    context.res = {
      status: 500,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: "Erro ao salvar apontamento: " + err.message,
    };
  }
};
