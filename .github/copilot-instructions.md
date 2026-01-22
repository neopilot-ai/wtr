# Copilot Instructions - Architecture & Flow

This document provides context for GitHub Copilot regarding the architecture and execution flow of the `wtr` tool.

## Core Architecture
- **Language**: Pure Bash (targeting 4.0+).
- **Entry Point**: `bin/wtr` is the main executable script.
- **Library System**: `bin/wtr` sources modular logic from the `lib/` directory.
  - `lib/log.sh`: ANSI-colored logging (success, info, warn, error, step).
  - `lib/config.sh`: Wrappers for `git config` and file-based `.wtrconfig`.
  - `lib/core.sh`: High-level Git worktree operations.
  - `lib/copy.sh`: Smart file copying with glob pattern support.
  - `lib/hooks.sh`: Lifecycle hook runner.
  - `lib/ui.sh`: User interaction helpers (prompts, selections).

## Command Dispatcher
The `main()` function in `bin/wtr` uses a `case` statement to dispatch commands to their respective `cmd_` functions (e.g., `create` -> `cmd_create`).

## Execution Flow (Example: `create` command)
1. **Flag Parsing**: Iterates through arguments to set configuration variables.
2. **Context Discovery**: Calls `discover_repo_root` to find the main Git repository.
3. **Preset Loading**: Applies defaults from `wtr.preset.<name>`.
4. **Pre-Create Hook**: Executes `preCreate` scripts from `.wtr/hooks/`.
5. **Worktree Creation**: Calls `git worktree add` with appropriate branch and path logic.
6. **Smart Copying**: Copies specific files/directories from the main repo to the worktree based on `.worktreeinclude` or config.
7. **Post-Create Hook**: Executes `postCreate` scripts within the newly created worktree.
8. **Tool Integration**: Optionally launches configured editors or AI adapters.

## Patterns & Guidelines
- **Logging**: Always route logs to `stderr` using `log_*` functions to keep `stdout` clean for command substitution.
- **Cross-Platform**: Use `lib/platform.sh` helpers to ensure compatibility across macOS, Linux, and WSL.
- **Error Handling**: Use `set -e` in the main script and return non-zero exit codes from library functions on failure.
- **Config Precedence**: CLI Flags > Local Config (`.git/config`) > Project Config (`.wtrconfig`) > Global Config.
