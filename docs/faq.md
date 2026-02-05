# wtr FAQ - Frequently Asked Questions

> Common questions answered. If you can't find your answer here, check the [Troubleshooting Guide](troubleshooting.md) or [full documentation index](INDEX.md).

---

## ❓ General Questions

### What is wtr?
**wtr** (Git Worktree Runner) is a command-line tool that makes Git worktrees practical for everyday development. It automates:
- Creating and managing multiple Git worktrees
- Smart file copying to new worktrees
- Integration with your favorite editor and AI tools
- Running commands across worktrees

See: [README.md](../README.md)

### Why use wtr instead of just Git worktrees?
Raw Git worktrees require manual setup for each one. **wtr** automates the tedious parts:
- ✅ Automatic file copying (.env, config files, etc.)
- ✅ Pre/post creation hooks for setup/cleanup
- ✅ Direct editor/AI tool integration
- ✅ Simple command-line interface
- ✅ Configuration presets for different workflows

### Is wtr free?
Yes! wtr is open-source under the [MIT License](../LICENSE).

### What platforms does wtr support?
- ✅ macOS (10.14+)
- ✅ Linux (Ubuntu 18.04+, CentOS 7+, Fedora, etc.)
- ✅ Windows (via WSL2 or Git Bash)

See: [Platform Support Guide](platforms.md)

### What do I need to use wtr?
Minimum requirements:
- **Bash 3.2+** (or later)
- **Git 2.5+** (for worktree support)
- Most system utilities (find, grep, sed, etc.)

Optional:
- **jq** (for JSON parsing, recommended)
- **timeout** command (for operation timeouts)

---

## 🚀 Getting Started

### How do I install wtr?
Choose your platform:

**macOS** (with Homebrew):
```bash
brew install neopilot-ai/tap/wtr
```

**Linux**:
```bash
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
```

**Manual** (any platform):
```bash
git clone https://github.com/neopilot-ai/wtr.git
./wtr/install.sh
```

See: [Setup Guide](setup.md)

### How do I create my first worktree?
```bash
wtr new feature-branch
```

This creates a worktree for the `feature-branch` branch. See: [Basic Workflow](basic-workflow.md)

### How do I access the worktree after creating it?
Use `wtr go` to get the path:
```bash
cd $(wtr go feature-branch)
```

Or create an alias:
```bash
alias wc='cd $(wtr go'
```

### Where do worktrees get created?
By default, in a `worktrees/` subdirectory of your repo. You can customize this:
```bash
git config wtr.directory ~/work/worktrees
```

See: [Configuration Guide](configuration.md)

---

## 📋 Usage Questions

### How do I see all my worktrees?
```bash
wtr list
```

Or with more details:
```bash
wtr list --long
```

### How do I remove a worktree?
```bash
wtr remove <id>
```

This deletes the worktree directory and cleans up Git tracking.

### How do I run commands in a worktree without switching to it?
```bash
wtr run <id> npm test
wtr run <id> python -m pytest
wtr run <id> git log --oneline
```

### Can I open a worktree directly in my editor?
Yes! If you've configured your editor:
```bash
wtr editor <id>
```

Supports: VS Code, Cursor, Vim, Emacs, Sublime, and more.

