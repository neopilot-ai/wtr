# Architecture & Execution Flow

## System Design
- **Single Binary**: The primary interface is `bin/wtr`.
- **Modular Library**: Logic is decoupled into `lib/*.sh` for maintainability.
- **Stateless core**: The tool relies on Git's internal worktree state and standard configurations.

## Critical Paths
- **Target Resolution**: `resolve_target` in `lib/core/worktree.sh` is central to mapping IDs/branches to absolute paths.
- **Copy Logic**: `lib/copy.sh` uses `bash` recursion-like globbing (`globstar`) to synchronize workspace state.
- **Hook Lifecycle**:
  - `preCreate`: Before worktree exists.
  - `postCreate`: Inside new worktree.
  - `preRemove`: Before deletion.
  - `postRemove`: After deletion.

## Data Flow
1. User Command
2. `bin/wtr` sources libraries.
3. `main()` dispatches to `cmd_<subcommand>`.
4. Library functions leverage `git` CLI for state mutation.
5. `ui.sh` and `log.sh` provide feedback to `stderr`.
