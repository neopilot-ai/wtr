# wtr Adapter System

## Overview

The wtr adapter system extends the CLI's functionality by adding support for various editors and AI tools. This document explains how to use existing adapters and create new ones.

## Available Adapters

### Editors

- `cursor` - Cursor AI Editor (Highly Recommended)
- `vscode` - Visual Studio Code
- `vscode_remote` - VS Code with Remote Containers/SSH
- `zed` - Zed Editor
- `sublime` - Sublime Text
- `nvim` - Neovim
- `vim` - Vim
- `emacs` - Emacs
- `idea` - IntelliJ IDEA
- `webstorm` - WebStorm
- `pycharm` - PyCharm
- `atom` - Atom
- `nano` - Nano Editor

### AI Tools

- `gemini` - Google Gemini AI (Recommended)
- `claude` - Anthropic Claude AI
- `aider` - Aider AI coding assistant
- `copilot` - GitHub Copilot CLI
- `cursor` - Cursor AI features
- `opencode` - OpenCode Interpreter
- `continue` - Continue.dev AI
- `codex` - OpenAI Codex

## Using Adapters

### Specifying Adapters via Flags

You can specify an adapter directly when creating or opening a worktree:

```bash
# Create and open in VS Code
git wtr new my-feature --editor vscode

# Create and start Aider
git wtr new my-feature --ai aider

# Chain them together
git wtr new my-feature -e -a
```

### Configuration (The Recommended Way)

Set your defaults once so you don't have to use flags:

```bash
git wtr config set wtr.editor.default cursor
git wtr config set wtr.ai.default gemini
```

## Creating Custom Adapters

Adapters are simple Bash scripts located in the `adapters/` directory.

### Editor Adapters

1. Create a new file in `adapters/editor/` named `{name}.sh`.
2. Implement the `open` command handling:

```bash
#!/usr/bin/env bash

# $1 - Command (always 'open' for editors)
# $2 - Worktree path
# $3 - Workspace file path (optional, for VS Code/Cursor)
case "$1" in
    open)
        local target="${3:-$2}"
        my-editor "$target" >/dev/null 2>&1 &
        ;;
    *)
        echo "Unknown command: $1" >&2
        exit 1
        ;;
esac
```

### AI Adapters

1. Create a new file in `adapters/ai/` named `{name}.sh`.
2. Implement the commands:

```bash
#!/usr/bin/env bash

# $1 - Command (open, analyze, etc.)
# $2 - Worktree path
# $@ - Remaining arguments passed to the tool
cmd="$1"
worktree="$2"
shift 2

case "$cmd" in
    open|start)
        cd "$worktree" && my-ai-tool "$@"
        ;;
    analyze)
        # Optional: Perform codebase analysis
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac
```

## Environment Variables

The following variables can be set in your shell to override configurations:

- `WTR_DEBUG=1` - Enable detailed debug logging
- `WTR_EDITOR_DEFAULT` - Override default editor
- `WTR_AI_DEFAULT` - Override default AI tool
- `WTR_WORKTREES_DIR` - Override base directory for worktrees

## Troubleshooting

### Check Adapter Status

Use the `adapter` command to see which tools are recognized and available in your PATH:

```bash
git wtr adapter
```

### Permissions

Ensure your custom adapter scripts are executable:

```bash
chmod +x adapters/editor/my-editor.sh
```

## Best Practices

1. **Backgrounding**: For GUI editors, always run the command in the background (`&`) and redirect output to `/dev/null` to keep the terminal free.
2. **Path Respect**: Use `$PATH` to find binaries instead of hardcoding absolute paths.
3. **Workspace Support**: If your editor supports workspace files (like `.code-workspace`), use the third argument provided to the `open` command.

## Adapter Contract

All adapters must adhere to the following contract:

# REQUIRED FUNCTIONS
adapter_detect()   # returns 0 if available
adapter_run()      # execute command
adapter_name()     # human-readable name
