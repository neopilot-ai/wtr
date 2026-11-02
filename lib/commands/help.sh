#!/usr/bin/env bash

# ── Per-command help functions ───────────────────────────────────────────────
# Each _help_<command>() provides detailed help for a single command.
# Dispatched by cmd_help when a command argument is provided.

_help_new() {
  cat <<'EOF'
git wtr new - Create a new worktree

Usage: git wtr new <branch> [options]

Creates a new git worktree with the given branch name. The worktree folder
is named after the branch (slashes and special chars become hyphens, e.g.,
feature/user-auth becomes folder "feature-user-auth").

Options:
  --from <ref>        Create from a specific ref (default: default branch)
  --from-current      Create from the current branch (for parallel variants)
  --remote <name>     Remote used for default base refs (default: wtr.defaultRemote)
  --track <mode>      Branch tracking mode: auto|remote|local|none (default: auto)
                      auto: tries remote first, then local, then creates new
  --no-copy           Skip file copying (wtr.copy.include patterns)
  --no-fetch          Skip git fetch before creating
  --no-hooks          Skip post-create hooks
  --sparse            Inherit sparse-checkout from the base worktree (Git 2.36+)
  --no-sparse         Force a full checkout (override wtr.sparse.inherit)
  --force             Allow same branch in multiple worktrees
                      (requires --name or --folder to distinguish them)
  --name <suffix>     Custom folder name suffix (appended after branch name)
  --folder <name>     Custom folder name (replaces default entirely)
  --yes               Non-interactive mode (skip prompts)
  --porcelain         Machine-readable key<TAB>value output (implies --yes)
                      Cannot be combined with --editor or --ai
  -e, --editor        Open in editor after creation
  -a, --ai            Start AI tool after creation

Examples:
  git wtr new feature/user-auth                 # Folder: feature-user-auth
  git wtr new hotfix --from v2.0.0              # Branch from tag
  git wtr new my-feature --from-current         # Branch from current HEAD
  git wtr new agent-task --porcelain             # Stable output for automation
  git wtr new feature -e -a                     # Create, open editor + AI
  git wtr new feature --force --name backend    # Second worktree for same branch
  git wtr new feature --folder my-dir           # Custom folder name
EOF
}

_help_pr() {
  cat <<'EOF'
git wtr pr - Create a worktree for a GitHub pull request

Usage: git wtr pr <number|url|branch> [options]

Creates a worktree from a GitHub pull request, similar to gh pr checkout.
Uses gh's native worktree checkout when available and a compatible fallback
otherwise, preserving configured Git remotes and protocols.
The default local branch is the PR head branch so GitHub CLI can infer the PR
from inside the worktree. Requires GitHub CLI (gh) for PR lookup.

Options:
  -b, --branch <name>  Local branch name to use (default: PR head branch)
  -R, --repo <repo>    Select GitHub repository for gh pr view
  --remote <name>      Override remote/repository used to fetch refs/pull/<number>/head
  --no-copy            Skip file copying (wtr.copy.include patterns)
  --no-hooks           Skip post-create hooks
  --force              Allow same branch in multiple worktrees
                       (requires --name or --folder to distinguish worktrees)
  --name <suffix>      Custom folder name suffix (appended after branch name)
  --folder <name>      Custom folder name (replaces default entirely)
  --yes                Non-interactive mode (skip prompts)
  -e, --editor         Open in editor after creation
  -a, --ai             Start AI tool after creation

Examples:
  git wtr pr 123                         # Branch/folder from PR head branch
  git wtr pr 123 --branch review/fix     # Custom local branch
  git wtr pr https://github.com/OWNER/REPO/pull/123 --folder review
  wtr pr 123 --cd                        # With shell integration
EOF
}

