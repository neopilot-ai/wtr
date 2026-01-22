# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`git wtr` (Git Worktree Runner) is a cross-platform CLI tool written in Bash that simplifies git worktree management. It wraps `git worktree` with quality-of-life features like editor integration, AI tool support, file copying, and hooks. It is installed as a git subcommand, so all commands are invoked as `git wtr <command>`.

## Important: v2.0.0 Command Structure

**As of v2.0.0**, the tool is invoked as `git wtr` (git subcommand) to avoid conflicts with GNU coreutils:

- **Production use**: `git wtr <command>` (git subcommand)
- **Development/testing**: `./bin/wtr <command>` (direct script execution)

**Binary structure**:

- `bin/git-wtr`: Thin wrapper that allows git subcommand invocation (`git wtr`)
- `bin/wtr`: Main script containing all logic (~1100 lines)

When testing changes locally, you use `./bin/wtr` directly. When documenting user-facing features or writing help text, always reference `git wtr`.

## Development Commands

### Testing Changes Locally

Since this is a Bash script project without a traditional build system, test changes by running the script directly:

```bash
# Run wtr from the repo (no installation needed)
./bin/wtr <command>

# Or use the full path
/path/to/wtr/bin/wtr <command>

# Test in a different git repository
cd ~/some-test-repo
/path/to/wtr/bin/wtr new test-branch
```

### Automated and Manual Testing

**This project uses BATS (Bash Automated Testing System) for automated tests.** However, manual verification remains important for cross-platform validation.

