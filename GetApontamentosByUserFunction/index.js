const pool = require("../shared/db");

module.exports = async function (context, req) {
  const devOpsUserDescriptor = req.query.devOpsUserDescriptor;

  // filtros opcionais
  const dataInicial = req.query.dataInicial;
  const dataFinal = req.query.dataFinal;
  const status = req.query.status;
  const workItemId = req.query.workItemId;

  let sql = `
    SELECT
      id,
      usuario,
      data AS "dataApontamento",
      "duracaoMinutos",
      atividade,
      comentario,
      status,
      "workItemId",
      "workitemtitulo",
      "originalEstimate",
      "remainingWork"
    FROM public."vw_Apontamentos_Usuario"
    WHERE 1=1
  `;

  const params = [];
  let paramIndex = 1;

  if (devOpsUserDescriptor) {
    sql += ` AND "devOpsUserDescriptor" = $${paramIndex}`;
    params.push(devOpsUserDescriptor);
    paramIndex++;
  }

  if (dataInicial) {
    sql += ` AND data >= $${paramIndex}`;
    params.push(dataInicial);
    paramIndex++;
  }

  if (dataFinal) {
    sql += ` AND data <= $${paramIndex}`;
    params.push(dataFinal);
    paramIndex++;
  }

  if (status && status !== "TODOS") {
    sql += ` AND status = $${paramIndex}`;
    params.push(status);
    paramIndex++;
  }

  if (workItemId) {
    sql += ` AND "workItemId" = $${paramIndex}`;
    params.push(workItemId);
    paramIndex++;
  }

  sql += ` ORDER BY data DESC`;

  console.log("🔎 SQL construído:", sql);
  console.log("🔎 Parâmetros:", params);

  try {
    const result = await pool.query(sql, params);
    console.log(`🔎 Query executada, retornou ${result.rowCount} linhas`);

    context.res = {
      status: 200,
      body: result.rows,
    };
  } catch (e) {
    console.error("🔥 Erro ao executar query:", e);
    context.res = {
      status: 500,
      body: `Erro ao consultar apontamentos: ${e.message}`,
    };
  }
};