_help_editor() {
  cat <<'EOF'
git wtr editor - Open worktree in editor

Usage: git wtr editor <branch> [--editor <name>]

Opens the specified worktree in your configured editor. Uses the default
editor from wtr.editor.default config, or the --editor flag to override.

Options:
  --editor <name>     Override the default editor for this invocation

Special:
  Use '1' to open the main repo root: git wtr editor 1

Available editors:
  antigravity, cursor, emacs, idea, nano, nvim, pycharm, sublime, vim,
  vscode, webstorm, zed, none (or any safe command in your PATH)
  Legacy compatibility: atom

Examples:
  git wtr editor my-feature                     # Uses default editor
  git wtr editor my-feature --editor vscode     # Override with vscode
  git wtr editor my-feature --editor "nano -w"  # Override-backed adapter with flags
  git wtr editor 1                              # Open main repo
EOF
}

_help_ai() {
  cat <<'EOF'
git wtr ai - Start AI coding tool in worktree

Usage: git wtr ai <branch> [--ai <name>] [-- args...]

Starts your configured AI coding tool in the specified worktree. Uses the
default AI tool from wtr.ai.default config, or the --ai flag to override.
Arguments after -- are passed through to the AI tool.

Options:
  --ai <name>         Override the default AI tool for this invocation

Special:
  Use '1' to start AI in the main repo root: git wtr ai 1

Available AI tools:
  antigravity, aider, auggie, claude, codex, copilot, cursor, gemini,
  opencode, none (or any safe command in your PATH)
  Legacy compatibility: continue

Examples:
  git wtr ai my-feature                         # Uses default AI tool
  git wtr ai my-feature --ai aider              # Override with aider
  git wtr ai my-feature --ai "claude --continue"
  git wtr ai my-feature -- --verbose            # Pass args to AI tool
  git wtr ai 1                                  # AI in main repo
EOF
}

_help_go() {
  cat <<'EOF'
git wtr go - Print worktree path

Usage: git wtr go <branch>

Prints the absolute path to the specified worktree. Useful for navigation
with cd or for scripting. For direct cd support, use shell integration:
  git wtr help init              # see setup instructions
  wtr cd <branch>                # then navigate directly

Special:
  Use '1' for the main repo root: git wtr go 1

Examples:
  git wtr go my-feature                         # Print path
  cd "$(git wtr go my-feature)"                 # Navigate to worktree
  wtr cd my-feature                             # With shell integration
EOF
}

_help_run() {
  cat <<'EOF'
git wtr run - Execute command in worktree

Usage: git wtr run <branch> <command...>

Runs the specified command in the worktree directory. The command and all
its arguments are executed with the worktree as the working directory.

Special:
  Use '1' to run in the main repo root: git wtr run 1 <command>

Examples:
  git wtr run my-feature npm test               # Run tests
  git wtr run my-feature git status             # Check git status
  git wtr run my-feature npm run dev            # Start dev server
  git wtr run 1 npm run build                   # Build in main repo
EOF
}

_help_list() {
  cat <<'EOF'
git wtr list - List all worktrees

Usage: git wtr list [--porcelain]
       git wtr ls [--porcelain]

Shows all git worktrees for the current repository in a formatted table.

Options:
  --porcelain         Machine-readable output (one worktree per line)

Examples:
  git wtr list                                  # Human-readable table
  git wtr ls --porcelain                        # Machine-readable output
EOF
}

_help_rm() {
  cat <<'EOF'
git wtr rm - Remove worktree(s)

Usage: git wtr rm <branch> [<branch>...] [options]

Removes one or more worktrees by branch name. Runs pre-remove and
post-remove hooks unless --force is used to override hook failures.

Options:
  --delete-branch     Also delete the git branch after removing the worktree
  --force             Force removal even if worktree has uncommitted changes
  --yes               Skip confirmation prompts

Examples:
  git wtr rm my-feature                         # Remove worktree
  git wtr rm my-feature --delete-branch         # Remove worktree + branch
  git wtr rm feat-1 feat-2 feat-3               # Remove multiple
  git wtr rm my-feature --force --yes           # Force, no prompts
EOF
}

_help_mv() {
  cat <<'EOF'
git wtr mv - Rename worktree and branch

Usage: git wtr mv <old> <new> [options]
       git wtr rename <old> <new> [options]

Renames both the worktree folder and its local branch. The remote branch
is not renamed (push the new branch and delete the old one manually).

Options:
  --force             Force move even if worktree is locked
  --yes               Skip confirmation prompts

Examples:
  git wtr mv feature-wip feature-auth           # Rename worktree + branch
  git wtr rename old-name new-name              # Alias for mv
  git wtr mv locked-wt new-name --force         # Force move if locked
EOF
}

