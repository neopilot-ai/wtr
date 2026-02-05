# wtr Basic Workflow - Your First Worktree

> Learn how to use wtr in 5 minutes. This guide covers the essential workflow for most developers.

---

## ⏱️ Time Required
- **Install**: 2 minutes
- **First worktree**: 3 minutes
- **Total**: ~5 minutes

**Prerequisites**: 
- Git 2.5+ (`git --version`)
- Bash 3.2+ (`bash --version`)
- A Git repository to work with

---

## Step 1: Install wtr (2 minutes)

### Option A: macOS with Homebrew (easiest)
```bash
brew install neopilot-ai/tap/wtr
```

### Option B: Linux using curl
```bash
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
```

### Option C: Manual (any platform)
```bash
git clone https://github.com/neopilot-ai/wtr.git
./wtr/install.sh
```

### Verify Installation
```bash
wtr --version
wtr doctor
```

The `wtr doctor` command will check that everything is working.

**See more**: [Setup Guide](setup.md)

---

## Step 2: Create Your First Worktree (1 minute)

Navigate to your Git repository and create a worktree:

```bash
cd ~/projects/my-repo
wtr new feature-awesome
```

This:
1. ✅ Creates a new branch called `feature-awesome`
2. ✅ Creates a worktree in `worktrees/feature-awesome/`
3. ✅ Copies any configuration files (.env, etc.)
4. ✅ Runs any setup hooks you've defined

---

## Step 3: Navigate to Your Worktree (1 minute)

Get the path to your worktree and navigate there:

```bash
cd $(wtr go feature-awesome)
```

**Tip**: Create an alias for easier navigation:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias wc='cd $(wtr go'

# Now use it:
wc feature-awesome)
```

You're now inside the `feature-awesome` worktree! Each worktree is completely isolated:
- ✅ Separate branch
- ✅ Separate node_modules/dependencies
- ✅ Separate working directory
- ⚠️ Shares main `.git` directory (more efficient)

---

## Step 4: Work Normally

Everything works like a normal Git repository:

```bash
# Make changes
echo "Hello from feature!" > hello.txt

# Commit
git add hello.txt
git commit -m "Add hello.txt"

# Push (optional)
git push origin feature-awesome

# Run tests
npm test
# or: python -m pytest
# or: your test command
```

You can:
- ✅ Edit files
- ✅ Run tests
- ✅ Commit changes
- ✅ Push to remote
- ✅ Install dependencies
- ✅ All normal Git operations

---

## Step 5: Work on Another Feature (1 minute)

Create another worktree for a different feature **without leaving your current one**:

```bash
# Still in feature-awesome worktree? No problem!
wtr new feature-other
cd $(wtr go feature-other)

# Now you're in feature-other worktree
# Make changes, test, commit...
```

This is the power of wtr! You can:
- Have multiple branches checked out simultaneously
- Switch between them instantly
- Run tests in each independently
- Work on multiple features at once

**Check all your worktrees**:
```bash
wtr list
```

---

## Step 6: When You're Done (1 minute)

Remove a worktree when finished:

```bash
wtr remove feature-awesome
```

This:
- ✅ Deletes the worktree directory
- ✅ Cleans up Git tracking
- ✅ Saves disk space
- ⚠️ Saves your commits (they're on the branch, not the worktree)

---

## 📋 Complete First Day Workflow

```bash
# Morning: Start two features
wtr new feature-login             # Feature 1
wtr new feature-settings          # Feature 2

# Work on first feature
cd $(wtr go feature-login)
npm install
# Make changes, commit...

# Switch to second feature
cd $(wtr go feature-settings)
npm install
# Make changes, commit...

# Check your work
wtr list

# Evening: Wrap up
wtr run feature-login npm test    # Test without switching
wtr editor feature-login           # Open in editor
wtr ai feature-settings            # Start AI assistant

# When done
wtr remove feature-login
wtr remove feature-settings
```

---

## 🎯 Common Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `wtr new <branch>` | Create worktree |
| `wtr go <id>` | Get path (use in `cd $(wtr go <id>)`) |
| `wtr list` | List all worktrees |
| `wtr run <id> <cmd>` | Run command without switching |
| `wtr editor <id>` | Open in your editor |
| `wtr ai <id>` | Start AI assistant |
| `wtr remove <id>` | Delete worktree |

**Full reference**: [Quick Reference Card](quick-reference.md)

---

## 🎓 Next Steps

### Ready to go deeper?

1. **Customize configuration**: [Configuration Guide](configuration.md)
   - Set default editor
   - Configure automatic file copying
   - Define workflows with presets

2. **Set up automation**: [Hooks Guide](hooks.md)
   - Run setup scripts automatically
   - Install dependencies on create
   - Run cleanup on remove

3. **Integrate tools**: [Editor & AI Integration](adapters.md)
   - Use your favorite editor
   - Start AI assistants instantly
   - Customize integrations

4. **Learn advanced workflows**: [Advanced Usage](advanced-usage.md)
   - Team collaboration patterns
   - Monorepo workflows
   - CI/CD integration

---

## ❓ Troubleshooting

### wtr command not found
```bash
# Check installation
which wtr

