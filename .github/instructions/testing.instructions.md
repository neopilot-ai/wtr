---
applyTo: bin/git-wtr, bin/wtr, lib/**/*.sh, adapters/**/*.sh, tests/**/*.bats
---

# Testing Instructions

Run the automated checks after any change, then the manual matrix for the areas you touched.

## Automated Checks (CI gates)

```bash
bats tests/                          # BATS suite, 29 files; fixtures in tests/test_helper.bash
bats tests/cmd_list.bats             # one file; add --filter "name" for one test
shellcheck bin/wtr bin/git-wtr lib/*.sh lib/commands/*.sh adapters/editor/*.sh adapters/ai/*.sh
./scripts/generate-completions.sh --check   # committed completions match the generator
```

These three jobs are exactly what `.github/workflows/lint.yml` runs on every pull request.

## Manual Matrix

```bash
# Basic create/remove
./bin/wtr new test-feature           # folder test-feature
./bin/wtr rm test-feature            # removed

# Branch sanitization
./bin/wtr new feature/auth           # folder feature-auth

# Remote branch (if exists)
./bin/wtr new existing-remote-branch # checks out tracking branch

# Local existing branch
./bin/wtr new existing-local-branch  # reuses local branch

# New branch creation
./bin/wtr new brand-new-feature      # creates branch + worktree

# Machine-readable creation (stdout: path, branch, hook_status records)
./bin/wtr new agent-feature --from HEAD --no-fetch --porcelain

# Force multiple worktrees same branch
./bin/wtr new test-feature --force --name backend   # test-feature-backend

# Editor + AI adapters
./bin/wtr config set wtr.editor.default cursor
./bin/wtr editor test-feature
./bin/wtr config set wtr.ai.default claude
./bin/wtr ai test-feature

# Listing
./bin/wtr list                       # human table
./bin/wtr list --porcelain           # path\tbranch\tstatus

# Navigation
cd "$(./bin/wtr go 1)"               # repo root
cd "$(./bin/wtr go test-feature)"    # worktree path

# Pull request worktrees (needs gh) and PR-based cleanup
./bin/wtr pr 123                     # folder from the PR head branch
./bin/wtr clean --merged --dry-run   # preview, remove nothing

# .wtrconfig trust (hooks and defaults stay inert until approved)
./bin/wtr trust

# Config commands
./bin/wtr config set wtr.editor.default cursor
./bin/wtr config get wtr.editor.default
./bin/wtr config set wtr.editor.default vscode --global
./bin/wtr config unset wtr.editor.default

# Copy patterns
git config --add wtr.copy.include "**/.env.example"
git config --add wtr.copy.exclude "**/.env"
./bin/wtr new test-copy              # copies example, not real env

# Hooks
git config --add wtr.hook.postCreate "echo 'Created!' > /tmp/wtr-test"
./bin/wtr new test-hooks             # /tmp/wtr-test exists
git config --add wtr.hook.postRemove "echo 'Removed!' > /tmp/wtr-removed"
./bin/wtr rm test-hooks              # /tmp/wtr-removed exists
```

## Installation & Environment Verification

```bash
git --version
./bin/wtr doctor      # checks repo, adapters, platform
./bin/wtr adapter     # lists editors + AI tools
```

## Adapter Sourcing Checks

```bash
bash -c 'source adapters/editor/nano.sh && editor_can_open && echo OK'
bash -c 'source adapters/ai/claude.sh && ai_can_start && echo OK'
```

## Debugging Toolkit

```bash
bash -x ./bin/wtr new test-feature   # global trace
WTR_DEBUG=1 ./bin/wtr new test-feature  # file:line:function on an unguarded failure
set -x; create_worktree ...; set +x  # scoped trace inside function
declare -f resolve_target            # confirm function loaded
echo "DEBUG worktree_path=$worktree_path" >&2  # variable inspection
```

## Success Criteria

- `bats tests/`, ShellCheck, and `./scripts/generate-completions.sh --check` pass.
- All commands exit 0 (except intentional failures) and produce expected side-effects.
- No unquoted path errors; spaces handled.
- Hooks run only once per creation/removal.
- `new --porcelain` emits only stable records on stdout; progress and hook output use stderr.
- `list --porcelain` stable for scripting.

## When Adding Features

- Add or extend the matching `tests/cmd_<name>.bats`; BATS covers behavior, this matrix covers what BATS cannot (editors, AI tools, shell integration).
- Extend this matrix minimally (keep concise).
- Prefer adding under relevant section (e.g. new flag under create/remove).
