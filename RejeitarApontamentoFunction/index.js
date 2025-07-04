const pool = require("../shared/db");

module.exports = async function (context, req) {
  const apontamentoId = req.body?.apontamentoId;
  const comentario = req.body?.comentario || "";
  const aprovadorId =
    req.body?.aprovadorId ||
    req.headers["x-ms-client-principal-name"] ||
    "anonimo";

  if (!apontamentoId) {
    context.res = {
      status: 400,
      body: "apontamentoId obrigatório",
    };
    return;
  }

  if (!comentario || comentario.trim() === "") {
    context.res = {
      status: 400,
      body: "comentário obrigatório ao rejeitar.",
    };
    return;
  }

  try {
    await pool.query("BEGIN");

    // insere o registro de ação de rejeição
    await pool.query(
      `INSERT INTO public."AprovacoesApontamentos"
   ("ApontamentoId", "AprovadorDevOpsUserId", "Status", "DataAprovacao", "Comentario")
   VALUES ($1, $2, 'REJEITADO', NOW(), $3)`,
      [apontamentoId, aprovadorId, comentario]
    );

    // atualiza o status do apontamento para REJEITADO
    const result = await pool.query(
      `UPDATE public."Apontamentos"
       SET "Status" = 'REJEITADO',
           "AlteradoEm" = NOW(),
           "AlteradoPor" = $2
       WHERE "Id" = $1
         AND "Status" = 'PENDENTE'
       RETURNING *`,
      [apontamentoId, aprovadorId]
    );

    if (result.rowCount === 0) {
      await pool.query("ROLLBACK");
      context.res = {
        status: 404,
        body: "Apontamento não encontrado ou não está pendente",
      };
      return;
    }

    // registra no log
    await pool.query(
      `INSERT INTO public."LogApontamentos"
   ("ApontamentoId", "Operacao", "DataOperacao", "UsuarioOperacao", "ConteudoAnterior", "ConteudoNovo")
   VALUES ($1, $2, NOW(), $3, $4, $5)`,
      [apontamentoId, "REJEITADO", aprovadorId, null, comentario]
    );

    await pool.query("COMMIT");

    context.res = {
      status: 200,
      body: "Apontamento rejeitado com sucesso",
    };
  } catch (error) {
    await pool.query("ROLLBACK");
    context.log.error("Erro ao rejeitar apontamento", error);
    context.res = {
      status: 500,
      body: `Erro interno: ${error.message}`,
    };
  }
};
