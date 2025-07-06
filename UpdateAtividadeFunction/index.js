const pool = require("../shared/db");

module.exports = async function (context, req) {
  try {
    const { Id, Nome, Descricao, Ativo } = req.body;

    if (!Id || !Nome) {
      context.res = {
        status: 400,
        body: "Campos obrigatórios não informados.",
      };
      return;
    }

    const query = `
      UPDATE public."Atividades"
      SET "Nome" = $1,
          "Descricao" = $2,
          "Ativo" = $3
      WHERE "Id" = $4
    `;

    await pool.query(query, [Nome, Descricao, Ativo, Id]);

    context.res = {
      status: 200,
      body: "Atividade atualizada com sucesso.",
    };
  } catch (err) {
    context.log.error("Erro ao atualizar atividade:", err);
    context.res = {
      status: 500,
      body: "Erro ao atualizar atividade: " + err.message,
    };
  }
};
