require("dotenv").config();
const httpMocks = require("node-mocks-http");
const functionHandler = require("../AprovarApontamentoFunction/index");

describe("AprovarApontamentoFunction", () => {
  it("deve retornar erro 400 se apontamentoId ou aprovadorId faltarem", async () => {
    const req = httpMocks.createRequest({
      method: "POST",
      body: {},
    });
    const context = { res: null };

    await functionHandler(context, req);

    expect(context.res.status).toBe(400);
    expect(context.res.body).toContain("obrigatórios");
  });

  it("deve retornar erro se apontamento não existir", async () => {
    const req = httpMocks.createRequest({
      method: "POST",
      body: { apontamentoId: 9999, aprovadorId: "gestor@azure" },
    });
    const context = { res: null, log: console };

    await functionHandler(context, req);

    expect(context.res.status).toBe(500);
    expect(context.res.body).toMatch(/Apontamento não encontrado/);
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
