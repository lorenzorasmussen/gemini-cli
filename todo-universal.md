# Gemini CLI - Universal To-Do List

This document outlines outstanding tasks and potential improvements for the Gemini CLI, identified during troubleshooting and development.

## 1. Startup Performance & Server Issues

**Status:** Partially Addressed

**Details:**
Initial long startup times and "Connection closed" errors were observed for several MCP servers.

**Actions Taken:**
- `auto_start` for `filesystem`, `memory`, `time`, and `git` servers in `settings.json` has been set to `false` due to missing `package.json` and `npm` workspace setup. This should significantly reduce startup time.
- `security_scanner` server configuration in `settings.json` has been updated to use Nix (`nix run github:modelcontextprotocol/servers#python -- python3 .gemini/scripts/lorenzo-security-server.py`) to resolve `ModuleNotFoundError: No module named 'mcp'`.

**Remaining Tasks:**
- **Verify Startup:** User needs to launch the Gemini CLI to confirm improved startup time and observe any new error messages.
- **Security Scanner Fix (Nix):** The Nix command for `security_scanner` is currently failing with `error: path '«github:modelcontextprotocol/servers/...»/flake.nix' does not exist`. This indicates an issue with the user's Nix setup or the `modelcontextprotocol/servers` Nix flake itself.
    - **Action:** Investigate and resolve the Nix environment issue to enable the `security_scanner` to start successfully. This may involve:
        - Ensuring Nix is correctly installed and configured.
        - Checking the `modelcontextprotocol/servers` GitHub repository for changes or specific instructions on using its Nix flake.
        - Debugging the Nix environment.
- **Re-enable NPM Servers (Optional):** If `filesystem`, `memory`, `time`, and `git` servers are desired, the user needs to:
    - **Action:** Provide a correct `package.json` file in the project root (`/Users/lorenzorasmussen/.gemini/`) that defines the `npm` workspaces for these servers.
    - **Action:** Run `npm install` in the project root.
    - **Action:** Set `auto_start` back to `true` for these servers in `settings.json` once the `npm` setup is complete.

---

## 2. Nix Flake Issue Investigation and Fix Instructions

**Problem:** The `security_scanner` server is failing to start with the error `error: path '«github:modelcontextprotocol/servers/...»/flake.nix' does not exist`. This indicates that Nix cannot find the `flake.nix` file at the expected location for the `github:modelcontextprotocol/servers` project.

**What to Investigate:**

The core issue is that the Nix flake reference `github:modelcontextprotocol/servers#python` in your `settings.json` is not correctly pointing to a valid Nix flake. This could be because:

*   **`flake.nix` is not at the repository root:** Our investigation confirmed that `flake.nix` is not present at the root of the `main` branch of the `modelcontextprotocol/servers` GitHub repository.
*   **The flake is in a subdirectory:** The `flake.nix` might be located in a subdirectory within the `modelcontextprotocol/servers` repository (e.g., `modelcontextprotocol/servers/nix/flake.nix`).
*   **Different branch:** The `flake.nix` might exist on a different branch (e.g., `master` instead of `main`, or a specific `nix` branch).
*   **Outdated reference:** The reference in your `settings.json` might be outdated, and the project's Nix structure has changed.
*   **Incorrect flake output:** The `#python` part of the reference might be incorrect or refer to an output that no longer exists or is not what you intend.

**How to Investigate and Find the Correct Reference:**

1.  **Manually browse the `modelcontextprotocol/servers` GitHub repository:**
    *   Go to `https://github.com/modelcontextprotocol/servers` in your web browser.
    *   Look for a `flake.nix` file. If it's not at the root, check common Nix flake locations like `nix/flake.nix`, `flake/flake.nix`, or similar subdirectories.
    *   Check different branches (e.g., `master`, `dev`, `nix`) if `main` doesn't have it.
    *   Look for any `README.md` or `docs/` within the repository that might explain its Nix usage or provide correct flake references.

