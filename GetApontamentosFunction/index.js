const pool = require("../shared/db");

module.exports = async function (context, req) {
  const workItemId = req.query.workItemId;

  if (!workItemId) {
    context.res = {
      status: 400,
      body: "Parâmetro workItemId obrigatório.",
    };
    return;
  }

  try {
    const query = `
      SELECT
        id,
        usuario,
        data,
        "duracaoMinutos",
        atividade,
        comentario
      FROM public."vw_Apontamentos_Detalhes"
      WHERE "workItemId" = $1
      ORDER BY data DESC
    `;

    const result = await pool.query(query, [workItemId]);

    context.res = {
      status: 200,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: result.rows,
    };
  } catch (err) {
    context.log.error("Erro ao consultar apontamentos", err);
    context.res = {
      status: 500,
      body: `Erro ao consultar apontamentos: ${err.message}`,
    };
  }
};
