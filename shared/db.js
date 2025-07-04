require("dotenv").config();
console.log("ambiente de teste", process.env.DB_PASSWORD);
const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,
  ssl: false,
});

module.exports = pool;