_help_copy() {
  cat <<'EOF'
git wtr copy - Copy files between worktrees

Usage: git wtr copy <target>... [options] [-- <pattern>...]

Copies files from the main repo (or another worktree) to the specified
target worktree(s). Uses wtr.copy.include/exclude config patterns by
default. Patterns after -- override configured patterns.

Options:
  -n, --dry-run       Preview what would be copied without copying
  -a, --all           Copy to all worktrees
  --from <source>     Copy from a different worktree (default: main repo)

Patterns:
  Glob patterns like ".env*", "*.json", "**/.env*" are supported.
  Configure defaults: git wtr config add wtr.copy.include ".env*"

Examples:
  git wtr copy my-feature                       # Uses configured patterns
  git wtr copy my-feature -- ".env*"            # Explicit pattern
  git wtr copy my-feature -- ".env*" "*.json"   # Multiple patterns
  git wtr copy -a -- ".env*"                    # Update all worktrees
  git wtr copy my-feature -n -- "**/.env*"      # Dry-run preview
  git wtr copy feat --from other-feat           # Copy between worktrees
EOF
}

_help_config() {
  cat <<'EOF'
git wtr config - Manage configuration

Usage: git wtr config [list] [--local|--global|--system]
       git wtr config get <key> [--local|--global|--system]
       git wtr config set <key> <value> [--local|--global]
       git wtr config add <key> <value> [--local|--global]
       git wtr config unset <key> [--local|--global]

Manages wtr configuration stored in git config. Supports local (repo),
global (user), and system scopes. Team defaults can also be set in
.wtrconfig (gitconfig syntax, committed to repo).

Actions:
  list      Show all wtr.* config values (default when no args)
  get       Read a config value (merged from all sources by default)
  set       Set a single value (replaces existing)
  add       Add a value (for multi-valued keys like hooks, copy patterns)
  unset     Remove a config value

Scope flags:
  --local   Target local git config (.git/config)
  --global  Target global git config (~/.gitconfig)
  --system  Read-only for list/get (write requires root)

Examples:
  git wtr config                                # List all config
  git wtr config list --local                   # List local config only
  git wtr config set wtr.editor.default cursor  # Set default editor
  git wtr config set wtr.editor.default "code --wait"
  git wtr config add wtr.copy.include ".env*"   # Add copy pattern
  git wtr config get wtr.ai.default             # Get AI tool setting
  git wtr config unset wtr.worktrees.prefix     # Remove prefix setting

Generic editor/AI defaults must be safe PATH commands. Filesystem paths
such as ./tool and shell-wrapper forms such as sh -c ... are rejected.
Override-backed adapters like claude, cursor, and nano may include flags.
EOF
}

_help_doctor() {
  cat <<'EOF'
git wtr doctor - Health check

Usage: git wtr doctor

Verifies your setup: git installation, repo state, worktrees directory,
configured editor, configured AI tool, OS detection, and hosting provider.
Shows actionable guidance for any issues found.

Examples:
  git wtr doctor                                # Run health check
EOF
}

_help_adapter() {
  cat <<'EOF'
git wtr adapter - List available adapters

Usage: git wtr adapter

Lists all built-in editor and AI tool adapters, along with their availability
on the current system. Safe PATH commands can also be used without a built-in
adapter. Path-based commands like ./tool and shell wrappers like sh -c are
rejected, while override-backed adapters such as claude, cursor, and nano may
include flags.

Examples:
  git wtr adapter                               # Show all adapters
EOF
}

