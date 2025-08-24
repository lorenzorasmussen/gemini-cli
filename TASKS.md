# Project Tasks

This file consolidates tasks, TODOs, and FIXMEs from across the project.

## From `PROJECT_IDEAS.md`

# Potential Gemini CLI Projects and Todos

## File Processor

### Description

A script that watches a specified directory and uses the Gemini CLI to automatically rename or tag files based on their content.

### Details needed

- Directory to watch (e.g., Downloads folder)
- Types of files to process (e.g., all files, specific extensions)
- Criteria for renaming/tagging (e.g., summarize content, extract keywords)

---

## Tasks from Code Comments

### High Priority (FIXME)

- **[packages/cli/src/ui/hooks/useToolScheduler.test.ts:213]** `FIXME(ntaylormullen): The following tests are skipped due to difficulties in`
- **[packages/core/src/core/prompts.ts:355]** `[FIXME] Refactor the remaining files.`
- **[packages/core/src/core/prompts.ts:356]** `[FIXME] Update tests to reflect the API change.`
- **[packages/core/src/ide/ide-client.ts:336]** `FIXME(chrstn): use the CLI version here.`
- **[packages/core/src/tools/edit.ts:274]** `FIXME(chrstn): See https://github.com/google-gemini/gemini-cli/pull/5618#discussion_r2255413084`
- **[packages/core/src/tools/mcp-client.ts:691]** `FIXME: remove this hack once GenAI SDK does callTool with request options`
- **[packages/core/src/tools/read-many-files.ts:97]** `FIXME(adh): Consider making this configurable or extendable through a command line argument.`
- **[packages/core/src/tools/read-many-files.ts:98]** `FIXME(adh): Look into sharing this list with the glob tool.`
- **[packages/core/src/utils/bfsFileSearch.ts:12]** `FIXME: Integrate with a more robust server-side logger.`
- **[packages/core/src/utils/memoryDiscovery.ts:24]** `FIXME: Integrate with a more robust server-side logger if available/appropriate.`
- **[packages/vscode-ide-companion/src/ide-server.ts:240]** `FIXME(chrstn): determine if this should be required or not.`

### General (TODO)

#### User Requested
- Connect to mcpTotal and update your progress there too

#### From Code
- **[.refact/history.md:4827]** `update todos in tasks`
- **[packages/cli/src/config/config.integration.test.ts:21]** `TODO(richieforeman): Consider moving this to test setup globally.`
- **[packages/cli/src/config/config.ts:263]** `TODO: Consider if App.tsx should get memory via a server call or if Config should refresh itself.`
- **[packages/cli/src/config/config.ts:332]** `TODO(b/343434939): This is a bit of a hack. The contextFileName should ideally be passed`
- **[packages/cli/src/ui/App.tsx:917]** `TODO(taehykim): It seems like references to ids aren't necessary in`
- **[packages/cli/src/ui/commands/initCommand.ts:78]** `provide a placeholder with a TODO.`
- **[packages/cli/src/ui/commands/types.ts:29]** `TODO(abhipatel12): Ensure that config is never null.`
- **[packages/cli/src/ui/commands/types.ts:182]** `TODO: Remove args. CommandContext now contains the complete invocation.`
- **[packages/cli/src/ui/hooks/slashCommandProcessor.ts:257]** `TODO: For better performance and architectural clarity, this two-pass`
- **[packages/cli/src/ui/hooks/useFolderTrust.ts:14]** `TODO: Update to avoid showing dialog for folders that are trusted.`
- **[packages/cli/src/ui/hooks/useFolderTrust.ts:20]** `TODO: Store folderPath in the trusted folders config file based on the choice.`
- **[packages/cli/src/ui/hooks/useGitBranchName.test.ts:132]** `skip(); // TODO: fix`
- **[packages/cli/src/ui/hooks/useGitBranchName.test.ts:213]** `skip(); // TODO: fix`
- **[packages/cli/src/utils/package.ts:32]** `TODO: Maybe bubble this up as an error.`
- **[packages/core/src/core/subagent.ts:120]** `TODO: In the future, this needs to support 'auto' or some other string to support routing use cases.`
- **[packages/core/src/core/subagent.ts:138]** `TODO: Consider adding max_tokens as a form of budgeting.`
- **[packages/core/src/telemetry/clearcut-logger/clearcut-logger.test.ts:32]** `TODO(richieforeman): Consider moving this to test setup globally.`