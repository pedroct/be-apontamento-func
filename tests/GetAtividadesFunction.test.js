const request = require("supertest");
const { app } = require("../server");
const { getConnection } = require("../shared/db");

describe("GET /api/GetAtividadesFunction", () => {
  it("deve retornar status 200 e lista de atividades", async () => {
    const res = await request(app)
      .get("/api/GetAtividadesFunction")
      .expect("Content-Type", /json/)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThanOrEqual(0);

    if (res.body.length > 0) {
      expect(res.body[0]).toHaveProperty("Id");
      expect(res.body[0]).toHaveProperty("Nome");
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
