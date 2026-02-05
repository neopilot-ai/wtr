# wtr Setup Guide - Installation & Configuration

> Get wtr up and running on your system with step-by-step instructions.

---

## 📋 Prerequisites

Before installing wtr, ensure you have:

### Required
- **Git 2.5 or later** (for worktree support)
  ```bash
  git --version    # Check version
  ```
- **Bash 3.2 or later** (or zsh, fish, etc.)
  ```bash
  bash --version   # Check version
  ```

### Recommended
- **jq** (for JSON parsing)
  ```bash
  jq --version     # Check if installed
  ```
- **timeout** command (for operation timeouts)
  ```bash
  timeout --version
  ```

### Optional
- Your favorite code editor (VS Code, Vim, etc.)
- AI assistant key (Claude, ChatGPT, etc.)

---

## 🚀 Installation by Platform

### macOS - Homebrew (Recommended)

**Step 1**: Add the tap
```bash
brew tap neopilot-ai/tap
```

**Step 2**: Install wtr
```bash
brew install wtr
```

**Step 3**: Verify installation
```bash
wtr --version
wtr doctor
```

### macOS - Manual Installation

```bash
# Clone repository
git clone https://github.com/neopilot-ai/wtr.git
cd wtr

# Run installer
./install.sh

# Add to PATH (if not already done)
export PATH="$HOME/.local/bin:$PATH"    # Add to ~/.bashrc or ~/.zshrc

# Verify
wtr --version
```

---

### Linux - Using curl (Recommended)

**Step 1**: Download and install
```bash
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
```

**Step 2**: Update PATH (if needed)
```bash
# Add to ~/.bashrc or ~/.zshrc if not in PATH
export PATH="$HOME/.local/bin:$PATH"
```

**Step 3**: Verify installation
```bash
wtr --version
wtr doctor
```

### Linux - Package Manager

**Ubuntu/Debian**:
```bash
# Manual installation method above, or
# Soon: apt install wtr
```

**Fedora/CentOS/RHEL**:
```bash
# Manual installation method above
```

**Arch Linux**:
```bash
# AUR: yay -S wtr-git
```

### Linux - Manual Installation

```bash
# Clone the repository
git clone https://github.com/neopilot-ai/wtr.git
cd wtr

# Run installer
./install.sh

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Make permanent (add to ~/.bashrc or ~/.zshrc)
```

---

### Windows - WSL2 (Recommended)

**Prerequisite**: Windows Subsystem for Linux 2 installed

```bash
# Inside WSL terminal, follow Linux installation above
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash

# Add to WSL ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
```

### Windows - Git Bash

```bash
# Inside Git Bash terminal
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash

# Add to Git Bash ~/.bashrc (usually in C:\Program Files\Git\etc\bash.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

### Windows - PowerShell (Limited Support)

For PowerShell, use WSL2 or Git Bash instead (recommended).

---

## ✅ Post-Installation

### 1. Verify Installation
```bash
wtr --version
wtr doctor
```

The `wtr doctor` command performs comprehensive system checks:
- ✅ Git version compatibility
- ✅ Bash version compatibility
- ✅ Required tools availability
- ✅ Configuration validity
- ✅ Worktree support verification

### 2. Test with First Worktree
```bash
cd ~/projects/any-git-repo
wtr new test-branch
wtr list
```

If this works, wtr is ready to use!

### 3. (Optional) Configure Shell Completion

**Bash**:
```bash
# Add to ~/.bashrc
source ~/.local/share/bash-completion.d/wtr.bash
```

**Zsh**:
```bash
# Add to ~/.zshrc
source ~/.local/share/zsh/site-functions/_wtr
```

**Fish**:
```bash
# Add to ~/.config/fish/config.fish
source ~/.local/share/fish/vendor_completions.d/wtr.fish
```

---

## ⚙️ Initial Configuration

After installation, configure wtr for your workflow:

### 1. Set Default Editor

Choose your preferred editor:

```bash
# VS Code
git config --global wtr.editor vscode

# Vim
git config --global wtr.editor vim

# Emacs
git config --global wtr.editor emacs

# Cursor
git config --global wtr.editor cursor

# Others: nano, nvim, sublime, atom, idea, pycharm, webstorm, zed
```

### 2. Set Default AI Tool (Optional)

```bash
# Claude
git config --global wtr.ai claude

# OpenCode
git config --global wtr.ai opencode

# Aider
git config --global wtr.ai aider

# Others: copilot, cursor, continue, gemini, windsurf
```

### 3. Configure Worktree Directory

Set where worktrees are created:

```bash
# Personal setup
mkdir -p ~/work
git config --global wtr.directory ~/work/worktrees

# Team setup
git config --global wtr.directory /var/workspaces
```

### 4. Configure Files to Copy

Specify files to automatically copy to new worktrees:

```bash
# Copy .env files
git config --add wtr.copy ".env"
git config --add wtr.copy ".env.local"