2.  **Search for Nix flake examples/documentation for the project:**
    *   Use a search engine (like Google) with queries such as:
        *   `modelcontextprotocol/servers nix flake example`
        *   `modelcontextprotocol/servers nix setup`
        *   `modelcontextprotocol/servers python nix`
    *   Look for official documentation, blog posts, or community discussions that show how to correctly use this project with Nix.

3.  **Inspect the `flake.nix` content (once found):**
    *   Once you locate the `flake.nix` file, examine its contents. It will define the outputs (e.g., `packages`, `apps`, `nixosModules`, `homeManagerModules`).
    *   Confirm that there is a `python` output that corresponds to what you expect (e.g., an application or package that provides the `mcp` module).

**What to Do to Fix:**

Once you have identified the correct Nix flake reference (e.g., `github:modelcontextprotocol/servers/path/to/flake#output_name`), you will need to update your `settings.json` file.

1.  **Open your `settings.json` file:**
    *   The file is located at `/Users/lorenzorasmussen/.gemini/settings.json`.

2.  **Locate the `security_scanner` entry:**
    ```json
        "security_scanner": {
          "command": "nix",
          "args": [
            "run",
            "github:modelcontextprotocol/servers#python", // <--- This line needs to be updated
            "--",
            "python3",
            ".gemini/scripts/lorenzo-security-server.py"
          ],
          "timeout": 30000,
          "trust": false,
          "includeTools": [
            "security_scan",
            "vulnerability_check",
            "compliance_audit",
            "ai_refactor"
          ],
          "description": "Lorenzo's Nordic security framework and AI refactoring",
          "auto_start": true,
          "health_check": true
        }
    ```

3.  **Update the Nix flake reference in the `args` array:**
    *   Replace `"github:modelcontextprotocol/servers#python"` with the correct reference you found.
    *   **Example (if flake is in a subdirectory and output name is different):** If you found `flake.nix` at `https://github.com/modelcontextprotocol/servers/tree/main/nix` and the output you need is `mcp-python-server`, the new reference would be `"github:modelcontextprotocol/servers/nix#mcp-python-server"`.

4.  **Save the `settings.json` file.**

5.  **Test the change:**
    *   Restart your Gemini CLI.
    *   Observe if the `security_scanner` starts without the Nix flake error.

---

## 3. Suggested Integrations for Workflows

Here are some ideas for integrating custom slash commands into your workflows, leveraging the Gemini CLI's capabilities. These suggestions are tailored to your role as a Senior AI Architecture & Security Consultant.

### 3.1. Security & System Health Integrations

*   **`/security:scan-project` (TOML Command)**
    *   **Description:** Scans the entire project for security vulnerabilities and sensitive information.
    *   **Implementation Idea:** Create a TOML command that uses `!{grep -r -E 'pattern1|pattern2' .}` for common sensitive patterns. For more advanced scanning, it could integrate with the `security_scanner` MCP server (once its Nix issue is resolved).
    *   **Benefit:** Automates routine security checks, leveraging your security expertise.

*   **`/system:health` (TOML Command)**
    *   **Description:** Provides a quick overview of system resources (CPU, memory, disk) and running processes.
    *   **Implementation Idea:** Create a TOML command using `!{free -h}`, `!{df -h}`, and `!{ps aux --sort=-%cpu | head -10}`.
    *   **Benefit:** Helps diagnose performance issues and ensures the development environment is stable.

*   **`/security:audit-logs` (TOML Command)**
    *   **Description:** Analyzes recent security-related logs for suspicious activity.
    *   **Implementation Idea:** Create a TOML command using `!{tail -n 100 /var/log/auth.log | grep -E 'failed|invalid'}` or similar commands for relevant log files.
    *   **Benefit:** Proactive security monitoring.

### 3.2. Development & Refactoring Workflow Integrations

*   **`/dev:lint` (TOML Command)**
    *   **Description:** Runs project-specific linters (e.g., ESLint, Ruff) on modified files or the entire codebase.
    *   **Implementation Idea:** Create a TOML command using `!{npm run lint}` or `!{ruff check .}`.
    *   **Benefit:** Ensures code quality and adherence to standards.

