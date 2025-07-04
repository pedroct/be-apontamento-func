const pool = require("../shared/db");

module.exports = async function (context, req) {
  const { dataInicial, dataFinal, status } = req.query;

  let query = `
    SELECT *
    FROM public."vw_Apontamentos_PainelGestor"
    WHERE 1=1
  `;

  const values = [];
  let paramIndex = 1;

  if (status) {
    query += ` AND status = $${paramIndex++}`;
    values.push(status);
  }
  if (dataInicial) {
    query += ` AND data >= $${paramIndex++}`;
    values.push(dataInicial);
  }
  if (dataFinal) {
    query += ` AND data <= $${paramIndex++}`;
    values.push(dataFinal);
  }

  query += ` ORDER BY data DESC`;

  try {
    const result = await pool.query(query, values);
    context.res = {
      status: 200,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: result.rows,
    };
  } catch (err) {
    context.log.error("Erro ao consultar apontamentos na view", err);
    context.res = {
      status: 500,
      body: `Erro ao consultar apontamentos: ${err.message}`,
    };
  }
};