# Copy config files
git config --add wtr.copy ".npmrc"
git config --add wtr.copy ".python-version"

# Using glob patterns
git config --add wtr.copy "config.*.json"
```

### 5. Test Configuration

```bash
# View configuration
git config -l | grep wtr

# Run diagnostics
wtr doctor
```

---

## 📁 Project-Level Configuration

For project-specific settings, create a `.wtrconfig` file:

```ini
[wtr]
# Project-specific settings
directory = ./worktrees
copy = .env.local
copy = .npmrc

[wtr.preset.frontend]
branch = develop
copyFiles = .env.local

[wtr.preset.mobile]
branch = main
copyFiles = .env.mobile
```

See: [Configuration Guide](configuration.md#project-configuration)

---

## 🔗 Shell Integration

### Add Custom Aliases

Edit your shell configuration (`~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`):

```bash
# Quick jump to worktree
alias wc='cd $(wtr go'

# List worktrees nicely
alias wl='wtr list'

# Create and jump to worktree
function wtn() {
  wtr new "$1" && cd "$(wtr go "${1##*/}")"
}

# Quick commands in worktree
function wr() {
  WORKID="$1"
  shift
  wtr run "$WORKID" "$@"
}
```

### Tab Completion Setup

**Bash**:
```bash
# Add to ~/.bashrc (after installing wtr)
complete -o default -C 'wtr completion' wtr
```

**Zsh**:
```bash
# Add to ~/.zshrc
autoload -Uz compinit && compinit
```

**Fish**:
```bash
# Add to ~/.config/fish/config.fish
source /usr/local/share/fish/vendor_completions.d/wtr.fish
```

---

## 🔧 Uninstalling wtr

### Remove Installation

```bash
# Find location
which wtr    # Note the path

# Remove binary
rm /path/to/wtr

# Remove configuration (optional)
git config --global --unset wtr.directory
git config --global --unset wtr.editor
git config --global --unset wtr.ai

# Remove project config (optional)
rm .wtrconfig                    # Per-project
```

### Clean Up Worktrees

Before uninstalling, clean up existing worktrees:

```bash
# Remove all worktrees
wtr list | while read id; do
  wtr remove "$id"
done

# Or manually
rm -rf worktrees/ .git/worktrees/
```

---

## 🆘 Troubleshooting Installation

### Problem: `wtr: command not found`

**Solution 1**: Check PATH
```bash
# Check if installed
ls -la ~/.local/bin/wtr   # or /usr/local/bin/wtr

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

**Solution 2**: Reinstall
```bash
# Remove old installation
rm -f ~/.local/bin/wtr

# Reinstall
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
```

### Problem: Permission Denied

```bash
# Make executable
chmod +x ~/.local/bin/wtr

# Or reinstall
curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
```

### Problem: Git Version Too Old

```bash
# Check version
git --version    # Need 2.5+

# Update Git
brew upgrade git          # macOS
sudo apt update && sudo apt upgrade git   # Ubuntu/Debian
```

### Problem: Bash Version Incompatible

```bash
# Check version
bash --version    # Need 3.2+

# Update Bash
brew install bash        # macOS
sudo apt install bash    # Ubuntu/Debian
```

### Problem: jq Not Found (Warning)

```bash
# jq is optional but recommended
# Install it:

# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Others
# See: https://jqlang.github.io/jq/
```

### Problem: wtr doctor Fails

```bash
# Run diagnostics
wtr doctor

# If specific tools missing:
# Install Git 2.5+, Bash 3.2+, and jq
# Then run: wtr doctor again
```

---

## 🎯 Next Steps

After installation, explore:

1. **Quick Start**: [Basic Workflow](basic-workflow.md) (5 min)
2. **Learn Commands**: [Quick Reference](quick-reference.md) (5 min)
3. **Configure**: [Configuration Guide](configuration.md) (10 min)
4. **Integrate Tools**: [Adapters Guide](adapters.md) (10 min)
5. **Automate**: [Hooks Guide](hooks.md) (15 min)
6. **Advanced**: [Advanced Usage](advanced-usage.md) (30 min)

---

## 📞 Getting Help

- **Installation issues**: Check [Troubleshooting](troubleshooting.md)
- **General help**: See [FAQ](faq.md)
- **Command reference**: [Quick Reference](quick-reference.md)
- **Report problems**: [GitHub Issues](https://github.com/neopilot-ai/wtr/issues)

---

## ✨ What's Next?

After successful installation, read:

1. **[Basic Workflow](basic-workflow.md)** - Your first worktree in 5 minutes
2. **[Quick Reference](quick-reference.md)** - All commands at a glance
3. **[Configuration Guide](configuration.md)** - Customize for your workflow

---

**Ready to create your first worktree?**

```bash
cd ~/projects/your-repo
wtr new my-feature
cd $(wtr go my-feature)
```

**Happy worktreeing!** 🎉
