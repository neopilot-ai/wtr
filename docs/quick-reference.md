# wtr Quick Reference Card

> Save this page or print it for quick command lookup while working

## 🎯 Most Common Commands

```bash
wtr new <branch>              # Create new worktree
wtr list                      # Show all worktrees
wtr go <id>                   # Get worktree path (for cd)
wtr remove <id>               # Delete worktree
wtr run <id> <command>        # Execute command in worktree
```

---

## 📋 Complete Command Reference

### Creating & Listing Worktrees

| Command | Purpose |
|---------|---------|
| `wtr new <branch>` | Create worktree for branch |
| `wtr new <branch> -p <path>` | Create at specific path |
| `wtr new <branch> -P <preset>` | Use configuration preset |
| `wtr list` | List all worktrees |
| `wtr list --long` | List with details |

### Navigation & Execution

| Command | Purpose |
|---------|---------|
| `wtr go <id>` | Print worktree path (use in shell: `cd $(wtr go <id>)`) |
| `wtr run <id> <cmd>` | Execute command in worktree |
| `wtr editor <id>` | Open worktree in editor |
| `wtr ai <id>` | Start AI assistant in worktree |

### Clean Up

| Command | Purpose |
|---------|---------|
| `wtr remove <id>` | Delete worktree |
| `wtr remove <id> --force` | Force deletion (skip safety checks) |

### Configuration

| Command | Purpose |
|---------|---------|
| `wtr config get <key>` | Get configuration value |
| `wtr config set <key> <value>` | Set configuration |
| `wtr config add <key> <value>` | Add list item |
| `wtr doctor` | Check system setup |

---

## 🔑 Useful Aliases

Add these to your shell config (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Go to worktree directory
alias wc='cd $(wtr go'

# Create and go to worktree
function wtn() {
  wtr new "$1" && cd "$(wtr go "${1##*/}")"
}

# Quick editor in worktree
alias wte='wtr editor'

# Quick run command in worktree
alias wtr='wtr run'
```

---

## ⚙️ Key Configuration Options

### Most Common Configs

```bash
# Set default editor
git config wtr.editor vim           # or: vscode, cursor, emacs, etc.

# Set default AI tool
git config wtr.ai claude            # or: opencode, aider, etc.

# Set working directory
git config wtr.directory ~/work     # Where worktrees go

# Set file copy pattern
git config wtr.copy ".env" "*.local"

# Create preset (named configuration)
git config wtr.preset.feature.branch main
git config wtr.preset.feature.copyFiles ".env"
```

### See All Options
Full reference: [Configuration Guide](configuration.md)

---

## 💡 Common Patterns

### Create & Open in One Step
```bash
wtr new my-feature && wtr editor $(wtr go my-feature | tail -1)
```

### Run Tests in Worktree
```bash
wtr run my-feature npm test
wtr run my-feature python -m pytest
```

### List and Filter Worktrees
```bash
wtr list | grep feature           # Find feature worktrees
wtr list | grep -E 'fix|hotfix'   # Find fixes
```

### Bulk Operations
```bash
# Remove all old worktrees
wtr list | grep old | while read id; do wtr remove "$id"; done
```

---

## 🎨 Editor Integration

### Open Worktree in Editor
```bash
wtr editor <id>              # Opens in default editor
wtr editor <id> -e vim       # Force specific editor
```

### Supported Editors
- **VS Code**: `code`, `vscode`
- **Cursor**: `cursor`
- **Vim**: `vim`, `nvim`
- **Sublime**: `sublime`
- **Emacs**: `emacs`
- **Nano**: `nano`
- **PyCharm**: `pycharm`
- **IntelliJ IDEA**: `idea`
- **WebStorm**: `webstorm`
- **Atom**: `atom` (legacy)
- **Zed**: `zed`

---

## 🤖 AI Integration

### Use AI in Worktree
```bash
wtr ai <id>                  # Opens with default AI
wtr ai <id> -a claude        # Force specific AI tool
```

### Supported AI Tools
- **Claude**: `claude`
- **OpenCode**: `opencode`
- **Aider**: `aider`
- **GitHub Copilot**: `copilot`
- **Cursor**: `cursor`
- **Continue**: `continue`
- **Codeium Windsurf**: `windsurf`

---

## 🔧 Troubleshooting

### Common Issues Quick Fix

| Problem | Solution |
|---------|----------|
| Worktree not found | Use `wtr list` to see available IDs |
| Permission denied | Check Git worktree permissions: `ls -la .git/worktrees/` |
| Editor not opening | Run `wtr doctor` and check editor setup |
| Files not copied | Verify `.worktreeinclude` or `wtr.copy` config |

### Diagnostic Command
```bash
wtr doctor    # Comprehensive system check
```

More help: [Troubleshooting Guide](troubleshooting.md)

---

## 📁 Project Structure

### Typical Worktree Directory
```
repo/
├── .git/                     # Main repo git directory
├── .wtrconfig               # wtr configuration
├── .worktreeinclude         # Files to copy on create
├── .wtr/
│   └── hooks/               # Pre/post hooks
├── worktrees/
│   ├── feature-1/           # Worktree 1
│   ├── feature-2/           # Worktree 2
│   └── readme-update/       # Worktree 3
```

---

## 🔗 File Copy & Hooks

### Copy Files When Creating Worktree
```bash
# Method 1: .worktreeinclude file
echo ".env" >> .worktreeinclude
echo "*.local" >> .worktreeinclude

# Method 2: Git config
git config --add wtr.copy ".env"
git config --add wtr.copy "config.local.*"

# Method 3: .wtrconfig file
[wtr]
copy = .env
copy = *.local
```

### Run Scripts on Worktree Create
```bash
.wtr/
  hooks/
    preCreate       # Runs before creation
    postCreate      # Runs in new worktree after creation
    preRemove       # Runs before deletion
    postRemove      # Runs after deletion
```

Example: [hooks/](../examples/hooks/)

---

## 📊 Useful One-Liners

```bash
# Count worktrees
wtr list | wc -l

# Find oldest worktree
wtr list | head -20

# List worktree paths
wtr list | while read id; do echo $(wtr go "$id"); done

# Total disk usage of worktrees
du -sh $(wtr list | xargs -I {} wtr go {})

# Kill all worktrees
wtr list | xargs -I {} wtr remove {}

# Worktrees with feature branches
git branch | grep feature | while read b; do wtr new "$b"; done
```

---

## 🎓 Next Steps

- **Getting started**: [Basic Workflow](basic-workflow.md)
- **All options**: [Configuration Guide](configuration.md)
- **Advanced usage**: [Advanced Usage](advanced-usage.md)
- **Troubleshooting**: [Troubleshooting Guide](troubleshooting.md)
- **Full docs**: [Documentation Index](INDEX.md)

---

## 🔍 Quick Search

**I want to...**
- Create a worktree → Start with `wtr new <branch>`
- Find all worktrees → Use `wtr list`
- Open in editor → Try `wtr editor <id>`
- Run tests → Use `wtr run <id> <command>`
- Get worktree path → Use `wtr go <id>`
- Configure defaults → Edit `.wtrconfig` or use `git config`
- Fix a problem → See [Troubleshooting](troubleshooting.md)

---

**Print this page** or bookmark it for quick reference while working.

For complete guides, see: [Documentation Index](INDEX.md)
