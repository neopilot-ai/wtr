# wtr

> **Modern Git Worktree Orchestration for Parallel Development**

[![GitHub Stars](https://img.shields.io/github/stars/neopilot-ai/wtr?style=flat-square&logo=github&label=Stars)](https://github.com/neopilot-ai/wtr/stargazers)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/Git-2.5%2B-orange.svg?style=flat-square&logo=git&logoColor=white)](https://git-scm.com/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg?style=flat-square)](#platform-support)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

---

## 📖 Table of Contents

- [🚀 Overview](#-overview)
- [🏆 Why Teams Adopt wtr](#-why-teams-adopt-wtr)
- [📸 Demo](#-demo)
- [⚡ Quick Start](#-quick-start)
- [🏃 Daily Workflow](#-daily-workflow)
- [✨ Why wtr?](#-why-wtr)
- [📐 Architecture & Workflow](#-architecture--workflow)
- [🌟 Features](#-features)
- [🧩 Commands Overview](#-commands-overview)
- [⚙️ Configuration](#️-configuration)
- [🖥️ Platform Support](#️-platform-support)
- [🤝 Contributing](#-contributing)

## 🚀 Overview


**wtr** is a portable, cross-platform CLI that makes **Git worktrees practical, fast, and enjoyable**.

It is designed for **modern parallel development**:

* Feature development alongside hotfixes
* Reviewing PRs without context switching
* Running tests on `main` while building features
* Spinning up **multiple AI agents on different branches**

If Git worktrees are powerful but painful, **wtr is the missing UX layer**.

---

## 🏆 Why Teams Adopt wtr

Engineering teams use `wtr` to eliminate the "branch switching tax" and enable high-velocity parallel workflows.

1. **Zero-Stash Workflow**: Stop stashing half-finished work. Just spin up a new worktree and keep your context.
2. **Instant PR Reviews**: Review a teammate's PR in a dedicated directory without touching your active workspace.
3. **AI-Ready Infrastructure**: The first tool designed to coordinate multiple AI agents working on different branches simultaneously.
4. **Onboarding in Seconds**: Automate environment setup (env files, npm install, etc.) for every new branch worktree.
5. **Clean Repos**: Automated cleanup of merged branches and stale worktrees keeps your development machine tidy.

---

## 📸 Demo

[![wtr Demo](https://img.shields.io/badge/Demo-Watch_CLI_in_Action-blueviolet?style=for-the-badge&logo=asciinema)](https://github.com/neopilot-ai/wtr)

> **Note:** We are currently recording a high-quality terminal GIF. In the meantime, you can explore the [Quick Start](#-quick-start) to see it for yourself!

---

## 🧠 What Are Git Worktrees? (Quick Explanation)

Normally, one repository directory = one checked-out branch.

Git worktrees allow **multiple branches to be checked out simultaneously**, each in its own directory:

```text
repo/            → main
repo-feature/    → feature branch
repo-hotfix/     → hotfix branch
```

### The Reality Today

* Switching branches breaks flow
* Stashing is fragile
* Reviewing PRs interrupts active work
* Parallel automation / AI workflows are difficult

### The Problem

Git worktrees exist — but the CLI is verbose, manual, and error-prone.

### The Solution

**wtr** wraps `git worktree` with:

* Clean commands
* Smart defaults
* Editor & AI integration
* Automation hooks

---

## ⚡ Quick Start

### Installation

```bash
git clone https://github.com/neopilot-ai/wtr.git
cd wtr
./install.sh
```

> **Upgrade**: Run `./install.sh --upgrade` to reinstall over the existing version.  
> **Uninstall**: Run `./install.sh --uninstall` to remove all binaries and config files.


<details>
<summary><b>Manual installation options</b></summary>

**macOS (Homebrew):**

```bash
ln -s "$(pwd)/bin/git-wtr" "$(brew --prefix)/bin/git-wtr"
```

**Linux / macOS (Intel):**

```bash
sudo mkdir -p /usr/local/bin
sudo ln -s "$(pwd)/bin/git-wtr" /usr/local/bin/git-wtr
```

**User-local:**

```bash
mkdir -p ~/bin
ln -s "$(pwd)/bin/git-wtr" ~/bin/git-wtr
export PATH="$HOME/bin:$PATH"
```

</details>

---

## 🏃 Daily Workflow

```bash
# One-time per repo setup
git wtr config set wtr.editor.default cursor
git wtr config set wtr.ai.default claude

# Create worktrees
git wtr new my-feature
git wtr new my-feature --editor
git wtr new my-feature --ai
git wtr new my-feature -e -a

# Navigate & run
git wtr editor my-feature
git wtr ai my-feature
git wtr run my-feature npm test

# Cleanup
git wtr rm my-feature
git wtr clean --merged

# 🎭 Advanced: Using Presets
# Define a "frontend" setup once, use it everywhere
git wtr config set wtr.preset.frontend.copy.include "**/.env.local"
git wtr config set wtr.preset.frontend.hooks.postCreate "npm install"

# Spin up a full environment in one command
git wtr new feature-login --preset frontend --editor
```

---

## ✨ Why wtr?

| Workflow        | Raw Git        | wtr                      |
| --------------- | -------------- | ------------------------------ |
| Create worktree | Verbose paths  | `git wtr new feature`    |
| Open editor     | Manual `cd`    | `git wtr editor feature` |
| Start AI tool   | Manual setup   | `git wtr ai feature`     |
| Copy env/config | Manual         | Automatic rules                |
| Run setup       | Manual scripts | Hooks                          |
| Cleanup         | Error-prone    | Smart clean                    |

**TL;DR**: Same Git power — dramatically better DX.

---

## 📐 Architecture & Workflow

### How it Works
`wtr` acts as a coordination layer between Git, your editors, and automation scripts.

```mermaid
graph TD
    A[wtr CLI] --> B[Git Core]
    B --> C[Worktree A]
    B --> D[Worktree B]
    A --> E[Adapters]
    E --> F[Editors: Cursor, VS Code, Zed...]
    E --> G[AI Tools: Claude, Aider, Copilot...]
    A --> H[Hooks & Automation]
    H --> I[Post-Create Setup]
    H --> J[Post-Remove Cleanup]
```

### The wtr Lifecycle

```mermaid
sequenceDiagram
    participant U as User
    participant B as wtr
    participant G as Git
    participant E as Editor/AI

    U->>B: git wtr new feature-1
    B->>G: git worktree add ../feature-1
    G-->>B: success
    B->>B: Copy config/env files
    B->>B: Run postCreate hooks
    U->>B: git wtr editor feature-1
    B->>E: Open Editor in feature-1 dir
    U->>B: git wtr rm feature-1
    B->>G: git worktree remove feature-1
    B->>B: Run postRemove hooks
```

---

## 🌟 Features

* Intuitive CLI for Git worktrees
* Repository-scoped worktree management
* Configuration-first design
* Editor integrations (Cursor, VS Code, Zed, more)
* AI coding tools (Claude, Gemini, Aider, Copilot, Cursor...)
* Smart file copying (env/config sync)
* Post-create / post-remove hooks
* Shared team configuration via `.wtrconfig`
* Parallel workflows & automation-friendly
* Bash, Zsh, Fish completions
* Cross-platform support

---

## 🧩 Commands Overview

```bash
git wtr new <branch>
git wtr editor <branch>
git wtr ai <branch>
git wtr run <branch> <cmd>
git wtr go <branch>
git wtr list
git wtr rm <branch>
git wtr clean
git wtr config
```

Run `git wtr help` for full reference.

---

## ⚙️ Configuration

Configuration uses **git config** and supports team sharing.

```bash
git wtr config set wtr.editor.default cursor
git wtr config set wtr.ai.default claude
git wtr config add wtr.copy.include "**/.env.example"
git wtr config add wtr.hook.postCreate "npm install"
```

### Team Defaults (`.wtrconfig`)

```gitconfig
[defaults]
    editor = cursor
    ai = claude

[copy]
    include = **/.env.example

[hooks]
    postCreate = npm install
```

Precedence:

1. Local repo config
2. `.wtrconfig`
3. Global git config

---

## 🖥️ Platform Support

| Platform | Status     | Notes                |
| -------- | ---------- | -------------------- |
| macOS    | ✅ Full     | Ventura+ recommended |
| Linux    | ✅ Full     | Ubuntu, Fedora, Arch |
| Windows  | ⚠️ Partial | Git Bash / WSL only  |

---

## � AI Integration with MCP

**wtr** includes a **Model Context Protocol (MCP) server** that enables AI assistants to autonomously manage git worktrees.

### Supported AI Assistants

- ✅ **Claude** (via Claude Desktop or API)
- ✅ **Cursor** (AI-powered IDE)
- ✅ **ChatGPT** (via custom integrations)
- ✅ **Custom Applications** (Node.js, Python, etc.)

### Quick Setup

**Claude Desktop**:
```bash
# Install MCP server
cd mcp-server && npm install && npm run build

# Add to Claude config: ~/Library/Application\ Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "wtr": {
      "command": "node",
      "args": ["/path/to/wtr/mcp/dist/index.js"]
    }
  }
}

# Restart Claude, then try:
# "Create a feature branch and run tests"
```

**Cursor**:
```json
// Settings → MCP Servers
{
  "wtr": {
    "type": "stdio",
    "command": "node",
    "args": ["/path/to/wtr/mcp/dist/index.js"]
  }
}
```

### Example: AI-Driven Workflow

```
You: "Create a worktree for PR #42 and run its tests"

Claude:
1. [Creates worktree] wtr add pr-42 --track
2. [Lists worktrees] wtr list
3. [Runs tests] wtr run pr-42 npm test
4. [Returns results] ✅ All tests pass!
```

Learn more: [MCP Server Documentation](mcp-server/README.md) | [Integration Guide](mcp-server/INTEGRATION_GUIDE.md)

---

## 🧠 Advanced Workflows

* Multiple worktrees per branch
* Parallel AI agents
* Non-interactive CI usage
* Repo bootstrapping scripts
* Large mono-repo workflows

➡️ Check out the [**Documentation Index**](docs/README.md) for deeper dives into:
- [Configuration](docs/configuration.md)
- [Editor & AI Adapters](docs/ADAPTERS.md)
- [MCP Server Setup](mcp-server/INTEGRATION_GUIDE.md)
- [Troubleshooting](docs/troubleshooting.md)

---

## 🤝 Contributing

Contributions are welcome:

* Editor adapters (JetBrains, Neovim)
* AI tool adapters
* Docs & tutorials
* Bug fixes

See **CONTRIBUTING.md** and **CODE_OF_CONDUCT.md**.

---

## 📄 License

Licensed under the **Apache License 2.0**.

---

Built for developers who work in parallel — with humans *and* AI.
