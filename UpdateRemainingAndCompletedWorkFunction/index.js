const fetch = require("node-fetch");

module.exports = async function (context, req) {
  const { organization, project, workItemId, newRemaining, newCompleted } =
    req.body || {};

  if (
    !organization ||
    !project ||
    !workItemId ||
    newRemaining === undefined ||
    newCompleted === undefined
  ) {
    context.res = {
      status: 400,
      body: "Parâmetros obrigatórios faltando.",
    };
    return;
  }

  const pat = process.env.AZURE_DEVOPS_PAT;
  const url = `https://dev.azure.com/${organization}/${project}/_apis/wit/workitems/${workItemId}?api-version=7.0`;

  const updatePayload = [
    {
      op: "add",
      path: "/fields/Microsoft.VSTS.Scheduling.RemainingWork",
      value: newRemaining,
    },
    {
      op: "add",
      path: "/fields/Microsoft.VSTS.Scheduling.CompletedWork",
      value: newCompleted,
    },
  ];

  const authHeader = Buffer.from(":" + pat).toString("base64");

  try {
    const response = await fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json-patch+json",
        Authorization: `Basic ${authHeader}`,
      },
      body: JSON.stringify(updatePayload),
    });

    if (!response.ok) {
      const erro = await response.text();
      context.res = {
        status: response.status,
        body: `Erro ao atualizar DevOps: ${erro}`,
      };
      return;
    }

    context.res = {
      status: 200,
      body: `Work item ${workItemId} atualizado com sucesso.`,
    };
  } catch (e) {
    context.res = {
      status: 500,
      body: `Erro ao enviar requisição ao Azure DevOps: ${e}`,
    };
  }
};