_help_clean() {
  cat <<'EOF'
git wtr clean - Remove stale worktrees

Usage: git wtr clean [options]

Removes empty worktree directories and optionally removes worktrees whose
PRs/MRs have been merged or closed. Auto-detects GitHub (gh) or GitLab
(glab) from the remote URL.

Also detects registry entries that are locked but whose directories no
longer exist (git worktree prune skips locked entries) and offers to
unlock and prune them. Confirmed automatically with --force or --yes.

Options:
  --merged            Also remove worktrees with merged PRs/MRs
  --closed            Also remove worktrees with closed PRs/MRs
  --to <ref>          Only remove worktrees for PRs/MRs targeting <ref>
  --yes, -y           Skip confirmation prompts
  --dry-run, -n       Show what would be removed without removing
  --force, -f         Force removal even if worktree has uncommitted changes or untracked files

Examples:
  git wtr clean                                 # Clean empty directories
  git wtr clean --merged                        # Also clean merged PRs
  git wtr clean --closed                        # Also clean closed PRs
  git wtr clean --merged --closed --to main     # Clean merged or closed PRs targeting main
  git wtr clean --merged --dry-run              # Preview PR cleanup
  git wtr clean --merged --yes                  # Auto-confirm everything
  git wtr clean --merged --force                # Force-clean, ignoring local changes
  git wtr clean --merged --force --yes          # Force-clean and auto-confirm
EOF
}

_help_completion() {
  cat <<'EOF'
git wtr completion - Generate shell completions

Usage: git wtr completion <shell>

Generates shell completion script for the specified shell. Add to your
shell configuration for tab completion of git wtr commands and options.

Supported shells: bash, zsh, fish

Setup:
  Homebrew installs native shell completions automatically.

  # Bash (manual setup, add to ~/.bashrc)
  source <(git wtr completion bash)

  # Zsh (manual setup, add to ~/.zshrc BEFORE compinit)
  eval "$(git wtr completion zsh)"

  # Fish (manual setup)
  mkdir -p ~/.config/fish/completions
  git wtr completion fish > ~/.config/fish/completions/git-wtr.fish
EOF
}

_help_init() {
  cat <<'EOF'
git wtr init - Generate shell integration

Usage: git wtr init <shell> [--as <name>]

Generates shell functions for enhanced features like 'wtr cd <branch>',
'wtr new <branch> --cd', and 'wtr pr <number> --cd', which can change the
current shell directory.
Add to your shell configuration.

Output is cached to ~/.cache/wtr/ for fast shell startup (~1ms vs ~60ms).
The cache refreshes the next time 'git wtr init <shell>' runs (checks version).
With the recommended setup below, it regenerates when the cache file is missing.
To force-regenerate: rm -rf ~/.cache/wtr

Supported shells: bash, zsh, fish

Options:
  --as <name>   Set custom function name (default: wtr)
                Useful if 'wtr' conflicts with another command (e.g., GNU tr)

Setup (sources cached output directly for fast startup):
  # Bash (add to ~/.bashrc)
  _wtr_init="${XDG_CACHE_HOME:-$HOME/.cache}/wtr/init-wtr.bash"
  [[ -f "$_wtr_init" ]] && head -n 1 "$_wtr_init" | grep -q ' init=6 ' || eval "$(git wtr init bash)" || true
  source "$_wtr_init" 2>/dev/null || true; unset _wtr_init

  # Zsh (add to ~/.zshrc)
  _wtr_init="${XDG_CACHE_HOME:-$HOME/.cache}/wtr/init-wtr.zsh"
  [[ -f "$_wtr_init" ]] && head -n 1 "$_wtr_init" | grep -q ' init=6 ' || eval "$(git wtr init zsh)" || true
  source "$_wtr_init" 2>/dev/null || true; unset _wtr_init

  # Fish (add to ~/.config/fish/config.fish)
  set -l _wtr_init (test -n "$XDG_CACHE_HOME" && echo $XDG_CACHE_HOME || echo $HOME/.cache)/wtr/init-wtr.fish
  test -f "$_wtr_init"; and head -n 1 "$_wtr_init" | string match -q '* init=6 *'; or git wtr init fish >/dev/null 2>&1
  source "$_wtr_init" 2>/dev/null

  # Custom function name (avoids conflict with coreutils wtr)
  eval "$(git wtr init zsh --as gwtr)"

After setup:
  wtr new my-feature --cd                        # create and cd into worktree
  wtr pr 123 --cd                                # create PR worktree and cd
  wtr cd my-feature                             # cd to worktree
  wtr cd 1                                      # cd to main repo
  wtr cd                                        # interactive picker (requires fzf)
  wtr <command>                                 # same as git wtr <command>

Command palette (wtr cd with no arguments, requires fzf):
  enter       cd into selected worktree
  ctrl-e      open in editor
  ctrl-a      start AI tool
  ctrl-d      delete worktree (with confirmation)
  ctrl-y      copy files to worktree
  ctrl-r      refresh list
  esc         cancel
EOF
}

