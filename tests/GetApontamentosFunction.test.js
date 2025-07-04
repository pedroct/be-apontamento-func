const request = require("supertest");
const { app } = require("../server");
const { getConnection } = require("../shared/db");

describe("GET /api/GetApontamentosFunction", () => {
  it("deve retornar status 200 e lista de apontamentos para um workItemId", async () => {
    // workItemId 33 foi inserido no teste anterior
    const workItemId = 33;

    const res = await request(app)
      .get(`/api/GetApontamentosFunction?workItemId=${workItemId}`)
      .expect("Content-Type", /json/)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);

    if (res.body.length > 0) {
      const apontamento = res.body[0];
      expect(apontamento).toHaveProperty("id");
      expect(apontamento).toHaveProperty("usuario");
      expect(apontamento).toHaveProperty("data");
      expect(apontamento).toHaveProperty("duracaoMinutos");
      expect(apontamento).toHaveProperty("atividade");
      expect(apontamento).toHaveProperty("comentario");
    }
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
