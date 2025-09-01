// workflow-state-server.js
// A basic Node.js MCP server for workflow state management.

const { Server } = require('@modelcontextprotocol/server');
const { TextContent, Tool } = require('@modelcontextprotocol/types');

const SERVER_NAME = "workflow-state";
const SERVER_VERSION = "1.0.0";

const server = new Server(SERVER_NAME);

// In a real implementation, you would manage state here.
// For simplicity, we'll just expose a basic tool.

@server.listTools()
async function listTools() {
  return [
    new Tool({
      name: "get_workflow_status",
      description: "Retrieves the current status of a workflow.",
      inputSchema: {
        type: "object",
        properties: {
          workflow_id: { type: "string", description: "ID of the workflow" }
        },
        required: ["workflow_id"]
      }
    }),
    new Tool({
      name: "update_workflow_status",
      description: "Updates the status of a workflow.",
      inputSchema: {
        type: "object",
        properties: {
          workflow_id: { type: "string", description: "ID of the workflow" },
          status: { type: "string", description: "New status of the workflow" }
        },
        required: ["workflow_id", "status"]
      }
    })
  ];
}

@server.callTool()
async function callTool(name, args) {
  switch (name) {
    case "get_workflow_status":
      // In a real scenario, fetch status from a database or state store.
      return [new TextContent({ text: `Workflow ${args.workflow_id} status: In Progress (mock)` })];
    case "update_workflow_status":
      // In a real scenario, update status in a database or state store.
      return [new TextContent({ text: `Workflow ${args.workflow_id} status updated to: ${args.status} (mock)` })];
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

async function main() {
  console.log(`Starting ${SERVER_NAME} MCP server v${SERVER_VERSION}...`);
  await server.run();
  console.log(`${SERVER_NAME} MCP server stopped.`);
}

main();
