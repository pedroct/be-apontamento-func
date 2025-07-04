const request = require("supertest");
const { app } = require("../server");
const { getConnection } = require("../shared/db");

describe("POST /api/InsertApontamentoFunction", () => {
  it("deve registrar um apontamento com sucesso", async () => {
    const apontamentoMock = {
      organizacaoDevOpsId: "sefaz-ce-demo",
      projetoDevOpsId: "a303633a-ba87-4741-8ec5-8b5146c3a88f",
      projetoDevOpsNome: "Desenvolvimento",
      workItemId: 33,
      workItemTipo: "Task",
      workItemTitulo: "Revisar Código",
      workItemParentId: 32,
      workItemParentTitulo: "01.01.01 HU Modelo",
      remainingWork: 5,
      originalEstimate: 10,
      completedWork: 5,
      devOpsUserDescriptor: "pedro.teixeira@sefaz.ce.gov.br",
      devOpsUserDisplayName: "Pedro Teixeira",
      atividadeId: 1, // garanta que exista atividade com Id=1
      dataApontamento: new Date().toISOString().slice(0, 10), // yyyy-mm-dd
      duracaoMinutos: 60,
      comentario: "Teste automático",
    };

    const res = await request(app)
      .post("/api/InsertApontamentoFunction")
      .send(apontamentoMock)
      .expect("Content-Type", /json/)
      .expect(200);

    expect(res.body).toHaveProperty("success", true);
    expect(res.body).toHaveProperty("id");
    expect(typeof res.body.id).toBe("number");
    expect(res.body.message).toMatch(/sucesso/i);
  });

  afterAll(async () => {
    const { Pool } = require("pg");
    const pool = new Pool({
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      host: process.env.DB_SERVER,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT,
    });
    await pool.end();
  });
});
