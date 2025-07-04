const axios = require("axios");

module.exports = async function (context, req) {
  const descriptor = req.query.descriptor;

  if (!descriptor) {
    context.res = {
      status: 400,
      body: "Parâmetro 'descriptor' é obrigatório.",
    };
    return;
  }

  const organization = process.env.AZDO_ORG;
  const pat = process.env.AZDO_PAT;

  try {
    const url = `https://vssps.dev.azure.com/${organization}/_apis/graph/users/${descriptor}?api-version=7.1-preview.1`;
    const response = await axios.get(url, {
      auth: {
        username: "",
        password: pat,
      },
    });

    context.res = {
      status: 200,
      body: response.data,
    };
  } catch (err) {
    context.log.error("Erro ao consultar Graph API:", err.message);
    context.res = {
      status: 500,
      body: "Erro ao buscar dados do usuário.",
    };
  }
};
