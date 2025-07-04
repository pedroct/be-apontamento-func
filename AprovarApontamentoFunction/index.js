const pool = require("../shared/db");

module.exports = async function (context, req) {
  const apontamentoId = req.body.apontamentoId;
  const aprovadorId =
    req.body.aprovadorId ||
    req.headers["x-ms-client-principal-name"] ||
    "anonimo";
  const comentario = req.body.comentario || "";

  if (!apontamentoId || !aprovadorId) {
    context.res = {
      status: 400,
      body: "apontamentoId e aprovadorId são obrigatórios",
    };
    return;
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const result = await client.query(
      `SELECT "Status" FROM public."Apontamentos" WHERE "Id" = $1`,
      [apontamentoId]
    );

    if (result.rows.length === 0) {
      throw new Error("Apontamento não encontrado");
    }

    if (result.rows[0].Status !== "PENDENTE") {
      throw new Error("Apontamento já processado");
    }

    await client.query(
      `INSERT INTO public."AprovacoesApontamentos"
        ("ApontamentoId", "AprovadorDevOpsUserId", "Status", "DataAprovacao", "Comentario")
       VALUES ($1, $2, 'APROVADO', NOW(), $3)`,
      [apontamentoId, aprovadorId, comentario]
    );

    await client.query(
      `UPDATE public."Apontamentos"
       SET "Status" = 'APROVADO', "AlteradoEm" = NOW(), "AlteradoPor" = $1
       WHERE "Id" = $2`,
      [aprovadorId, apontamentoId]
    );

    await client.query(
      `INSERT INTO public."LogApontamentos"
       ("ApontamentoId", "Operacao", "UsuarioOperacao", "DataOperacao")
       VALUES ($1, 'APROVACAO', $2, NOW())`,
      [apontamentoId, aprovadorId]
    );

    await client.query("COMMIT");

    context.res = {
      status: 200,
      body: { success: true, message: "Apontamento aprovado com sucesso." },
    };
  } catch (err) {
    await client.query("ROLLBACK");
    context.log.error("Erro ao aprovar apontamento:", err.message);
    context.res = {
      status: 500,
      body: "Erro ao aprovar apontamento: " + err.message,
    };
  } finally {
    client.release();
  }
};