_help_trust() {
  cat <<'EOF'
git wtr trust - Trust .wtrconfig commands

Usage: git wtr trust

Reviews and approves executable commands defined in the repository's
.wtrconfig file. Hooks and editor/AI defaults from .wtrconfig are not
used until explicitly trusted.

This prevents malicious contributors from injecting arbitrary shell
commands via shared .wtrconfig files. Trust is stored per repository
path, common Git directory filesystem identity, and executable command
definitions in ~/.config/wtr/trusted/. Replacing a repository at the same
path or changing those commands requires new approval. Older path-only
approvals require renewal.

Approval includes scripts and programs invoked by these commands. Their
contents are not hashed or pinned; review delegated code and trust its
contributors before approving.

Trust requires a known filesystem birth time for the Git directory.
Without it, .wtrconfig executable commands remain untrusted.

Hooks and defaults from your local git config (.git/config, ~/.gitconfig)
are always trusted since you control those files directly.

Examples:
  git wtr trust                                 # Review and approve commands
EOF
}

_help_version() {
  cat <<'EOF'
git wtr version - Show version

Usage: git wtr version
EOF
}

# ── Main help command ────────────────────────────────────────────────────────

cmd_help() {
  local command="${1:-}"

  # No argument: show full help page
  if [ -z "$command" ]; then
    _help_full
    return 0
  fi

  # Map aliases to canonical names
  case "$command" in
    ls)       command="list" ;;
    rename)   command="mv" ;;
    adapters) command="adapter" ;;
  esac

  # Dispatch to per-command help function
  local help_func="_help_${command//-/_}"
  if type "$help_func" >/dev/null 2>&1; then
    "$help_func"
  else
    log_error "No help available for: $command"
    echo "Use 'git wtr help' for available commands" >&2
    return 1
  fi
}

