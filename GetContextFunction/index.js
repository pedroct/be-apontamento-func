const {
  WebApi,
  getPersonalAccessTokenHandler,
} = require("azure-devops-node-api");
const axios = require("axios");

module.exports = async function (context, req) {
  //context.log("👉 GetContextFunction buscando Parent por System.Parent");

  try {
    const pat = process.env.AZURE_DEVOPS_PAT;

    const orgName = req.query.organization;
    const projectName = req.query.project;
    const workItemParam = req.query.workItemId || req.query.workitem;

    if (!pat || !orgName || !projectName) {
      context.res = {
        status: 400,
        body: "Parâmetros obrigatórios faltando (organization, project, PAT)",
      };
      return;
    }

    const authBasic = Buffer.from(`:${pat}`).toString("base64");

    // buscar dados do projeto
    const webApi = new WebApi(
      `https://dev.azure.com/${orgName}`,
      getPersonalAccessTokenHandler(pat)
    );
    const coreApi = await webApi.getCoreApi();
    const project = await coreApi.getProject(projectName);
    const projectId = project.id;

    // buscar dados do work item
    let workItemId = null;
    let workItemType = null;
    let workItemTitle = null;
    let workItemParentId = null;
    let workItemParentTitle = null;
    let remainingWork = null;
    let originalEstimate = null;
    let completedWork = null;
    let userDescriptor = "me";
    let userDisplayName = "desconhecido";

    if (workItemParam) {
      const fields = [
        "System.Title",
        "System.WorkItemType",
        "System.Parent",
        "System.AssignedTo",
        "Microsoft.VSTS.Scheduling.RemainingWork",
        "Microsoft.VSTS.Scheduling.OriginalEstimate",
        "Microsoft.VSTS.Scheduling.CompletedWork",
      ].join(",");

      const workItemUrl = `https://dev.azure.com/${orgName}/${projectName}/_apis/wit/workitems/${workItemParam}?fields=${fields}&api-version=7.1`;

      const wiResponse = await axios.get(workItemUrl, {
        headers: { Authorization: `Basic ${authBasic}` },
      });

      const workItem = wiResponse.data;

      workItemId = workItem.id.toString();
      workItemType = workItem.fields["System.WorkItemType"] || null;
      workItemTitle = workItem.fields["System.Title"] || null;
      remainingWork =
        workItem.fields["Microsoft.VSTS.Scheduling.RemainingWork"] || null;
      originalEstimate =
        workItem.fields["Microsoft.VSTS.Scheduling.OriginalEstimate"] || null;
      completedWork =
        workItem.fields["Microsoft.VSTS.Scheduling.CompletedWork"] || null;

      // pegar responsável do work item
      const assignedTo = workItem.fields["System.AssignedTo"];
      if (assignedTo) {
        userDisplayName = assignedTo.displayName || "desconhecido";
        userDescriptor = assignedTo.uniqueName || "me";
      }

      // buscar o parent
      if (workItem.fields["System.Parent"]) {
        const parentId = workItem.fields["System.Parent"];
        workItemParentId = parentId;

        const parentUrl = `https://dev.azure.com/${orgName}/_apis/wit/workitems/${parentId}?fields=System.Title&api-version=7.1`;
        const parentResp = await axios.get(parentUrl, {
          headers: { Authorization: `Basic ${authBasic}` },
        });
        workItemParentTitle = parentResp.data.fields["System.Title"] || null;
      }
    }

    const result = {
      organizationId: orgName,
      projectId: projectId,
      projectName: projectName,
      workItemId: workItemId,
      workItemType: workItemType,
      workItemTitle: workItemTitle,
      workItemParentId: workItemParentId,
      workItemParentTitle: workItemParentTitle,
      remainingWork: remainingWork,
      originalEstimate: originalEstimate,
      completedWork: completedWork,
      userDescriptor: userDescriptor,
      userDisplayName: userDisplayName,
    };

    //context.log("resultado final:", JSON.stringify(result));

    context.res = {
      status: 200,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: result,
    };
  } catch (error) {
    context.log.error("Erro na GetContextFunction", error);
    context.res = {
      status: 500,
      body: `Erro ao obter contexto: ${error.message}`,
    };
  }
};