# Reinstall if needed
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
```

### Git version too old
```bash
# Check version
git --version

# Need 2.5+. Update:
brew upgrade git              # macOS
sudo apt-get upgrade git      # Ubuntu/Debian
```

### Worktree creation fails
```bash
# Comprehensive diagnostics
wtr doctor

# Check Git is configured
git config -l | head -20
```

**More help**: [Troubleshooting Guide](troubleshooting.md)

---

## 💡 Pro Tips

### 1. Create Quick Aliases
```bash
# In ~/.bashrc or ~/.zshrc

# Jump to worktree (with your custom command)
alias wc='cd $(wtr go'

# List worktrees in a prettier format
function wl() {
  echo "Worktrees:"
  wtr list | while read id; do
    path=$(wtr go "$id")
    echo "  $id → $path"
  done
}

# Create and jump to worktree
function wtn() {
  wtr new "$1" && cd "$(wtr go "${1##*/}")"
}
```

### 2. Use with Other Tools
```bash
# Open in VS Code
wtr editor my-feature

# Start coding with Claude
wtr ai my-feature -a claude

# Run tests
wtr run my-feature npm test
```

### 3. Leverage Git Integration
```bash
# Create feature branch and worktree together
git checkout -b feature-new && wtr new feature-new

# Push from worktree
cd $(wtr go feature-new)
git push origin feature-new
```

---

## 🚀 Common Workflows

### Feature Development Workflow
```bash
# Create feature
wtr new user-auth

# Work on it
cd $(wtr go user-auth)
npm install
# Edit files, commit...

# Push and open PR
git push -u origin user-auth
# (Open PR in GitHub/GitLab/etc.)

# Meanwhile, work on something else
wtr new api-docs
cd $(wtr go api-docs)

# Test feature before merging
wtr run user-auth npm test

# Cleanup when done
wtr remove user-auth
```

### Review & Test Workflow
```bash
# Fetch PR branch
git fetch origin pull/789/head:pr-789

# Create worktree to review
wtr new pr-789
cd $(wtr go pr-789)

# Review & test
npm install
npm test

# Done
wtr remove pr-789
```

### Parallel Task Workflow
```bash
# Multiple features in parallel
wtr new feature-a
wtr new feature-b
wtr new feature-c

# Jump around
cd $(wtr go feature-a)  # Work here
cd $(wtr go feature-b)  # Then here
cd $(wtr go feature-c)  # And here

# Test all the way
wtr run feature-a npm test
wtr run feature-b npm test
wtr run feature-c npm test
```

---

## 📊 Understanding the Structure

After creating a worktree, your repo looks like:

```
my-repo/
├── .git/                      ← Shared Git directory
├── src/
├── package.json
├── .wtrconfig                 ← wtr configuration
├── .worktreeinclude           ← Files to copy
├── .wtr/
│   └── hooks/
│       ├── postCreate         ← Runs after creation
│       └── preRemove          ← Runs before deletion
└── worktrees/
    ├── feature-awesome/       ← Your worktree
    │   ├── src/
    │   ├── package.json
    │   └── node_modules/
    └── feature-other/
        ├── src/
        ├── package.json
        └── node_modules/
```

Each worktree:
- 📁 Has its own directory
- 🌿 Has its own branch
- 📦 Has its own node_modules/dependencies
- 🔗 Shares the main `.git` directory
- 💾 More efficient than full clones

---

## ✅ Success Checklist

After following this guide, you should be able to:

- ✅ Install wtr
- ✅ Create a worktree
- ✅ Navigate to it
- ✅ Make changes and commit
- ✅ Work on multiple features simultaneously
- ✅ Run commands in any worktree
- ✅ Open worktrees in your editor
- ✅ Remove worktrees when done

**N﻿ext step**: Explore [Configuration Guide](configuration.md) to customize your setup!

---

## 🆘 Need Help?

1. **Quick answers**: [FAQ](faq.md)
2. **Specific error**: [Error Guide](errors.md)
3. **Common issues**: [Troubleshooting](troubleshooting.md)
4. **All guides**: [Documentation Index](INDEX.md)
5. **Report problem**: [GitHub Issues](https://github.com/neopilot-ai/wtr/issues)

---

**Ready to dive deeper?**
- Customize: [Configuration Guide](configuration.md)
- Automate: [Hooks Guide](hooks.md)
- Integrate: [Adapters Guide](adapters.md)
- Advanced: [Advanced Usage](advanced-usage.md)

**Happy worktreeing!** 🎉
