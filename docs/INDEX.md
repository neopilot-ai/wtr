# wtr Documentation - Complete Guide

> Making Git Worktrees practical for modern engineering teams

## 📚 Documentation Overview

This documentation is organized into sections for different user types and use cases. Start with the section that matches your needs.

---

## 🚀 Getting Started

### For New Users
1. **[README.md](../README.md)** - Product overview and quick start
2. **[Installation & Setup](setup.md)** - How to install and configure wtr
3. **[Basic Workflow](basic-workflow.md)** - Your first worktree in 5 minutes

### Quick Links
- **[Quick Reference Card](quick-reference.md)** - One-page cheat sheet
- **[Common Commands](commands.md)** - All wtr commands explained
- **[FAQ](faq.md)** - Frequently asked questions

---

## 📖 Core Documentation

### Essential Guides
- **[Configuration Guide](configuration.md)** - Customize wtr for your workflow
- **[Editor & AI Integration](adapters.md)** - Use your favorite tools with wtr
- **[Tool Integration Guide](INTEGRATION_GUIDE.md)** - Set up editors, AI, MCP, and more
- **[Troubleshooting](troubleshooting.md)** - Solve common problems

### Advanced Topics
- **[Advanced Usage & Workflows](advanced-usage.md)** - Power-user patterns
- **[Hooks & Automation](hooks.md)** - Automate setup and teardown
- **[Monorepo Workflows](monorepos.md)** - Special patterns for monorepos

---

## 🏗️ Reference

### Developer Resources
- **[Architecture Guide](../ARCHITECTURE.md)** - How wtr works internally
- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute to wtr
- **[API Reference](api-reference.md)** - Tool APIs and command specs

### Performance & Security
- **[Security Model](security.md)** - How wtr handles sensitive data
- **[Performance Guide](performance.md)** - Optimizing wtr for your team

---

## 🔧 Maintenance

### System Administration  
- **[Platform Support](platforms.md)** - macOS, Linux, Windows compatibility
- **[Upgrading wtr](upgrading.md)** - Upgrade to new versions safely
- **[Uninstalling wtr](uninstalling.md)** - Complete removal instructions

### Error Reference
- **[Error Guide](errors.md)** - All error messages explained
- **[Error Codes](error-codes.md)** - Debugging reference

---

## 📊 Cheat Sheets

| Chart | Purpose |
|------|---------|
| [Quick Reference](quick-reference.md) | All commands on one page |
| [Git Config Cheat Sheet](config-cheatsheet.md) | All config options quick lookup |
| [Keyboard Shortcuts](shortcuts.md) | Common editor shortcuts |

---

## 🎯 Use Case Guides

### By Workflow
- **[Feature Branch Workflow](workflows/feature-branches.md)** - Standard per-feature worktrees
- **[PR Review Workflow](workflows/pr-review.md)** - Quick PR testing without context switch
- **[Hotfix Workflow](workflows/hotfix.md)** - Emergency fixes alongside main development
- **[Multiple Parallel Tasks](workflows/parallel-tasks.md)** - Working on multiple features

### By Role
- **[For Individual Developers](guides/individual-dev.md)** - Solo developer setup
- **[For Teams](guides/team-setup.md)** - Team collaboration patterns
- **[For DevOps/CI](guides/devops.md)** - Integration with automation
- **[For AI Agents](guides/ai-agents.md)** - Autonomous agent coordination

### By Project Type
- **[Frontend Projects](project-types/frontend.md)** - React, Vue, Svelte, etc.
- **[Backend Projects](project-types/backend.md)** - Node, Python, Go, etc.
- **[Monorepos](project-types/monorepos.md)** - Turborepo, Nx, Lerna, etc.
- **[Polyrepos](project-types/polyrepos.md)** - Multi-repository coordination

---

## 📱 Platform-Specific Guides

