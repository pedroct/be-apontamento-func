module.exports = async () => {
  console.log(">>> Fechando pool do teardown global");
  const pool = require("../shared/db");
  await pool.end();
};
