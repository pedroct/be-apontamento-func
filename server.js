const express = require("express");
const funcAtividades = require("./GetAtividadesFunction/index");
const funcInsert = require("./InsertApontamentoFunction/index");
const funcGetApontamentos = require("./GetApontamentosFunction/index");

const app = express();
app.use(express.json());

app.get("/api/GetAtividadesFunction", async (req, res) => {
  const context = { res: {}, log: console };
  await funcAtividades(context, { query: req.query });
  if (!context.res.headers) context.res.headers = {};
  if (!context.res.headers["Content-Type"]) {
    context.res.headers["Content-Type"] = "application/json";
  }
  res
    .status(context.res.status || 200)
    .set(context.res.headers)
    .send(context.res.body);
});

app.post("/api/InsertApontamentoFunction", async (req, res) => {
  const context = { res: {}, log: console };
  await funcInsert(context, { body: req.body });
  if (!context.res.headers) context.res.headers = {};
  if (!context.res.headers["Content-Type"]) {
    context.res.headers["Content-Type"] = "application/json";
  }
  res
    .status(context.res.status || 200)
    .set(context.res.headers)
    .send(context.res.body);
});

app.get("/api/GetApontamentosFunction", async (req, res) => {
  const context = { res: {}, log: console };
  await funcGetApontamentos(context, { query: req.query });
  if (!context.res.headers) context.res.headers = {};
  if (!context.res.headers["Content-Type"]) {
    context.res.headers["Content-Type"] = "application/json";
  }
  res
    .status(context.res.status || 200)
    .set(context.res.headers)
    .send(context.res.body);
});

module.exports = { app };