### macOS
- [Installation on macOS](platforms/macos.md)
- [Homebrew Integration](platforms/macos-homebrew.md)
- [Shell Integration (zsh/bash)](platforms/macos-shell.md)

### Linux
- [Installation on Linux](platforms/linux.md)
- [Package Managers (apt/yum/brew)](platforms/linux-pm.md)  
- [shell Integration](platforms/linux-shell.md)

### Windows
- [Installation on Windows](platforms/windows.md)
- [Git Bash Setup](platforms/windows-bash.md)
- [WSL Configuration](platforms/windows-wsl.md)
- [PowerShell Integration](platforms/windows-pwsh.md)

---

## 🤝 Community

### Getting Help
- **[FAQ](faq.md)** - Common questions answered
- [GitHub Issues](https://github.com/neopilot-ai/wtr/issues) - Report bugs and feature requests
- [Discussions](https://github.com/neopilot-ai/wtr/discussions) - Community chat

### Contributing
- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute
- **[Code of Conduct](../CODE_OF_CONDUCT.md)** - Our community standards
- **[Development Setup](contributing/dev-setup.md)** - Developer environment setup

---

## 📈 Learning Path

### Beginner (30 minutes)
1. Read: [README.md](../README.md) overview
2. Install: [Setup guide](setup.md)
3. Try: [First worktree](basic-workflow.md)
4. Reference: [Quick reference card](quick-reference.md)

### Intermediate (2-3 hours)
1. Read: [Configuration Guide](configuration.md)
2. Try: Set up your defaults
3. Read: [Adapters Guide](adapters.md)
4. Integrate: Your favorite editor/AI tool
5. Explore: [Advanced Usage](advanced-usage.md)

### Advanced (4-6 hours)
1. Read: [Architecture Guide](../ARCHITECTURE.md)
2. Study: [Hooks & Automation](hooks.md)
3. Explore: [Advanced Workflows](advanced-usage.md)
4. Set up: [Team configuration](guides/team-setup.md)
5. Learn: [Performance optimization](performance.md)

---

## 🔍 Quick Lookup

### I want to...

**Create a worktree**
- Basic: [First worktree](basic-workflow.md)
- With setup: [Hooks](hooks.md)
- Advanced: [Advanced usage](advanced-usage.md)

**Configure wtr**
- All options: [Configuration guide](configuration.md)
- Team setup: [Team configuration](guides/team-setup.md)
- Examples: [Configuration examples](config-examples.md)

**Integrate with tools**
- Editor: [Editor adapters](adapters.md#editors)
- AI: [AI adapters](adapters.md#ai-tools)
- Custom: [Building adapters](adapters.md#creating-custom-adapters)

**Fix a problem**
- Common issues: [Troubleshooting](troubleshooting.md)
- Specific error: [Error guide](errors.md)
- Platform issue: [Platform guide](platforms.md)

**Work with my team**
- Setup: [Team configuration](guides/team-setup.md)
- Workflows: [Team workflows](guides/team-setup.md#team-workflows)
- CI/CD: [Automation guide](guides/devops.md)

---

## 📋 Command Reference

Quick access to command documentation:

```bash
wtr new <branch>           # Create worktree
wtr list                   # List all worktrees
wtr go <id>                # Get worktree path
wtr run <id> <cmd>         # Run command in worktree
wtr editor <id>            # Open in editor
wtr ai <id>                # Start AI tool
wtr remove <id>            # Delete worktree
wtr config get/set/add     # Manage configuration
wtr doctor                  # System diagnostics
```

Full reference: [Commands Guide](commands.md)

---

## 🆘 Getting Help

### Need Help?

1. **Check the FAQ**: [faq.md](faq.md)
2. **Search troubleshooting**: [troubleshooting.md](troubleshooting.md)
3. **Look up errors**: [error-guide.md](errors.md)
4. **Review examples**: [Examples directory](../examples/)

### Can't find what you need?

- 📧 [File an issue](https://github.com/neopilot-ai/wtr/issues)
- 💬 [Start a discussion](https://github.com/neopilot-ai/wtr/discussions)
- 🆘 [Ask community](https://github.com/neopilot-ai/wtr/discussions)

---

## 📦 What's Included

### Guides Included
- ✅ Installation & setup
- ✅ Basic usage
- ✅ Advanced workflows
- ✅ Configuration reference
- ✅ Tool integration
- ✅ Troubleshooting
- ✅ Error reference
- ✅ Platform-specific guides

### Resources Included
- ✅ Code examples
- ✅ Shell scripts
- ✅ Configuration files
- ✅ Cheat sheets
- ✅ FAQs

---

## 🔗 Document Map

```
docs/
├── README.md                          ← Start here
├── setup.md                           (NEW) Installation guide
├── basic-workflow.md                  (NEW) First steps
├── quick-reference.md                 (NEW) Cheat sheet
├── commands.md                        (NEW) Command reference
├── configuration.md                   (EXISTING) Configuration guide
├── adapters.md                        (EXISTING) Tool integration
├── troubleshooting.md                 (EXISTING) Common issues
├── advanced-usage.md                  (EXISTING) Power features
├── hooks.md                           (NEW) Automation guide
├── monorepos.md                       (NEW) Monorepo patterns
├── faq.md                             (NEW) Frequently asked questions
├── errors.md                          (NEW) Error reference
├── config-cheatsheet.md               (NEW) Config quick lookup
├── security.md                        (NEW) Security model
├── performance.md                     (NEW) Performance tuning
├── platforms.md                       (NEW) Platform support
├── workflows/
│   ├── feature-branches.md            (NEW) Feature branch workflow
│   ├── pr-review.md                   (NEW) PR review workflow
│   └── parallel-tasks.md              (NEW) Parallel development
├── guides/
│   ├── individual-dev.md              (NEW) Solo developer
│   ├── team-setup.md                  (NEW) Team configuration
│   ├── devops.md                      (NEW) CI/CD integration
│   └── ai-agents.md                   (NEW) AI agent coordination
├── project-types/
│   ├── frontend.md                    (NEW) Frontend projects
│   ├── backend.md                     (NEW) Backend projects
│   └── monorepos.md                   (NEW) Monorepo patterns
├── platforms/
│   ├── macos.md                       (NEW) macOS setup
│   ├── linux.md                       (NEW) Linux setup
│   └── windows.md                     (NEW) Windows setup
└── contributing/
    └── dev-setup.md                   (NEW) Developer setup
```

---

## 📍 Document Navigation

### Cross-References

All documents include:
- **Table of Contents** at the top
- **Related Guides** at the bottom
- **"See Also"** sections for related topics
- **Back links** to parent documents

### Reading Recommendations

- Start with: [README.md](../README.md)
- Continue with: [setup.md](setup.md)
- Then explore: Based on your use case
- Reference: [quick-reference.md](quick-reference.md) while working

---

## ✨ Documentation Highlights

### Best For Quick Learning
- [Quick Reference Card](quick-reference.md) - 1 page
- [FAQ](faq.md) - Common Q&A
- [Basic Workflow](basic-workflow.md) - 5 minute intro

### Best For Comprehensive Understanding
- [Configuration Guide](configuration.md) - Complete reference
- [Advanced Usage](advanced-usage.md) - Expert patterns
- [Architecture Guide](../ARCHITECTURE.md) - Internal details

### Best For Examples
- [examples/](../examples/) directory
- [Workflows](workflows/) guides
- [Configuration examples](config-examples.md)

---

## 🔄 Documentation Updates

This documentation is continuously improved. Check back for:
- New guides and tutorials
- Updated command reference
- Community-contributed examples
- Platform-specific improvements

---

**Last Updated**: February 2026  
**Version**: 2.0+  
**Status**: Complete & Maintained

See [CONTRIBUTING.md](../CONTRIBUTING.md#documentation) to contribute to documentation.
