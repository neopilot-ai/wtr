# Advanced Usage Guide

> Advanced workflows and patterns for wtr

[Back to README](../README.md) | [Configuration](configuration.md) | [Troubleshooting](troubleshooting.md)

---

## Table of Contents

- [Repository Scoping](#repository-scoping)
- [Working with Multiple Branches](#working-with-multiple-branches)
- [Working with Multiple Repositories](#working-with-multiple-repositories)
- [Custom Workflow Scripts](#custom-workflow-scripts)
- [CI/CD Integration](#cicd-integration)
- [Multiple Worktrees Same Branch](#multiple-worktrees-same-branch)
- [Parallel AI Development](#parallel-ai-development)
- [Sparse-Checkout Inheritance](#sparse-checkout-inheritance)

---

## Repository Scoping

**wtr is repository-scoped** - each git repository has its own independent set of worktrees:

- Run `git wtr` commands from within any git repository
- Worktree folders are named after their branch names
- Each repo manages its own worktrees independently
- Switch repos with `cd`, then run `git wtr` commands for that repo

---

## Working with Multiple Branches

```bash
# Terminal 1: Work on feature
git wtr new feature-a
git wtr editor feature-a

# Terminal 2: Review PR
git wtr new pr/123
git wtr editor pr/123

# Terminal 3: Navigate to main branch (repo root)
wtr cd 1                  # With shell integration (git wtr init)
cd "$(git wtr go 1)"     # Without shell integration
```

---

## Working with Multiple Repositories

Each repository has its own independent set of worktrees. Switch repos with `cd`:

```bash
# Frontend repo
cd ~/GitHub/frontend
git wtr list
# BRANCH          PATH
# main [main]     ~/GitHub/frontend
# auth-feature    ~/GitHub/frontend-worktrees/auth-feature
# nav-redesign    ~/GitHub/frontend-worktrees/nav-redesign

git wtr editor auth-feature      # Open frontend auth work
git wtr ai nav-redesign          # AI on frontend nav work

# Backend repo (separate worktrees)
cd ~/GitHub/backend
git wtr list
# BRANCH          PATH
# main [main]     ~/GitHub/backend
# api-auth        ~/GitHub/backend-worktrees/api-auth
# websockets      ~/GitHub/backend-worktrees/websockets

git wtr editor api-auth          # Open backend auth work
git wtr ai websockets            # AI on backend websockets

# Switch back to frontend
cd ~/GitHub/frontend
git wtr editor auth-feature      # Opens frontend auth
```

**Key point:** Each repository has its own worktrees. Use branch names to identify worktrees.

---

## Custom Workflow Scripts

Create a `.wtr-setup.sh` in your repo:

```bash
#!/bin/sh
# .wtr-setup.sh - Project-specific git wtr configuration

git wtr config set wtr.worktrees.prefix "dev-"
git wtr config set wtr.editor.default cursor

# Copy configs
git wtr config add wtr.copy.include ".env.example"
git wtr config add wtr.copy.include "docker-compose.yml"

# Setup hooks
git wtr config add wtr.hook.postCreate "docker-compose up -d db"
git wtr config add wtr.hook.postCreate "npm install"
git wtr config add wtr.hook.postCreate "npm run db:migrate"
```

Then run: `sh .wtr-setup.sh`

---

## CI/CD Integration

Perfect for CI/CD or scripts with non-interactive mode:

```bash
# Create worktree without prompts
git wtr new ci-test --yes --no-copy

# Remove without confirmation
git wtr rm ci-test --yes --delete-branch
```

**Flags for automation:**

| Flag              | Description                          |
| ----------------- | ------------------------------------ |
| `--yes`           | Skip all confirmation prompts        |
| `--no-copy`       | Skip file copying (faster)           |
| `--no-fetch`      | Skip git fetch (use existing refs)   |
| `--no-hooks`      | Skip post-create hooks               |
| `--delete-branch` | Delete branch when removing worktree |

---

## Multiple Worktrees Same Branch

> [!TIP]
> Git normally prevents checking out the same branch in multiple worktrees to avoid conflicts. `git wtr` supports bypassing this safety check with `--force` and `--name` flags.

**Use cases:**

- Splitting work across multiple AI agents on one feature
- Testing same branch in different environments/configs
- Running parallel CI/build processes
- Debugging without disrupting main worktree

**Risks:**

- Concurrent edits in multiple worktrees can cause conflicts
- Easy to lose work if not careful
- Git's safety check exists for good reason

### Using `--force` with `--name` (required)

```bash
# Create multiple worktrees for same branch with descriptive names
git wtr new feature-auth                          # Main worktree: feature-auth/
git wtr new feature-auth --force --name backend   # Creates: feature-auth-backend/
git wtr new feature-auth --force --name frontend  # Creates: feature-auth-frontend/
git wtr new feature-auth --force --name tests     # Creates: feature-auth-tests/

# All worktrees are on the same 'feature-auth' branch
# The --name flag is required with --force to distinguish worktrees
```

### Best Practices

- Always provide a descriptive `--name` (backend, frontend, tests, ci, etc.)
- Only edit files in one worktree at a time
- Commit/stash changes before switching worktrees
- Ideal for parallel AI agents working on different parts of one feature
- Use `git wtr list` to see all worktrees and their branches

---

## Parallel AI Development

Run multiple AI agents on the same feature branch, each working on different parts:

```bash
# Terminal 1: Backend work
git wtr new feature-auth --force --name backend
git wtr ai feature-auth-backend -- --message "Implement API endpoints"

# Terminal 2: Frontend work
git wtr new feature-auth --force --name frontend
git wtr ai feature-auth-frontend -- --message "Build UI components"

# Terminal 3: Tests
git wtr new feature-auth --force --name tests
git wtr ai feature-auth-tests -- --message "Write integration tests"

# All agents commit to the same feature-auth branch
```

**Workflow tips:**

1. **Divide by directory** - Have each agent focus on non-overlapping directories (e.g., `src/api/`, `src/components/`, `tests/`)
2. **Frequent commits** - Each agent should commit frequently to avoid conflicts
3. **Pull before push** - Have agents pull changes from others before pushing
4. **Use descriptive names** - Make it clear what each worktree is for

---

## Sparse-Checkout Inheritance

When working in a large monorepo, a base worktree often uses [sparse-checkout](https://git-scm.com/docs/git-sparse-checkout) to materialize only a slice of the tree. `wtr` carries that slice into the worktrees you branch off it, so feature worktrees stay lean instead of exploding into the full repo.

```bash
# my-app is a sparse worktree checking out only apps/my-app + packages.
# A feature branch off it inherits the same cone automatically:
git wtr new my-app-feature-xyz --from my-app

# The new worktree contains only the inherited sparse slice:
ls "$(git wtr go my-app-feature-xyz)"
git -C "$(git wtr go my-app-feature-xyz)" sparse-checkout list

# Opt out for a single command (full checkout):
git wtr new big-refactor --from my-app --no-sparse
```

**How it works:**

- On Git 2.36+, wtr inspects the worktree holding the base ref (`--from`, falling back to the current worktree). If it has valid sparse-checkout settings, wtr creates the new worktree from that source so Git copies its patterns and per-worktree config before checkout — the full tree is never written to disk.
- Git 2.17–2.35 keeps the existing full-checkout behavior. An explicit `--sparse` request prints a warning that inheritance requires Git 2.36+.
- Controlled by `wtr.sparse.inherit` (default on). Use `--sparse` / `--no-sparse` to override per command.
- Full-checkout repositories are unaffected — they always get a full checkout.

> [!NOTE]
> Sparse-checkout is per-worktree, not per-branch. Inheriting "from `my-app`" copies the live sparse settings and worktree-specific Git config of the `my-app` worktree, not anything stored on the branch itself. If the same branch is checked out more than once, wtr prefers the current matching worktree; otherwise it warns and creates a full checkout rather than choosing arbitrarily.

---

[Back to README](../README.md) | [Configuration](configuration.md) | [Troubleshooting](troubleshooting.md)
