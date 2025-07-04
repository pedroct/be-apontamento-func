const pool = require("../shared/db");

module.exports = async function (context, req) {
  try {
    const query = `
      SELECT "Id", "Nome"
      FROM public."vw_AtividadesAtivas"
      ORDER BY "Nome"
    `;

    const result = await pool.query(query);

    context.res = {
      status: 200,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: result.rows,
    };
  } catch (err) {
    context.log.error("Erro ao buscar atividades:", err);
    context.res = {
      status: 500,
      body: "Erro ao buscar atividades: " + err.message,
    };
  }
};
