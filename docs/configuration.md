# Configuration Reference

> Complete configuration guide for wtr

[Back to README](../README.md) | [Advanced Usage](advanced-usage.md) | [Troubleshooting](troubleshooting.md)

---

## Table of Contents

- [Configuration Sources](#configuration-sources)
- [Team Configuration (.wtrconfig)](#team-configuration-wtrconfig)
- [Worktree Settings](#worktree-settings)
- [Provider Settings](#provider-settings)
- [Editor Settings](#editor-settings)
- [AI Tool Settings](#ai-tool-settings)
- [File Copying](#file-copying)
- [Directory Copying](#directory-copying)
- [Hooks](#hooks)
- [UI Settings](#ui-settings)
- [Shell Completions](#shell-completions)
- [Configuration Examples](#configuration-examples)
- [Environment Variables](#environment-variables)

---

## Configuration Sources

All configuration is stored via `git config`, making it easy to manage per-repository or globally. You can also use a `.wtrconfig` file for team-shared settings.

**Configuration precedence** (highest to lowest):

1. `git config --local` (`.git/config`) - personal overrides
2. `.wtrconfig` (repo root) - team defaults
3. `git config --global` (`~/.gitconfig`) - user defaults
4. `git config --system` (`/etc/gitconfig`) - system defaults
5. Environment variables
6. Default values

---

## Team Configuration (.wtrconfig)

Create a `.wtrconfig` file in your repository root to share configuration across your team:

```gitconfig
# .wtrconfig - commit this file to share settings with your team

[copy]
    include = **/.env.example
    include = *.md
    exclude = **/.env

[copy]
    includeDirs = node_modules
    excludeDirs = node_modules/.cache

[hooks]
    postCreate = npm install
    postCreate = cp .env.example .env

[defaults]
    editor = cursor
    ai = claude
    remote = upstream
```

> [!TIP]
> See `templates/.wtrconfig.example` for a complete example with all available settings.

> [!IMPORTANT]
> Hooks and editor/AI defaults from `.wtrconfig` are executable command entries. They are ignored until you review them with `git wtr trust`; changing those entries requires re-approval.

Approval is bound to the repository path and the filesystem identity of its common Git directory. A replacement or fresh clone at the same path needs new approval, as do approvals created by older versions that only used the path. Normal commits and linked worktrees retain approval. This is command-definition trust: scripts, dependencies, and tools invoked by approved commands are not hashed or pinned, so their contents can change within the trusted repository. Review delegated code and trust its contributors before approving.

Command definitions are captured once for trust verification and consumption, with NUL-delimited records preserving multiline values. The version 3 trust format invalidates older approvals; review commands again with `git wtr trust` after upgrading.

The identity includes device, inode, and birth time with nanosecond precision. If the filesystem or `stat` implementation cannot provide a known birth time, approval fails closed and `.wtrconfig` executable commands remain disabled.

---

## Worktree Settings

```bash
# Base directory for worktrees
# Default: <repo-name>-worktrees (sibling to repo)
# Supports: absolute paths, repo-relative paths, tilde expansion
wtr.worktrees.dir = <path>

# Examples:
# Absolute path
wtr.worktrees.dir = /Users/you/all-worktrees/my-project

# Repo-relative (inside repository - requires .gitignore entry)
wtr.worktrees.dir = .worktrees

# Home directory (tilde expansion)
wtr.worktrees.dir = ~/worktrees/my-project

# Folder prefix (default: "")
wtr.worktrees.prefix = dev-

# Default branch (default: auto-detect)
wtr.defaultBranch = main

# Default remote for fetches, tracking, and default base refs (default: origin)
wtr.defaultRemote = upstream
```

> [!IMPORTANT]
> If storing worktrees inside the repository, add the directory to `.gitignore`.

```bash
echo "/.worktrees/" >> .gitignore
```

---

## Sparse-Checkout Settings

If the worktree you branch from uses [sparse-checkout](https://git-scm.com/docs/git-sparse-checkout) (e.g. a slice of a large monorepo), `wtr` can give the new worktree the same narrowed working tree instead of an expensive full checkout.

```bash
# Inherit sparse-checkout from the base worktree (default: true)
wtr.sparse.inherit = true
```

On Git 2.36+, `git wtr new` looks at the worktree holding the base ref (the `--from` target, falling back to the current worktree). If that worktree has valid sparse-checkout settings, wtr runs worktree creation from that source so Git copies its patterns and per-worktree config before checkout. The full tree is never materialized. Git 2.17–2.35 retains full-checkout behavior; explicit `--sparse` requests print a version warning.

Per-command overrides:

```bash
# Force inheritance even if wtr.sparse.inherit is off
git wtr new feature-xyz --from my-app --sparse

# Force a full checkout even if wtr.sparse.inherit is on
git wtr new feature-xyz --from my-app --no-sparse
```

> [!NOTE]
> Sparse-checkout is stored per-worktree, not per-branch. "Inherit from `my-app`" means inherit the live sparse settings and worktree-specific Git config of the `my-app` *worktree*. Ambiguous duplicate-branch worktrees fall back to a full checkout instead of choosing a source arbitrarily.

---

## Provider Settings

The `clean --merged` and `clean --closed` commands auto-detect your hosting provider from the `origin` remote URL (`github.com` → GitHub, `gitlab.com` → GitLab). For self-hosted instances, set the provider explicitly:

```bash
# Override auto-detected hosting provider (github or gitlab)
wtr.provider = gitlab
```

**Setup:**

```bash
# Self-hosted GitLab
git wtr config set wtr.provider gitlab

# Self-hosted GitHub Enterprise
git wtr config set wtr.provider github
```

**Required CLI tools:**

| Provider | CLI Tool | Install                                                        |
| -------- | -------- | -------------------------------------------------------------- |
| GitHub   | `gh`     | [cli.github.com](https://cli.github.com/)                      |
| GitLab   | `glab`   | [gitlab.com/gitlab-org/cli](https://gitlab.com/gitlab-org/cli) |

---

## Editor Settings

```bash
# Default editor: antigravity, cursor, vscode, zed, or none
wtr.editor.default = cursor

# Workspace file for VS Code/Cursor/Antigravity (relative path from worktree root)
# If set, opens the workspace file instead of the folder
# If not set, auto-detects *.code-workspace files in worktree root
# Set to "none" to disable workspace lookup entirely
wtr.editor.workspace = project.code-workspace
```

**Setup editors:**

- **Antigravity**: Install from [antigravity.google](https://antigravity.google), with the `agy-ide` command available
- **Cursor**: Install from [cursor.com](https://cursor.com), enable shell command
- **VS Code**: Install from [code.visualstudio.com](https://code.visualstudio.com), enable `code` command
- **Zed**: Install from [zed.dev](https://zed.dev), `zed` command available automatically

**Workspace files:**

VS Code, Cursor, and Antigravity support `.code-workspace` files for multi-root workspaces, custom settings, and recommended extensions. When opening a worktree:

1. If `wtr.editor.workspace` is set to a path, opens that file (relative to worktree root)
2. If set to `none`, disables workspace lookup (always opens folder)
3. Otherwise, auto-detects any `*.code-workspace` file in the worktree root
4. Falls back to opening the folder if no workspace file is found

---

## AI Tool Settings

```bash
# Default AI tool: none (or antigravity, aider, auggie, claude, codex, copilot, cursor, gemini, opencode)
wtr.ai.default = none
```

**Built-in AI Tool Adapters:**

| Tool                                                                                                                        | Install                                                        | Use Case                                                 | Set as Default                                  |
| --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| **[Antigravity CLI](https://antigravity.google/docs/cli/getting-started)**                                                   | Install from antigravity.google                                | Terminal agent paired with the Antigravity IDE           | `git wtr config set wtr.ai.default antigravity` |
| **[Aider](https://aider.chat/docs/install.html)**                                                                            | `python -m pip install aider-install && aider-install`          | Pair programming and file editing                        | `git wtr config set wtr.ai.default aider`       |
| **[Auggie CLI](https://docs.augmentcode.com/cli/overview)**                                                                  | `npm install -g @augmentcode/auggie`                            | Context-aware agentic CLI for automation and development | `git wtr config set wtr.ai.default auggie`      |
| **[Claude Code](https://claude.com/claude-code)**                                                                            | Install from claude.com                                        | Terminal-native coding agent                             | `git wtr config set wtr.ai.default claude`      |
| **[Codex CLI](https://developers.openai.com/codex/cli/reference/)**                                                          | `npm install -g @openai/codex`                                 | OpenAI coding agent                                      | `git wtr config set wtr.ai.default codex`       |
| **[GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli)**       | `npm install -g @github/copilot` or `brew install copilot-cli` | GitHub's terminal coding agent                           | `git wtr config set wtr.ai.default copilot`     |
| **[Cursor Agent](https://cursor.com/docs/cli/installation)**                                                                 | Install the `agent` CLI from cursor.com                         | Cursor's standalone terminal agent                       | `git wtr config set wtr.ai.default cursor`      |
| **[Gemini CLI](https://github.com/google-gemini/gemini-cli)**                                                                | `npm install -g @google/gemini-cli`                             | Open-source coding agent powered by Gemini               | `git wtr config set wtr.ai.default gemini`      |
| **[OpenCode](https://opencode.ai)**                                                                                          | Install from opencode.ai                                       | Open-source terminal coding agent                        | `git wtr config set wtr.ai.default opencode`    |
| **[Continue (legacy)](https://github.com/continuedev/continue)**                                                              | Existing `cn` installations only                               | Compatibility; the project is no longer maintained      | `git wtr config set wtr.ai.default continue`    |

Any safe executable command in `PATH` also works without a built-in adapter. For
example, after installing [Goose](https://github.com/aaif-goose/goose) or
[Qwen Code](https://github.com/QwenLM/qwen-code):

```bash
git wtr config set wtr.ai.default goose
git wtr config set wtr.ai.default qwen
```

**Examples:**

```bash
# Set default AI tool for this repo
git wtr config set wtr.ai.default claude

# Or set globally for all repos
git wtr config set wtr.ai.default claude --global

# Then just use git wtr ai
git wtr ai my-feature

# Pass arguments to the tool
git wtr ai my-feature -- --plan "refactor auth"
```

---

## File Copying

Copy files to new worktrees using glob patterns:

```bash
# Add patterns to copy (multi-valued)
git wtr config add wtr.copy.include "**/.env.example"
git wtr config add wtr.copy.include "**/CLAUDE.md"
git wtr config add wtr.copy.include "*.config.js"

# Exclude patterns (multi-valued)
git wtr config add wtr.copy.exclude "**/.env"
git wtr config add wtr.copy.exclude "**/secrets.*"
```

### Using .worktreeinclude file

Alternatively, create a `.worktreeinclude` file in your repository root:

```gitignore
# .worktreeinclude - files to copy to new worktrees
# Comments start with #

**/.env.example
**/CLAUDE.md
*.config.js
```

The file uses `.gitignore`-style syntax (one pattern per line, `#` for comments, empty lines ignored). Patterns from `.worktreeinclude` are merged with `wtr.copy.include` config settings - both sources are used together.

### Security Best Practices

**The key distinction:** Development secrets (test API keys, local DB passwords) are **low risk** on personal machines. Production credentials are **high risk** everywhere.

```bash
# Personal dev: copy what you need to run dev servers
git wtr config add wtr.copy.include "**/.env.development"
git wtr config add wtr.copy.include "**/.env.local"
git wtr config add wtr.copy.exclude "**/.env.production"  # Never copy production
```

> [!TIP]
> The tool only prevents path traversal (`../`). Everything else is your choice - copy what you need for your worktrees to function.

---

## Directory Copying

Copy entire directories (like `node_modules`, `.venv`, `vendor`) to avoid reinstalling dependencies:

```bash
# Copy dependency directories to speed up worktree creation
git wtr config add wtr.copy.includeDirs "node_modules"
git wtr config add wtr.copy.includeDirs ".venv"
git wtr config add wtr.copy.includeDirs "vendor"
git wtr config add wtr.copy.includeDirs "packages/*/generated"
```

Directory include patterns are relative to the repository root. Literal paths
are checked directly, `*` and `?` match within the pattern's explicit depth,
and `**` enables recursive matching when a full-tree search is intentional. For
backward compatibility, a bare basename that has no root-level match falls back
to a recursive search. Prefer an explicit nested path to avoid that scan.

```bash
# Exclude specific nested directories (supports glob patterns)
git wtr config add wtr.copy.excludeDirs "node_modules/.cache"  # Exclude exact path
git wtr config add wtr.copy.excludeDirs "node_modules/.npm"    # Exclude npm cache (may contain tokens)

# Exclude using wildcards
git wtr config add wtr.copy.excludeDirs "node_modules/.*"      # Exclude all hidden dirs in node_modules
git wtr config add wtr.copy.excludeDirs "*/.cache"             # Exclude .cache at any level
```

Directory exclusions never descend through symlinks. An exclusion matching a
symlink itself removes only the link, including when the pattern ends in `/`;
the link target is preserved. Exclusions are skipped when the copied directory
or one of its path components is a symlink.

> [!WARNING]
> Dependency directories may contain sensitive files (credentials, tokens, cached secrets). Always use `wtr.copy.excludeDirs` to exclude sensitive subdirectories if needed.

**Use cases:**

- **JavaScript/TypeScript:** Copy `node_modules` to avoid `npm install` (can take minutes for large projects)
- **Python:** Copy `.venv` or `venv` to skip `pip install`
- **PHP:** Copy `vendor` to skip `composer install`
- **Go:** Copy build caches in `.cache` or `bin` directories

**How it works:** The tool uses `find` to locate directories by name and copies them with `cp -r`. This is much faster than reinstalling dependencies but uses more disk space.

---

## Hooks

Run custom commands during worktree operations:

```bash
# Post-create hooks (multi-valued, run in order)
git wtr config add wtr.hook.postCreate "npm install"
git wtr config add wtr.hook.postCreate "npm run build"

# Pre-remove hooks (run before deletion, abort on failure)
git wtr config add wtr.hook.preRemove "npm run cleanup"

# Post-remove hooks
git wtr config add wtr.hook.postRemove "echo 'Cleaned up!'"

# Post-cd hooks (run after wtr cd, wtr new --cd, or wtr pr --cd, in current shell)
git wtr config add wtr.hook.postCd "source ./vars.sh"
```

**Hook execution order:**

| Hook         | Timing                           | Use Case                                    |
| ------------ | -------------------------------- | ------------------------------------------- |
| `postCreate` | After worktree creation          | Setup, install dependencies                 |
| `preRemove`  | Before worktree deletion         | Cleanup requiring directory access          |
| `postRemove` | After worktree deletion          | Notifications, logging                      |
| `postCd`     | After `wtr cd`, `wtr new --cd`, or `wtr pr --cd` changes directory | Re-source environment, update shell context |

> **Note:** Pre-remove hooks abort removal on failure. Use `--force` to skip failed hooks.
>
> **Note:** `postCd` hooks run in the **current shell** (not a subshell) so they can modify environment variables. They only run via shell integration (`wtr cd`, `wtr new --cd`, `wtr pr --cd`), not raw `git wtr` commands or `git wtr go`. Failures warn but don't undo the directory change.

**Environment variables available in hooks:**

- `REPO_ROOT` - Repository root path
- `WORKTREE_PATH` - Worktree path
- `BRANCH` - Branch name

**Examples for different build tools:**

```bash
# Node.js (npm)
git wtr config add wtr.hook.postCreate "npm install"

# Node.js (pnpm)
git wtr config add wtr.hook.postCreate "pnpm install"

# Python
git wtr config add wtr.hook.postCreate "pip install -r requirements.txt"

# Ruby
git wtr config add wtr.hook.postCreate "bundle install"

# Rust
git wtr config add wtr.hook.postCreate "cargo build"
```

---

## UI Settings

Control color output behavior.

| Git Config Key | `.wtrconfig` Key | Description       | Values                              |
| -------------- | ---------------- | ----------------- | ----------------------------------- |
| `wtr.ui.color` | `ui.color`       | Color output mode | `auto` (default), `always`, `never` |

```bash
# Disable color output
git wtr config set wtr.ui.color never

# Force color output (e.g., when piping to a pager)
git wtr config set wtr.ui.color always
```

**Precedence**: `NO_COLOR` env (highest) > `WTR_COLOR` env > `wtr.ui.color` config > auto-detect (TTY).

The `NO_COLOR` environment variable ([no-color.org](https://no-color.org)) always wins regardless of other settings.

---

## Shell Completions

Enable tab completion using the built-in `completion` command.
Homebrew installs native Bash, Zsh, and Fish completion files automatically, so
manual setup is mainly for source installs or explicit shell configuration.

### Bash

Requires `bash-completion` v2:

```bash
# macOS
brew install bash-completion@2

# Ubuntu/Debian
sudo apt install bash-completion

# Add to ~/.bashrc
source <(git wtr completion bash)
```

### Zsh

Add to `~/.zshrc` **before** any existing `compinit` call:

```bash
eval "$(git wtr completion zsh)"
```

<details>
<summary>Why before compinit?</summary>

Zsh needs to know `wtr` is a valid git subcommand before the completion system initializes. The `completion zsh` command outputs the required `zstyle` registration.

</details>

### Fish

```bash
mkdir -p ~/.config/fish/completions
git wtr completion fish > ~/.config/fish/completions/git-wtr.fish
```

---

## Configuration Examples

### Minimal Setup (Just Basics)

```bash
git wtr config set wtr.worktrees.prefix "wt-"
git wtr config set wtr.defaultBranch "main"
```

### Full-Featured Setup (Node.js Project)

```bash
# Worktree settings
git wtr config set wtr.worktrees.prefix "wt-"

# Editor
git wtr config set wtr.editor.default cursor

# Copy environment templates
git wtr config add wtr.copy.include "**/.env.example"
git wtr config add wtr.copy.include "**/.env.development"
git wtr config add wtr.copy.exclude "**/.env.local"

# Build hooks
git wtr config add wtr.hook.postCreate "pnpm install"
git wtr config add wtr.hook.postCreate "pnpm run build"
```

### Global Defaults

```bash
# Set global preferences
git wtr config set wtr.editor.default cursor --global
git wtr config set wtr.ai.default claude --global
git wtr config set wtr.defaultRemote upstream --global
```

---

## Environment Variables

For the variables that back a `wtr.*` key (`WTR_WORKTREES_DIR`, `WTR_WORKTREES_PREFIX`, `WTR_DEFAULT_BRANCH`, `WTR_DEFAULT_REMOTE`, `WTR_EDITOR_DEFAULT`, `WTR_AI_DEFAULT`, `WTR_PROVIDER`), the environment value is used only when no `git config` or `.wtrconfig` source sets that key. The other variables are read directly and are not part of that order: `WTR_DIR` is resolved before any configuration loads, `WTR_EDITOR_CMD` and `WTR_AI_CMD` are consumed by the adapter loader, `WTR_COLOR` sets the initial color mode but a `wtr.ui.color` value of `always` or `never` replaces it, and `NO_COLOR` disables color regardless of any other setting.

| Variable               | Description                                                          | Default                                  |
| ---------------------- | -------------------------------------------------------------------- | ---------------------------------------- |
| `WTR_DIR`              | Override script directory location                                   | Auto-detected                            |
| `WTR_WORKTREES_DIR`    | Override base worktrees directory                                    | `wtr.worktrees.dir` config               |
| `WTR_WORKTREES_PREFIX` | Folder name prefix for new worktrees                                 | `wtr.worktrees.prefix` config            |
| `WTR_DEFAULT_BRANCH`   | Base branch for new worktrees                                        | `wtr.defaultBranch` config (auto-detect) |
| `WTR_EDITOR_DEFAULT`   | Default editor adapter                                               | `wtr.editor.default` config              |
| `WTR_AI_DEFAULT`       | Default AI tool adapter                                              | `wtr.ai.default` config                  |
| `WTR_EDITOR_CMD`       | Custom editor command (e.g., `emacs`)                                | None                                     |
| `WTR_EDITOR_CMD_NAME`  | First word of `WTR_EDITOR_CMD` for availability checks               | None                                     |
| `WTR_AI_CMD`           | Custom AI tool command (e.g., `copilot`)                             | None                                     |
| `WTR_AI_CMD_NAME`      | First word of `WTR_AI_CMD` for availability checks                   | None                                     |
| `WTR_DEFAULT_REMOTE`   | Remote used for default base refs and tracking                       | `origin`                                 |
| `WTR_COLOR`            | Override color output (`always`, `never`, `auto`)                    | `auto`                                   |
| `WTR_PROVIDER`         | Override hosting provider (`github` or `gitlab`)                     | Auto-detected from URL                   |
| `NO_COLOR`             | Disable color output when set ([no-color.org](https://no-color.org)) | Unset                                    |

**Hook environment variables** (available in hook scripts):

| Variable        | Description          |
| --------------- | -------------------- |
| `REPO_ROOT`     | Repository root path |
| `WORKTREE_PATH` | Worktree path        |
| `BRANCH`        | Branch name          |

---

[Back to README](../README.md) | [Advanced Usage](advanced-usage.md) | [Troubleshooting](troubleshooting.md)
