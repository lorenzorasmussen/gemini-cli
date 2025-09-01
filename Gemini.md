## Gemini Added Memories
- Next steps for Gemini CLI startup issues: 1. Launch CLI to observe startup time and new error messages. 2. If security_scanner fails, investigate Nix setup or modelcontextprotocol/servers Nix flake. 3. If npm-based servers are desired, provide package.json and run npm install.
- The Nix flake reference 'github:modelcontextprotocol/servers#python' in settings.json is likely incorrect or outdated, as 'flake.nix' is not found at the root of the 'modelcontextprotocol/servers' GitHub repository. The user needs to find the correct Nix flake reference for this project and update settings.json accordingly, and ensure their Nix environment is correctly set up.
- Extensions to the Gemini CLI can be added in two primary ways: 1. By creating brand new Model Context Protocol (MCP) servers in separate repositories, which can then be configured in settings.json. 2. By adding new tools (functionalities) to existing MCP servers by modifying their source code.
- Key learnings from the thread: Successfully created a Gemini CLI extension with various multi-step workflow patterns (general, Nix, GitHub Actions, intelligent routing, DevOps, cross-tool integration, file organization). Implemented intelligent dependency installation for shell scripts. Clarified Gemini.md's role as memory storage vs. todo-universal.md as a context file. Homebrew installation was discussed, highlighting interactivity and tool limitations.
- Notes on Gemini CLI Workflow State Management & Multi-Step Automation:

**State Persistence Strategies:**
- File-based: Simple, single machine, JSON files.
- Redis-backed: Distributed, multi-user, Redis store.
- MCP Integration: Complex agent coordination, MCP server state.
- Checkpoint-based: Long-running, interruptible tasks, snapshot files.

**State Management Guidelines:**
- Atomic Updates: Use `jq` with temp files for safe JSON state updates.
- Backup Strategy: Timestamped backups before state modifications.
- State Validation: Implement schema validation for state integrity.
- Cleanup Policies: Automatic cleanup of old state files/checkpoints.
- Error Recovery: Design for graceful failure and state reconstruction.

**Performance Considerations:**
- State Size Limits: Keep state objects under 1MB for fast I/O.
- Update Frequency: Batch state updates for high-frequency events.
- Concurrent Access: Use file locking for multi-process state access.
- Memory Usage: Monitor state object growth in long-running workflows.

**Implemented Patterns (Examples):**
- File-Based State Management (TOML commands for init/update).
- `inotifywait`-Powered Reactive Workflows (TOML command to set up script).
- Redis-Backed Persistent State (TOML commands for init/update).
- Event-Driven Multi-Step Automation (Bash script combining `inotifywait` and `gemini`).
- Multi-Agent State Coordination (TOML command for routing).
- Checkpointed Workflow Execution (TOML command for creating/restoring checkpoints).
- State-Aware Command Orchestration (TOML command for intelligent routing).
- CI/CD Pipeline State Coordination (TOML command for pipeline state).
- Distributed Workflow State Synchronization (TOML command for multi-machine sync).
- Reactive State-Driven Automation (Bash script for event-triggered workflows).

**References (from the document):**
[1] https://stackoverflow.com/questions/72574918/is-it-possible-to-implement-a-shared-state-management-for-cli-applications-witho
[2] https://stackoverflow.com/questions/13754775/using-inotifywait-in-a-script-to-automate-a-git-commit-when-files-have-been-adde
[3] https://redis.io/blog/langgraph-redis-build-smarter-ai-agents-with-memory-persistence/
[4] https://www.baeldung.com/linux/dnotify-inotify-monitor-directory
[5] https://wafatech.sa/blog/linux/linux-security/exploring-inotify-monitoring-directory-changes-on-linux-servers/
[6] https://langchain-ai.github.io/langgraph/tutorials/workflows/
[7] https://www.linkedin.com/pulse/state-graphs-agent-workflows-dattaraj-rao-d6l3f
[8] https://bytewax.io/blog/real-time-ai-agents-streaming-and-caching
[9] https://blog.dust.tt/agent-memory-building-persistence-into-ai-collaboration/
[10] https://angus.readthedocs.io/en/2019/bash_automation.html
[11] https://www.reddit.com/r/commandline/comments/1epjppl/10_cli_tools_that_made_the_biggest_impact_on/
[12] https://digitensions.home.blog/2020/03/31/using-bash-scripts-avpres/
[13] https://qmacro.org/blog/posts/2021/04/28/unpacking-bash-shell-tips-from-a-github-actions-workflow/
[14] https://www.reddit.com/r/ansible/comments/ij196g/using_ansible_in_automated_workflow/
[15] https://uomresearchit.github.io/shell-programming-course/
[16] https://towardsdatascience.com/a-developers-guide-to-building-scalable-ai-workflows-vs-agents/
[17] https://blog.n8n.io/ai-agentic-workflows/
[18] https://www.reddit.com/login/
[19] https://labex.io/tutorials/linux-how-to-automate-linux-file-workflows-with-scripts-425774
[20] https://gcore.com/learning/bash-scripting-streamline-linux-workflow
[21] https://attuneops.io/bash-automation-guide/
[22] https://labex.io/tutorials/shell-how-to-manage-files-in-bash-scripting-392551
[23] https://www.kdnuggets.com/how-navigate-filesystem-bash
[24] https://outshift.cisco.com/blog/how-agent-oriented-design-patterns-transform-system-development
[25] https://www.checklyhq.com/blog/monitor-complex-user-flows-with-multistep-checks/
[26] https://support.testrail.com/hc/en-us/articles/33017216938900-Best-Practices-Guide-TestRail-CLI
[27] https://docs.mapp.com/docs/multi-step-automation-workflows
[28] https://www.diagrid.io/blog/building-effective-dapr-agents
[29] https://www.infoq.com/articles/ai-agent-cli/