*   **`/dev:test` (TOML Command)**
    *   **Description:** Executes project unit tests or integration tests.
    *   **Implementation Idea:** Create a TOML command using `!{npm test}` or `!{pytest}`.
    *   **Benefit:** Automates testing, crucial for refactoring and feature development.

*   **`/refactor:suggest` (MCP Server Tool/TOML Command)**
    *   **Description:** Analyzes a given code file or section and suggests refactoring improvements based on best practices or AI patterns.
    *   **Implementation Idea:** This could be a custom MCP server (perhaps extending the `security_scanner` or a new "refactoring" server) that uses AI models to analyze code. A simpler TOML command could just `cat` the file and prompt the LLM.
    *   **Benefit:** Leverages your "Automated Refactoring" specialization.

*   **`/project:todo` (TOML Command)**
    *   **Description:** Displays the contents of `todo-universal.md` and allows for quick additions.
    *   **Implementation Idea:** Create a TOML command using `!{cat ~/.gemini/todo-universal.md}` to display. For adding, it would require a more complex prompt that guides the user to append to the file.
    *   **Benefit:** Integrates the `todo-universal.md` directly into the CLI workflow.

### 3.3. AI Architecture & Strategy Integrations

*   **`/ai:model-info` (MCP Server Tool/TOML Command)**
    *   **Description:** Retrieves and displays information about configured AI models (e.g., capabilities, cost, latency).
    *   **Implementation Idea:** Could be a TOML command that reads `settings.json` and formats the `supported_models` section, or an MCP server that queries live model APIs.
    *   **Benefit:** Supports your "AI Strategy" specialization.

*   **`/ai:deploy` (TOML Command)**
    *   **Description:** Automates the deployment of AI models or services.
    *   **Implementation Idea:** Create a TOML command using `!{gcloud run deploy ...}` or `!{docker push ...}`.
    *   **Benefit:** Streamlines deployment workflows.

---

## 4. Tasks from Script Analysis

Here are potential tasks identified from reviewing the scripts in the `scripts/` directory:

*   **`check-protected-directory.sh`**:
    *   **Task:** Improve path validation logic to be more robust (e.g., using `realpath` or more sophisticated regex).
    *   **Task:** Add a test for this script.
*   **`consolidate-memory.sh`**:
    *   **Task:** Add error handling for `jq` command (e.g., if `.jsonl` files are malformed).
    *   **Task:** Add a test for this script.
*   **`enforce-file-standards.sh`**:
    *   **Task:** Extend to support more file types and linters (e.g., `prettier`, `black`, `ruff`).
    *   **Task:** Add a test for this script.
*   **`eslint-security-enforcer.sh`**:
    *   **Task:** Ensure `eslint_report.json` is properly handled (e.g., parsed and logged, not just deleted).
    *   **Task:** Add a test for this script.
*   **`gradual-memory-decay.sh`**:
    *   **Task:** Add a mechanism to ensure memories are indeed sorted by timestamp before decay, or sort them within the script.
    *   **Task:** Add a test for this script.
*   **`log-security-violations.sh`**:
    *   **Task:** Consider structured logging (JSON) for easier parsing and analysis of security violations.
    *   **Task:** Add a test for this script.
*   **`lorenzo-security-server.py`**:
    *   **Task:** Implement `vulnerabilities` and `compliance` scan types.
    *   **Task:** Implement actual AI refactoring logic (currently a placeholder).
    *   **Task:** Add comprehensive unit tests for the server's tools and logic.
*   **`production-hook-enforcer.sh`**:
    *   **Task:** Improve error handling and reporting if sub-scripts fail.
    *   **Task:** Add a test for this script.
*   **`save_to_mem0.py`**:
    *   **Task:** Integrate with `consolidate-memory.sh` to ensure new entries are included in the main memory bank.
    *   **Task:** Add a test for this script.
*   **`validate-bash-command.sh`**:
    *   **Task:** Improve command validation to handle more complex cases (e.g., arguments, pipes, redirects).
    *   **Task:** Add a test for this script.