1. **Automated Tests**: Run `bats test/*.bats` (requires [BATS](https://github.com/bats-core/bats-core)).
2. **Manual Verification Script**: Run `./test/verify.sh` for a quick end-to-end check.
3. **Manual Testing checklist**: Follow the checklist below for thorough verification.
4. Test on multiple platforms if possible (macOS, Linux, Windows Git Bash).

### Manual Testing Workflow

Test changes using this comprehensive checklist (from CONTRIBUTING.md):

```bash
# Create worktree with simple branch name
./bin/wtr new test-feature
# Expected: Creates folder "test-feature"

# Create worktree with branch containing slashes
./bin/wtr new feature/auth
# Expected: Creates folder "feature-auth" (sanitized)

# Create worktree from remote branch (if exists)
./bin/wtr new existing-remote-branch
# Expected: Checks out remote tracking branch

# Create worktree from local branch (if exists)
./bin/wtr new existing-local-branch
# Expected: Creates worktree from local branch

# Create worktree with new branch
./bin/wtr new brand-new-feature
# Expected: Creates new branch and worktree

# Test --from-current flag
git checkout -b test-from-current-base
./bin/wtr new variant-1 --from-current
# Expected: Creates variant-1 from test-from-current-base (not main)

# Test --force and --name flags together
./bin/wtr new test-feature --force --name backend
# Expected: Creates folder "test-feature-backend" on same branch

# Open in editor (if testing adapters)
./bin/wtr config set wtr.editor.default cursor
./bin/wtr editor test-feature
# Expected: Opens Cursor at worktree path

# Run AI tool (if testing adapters)
./bin/wtr config set wtr.ai.default claude
./bin/wtr ai test-feature
# Expected: Starts Claude Code in worktree directory

# Remove worktree by branch name
./bin/wtr rm test-feature
# Expected: Removes worktree folder

# List worktrees
./bin/wtr list
# Expected: Table format with branches and paths
./bin/wtr list --porcelain
# Expected: Machine-readable tab-separated output

# Test configuration commands
./bin/wtr config set wtr.editor.default cursor
./bin/wtr config get wtr.editor.default
# Expected: Returns "cursor"
./bin/wtr config set wtr.editor.default vscode --global
./bin/wtr config unset wtr.editor.default

# Test shell completions with tab completion
git wtr new <TAB>
git wtr editor <TAB>
# Expected: Shows available branches/worktrees

# Test git wtr go for main repo and worktrees
cd "$(./bin/wtr go 1)"
# Expected: Navigates to repo root
cd "$(./bin/wtr go test-feature)"
# Expected: Navigates to worktree

# Test git wtr run command
./bin/wtr run test-feature npm --version
# Expected: Runs npm --version in worktree directory
./bin/wtr run 1 git status
# Expected: Runs git status in main repo
./bin/wtr run test-feature echo "Hello from worktree"
# Expected: Outputs "Hello from worktree"

# Test copy patterns with include/exclude
git config --add wtr.copy.include "**/.env.example"
git config --add wtr.copy.exclude "**/.env"
./bin/wtr new test-copy
# Expected: Copies .env.example but not .env

# Test .worktreeinclude file
printf '# Test patterns\n**/.env.example\n*.md\n' > .worktreeinclude
echo "TEST=value" > .env.example
./bin/wtr new test-worktreeinclude
# Expected: Copies .env.example and *.md files to worktree
ls "$(./bin/wtr go test-worktreeinclude)/.env.example"
./bin/wtr rm test-worktreeinclude
rm .worktreeinclude .env.example

# Test directory copying with include/exclude patterns
git config --add wtr.copy.includeDirs "node_modules"
git config --add wtr.copy.excludeDirs "node_modules/.cache"
./bin/wtr new test-dir-copy
# Expected: Copies node_modules but excludes node_modules/.cache

# Test wildcard exclude patterns for directories
git config --add wtr.copy.includeDirs ".venv"
git config --add wtr.copy.excludeDirs "*/.cache"  # Exclude .cache at any level
./bin/wtr new test-wildcard
# Expected: Copies .venv and node_modules, excludes all .cache directories

# Test copy command (copy files to existing worktrees)
echo "TEST=value" > .env.example
./bin/wtr new test-copy
./bin/wtr copy test-copy -- ".env.example"
# Expected: Copies .env.example to worktree

./bin/wtr copy test-copy -n -- "*.md"
# Expected: Dry-run shows what would be copied without copying

./bin/wtr copy -a -- ".env.example"
# Expected: Copies to all worktrees

./bin/wtr rm test-copy --force --yes
rm .env.example

# Test post-create and post-remove hooks
git config --add wtr.hook.postCreate "echo 'Created!' > /tmp/wtr-test"
./bin/wtr new test-hooks
# Expected: Creates /tmp/wtr-test file
git config --add wtr.hook.preRemove "echo 'Pre-remove!' > /tmp/wtr-pre-removed"
git config --add wtr.hook.postRemove "echo 'Removed!' > /tmp/wtr-removed"
./bin/wtr rm test-hooks
# Expected: Creates /tmp/wtr-pre-removed and /tmp/wtr-removed files

# Test pre-remove hook failure aborts removal
git config wtr.hook.preRemove "exit 1"
./bin/wtr new test-hook-fail
./bin/wtr rm test-hook-fail
# Expected: Removal aborted due to hook failure
./bin/wtr rm test-hook-fail --force
# Expected: Removal proceeds despite hook failure
```

### Debugging Bash Scripts

When debugging issues:

```bash
# Enable tracing to see each command executed
bash -x ./bin/wtr <command>

# Or add 'set -x' temporarily to specific functions
# In lib/core.sh or other files:
set -x  # Enable tracing
# ... code to debug ...
set +x  # Disable tracing

# Check if functions are defined
declare -f function_name

# Check variable values
echo "Debug: var=$var" >&2
```

### Verifying Installation

```bash
# Verify git is available
git --version

# Check git wtr setup
./bin/wtr doctor

# List available adapters
./bin/wtr adapter
```

## Architecture

### Module Structure

- **`bin/wtr`**: Main executable and command dispatcher. Sources all lib files and routes commands to appropriate handlers.
- **`lib/core.sh`**: Git worktree operations (create, remove, list). Contains core business logic for worktree management.
- **`lib/config.sh`**: Configuration management via `git config` wrapper functions. Supports local/global/system scopes.
- **`lib/platform.sh`**: OS-specific utilities for macOS/Linux/Windows.
- **`lib/ui.sh`**: User interface helpers (logging, prompts, formatting).
- **`lib/copy.sh`**: File copying logic with glob pattern support. Includes `copy_patterns()` for file copying and `copy_directories()` for directory copying.
- **`lib/hooks.sh`**: Hook execution system for post-create/post-remove actions.
- **`adapters/editor/*.sh`**: Editor adapters (must implement `editor_can_open` and `editor_open`).
- **`adapters/ai/*.sh`**: AI tool adapters (must implement `ai_can_start` and `ai_start`).
- **`completions/`**: Shell completions for Bash, Zsh, and Fish.
- **`templates/`**: Example configuration scripts (setup-example.sh, run_services.example.sh) for users to customize.

### Key Design Patterns

**Repository Scoping**: Each git repository manages its own independent worktrees. Commands must be run from within a git repo. Worktree locations are resolved relative to the repository root.

**Branch Name Mapping**: Branch names are sanitized to valid folder names (slashes and special chars → hyphens). For example, `feature/user-auth` becomes folder `feature-user-auth`.

**Special ID '1'**: The main repository is always accessible via ID `1` in commands (e.g., `git wtr go 1`, `git wtr editor 1`).

**Configuration Storage**: Configuration is stored via `git config` (local, global, or system) and can also be stored in a `.wtrconfig` file for team-shared settings. The `.wtrconfig` file uses gitconfig syntax and is parsed natively by git using `git config -f`.

**Adapter Pattern**: Editor and AI tool integrations follow a simple adapter pattern with two required functions per adapter type:

- Editor adapters: `editor_can_open()` (check availability) and `editor_open(path)` (open editor)
- AI adapters: `ai_can_start()` (check availability) and `ai_start(path, args...)` (start tool)
- Return code 0 indicates success/availability; non-zero indicates failure
- See "Adapter Contract" in Important Implementation Details for full specifications

**Generic Adapter Fallback**: In addition to specific adapter files, wtr supports generic adapters via environment variables:

- `WTR_EDITOR_CMD`: Custom editor command (e.g., `WTR_EDITOR_CMD="emacs"`)
- `WTR_AI_CMD`: Custom AI tool command (e.g., `WTR_AI_CMD="copilot"`)

These generic functions (defined early in `bin/wtr`) provide a fallback when no specific adapter file exists. This allows users to configure custom tools without creating adapter files. The generic adapter functions check if the command exists using `command -v` and execute it using `eval` to handle multi-word commands properly (e.g., `code --wait`, `bunx @github/copilot@latest`).

### Command Flow

Understanding how commands are dispatched through the system:

1. **Entry Point** (`main()` in `bin/wtr`): Main dispatcher receives command and routes to appropriate handler via case statement
2. **Command Handlers** (`bin/wtr`): Each `cmd_*` function handles a specific command (e.g., `cmd_create`, `cmd_editor`, `cmd_ai`)
3. **Library Functions** (`lib/*.sh`): Command handlers call reusable functions from library modules
4. **Adapters** (`adapters/*`): Dynamically loaded when needed via `load_editor_adapter` or `load_ai_adapter`

**Example flow for `git wtr new my-feature`:**

```
bin/wtr main()
  → cmd_create()
  → resolve_base_dir() [lib/core.sh]
  → create_worktree() [lib/core.sh]
  → copy_patterns() [lib/copy.sh]
  → run_hooks_in() [lib/hooks.sh]
```

**Example flow for `git wtr editor my-feature`:**

```
bin/wtr main()
  → cmd_editor()
  → resolve_target() [lib/core.sh]
  → load_editor_adapter()
  → editor_open() [adapters/editor/*.sh]
```

**Example flow for `git wtr run my-feature npm test`:**

```
bin/wtr main()
  → cmd_run()
  → resolve_target() [lib/core.sh]
  → (cd "$worktree_path" && eval "$command")
```

## Design Principles

When making changes, follow these core principles (from CONTRIBUTING.md):

1. **Cross-platform first** - Code must work on macOS, Linux, and Windows Git Bash
2. **No external dependencies** - Only require git and basic POSIX shell utilities
3. **Configuration over flags** - Users set defaults once, then use simple commands
4. **Fail safely** - Validate inputs, check return codes, provide clear error messages
5. **Stay modular** - Keep functions small, focused, and reusable
6. **User-friendly** - Prioritize good UX with clear output and helpful error messages

## Common Development Tasks

### Updating the Version Number

When releasing a new version, update the version constant in `bin/wtr`:

```bash
# bin/wtr line 8
WTR_VERSION="2.0.0"  # Update this
```

The version is displayed with `git wtr version` and `git wtr --version`.

### Adding a New Editor Adapter

Create `adapters/editor/<name>.sh` with these two functions:

```bash
#!/usr/bin/env bash
# EditorName adapter

editor_can_open() {
  command -v editor-cli >/dev/null 2>&1
}

editor_open() {
  local path="$1"

  if ! editor_can_open; then
    log_error "EditorName not found. Install from https://..."
    return 1
  fi

  editor-cli "$path"
}
```

Also update:

- README.md with installation/setup instructions
- Completions in `completions/` to include the new editor name (all three: bash, zsh, fish)
- The help text in `bin/wtr` - search for "Available editors:" in the `cmd_help` function and `load_editor_adapter` function

### Adding a New AI Tool Adapter

Create `adapters/ai/<name>.sh` with these two functions:

```bash
#!/usr/bin/env bash
# ToolName AI adapter

ai_can_start() {
  command -v tool-cli >/dev/null 2>&1
}

ai_start() {
  local path="$1"
  shift

  if ! ai_can_start; then
    log_error "ToolName not found. Install with: ..."
    return 1
  fi

  (cd "$path" && tool-cli "$@")
}
```

Also update:

- README.md with installation instructions and use cases
- Completions to include the new AI tool name (all three: bash, zsh, fish)
- The help text in `bin/wtr` - search for "Available AI tools:" in the `cmd_help` function and `load_ai_adapter` function

### Modifying Core Functionality

When changing `lib/*.sh` files:

- Maintain backwards compatibility with existing configurations
- Follow POSIX-compatible Bash patterns (target Bash 3.2+)
- Use `set -e` for error handling
- Quote all variables: `"$var"`
- Use `local` for function-scoped variables
- Provide clear error messages via `log_error` and `log_info` from `lib/ui.sh`
- Test on multiple platforms (macOS, Linux, Windows Git Bash)

### Shell Completion Updates

When adding new commands or flags, update all three completion files:

- `completions/wtr.bash` (Bash)
- `completions/_git-wtr` (Zsh)
- `completions/git-wtr.fish` (Fish)

### Git Version Compatibility

The codebase includes fallbacks for different Git versions:

- **Git 2.22+**: Uses modern commands like `git branch --show-current`
- **Git 2.5-2.21**: Falls back to `git rev-parse --abbrev-ref HEAD`
- **Minimum**: Git 2.5+ (for basic `git worktree` support)

When using Git commands, check if fallbacks exist (search for `git branch --show-current` in `lib/core.sh`) or add them for new features.

## Code Style

- **Shebang**: `#!/usr/bin/env bash` (not `/bin/bash` or `/bin/sh`)
- **Functions**: `snake_case` naming
- **Variables**: `snake_case` for local vars, `UPPER_CASE` for constants/env vars
- **Indentation**: 2 spaces (no tabs)
- **Quotes**: Always quote variables and paths
- **Error handling**: Check return codes, use `|| exit 1` or `|| return 1`

## Configuration Reference

All config keys use `wtr.*` prefix and are managed via `git config`. Configuration can also be stored in a `.wtrconfig` file for team sharing.

**Configuration precedence** (highest to lowest):

1. `git config --local` (`.git/config`) - personal overrides
2. `.wtrconfig` (repo root) - team defaults
3. `git config --global` (`~/.gitconfig`) - user defaults
4. `git config --system` (`/etc/gitconfig`) - system defaults
5. Environment variables
6. Fallback values

### Git Config Keys

- `wtr.worktrees.dir`: Base directory for worktrees (default: `<repo-name>-worktrees`)
- `wtr.worktrees.prefix`: Folder prefix for worktrees (default: `""`)
- `wtr.defaultBranch`: Default branch name (default: auto-detect)
- `wtr.editor.default`: Default editor (cursor, vscode, zed, etc.)
- `wtr.editor.workspace`: Workspace file path for VS Code/Cursor (relative to worktree root, auto-detects if not set)
- `wtr.ai.default`: Default AI tool (aider, claude, codex, etc.)
- `wtr.copy.include`: Multi-valued glob patterns for files to copy
- `wtr.copy.exclude`: Multi-valued glob patterns for files to exclude
- `wtr.copy.includeDirs`: Multi-valued directory patterns to copy (e.g., "node_modules", ".venv", "vendor")
- `wtr.copy.excludeDirs`: Multi-valued directory patterns to exclude when copying (supports globs like "node_modules/.cache", "\*/.cache")
- `wtr.hook.postCreate`: Multi-valued commands to run after creating worktree
- `wtr.hook.preRemove`: Multi-valued commands to run before removing worktree (abort on failure unless --force)
- `wtr.hook.postRemove`: Multi-valued commands to run after removing worktree

### File-based Configuration

- `.wtrconfig`: Repository-level config file using gitconfig syntax (parsed via `git config -f`)
- `.worktreeinclude`: File with glob patterns (merged with `wtr.copy.include`)

#### .wtrconfig Key Mapping

| Git Config Key         | .wtrconfig Key     |
| ---------------------- | ------------------ |
| `wtr.copy.include`     | `copy.include`     |
| `wtr.copy.exclude`     | `copy.exclude`     |
| `wtr.copy.includeDirs` | `copy.includeDirs` |
| `wtr.copy.excludeDirs` | `copy.excludeDirs` |
| `wtr.hook.postCreate`  | `hooks.postCreate` |
| `wtr.hook.preRemove`   | `hooks.preRemove`  |
| `wtr.hook.postRemove`  | `hooks.postRemove` |
| `wtr.editor.default`   | `defaults.editor`  |
| `wtr.editor.workspace` | `editor.workspace` |
| `wtr.ai.default`       | `defaults.ai`      |

## Environment Variables

**System environment variables**:

- `WTR_DIR`: Override script directory location (default: auto-detected via `resolve_script_dir()` in `bin/wtr`)
- `WTR_WORKTREES_DIR`: Override base worktrees directory (fallback if `wtr.worktrees.dir` not set)
- `WTR_EDITOR_CMD`: Generic editor command for custom editors without adapter files
- `WTR_EDITOR_CMD_NAME`: First word of `WTR_EDITOR_CMD` used for availability checks
- `WTR_AI_CMD`: Generic AI tool command for custom tools without adapter files
- `WTR_AI_CMD_NAME`: First word of `WTR_AI_CMD` used for availability checks

**Hook environment variables** (available in `wtr.hook.postCreate`, `wtr.hook.preRemove`, and `wtr.hook.postRemove` scripts):

- `REPO_ROOT`: Repository root path
- `WORKTREE_PATH`: Worktree path
- `BRANCH`: Branch name

**Note:** `preRemove` hooks run with cwd set to the worktree directory (before deletion). If a preRemove hook fails, removal is aborted unless `--force` is used.

## Important Implementation Details

**Worktree Path Resolution**: The `resolve_target()` function in `lib/core.sh` handles both branch names and the special ID '1'. It checks in order: special ID, current branch in main repo, sanitized path match, full directory scan. Returns tab-separated format: `is_main\tpath\tbranch`.

**Base Directory Resolution** (v1.1.0+): The `resolve_base_dir()` function in `lib/core.sh` determines where worktrees are stored. Behavior:

- Empty config → `<repo>-worktrees` (sibling directory)
- Relative paths → resolved from **repo root** (e.g., `.worktrees` → `<repo>/.worktrees`)
- Absolute paths → used as-is (e.g., `/tmp/worktrees`)
- Tilde expansion → `~/worktrees` → `$HOME/worktrees`
- Auto-warns if worktrees inside repo without `.gitignore` entry

**Track Mode**: The `create_worktree()` function in `lib/core.sh` intelligently chooses between remote tracking, local branch, or new branch creation based on what exists. It tries remote first, then local, then creates new.

**Configuration Precedence**: The `cfg_default()` function in `lib/config.sh` checks local git config first, then `.wtrconfig` file, then global/system git config, then environment variables, then fallback values. Use `cfg_get_all(key, file_key, scope)` for multi-valued configs where `file_key` is the corresponding key in `.wtrconfig` (e.g., `copy.include` for `wtr.copy.include`).

**Multi-Value Configuration Pattern**: Some configs support multiple values (`wtr.copy.include`, `wtr.copy.exclude`, `wtr.copy.includeDirs`, `wtr.copy.excludeDirs`, `wtr.hook.postCreate`, `wtr.hook.preRemove`, `wtr.hook.postRemove`). The `cfg_get_all()` function merges values from local + global + system + `.wtrconfig` file and deduplicates. Set with: `git config --add wtr.copy.include "pattern"`.

**Adapter Loading**: Adapters are sourced dynamically via `load_editor_adapter()` and `load_ai_adapter()` in `bin/wtr`. They must exist in `adapters/editor/` or `adapters/ai/` and define the required functions.

**Adapter Contract**:

- **Editor adapters**: Must implement `editor_can_open()` (returns 0 if available) and `editor_open(path)` (opens editor at path)
- **AI adapters**: Must implement `ai_can_start()` (returns 0 if available) and `ai_start(path, args...)` (starts tool at path with optional args)
- Both should use `log_error` from `lib/ui.sh` for user-facing error messages

**Directory Copying**: The `copy_directories()` function in `lib/copy.sh` copies entire directories (like `node_modules`, `.venv`, `vendor`) to speed up worktree creation. This is particularly useful for avoiding long dependency installation times. The function:

- Uses `find` to locate directories by name pattern
- Supports glob patterns for exclusions (e.g., `node_modules/.cache`, `*/.cache`)
- Validates patterns to prevent path traversal attacks
- Removes excluded subdirectories after copying the parent directory
- Called from `cmd_create()` in `bin/wtr`

**Security note:** Dependency directories may contain sensitive files (tokens, cached credentials). Always use `wtr.copy.excludeDirs` to exclude sensitive subdirectories.

## Troubleshooting Development Issues

### Permission Denied Errors

```bash
# If you get "Permission denied" when running ./bin/wtr
chmod +x ./bin/wtr
```

### Symlink Issues

```bash
# If symlink doesn't work, check if /usr/local/bin exists
ls -la /usr/local/bin

# Create it if needed (macOS/Linux)
sudo mkdir -p /usr/local/bin

# Verify symlink (v2.0.0+: symlink to git-wtr, not wtr)
ls -la /usr/local/bin/git-wtr

# Create symlink for v2.0.0+
sudo ln -s "$(pwd)/bin/git-wtr" /usr/local/bin/git-wtr

# Verify it works
git wtr version
```

### Adapter Not Found

```bash
# Check if adapter file exists
ls -la adapters/editor/
ls -la adapters/ai/

# Verify adapter is being sourced correctly
bash -x ./bin/wtr adapter  # Shows which files are being loaded

# Test specific adapter function availability
bash -c 'source adapters/editor/cursor.sh && editor_can_open && echo "Available" || echo "Not found"'
bash -c 'source adapters/ai/claude.sh && ai_can_start && echo "Available" || echo "Not found"'

# Debug adapter loading with trace
bash -x ./bin/wtr editor test-feature --editor cursor
# Shows full execution trace including adapter loading
```

### Testing in Other Repos

```bash
# When testing, use a separate test repo to avoid breaking your work
mkdir -p ~/wtr-test-repo
cd ~/wtr-test-repo
git init
git commit --allow-empty -m "Initial commit"

# Now test git wtr commands
/path/to/wtr/bin/wtr new test-feature
```

## Documentation Structure

This project has multiple documentation files for different purposes:

- **`CLAUDE.md`** (this file) - Extended development guide for Claude Code
- **`README.md`** - User-facing documentation (commands, configuration, installation)
- **`CONTRIBUTING.md`** - Contribution guidelines and coding standards
- **`.github/copilot-instructions.md`** - Condensed AI agent guide (architecture, adapter contracts, debugging)
- **`.github/instructions/*.instructions.md`** - File-pattern-specific guidance:
  - `testing.instructions.md` - Manual testing checklist
  - `sh.instructions.md` - Shell scripting conventions
  - `lib.instructions.md` - Core library modification guidelines
  - `editor.instructions.md` - Editor adapter contract
  - `ai.instructions.md` - AI tool adapter contract
  - `completions.instructions.md` - Shell completion updates

When working on specific areas, consult the relevant `.github/instructions/*.md` file for detailed guidance.