See: [Editor Integration](adapters.md#editors)

### Can I use an AI assistant in my worktree?
Yes! If you've configured an AI tool:
```bash
wtr ai <id>
```

Supports: Claude, OpenCode, Aider, GitHub Copilot, and more.

See: [AI Tool Integration](adapters.md#ai-tools)

---

## ⚙️ Configuration Questions

### Why would I use configuration presets?
Presets let you define different setups for different workflows. Example:

```bash
# Define presets
git config wtr.preset.feature.branch main
git config wtr.preset.feature.copyFiles ".env"
git config wtr.preset.hotfix.branch production
git config wtr.preset.hotfix.copyFiles ".env" "secrets.env"

# Use presets
wtr new feature-name -P feature
wtr new patch-123 -P hotfix
```

Without presets, you'd need to specify all options each time.

See: [Configuration Guide](configuration.md)

### How do I copy files automatically when creating a worktree?
Three methods:

**Method 1: File pattern (.worktreeinclude)**
```bash
echo ".env" >> .worktreeinclude
echo "config.local.*" >> .worktreeinclude
```

**Method 2: Git config**
```bash
git config --add wtr.copy ".env"
git config --add wtr.copy "config.local.*"
```

**Method 3: Preset**
```bash
git config wtr.preset.dev.copy ".env"
git config wtr.preset.dev.copy ".npmrc"
```

See: [File Copying Guide](configuration.md#copying-files)

### Can I run setup scripts when creating a worktree?
Yes! Use hooks. Create these files:

```bash
.wtr/hooks/postCreate      # Runs in new worktree after creation
.wtr/hooks/preRemove       # Runs before deletion
```

Example: [Example Hooks](../examples/hooks/)

### How do I use different configurations for different Git branches?
Use presets or check the branch in your postCreate hook:

```bash
# In .wtr/hooks/postCreate
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" == "main" ]]; then
    npm run build
elif [[ "$BRANCH" == hotfix* ]]; then
    npm run build:prod
fi
```

---

## 🎯 Workflow Questions

### How do I work on multiple features simultaneously?
This is wtr's main use case! Create a worktree for each feature:

```bash
wtr new feature-1
wtr new feature-2
wtr new feature-3

wtr list                    # See all your worktrees
cd $(wtr go feature-1)      # Switch between them
```

Each worktree has its own branch, dependencies, and state.

See: [Feature Branch Workflow](workflows/feature-branches.md)

### How do I review PRs using wtr?
Create a temporary worktree for the PR branch:

```bash
git fetch origin pull/123/head:pr-123
wtr new pr-123
cd $(wtr go pr-123)
npm test        # or your test command
```

See: [PR Review Workflow](workflows/pr-review.md)

### How does wtr help with hotfixes?
Create hotfixes without context-switching:

```bash
# In your main feature work
wtr new hotfix-123

# In the hotfix worktree
cd $(wtr go hotfix-123)
# Fix the issue, test, commit, push

# Back to your feature work
cd $(wtr go feature-456)
```

See: [Hotfix Workflow](workflows/hotfix.md)

### Can I use wtr with monorepos?
Yes! Special considerations for monorepos:

```bash
# Monorepo with Turborepo/Nx
git config wtr.copy "pnpm-lock.yaml"
git config wtr.hook.postCreate "pnpm install"

wtr new feature-new-package
cd $(wtr go feature-new-package)
turbo run test              # or 'nx test'
```

See: [Monorepo Guide](monorepos.md)

---

## 🔧 Troubleshooting & Support

### wtr command not found
**Cause**: wtr not installed or not in PATH

**Solution**:
```bash
# Reinstall
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash

# Check installation
which wtr
```

### Worktree creation fails
**Cause**: Various reasons (permission errors, git issues, etc.)

**First step**: Run diagnostics
```bash
wtr doctor
```

Then see: [Troubleshooting Guide](troubleshooting.md)

### Files not copying to new worktree
**Causes**: 
- `.worktreeinclude` file not found
- Pattern doesn't match files
- Permission issues

**Debug**:
```bash
# Check what wtr will copy
cat .worktreeinclude

# Check if files exist
ls -la .env .npmrc

# Try with verbose output
wtr new branch-name -v
```

See: [File Copying Guide](configuration.md#copying-files)

### Editor/AI tool not opening
**Cause**: Editor not configured or not installed

**Solution**:
```bash
# Check configuration
git config wtr.editor
git config wtr.ai

# Run diagnostics
wtr doctor

# Set up editor
git config wtr.editor vim      # or: vscode, cursor, emacs, etc.
```

See: [Editor Integration](adapters.md)

### Why is my hook script not running?
**Causes**:
- Script not executable
- Script has syntax errors
- Wrong permissions
- Script name misspelled

**Debug**:
```bash
# Make executable
chmod +x .wtr/hooks/postCreate

# Check for errors
bash -n .wtr/hooks/postCreate    # Syntax check
```

### How do I check everything is working?
```bash
wtr doctor
```

This checks Git installation, worktree support, required tools, and configuration.

### How do I get help?
1. Check [FAQ](faq.md) (you are here!)
2. See [Quick Reference](quick-reference.md)
3. Read [Troubleshooting Guide](troubleshooting.md)
4. Check [Error Reference Guide](errors.md)
5. Search [Documentation Index](INDEX.md)
6. [Report an issue](https://github.com/neopilot-ai/wtr/issues)

---

## 💻 Developer Questions

### Can I integrate wtr into my CI/CD pipeline?
Yes! Use `wtr run` to execute commands in worktrees:

```bash
# GitHub Actions example
- name: Test all branches
  run: |
    wtr list | while read id; do
      wtr run "$id" npm test
    done
```

See: [CI/CD Integration Guide](guides/devops.md)

### Can I use wtr with AI agents?
Yes! Use `wtr run` to execute commands, or integrate directly:

```bash
# Spawn AI in worktree
wtr ai feature-123 -a claude

# Run command in worktree
wtr run feature-123 git diff
```

See: [AI Agent Integration Guide](guides/ai-agents.md)

### Can I create custom adapters for editors/AI tools?
Yes! See the [Adapter System Guide](adapters.md#creating-custom-adapters) for instructions.

### How do I contribute to wtr?
See: [Contributing Guide](../CONTRIBUTING.md)

---

## 📚 Advanced Questions

### How does wtr handle Git references?
- Creates local branches pointing to remote branches
- Uses Git worktree for isolated development
- Shares main `.git` directory with main repo

### Can I create worktrees for commits, tags, or remote branches?
Yes! Any Git reference works:

```bash
wtr new v1.0.0              # Tag
wtr new origin/main         # Remote branch
wtr new abc123def           # Commit hash
```

### How do I share worktrees with my team?
Worktrees are local to each developer. Share configuration:

```bash
# Commit to repo
git add .wtrconfig .worktreeinclude .wtr/hooks/
git commit -m "Add wtr configuration"
```

Team members get the same setup after pulling.

### Can I have multiple worktrees for the same branch?
Yes, but you need to use different paths:

```bash
wtr new feature-123 -p /path/to/worktree1
wtr new feature-123 -p /path/to/worktree2
```

This is uncommon and generally not recommended.

### How much disk space do worktrees use?
Each worktree shares the Git object database with the main repo. Typical overhead is 10-20% of the main repo size for a worktree (just code/build folders, not .git directory).

---

## 🚨 Performance & Optimization

### My worktree operations are slow. How do I optimize?
See: [Performance Guide](performance.md)

Common optimizations:
1. Use `.worktreeinclude` to avoid copying unnecessary files
2. Use `wtr.ignorePatterns` to exclude large directories
3. Run `git gc` periodically
4. Use fast storage (SSD) for worktrees

### How do I delete all old worktrees quickly?
```bash
# Dangerous! Only if you're sure
wtr list | xargs -I {} wtr remove {}

# Safer version with confirmation
wtr list | while read id; do
  read -p "Remove $id? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    wtr remove "$id"
  fi
done
```

---

## 📞 Contact & Support

### Didn't find your answer?

1. **Search documentation**: [Full docs](INDEX.md)
2. **Check troubleshooting**: [Troubleshooting guide](troubleshooting.md)
3. **Report issue**: [GitHub Issues](https://github.com/neopilot-ai/wtr/issues)
4. **Ask community**: [GitHub Discussions](https://github.com/neopilot-ai/wtr/discussions)

---

**Last Updated**: February 2026  
**Have a question?** [Open a discussion](https://github.com/neopilot-ai/wtr/discussions)
