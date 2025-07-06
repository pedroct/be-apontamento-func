const pool = require("../shared/db");

module.exports = async function (context, req) {
  try {
    const { Nome, Descricao } = req.body;

    if (!Nome) {
      context.res = {
        status: 400,
        body: "O campo 'Nome' é obrigatório.",
      };
      return;
    }

    const query = `
      INSERT INTO public."Atividades" ("Nome", "Descricao")
      VALUES ($1, $2)
      RETURNING "Id", "Nome", "Descricao", "Ativo", "CriadoEm"
    `;

    const values = [Nome, Descricao || null];

    const result = await pool.query(query, values);

    context.res = {
      status: 201,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: result.rows[0],
    };
  } catch (err) {
    context.log.error("Erro ao inserir atividade:", err);
    context.res = {
      status: 500,
      body: "Erro ao inserir atividade: " + err.message,
    };
  }
};