# Full help page (shown when no command is specified)
_help_full() {
  cat <<'EOF'
git wtr - Git worktree runner

PHILOSOPHY: Configuration over flags. Set defaults once, then use simple commands.

────────────────────────────────────────────────────────────────────────────────

QUICK START:
  cd ~/your-repo                                   # Navigate to git repo first
  git wtr config set wtr.editor.default cursor     # One-time setup
  git wtr config set wtr.ai.default claude         # One-time setup
  git wtr new my-feature                           # Creates worktree in folder "my-feature"
  git wtr editor my-feature                        # Opens in cursor
  git wtr ai my-feature                            # Starts claude
  git wtr rm my-feature                            # Remove when done

────────────────────────────────────────────────────────────────────────────────

KEY CONCEPTS:
  • Worktree folders are named after the branch name
  • Main repo is accessible via special ID '1' (e.g., git wtr go 1, git wtr editor 1)
  • Commands accept branch names to identify worktrees
    Example: git wtr editor my-feature, git wtr go feature/user-auth
  • Run 'git wtr help <command>' for detailed help on any command

────────────────────────────────────────────────────────────────────────────────

CORE COMMANDS (daily workflow):

  new <branch> [options]
         Create a new worktree (folder named after branch)
         --from <ref>: create from specific ref
         --from-current: create from current branch (for parallel variants)
         --remote <name>: remote used for default base refs
         --track <mode>: tracking mode (auto|remote|local|none)
         --no-copy: skip file copying
         --no-fetch: skip git fetch
         --no-hooks: skip post-create hooks
         --force: allow same branch in multiple worktrees (requires --name or --folder)
         --name <suffix>: custom folder name suffix (e.g., backend, frontend)
         --folder <name>: custom folder name (replaces default, useful for long branches)
         --yes: non-interactive mode
         --porcelain: machine-readable key<TAB>value output (implies --yes)
         -e, --editor: open in editor after creation
         -a, --ai: start AI tool after creation

  pr <number|url|branch> [options]
         Create a worktree from a GitHub pull request (requires gh)
         -b, --branch <name>: local branch name (default: PR head branch)
         -R, --repo <repo>: repository for gh pr view
         --remote <name>: override remote/repository used to fetch refs/pull/<number>/head
         --no-copy: skip file copying
         --no-hooks: skip post-create hooks
         --force: allow same branch in multiple worktrees (requires --name or --folder)
         --name <suffix>: custom folder name suffix
         --folder <name>: custom folder name
         --yes: non-interactive mode
         -e, --editor: open in editor after creation
         -a, --ai: start AI tool after creation

  editor <branch> [--editor <name>]
         Open worktree in editor (uses wtr.editor.default or --editor)
         Special: use '1' to open repo root

  ai <branch> [--ai <name>] [-- args...]
         Start AI coding tool in worktree (uses wtr.ai.default or --ai)
         Special: use '1' to open repo root

  go <branch>
         Print worktree path (tip: use 'wtr cd <branch>' with shell integration)
         Special: use '1' for repo root

  run <branch> <command...>
         Execute command in worktree directory
         Special: use '1' to run in repo root

         Examples:
           git wtr run feature npm test
           git wtr run feature-auth git status
           git wtr run 1 npm run build

  list [--porcelain]
         List all worktrees
         Aliases: ls

  rm <branch> [<branch>...] [options]
         Remove worktree(s) by branch name
         --delete-branch: also delete the branch
         --force: force removal (dirty worktree)
         --yes: skip confirmation

  mv <old> <new> [--force] [--yes]
         Rename worktree and its branch
         Aliases: rename
         --force: force move (locked worktree)
         --yes: skip confirmation
         Note: Only renames local branch. Remote branch unchanged.

         Examples:
           git wtr mv feature-wip feature-auth
           git wtr rename old-name new-name

  copy <target>... [options] [-- <pattern>...]
         Copy files from main repo to worktree(s)
         -n, --dry-run: preview without copying
         -a, --all: copy to all worktrees
         --from <source>: copy from different worktree (default: main repo)
         Patterns after -- override wtr.copy.include config

         Examples:
           git wtr copy my-feature                       # Uses configured patterns
           git wtr copy my-feature -- ".env*"            # Explicit pattern
           git wtr copy my-feature -- ".env*" "*.json"   # Multiple patterns
           git wtr copy -a -- ".env*"                    # Update all worktrees
           git wtr copy my-feature -n -- "**/.env*"      # Dry-run preview

────────────────────────────────────────────────────────────────────────────────

SETUP & MAINTENANCE:

  config [list] [--local|--global|--system]
  config get <key> [--local|--global|--system]
  config {set|add|unset} <key> [value] [--local|--global]
         Manage configuration
         - list: show all wtr.* config values (default when no args)
         - get: read a config value (merged from all sources by default)
         - set: set a single value (replaces existing)
         - add: add a value (for multi-valued configs like hooks, copy patterns)
         - unset: remove a config value
         Without scope flag, list/get show merged config from all sources
         Use --local/--global to target a specific scope for write operations

  doctor
         Health check (verify git, editors, AI tools)

  adapter
         List available editor & AI tool adapters
         Note: Safe PATH commands can be used (e.g., code --wait, bunx @github/copilot@latest)

  clean [options]
         Remove stale/prunable worktrees and empty directories
         --merged: also remove worktrees with merged PRs/MRs
         --closed: also remove worktrees with closed PRs/MRs
         --to <ref>: limit PR cleanup to PRs/MRs targeting <ref>
                   Auto-detects GitHub (gh) or GitLab (glab) from remote URL
                   Override: git wtr config set wtr.provider gitlab
         --yes, -y: skip confirmation prompts
         --dry-run, -n: show what would be removed without removing
         --force, -f: force removal even if worktree has uncommitted changes or untracked files

  trust
         Review and approve .wtrconfig executable commands
         Hooks and editor/AI defaults from .wtrconfig are not used until trusted
         Trust is re-required when executable command entries change

  completion <shell>
         Generate shell completions (bash, zsh, fish)
         Usage: eval "$(git wtr completion zsh)"

  init <shell> [--as <name>]
         Generate shell integration for wtr cd, wtr new --cd, and wtr pr --cd (bash, zsh, fish)
         --as <name>: custom function name (default: wtr)
         Output is cached for fast startup (refreshes when 'git wtr init' runs)
         See git wtr help init for recommended setup
         With fzf: 'wtr cd' opens a command palette (preview, editor, AI, delete)

  version
         Show version

────────────────────────────────────────────────────────────────────────────────

WORKFLOW EXAMPLES:

  # One-time repo setup
  cd ~/GitHub/my-project
  git wtr config set wtr.editor.default cursor
  git wtr config set wtr.ai.default claude

  # Daily workflow
  git wtr new feature/user-auth               # Create worktree (folder: feature-user-auth)
  git wtr pr 123                              # Create worktree for pull request #123
  git wtr editor feature/user-auth            # Open in editor
  git wtr ai feature/user-auth                # Start AI tool

  # Run commands in worktree
  git wtr run feature/user-auth npm test      # Run tests
  git wtr run feature/user-auth npm run dev   # Start dev server

  # Navigate to worktree directory
  wtr new hotfix --cd                          # Create and cd into worktree (with shell integration)
  wtr pr 123 --cd                              # Create PR worktree and cd
  wtr cd                                    # Interactive picker (requires fzf)
  wtr cd feature/user-auth                  # With shell integration (git wtr init)
  cd "$(git wtr go feature/user-auth)"      # Without shell integration

  # Override defaults with flags
  git wtr editor feature/user-auth --editor vscode
  git wtr ai feature/user-auth --ai aider

  # Chain commands together
  git wtr new hotfix && git wtr editor hotfix && git wtr ai hotfix

  # Create variant worktrees from current branch (for parallel work)
  git checkout feature/user-auth
  git wtr new variant-1 --from-current        # Creates variant-1 from feature/user-auth
  git wtr new variant-2 --from-current        # Creates variant-2 from feature/user-auth

  # When finished
  git wtr rm feature/user-auth --delete-branch

  # Check setup and available tools
  git wtr doctor
  git wtr adapter

────────────────────────────────────────────────────────────────────────────────

CONFIGURATION OPTIONS:

  wtr.worktrees.dir        Worktrees base directory
  wtr.worktrees.prefix     Worktree folder prefix (default: "")
  wtr.defaultBranch        Default branch (default: auto)
  wtr.defaultRemote        Default remote (default: origin)
  wtr.editor.default       Default editor
                           Options: antigravity, cursor, emacs, idea, nano,
                           nvim, pycharm, sublime, vim, vscode, webstorm,
                           zed, none (legacy: atom)
  wtr.editor.workspace     Workspace file for VS Code/Cursor/Antigravity
                           (relative path, auto-detects, or "none")
  wtr.ai.default           Default AI tool
                           Options: antigravity, aider, auggie, claude,
                           codex, copilot, cursor, gemini, opencode, none
                           (legacy: continue)
  wtr.copy.include         Files to copy (multi-valued)
  wtr.copy.exclude         Files to exclude (multi-valued)
  wtr.copy.includeDirs     Directories to copy (multi-valued)
                           Example: node_modules, .venv, vendor
                           Supports repo-relative globs; ** matches recursively
                           WARNING: May include sensitive files!
                           Use wtr.copy.excludeDirs to exclude them.
  wtr.copy.excludeDirs     Directories to exclude (multi-valued)
                           Supports glob patterns (e.g., "node_modules/.cache", "*/.npm")
  wtr.hook.postCreate      Post-create hooks (multi-valued)
  wtr.hook.preRemove       Pre-remove hooks (multi-valued, abort on failure)
  wtr.hook.postRemove      Post-remove hooks (multi-valued)
  wtr.hook.postCd          Post-cd hooks (multi-valued, wtr cd / wtr new --cd / wtr pr --cd only)
  wtr.ui.color             Color output mode (auto, always, never; default: auto)

────────────────────────────────────────────────────────────────────────────────

MORE INFO: https://github.com/neopilot-ai/wtr
EOF
}
