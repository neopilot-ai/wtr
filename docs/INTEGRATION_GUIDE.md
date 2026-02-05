# wtr Integration Guide

> Complete guide to integrating wtr with your tools, editors, and AI assistants.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Editor Integration](#-editor-integration)
- [AI Tool Integration](#-ai-tool-integration)
- [MCP Server Setup](#-mcp-server-setup)
- [Team Integration](#-team-integration)
- [Custom Adapters](#-creating-custom-adapters)
- [Troubleshooting](#-troubleshooting)

---

## Overview

wtr integrates with:
- **Editors**: VS Code, Cursor, Vim, Emacs, JetBrains IDEs, and more
- **AI Tools**: Claude, OpenCode, Aider, GitHub Copilot, Codeium, and more
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins, etc.
- **Custom Tools**: Build your own adapter

---

## 🎨 Editor Integration

### Quick Setup

Set your default editor globally:

```bash
# Choose one:
git config --global wtr.editor vscode
git config --global wtr.editor cursor
git config --global wtr.editor vim
git config --global wtr.editor emacs
```

Then open a worktree in your editor:

```bash
wtr editor <worktree-id>         # Opens with default editor
wtr editor <worktree-id> -e vim  # Override to specific editor
```

### Supported Editors

#### VS Code / VSCode Remote

**Default Name**: `vscode`, `code`

**Setup**:
```bash
# Install VS Code
https://code.visualstudio.com

# Configure wtr
git config --global wtr.editor vscode

# Use it
wtr editor my-feature
```

**What it does**:
- Opens worktree directory in VS Code
- Uses VS Code Remote if on remote server
- Preserves workspace settings

---

#### Cursor

**Default Name**: `cursor`

**Setup**:
```bash
# Install Cursor (AI-powered VS Code)
https://cursor.com

# Configure wtr
git config --global wtr.editor cursor

# Use it
wtr editor my-feature
```

**What it does**:
- Opens worktree in Cursor
- Enables AI assistance within worktree context

---

#### Vim / Neovim

**Default Names**: `vim`, `nvim`

**Setup**:
```bash
# Install Vim or Neovim
brew install vim              # macOS
brew install neovim           # macOS (Neovim)
sudo apt update && sudo apt install vim   # Linux

# Configure wtr (choose one)
git config --global wtr.editor vim
git config --global wtr.editor nvim

# Use it
wtr editor my-feature
```

**What it does**:
- Opens Vim/Neovim in worktree directory
- Preserves your vim configuration

**Tips**:
```bash
# With custom vimrc
wtr editor my-feature -e 'vim -u ~/.vimrc'

# With plugin manager (vim-plug)
wtr editor my-feature -e 'nvim +"Telescope find_files"'
```

---

#### Emacs

**Default Name**: `emacs`

**Setup**:
```bash
# Install Emacs
brew install emacs            # macOS
sudo apt install emacs        # Linux

# Configure wtr
git config --global wtr.editor emacs

# Use it
wtr editor my-feature
```

---

#### JetBrains IDEs

**Supported**: IntelliJ IDEA, PyCharm, WebStorm, CLion, GoLand

**Default Names**: `idea`, `pycharm`, `webstorm`, `clion`, `goland`

**Setup**:
```bash
# Install your IDE from JetBrains

# Configure wtr
git config --global wtr.editor idea       # IntelliJ
git config --global wtr.editor pycharm    # PyCharm
git config --global wtr.editor webstorm   # WebStorm

# Use it
wtr editor my-feature
```

**What it does**:
- Opens worktree as new project window
- Preserves IDE configuration
- Each worktree can have separate IDE state

---

#### Other Editors

| Editor | Name | Installation |
|--------|------|--------------|
| Sublime Text | `sublime` | [sublime.com](https://www.sublimetext.com) |
| Nano | `nano` | `brew install nano` or built-in |
| Atom | `atom` | ⚠️ Deprecated, use VS Code instead |
| Zed | `zed` | [zed.dev](https://zed.dev) |

---

## 🤖 AI Tool Integration

### Quick Setup

Set your default AI tool:

```bash
# Choose one:
git config --global wtr.ai claude
git config --global wtr.ai opencode
git config --global wtr.ai aider
git config --global wtr.ai copilot
```

Then open a worktree with AI:

```bash
wtr ai <worktree-id>         # Opens with default AI
wtr ai <worktree-id> -a claude  # Override to specific tool
```

### Supported AI Tools

#### Claude

**Default Name**: `claude`

**Setup**:
```bash
# Option 1: Using Claude Desktop + MCP Server
# See "MCP Server Setup" section below

# Option 2: Using Cursor (has Claude built-in)
git config --global wtr.editor cursor
wtr editor my-feature   # Cursor with Claude

# Option 3: Using Continue extension in VS Code
# Configure wtr to use Claude in VS Code
```

**Usage**:
```bash
wtr ai my-feature        # Opens Claude in worktree context
```

---

#### OpenCode

**Default Name**: `opencode`

**Setup**:
```bash
# Install OpenCode
npm install -g @opencode/cli
# or
pip install opencode

# Configure wtr
git config --global wtr.ai opencode

# Use it
wtr ai my-feature
```

---

#### Aider

**Default Name**: `aider`

**Setup**:
```bash
# Install Aider (requires Python 3.8+)
pip install aider-ai

# Verify installation
aider --version

# Configure wtr
git config --global wtr.ai aider

# Use it
wtr ai my-feature
```

**What it does**:
- Launches Aider in the worktree
- Aider uses Claude API by default
- Works in terminal

**Configuration**:
```bash
# Set API key
export OPENAI_API_KEY="sk-..."

# Use with different model
wtr run my-feature aider --model gpt-4
```

---

#### GitHub Copilot

**Default Name**: `copilot`

**Setup**:
```bash
# GitHub Copilot requires authentication

# Option 1: VS Code with Copilot Extension
git config --global wtr.editor vscode
# VS Code will handle Copilot auth

# Option 2: Copilot CLI (if available)
npm install -g @github/copilot-cli
git config --global wtr.ai copilot

# Authenticate
copilot auth login

# Use it
wtr ai my-feature
```

---

#### Cursor (IDE)

**Default Name**: `cursor`

**Setup**:
```bash
# Cursor combines VS Code with AI
brew install cursor

# Configure wtr
git config --global wtr.editor cursor

# Use it
wtr editor my-feature     # Cursor opens with AI context
```

---

#### Continue Extension

**Setup** (for VS Code):
```bash
# Install Continue extension in VS Code
# Extensions → Search "Continue" → Install

# Configure to use your AI provider:
# Continue → Settings → Configure with LLM of choice

# Launch VS Code with wtr
git config --global wtr.editor vscode
wtr editor my-feature
```

---

#### Codeium Windsurf

**Default Name**: `windsurf`

**Setup**:
```bash
# Install Windsurf
https://windsurf.codeium.com

# Configure wtr
git config --global wtr.ai windsurf

# Use it
wtr ai my-feature
```

---

#### Google Gemini

**Default Name**: `gemini`

**Setup**:
```bash
# Get Gemini API key
# https://makersuite.google.com/app/apikey

# Set environment variable
export GEMINI_API_KEY="your-key-here"

# Configure wtr
git config --global wtr.ai gemini

# Use it
wtr ai my-feature
```

---

### Chaining Tools

Use both editor AND AI together:

```bash
# Create worktree
wtr new my-feature

# Open in editor
wtr editor my-feature

# In another terminal, open AI
wtr ai my-feature

# Or combine them
wtr editor my-feature && wtr ai my-feature
```

---

## 🌐 MCP Server Setup

The **Model Context Protocol (MCP) server** allows AI assistants to autonomously manage wtr.

### What is MCP?

MCP enables AI assistants to:
- Create, list, and remove worktrees
- Run commands in worktrees
- Manage configuration
- Automate complex workflows

### Prerequisites

- Node.js 16+ (or Python 3.8+)
- wtr installed and configured
- Git repository set up

### Setup for Claude Desktop

**Step 1**: Copy MCP server to wtr directory

```bash
cd /path/to/wtr
cp -r mcp ~/wtr-mcp
cd ~/wtr-mcp
npm install
npm run build
```

**Step 2**: Configure Claude

Edit: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "wtr": {
      "command": "node",
      "args": ["~/wtr-mcp/dist/index.js"],
      "env": {
        "WTR_HOME": "/path/to/your/repo"
      }
    }
  }
}
```

**Step 3**: Restart Claude

Close and reopen Claude Desktop.

**Step 4**: Test

In Claude, try:
```
"List all worktrees"
"Create a worktree for 'feature-xyz'"
"Run tests in the latest worktree"
```

### Setup for Cursor

**Step 1**: Build MCP server

```bash
cd /path/to/wtr/mcp
npm install && npm run build
```

**Step 2**: Configure Cursor

Settings → MCP Servers → Add

```json
{
  "wtr": {
    "type": "stdio",
    "command": "node",
    "args": ["/path/to/wtr/mcp/dist/index.js"],
    "env": {
      "WTR_HOME": "/path/to/your/repo"
    }
  }
}
```

**Step 3**: Restart Cursor

**Step 4**: Use in Chat

In Cursor's chat, mention worktrees and wtr actions.

### MCP Server Features

The MCP server provides these tools to AI:

1. **list_worktrees** - Get all worktrees
2. **create_worktree** - Create new worktree
3. **remove_worktree** - Delete worktree
4. **run_command** - Execute command in worktree
5. **get_worktree_info** - Get worktree details
6. **read_file** - Read file from worktree
7. **execute_git_command** - Run Git commands

### Example AI Workflows

**Workflow 1: Independent Feature Development**
```
User: "Create three feature branches and check them out"

Claude:
1. Creates feature-auth worktree
2. Creates feature-ui worktree
3. Creates feature-api worktree
4. Lists them for user
```

**Workflow 2: PR Review & Testing**
```
User: "Review PR #42 - create a worktree, install deps, and run tests"

Claude:
1. Creates pr-42 worktree
2. Runs "npm install"
3. Runs test suite
4. Reports results
```

**Workflow 3: Parallel Development**
```
User: "Work on bug-fix while I continue feature work"

Claude:
1. Creates bug-fix worktree
2. Analyzes issue
3. Makes changes
4. Runs tests
5. Creates commit with changes
```

---

## 👥 Team Integration

### Shared Configuration

**Create `.wtrconfig` in repo root**:

```ini
[defaults]
editor = cursor
ai = claude

[copy]
include = .env.example
include = .npmrc

[hooks]
postCreate = npm install
postCreate = npm run build
```

**Commit to repo**:
```bash
git add .wtrconfig
git commit -m "Add wtr team configuration"
git push
```

**Team members pull and use**:
```bash
git pull
wtr new feature-name   # Uses team defaults
```

### Automation with GitHub Actions

**Example: Auto-create PR review worktrees**

```yaml
name: Create Review Worktree

on:
  pull_request:
    types: [opened]

jobs:
  create_worktree:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install wtr
        run: |
          curl https://raw.githubusercontent.com/neopilot-ai/wtr/main/install.sh | bash
      
      - name: Create worktree for PR
        run: |
          wtr new pr-${{ github.event.pull_request.number }}
          wtr run pr-${{ github.event.pull_request.number }} npm test
      
      - name: Post results
        if: always()
        run: |
          echo "✅ Worktree created for PR review" >> $GITHUB_STEP_SUMMARY
```

### Team Workflow Patterns

**Pattern 1: Feature Branch Per Task**
```bash
# Team convention: wtr new <ticket-id>
wtr new PROJ-421      # Task ID
wtr new AUTH-98       # Service prefix

# Team members:
wtr list              # See who's working on what
```

**Pattern 2: Standardized Presets**
```bash
# Define in .wtrconfig
git config wtr.preset.backend.branch develop
git config wtr.preset.backend.copy ".env.backend"

git config wtr.preset.frontend.branch staging
git config wtr.preset.frontend.copy ".env.frontend"

# Everyone uses same setup
wtr new feature-api --preset backend
wtr new feature-ui --preset frontend
```

---

## 🔧 Creating Custom Adapters

### Adapter System

wtr loads adapters from `adapters/` directory:

```
adapters/
├── editor/           # Editor adapters
│   ├── vscode.sh
│   ├── vim.sh
│   ├── custom.sh     # Your custom adapter
├── ai/               # AI adapters
│   ├── claude.sh
│   ├── custom.sh     # Your custom adapter
```

### Creating an Editor Adapter

**File**: `adapters/editor/my-editor.sh`

```bash
#!/bin/bash
# wtr adapter for MyEditor
# Usage: source this file, then call editor_open <path>

editor_open() {
    local path="$1"
    
    # Your editor invocation
    my-editor "$path" &
    
    return $?
}
```

**Register in `.wtrconfig`**:
```ini
[adapters]
editor.my-editor = adapters/editor/my-editor.sh
```

**Use it**:
```bash
wtr editor <worktree> -e my-editor
```

### Creating an AI Tool Adapter

**File**: `adapters/ai/my-tool.sh`

```bash
#!/bin/bash
# wtr adapter for MyAI Tool

ai_start() {
    local path="$1"
    
    cd "$path" || return 1
    
    # Launch your AI tool
    my-ai-tool --path "$path" &
    
    return $?
}
```

**Register & use**:
```bash
git config wtr.ai my-tool
wtr ai <worktree>
```

### Adapter Best Practices

1. **Return exit codes**: 0 for success, non-zero for failure
2. **Handle paths properly**: Quote all path variables
3. **Background processes**: Use `&` or start detached
4. **Error messages**: Log to stderr
5. **Configuration**: Read from git config

---

## 🆘 Troubleshooting

### Editor Won't Open

```bash
# Check if editor is configured
git config wtr.editor

# Check if editor exists
which vscode       # or your editor name

# Try opening manually
vscode /path/to/worktree

# Check permissions
ls -la ~/.config/  # For Linux
```

### AI Tool Not Found

```bash
# Check configuration
git config wtr.ai

# Verify tool is installed
which aider        # or your tool name

# Test tool directly
aider --help

# Reinstall if needed
pip install aider-ai
npm install -g @opencode/cli
```

### MCP Server Not Connecting

```bash
# Check Node.js version
node --version    # Need 16+

# Rebuild MCP server
cd ~/wtr-mcp
npm install && npm run build

# Check Claude config file
cat "~/Library/Application Support/Claude/claude_desktop_config.json"

# Restart Claude completely
# (Don't just close, fully quit)
```

### Integration Script Errors

```bash
# Check script syntax
bash -n adapters/editor/my-editor.sh

# Test script manually
source adapters/editor/my-editor.sh
editor_open /tmp/test

# Check logs
wtr new test -v   # Verbose mode
```

---

## 📚 Next Steps

- [Editor & AI Reference](adapters.md) - Detailed adapter documentation
- [Configuration Guide](configuration.md) - All configuration options
- [Advanced Usage](advanced-usage.md) - Complex workflows
- [Troubleshooting](troubleshooting.md) - Problem solving

---

## 🔗 Related Resources

- **[MCP Specification](https://modelcontextprotocol.io/)** - Model Context Protocol details
- **[Claude Documentation](https://claude.ai/docs)** - Claude API and desktop setup
- **[Cursor Documentation](https://cursor.com/docs)** - Cursor IDE setup
- **[GitHub Actions](https://github.com/features/actions)** - CI/CD integration

---

**Last Updated**: February 2026

Have questions? [Open an issue](https://github.com/neopilot-ai/wtr/issues) or [start a discussion](https://github.com/neopilot-ai/wtr/discussions).
