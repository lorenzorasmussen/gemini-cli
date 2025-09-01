# Workflow Automation Extension for Gemini CLI

**Date:** September 1, 2025

## Overview

This extension provides a collection of multi-step workflows and utility commands for the Gemini CLI, designed to automate various tasks related to AI architecture, security, development, and system management. It leverages the Gemini CLI's custom slash command capabilities, shell command execution, and Model Context Protocol (MCP) server integration.

## Implemented Patterns

This extension demonstrates the following patterns from the "Multi-Step Workflows with Chained Gemini CLI Custom Slash Commands" document:

*   **Extension-Based Workflow Orchestration:** The core structure of this extension itself.
*   **General Workflow Commands:** `/init`, `/analyze`, `/deploy:prepare`, `/deploy:execute`, `/deploy:verify`, `/cleanup`.
*   **Nix Integration:**
    *   `/nix:dev-setup`: Complete Nix development environment setup.
    *   `/nix:multi-deploy`: Multi-machine NixOS deployment workflow.
    *   `/nix:macos-manage`: Nix package and environment management for macOS.
*   **GitHub Actions Integration:** Demonstrated by `.github/workflows/gemini-multi-step.yml`.
*   **Intelligent Workflow Orchestration:** `/router:workflow-dispatch` for dynamic command routing.
*   **Development Lifecycle Automation:** `/devops:full-lifecycle` for end-to-end DevOps chain.
*   **Cross-Tool Integration:** `commands/integrations/hybrid-ai-workflow.sh` for orchestrating with external AI agents (e.g., Claude Code).
*   **Automated File Organization:** `/files:smart-organize` for comprehensive file management.
*   **State-Aware Command Chaining:** `/analysis:prepare-context` and `/analysis:deep-dive` for staged analysis.
*   **Security Workflow Verification:** `/security:verify-workflow` for checking security best practices in TOML files.
*   **MCP-Orchestrated Workflows:** Implemented with `mcp-servers/workflow-state-server.js`.

## Usage

To use this extension:

1.  **Ensure Gemini CLI is running.**
2.  **Restart your Gemini CLI** after placing this extension in the correct directory (`~/.gemini/extensions/workflow-automation/`).
3.  **Access commands:** Once restarted, the following slash commands will be available:
    *   `/init`
    *   `/analyze`
    *   `/deploy:prepare`
    *   `/deploy:execute`
    *   `/deploy:verify`
    *   `/cleanup`
    *   `/nix:dev-setup`
    *   `/nix:multi-deploy`
    *   `/nix:macos-manage`
    *   `/router:workflow-dispatch`
    *   `/devops:full-lifecycle`
    *   `/files:smart-organize`
    *   `/security:verify-workflow`

    You can also run the `commands/integrations/hybrid-ai-workflow.sh` and `commands/integrations/workflow_chain.sh` scripts directly.

## Dependencies for MCP-Orchestrated Workflows

The `workflow-state-server.js` (for MCP-Orchestrated Workflows) requires Node.js and its dependencies. Navigate to `mcp-servers/` and run `npm install` to install required packages (`@modelcontextprotocol/server`, `@modelcontextprotocol/types`).
