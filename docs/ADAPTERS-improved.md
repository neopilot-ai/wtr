# wtr Adapter System (Improved)

## Overview

The wtr adapter system extends the CLI's functionality by adding support for various editors and AI tools. Adapters enable seamless integration with your preferred development environment and AI assistants.

**Key Features:**
- Automatic tool detection and installation hints
- Standardized interface across all adapters
- Configuration management via environment variables
- Comprehensive error handling and logging
- Support for both standalone and remote execution
- Debug mode for troubleshooting

## Available Adapters

### Editor Adapters (14 Total)

All editor adapters have been standardized using `adapters/lib.sh` for consistent error handling, command discovery, and validation.

#### GUI Editors (Non-blocking)

| Adapter | Tool | Best For | Remote | Key Features |
|---------|------|----------|--------|--------------|
| `cursor` | Cursor | AI-powered coding | Yes | Integrated AI, fast startup |
| `vscode` | VS Code | General development | No | Extensions, debugger |
| `vscode_remote` | VS Code Remote | Remote/containers/WSL | Yes | Dev containers, SSH |
| `zed` | Zed | Performance, Rust projects | Limited | GPU-accelerated, fast |
| `sublime` | Sublime Text | Lightweight editing | No | Minimal resources |

#### JetBrains IDEs

| Adapter | Tool | Best For | Language Focus | Features |
|---------|------|----------|-----------------|----------|
| `idea` | IntelliJ IDEA | Java development | Java, Kotlin | Full IDE, Android support |
| `webstorm` | WebStorm | JavaScript/TypeScript | Node.js | Frontend tools, debugging |
| `pycharm` | PyCharm | Python development | Python | Django, FastAPI, testing |

#### Terminal Editors (Blocking)

Terminal editors block until you exit, making them ideal for focused work sessions.

| Adapter | Tool | Best For | Features | Exit Key |
|---------|------|----------|----------|----------|
| `vim` | Vim | Keyboard-centric work | Modal editing, powerful | :wq or :qa |
| `nvim` | Neovim | Modern Vim setup | LSP support, Lua | :wq or :qa |
| `emacs` | Emacs | Extensible editing | Daemon mode, lisp | C-x C-c |
| `nano` | Nano | Simple editing | Beginner friendly | Ctrl+X |

#### Legacy/Specialized

| Adapter | Tool | Status | Recommendation | Notes |
|---------|------|--------|-----------------|-------|
| `atom` | Atom | Maintenance mode | ⚠️ Consider VS Code | Lightweight, family of Eclipse |
| `antigravity` | Antigravity | Cloud-based | Limited | Emerging platform |

### AI Tool Adapters (9 Total)

All AI adapters support standardized commands: `open`, `check`, `version`, and `help`.

#### API-Based AI Assistants (Recommended)

These provide the most powerful code analysis and suggestions:

| Adapter | Model | Best For | API Provider | Config |
|---------|-------|----------|--------------|--------|
| `claude` | Claude 3.5 Sonnet | Code analysis, creative tasks | Anthropic | `CLAUDE_API_KEY` |
| `gemini` | Gemini 1.5 Pro | Multimodal analysis, images | Google | `GEMINI_API_KEY` |

Setup:
```bash
# Claude
export CLAUDE_API_KEY="sk-ant-..."
adapters/ai/claude.sh check

# Gemini
export GEMINI_API_KEY="AIza..."
adapters/ai/gemini.sh check
```

#### IDE-Embedded AI (Requires Extension)

These run inside your editor as extensions:

| Adapter | Platform | Install | Activation | Best For |
|---------|----------|---------|------------|----------|
| `cursor` | Cursor IDE | Built-in | Automatic | Integrated AI experience |
| `copilot` | VS Code | Marketplace | `gh auth login` | GitHub integration |
| `continue` | VS Code/JetBrains | Extension | First run setup | Flexible LLM selection |

Setup:
```bash
# GitHub Copilot
gh auth login
# Install VS Code extension, then:
adapters/ai/copilot.sh check

# Continue.dev
# Install extension in VS Code/JetBrains
adapters/ai/continue.sh install
```

#### Command-Line Tools

Interactive tools that run in your terminal:

| Adapter | Type | Command | Best For | Installation |
|---------|------|---------|----------|--------------|
| `aider` | Pair programmer | `aider` | Refactoring, code review | `pip install aider-chat` |
| `opencode` | Interpreter | `opencode` | Code execution analysis | `pip install opencode` |

Usage:
```bash
# Aider pair programming
adapters/ai/aider.sh open /path/to/repo

# OpenCode analysis
adapters/ai/opencode.sh analyze /path/to/repo
```

#### Deprecated / Limited Support

| Adapter | Status | Reason | Alternative |
|---------|--------|--------|-------------|
| `codex` | Deprecated | Replaced by GPT-4 | Use `claude` or local LLM |
| `antigravity` | Placeholder | Pending service | Use `claude` or `gemini` |

## Using Adapters

### Quick Start

#### Open Worktree with Editor

```bash
# Create worktree and open in VS Code
git wtr create my-feature --editor vscode

# Use default configured editor
git wtr create my-feature

# Open existing worktree
git wtr run my-feature --editor cursor

# Chain multiple adapters
git wtr create my-feature -e cursor -a claude
```

#### Start with AI Assistant

```bash
# Analyze with Claude
git wtr create my-feature --ai claude

# Pair program with Aider
git wtr create my-feature --ai aider

# Use configured default
git wtr create my-feature --ai
```

### Configuration

Set your preferred adapters permanently to avoid repeated flags:

```bash
# Set default editor (one-time setup)
git wtr config set wtr.editor.default cursor

# Set default AI tool
git wtr config set wtr.ai.default aider

# View current config
git wtr config list

# View for a specific key
git wtr config get wtr.editor.default
```

Configuration search order (highest priority first):
1. Command-line flags
2. Local config (`.git/config`)
3. Project config (`.wtrconfig`)
4. Global config (`~/.config/wtr/`)

### Environment Variables

Control adapter behavior with environment variables:

```bash
# Global debug mode (all adapters)
export WTR_ADAPTER_DEBUG=1

# AI tool API keys
export CLAUDE_API_KEY="your-anthropic-key"
export GEMINI_API_KEY="your-google-key"
export OPENAI_API_KEY="your-openai-key"

# Editor selection
export WTR_EDITOR_DEFAULT="vim"

# AI tool selection
export WTR_AI_DEFAULT="aider"
```

### Adapter-Specific Commands

Each adapter supports standardized commands:

```bash
# Check installation status
adapters/editor/vscode.sh check
adapters/ai/claude.sh check

# Get version information
adapters/editor/vscode.sh version
adapters/ai/gemini.sh version

# Show usage help
adapters/editor/vim.sh help
adapters/ai/aider.sh help

# For AI adapters: analyze project
adapters/ai/claude.sh analyze /path/to/repo
adapters/ai/gemini.sh open /path/to/repo
```

## Advanced Usage

### Remote Development

VS Code Remote adapter supports development over SSH, in containers, or WSL:

```bash
# For SSH remote development
git wtr create feature --editor vscode_remote

# For DevContainers
# Automatically detects .devcontainer/devcontainer.json
git wtr create feature --editor vscode_remote

# For WSL development
# Automatically detected when running from WSL
git wtr create feature --editor vscode_remote
```

### Terminal Editor Workflows

Terminal editors (vim, nvim, nano, emacs) block until you exit, perfect for focused editing:

```bash
# Edit in Vim
git wtr create --editor vim feature-name

# Edit in Neovim with LSP
git wtr create --editor nvim feature-name

# Edit in Emacs daemon mode
git wtr create --editor emacs feature-name
```

Exit keys:
- **vim/nvim**: `:wq` (save quit) or `:qa` (quit all)
- **emacs**: `Ctrl+X Ctrl+C`
- **nano**: `Ctrl+X`

### AI Integration Workflows

#### Analyze Existing Worktree

```bash
# Get Claude's perspective on the codebase
adapters/ai/claude.sh analyze ~/worktrees/my-feature

# Get structured analysis from Gemini
adapters/ai/gemini.sh open ~/worktrees/my-feature
```

#### Pair Programming Session

```bash
# Start Aider for interactive refactoring
adapters/ai/aider.sh start ~/worktrees/my-feature

# Aider will ask you questions and help improve code
# Type 'quit' to exit
```

#### Setting Up Continue for Dynamic LLM Selection

```bash
# First, install the Continue.dev extension
adapters/ai/continue.sh install

# Check setup
adapters/ai/continue.sh check

# Open your worktree with Continue
adapters/ai/continue.sh open ~/worktrees/my-feature
```

## Adapter Implementation Guide

### Creating Editor Adapters

All properly designed editor adapters follow this pattern:

#### 1. Header and Setup

```bash
#!/usr/bin/env bash
# wtr My Editor Adapter
# Description of the editor

set -e

# Source the adapter library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADAPTERS_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$ADAPTERS_DIR/lib.sh" ]; then
    source "$ADAPTERS_DIR/lib.sh"
fi
```

#### 2. Tool Discovery

```bash
find_tool_cmd() {
    # Use adapter_get_tool to find command
    adapter_get_tool "editor-cli" "editor" || return 1
}

check_tool() {
    if find_tool_cmd >/dev/null 2>&1; then
        adapter_log_info "Editor found"
        return 0
    else
        adapter_log_error "Editor not found"
        return 1
    fi
}
```

#### 3. Open Implementation

```bash
open_tool() {
    local target="$1"
    
    # Validate input
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid path: $target"
        return 1
    fi
    
    # Find tool
    local cmd
    cmd=$(find_tool_cmd) || {
        adapter_log_error "Tool not found"
        exit 127
    }
    
    adapter_log_debug "Using command: $cmd"
    adapter_log_info "Opening: $target"
    
    # Execute (background for GUI, foreground for terminal)
    adapter_exec_bg "$cmd" "$target"  # GUI editors
    # OR
    adapter_exec "$cmd" "$target"     # Terminal editors
}
```

#### 4. Main Command Router

```bash
main() {
    local cmd="$1"
    shift || { adapter_log_error "No command"; exit 1; }
    
    case "$cmd" in
        open)
            open_tool "${1:-.}"
            ;;
        check)
            check_tool
            ;;
        version)
            find_tool_cmd | xargs -I {} {} --version 2>/dev/null || echo "unknown"
            ;;
        help|--help|-h)
            echo "wtr My Editor Adapter"
            echo "Usage: $0 <command> [args]"
            echo "Commands: open, check, version, help"
            ;;
        *)
            adapter_log_error "Unknown command: $cmd"
            exit 1
            ;;
    esac
}

main "$@"
```

### Creating AI Adapters

AI adapters have similar structure but different command handling:

#### 1. Configuration Loading

```bash
load_api_key() {
    # Environment first
    [ -n "${MY_API_KEY}" ] && echo "${MY_API_KEY}" && return 0
    
    # Config files
    local configs=(
        "$HOME/.config/wtr/my-ai"
        "$HOME/.config/my-ai/key"
        "$HOME/.my-ai/apikey"
    )
    
    for config in "${configs[@]}"; do
        [ -f "$config" ] && cat "$config" | tr -d ' \n' && return 0
    done
    
    return 1
}
```

#### 2. API Integration

```bash
call_api() {
    local endpoint="$1"
    local data="$2"
    local api_key="$3"
    
    adapter_log_debug "Calling: $endpoint"
    
    curl -s -X POST "https://api.example.com/v1/$endpoint" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d "$data" 2>/dev/null
}
```

#### 3. Analysis Function

```bash
analyze_project() {
    local target="$1"
    
    # Validate
    adapter_validate_path "$target" || {
        adapter_log_error "Invalid path"
        return 1
    }
    
    # Get API key
    local api_key
    api_key=$(load_api_key) || {
        adapter_log_error "API key not configured"
        echo "Setup: export MY_API_KEY='your-key'"
        exit 127
    }
    
    adapter_log_info "Analyzing: $target"
    
    # Build request
    local prompt="Analyze this: ..."
    local response
    response=$(call_api "analyze" '{"prompt":"'"$prompt"'"}' "$api_key")
    
    # Handle response
    echo "$response" | jq -r '.result' 2>/dev/null || echo "Error"
}
```

#### 4. Command Routing

```bash
main() {
    case "${1:-help}" in
        open|start) analyze_project "${2:-.}" ;;
        check|status) [ -n "$(load_api_key)" ] && echo "Configured" || echo "Not configured" ;;
        version) echo "Model: $MY_MODEL" ;;
        help) show_help ;;
        *) adapter_log_error "Unknown: $1" ;;
    esac
}

main "$@"
```

### Using lib.sh Utilities

Available functions in `adapters/lib.sh`:

**Logging (always outputs to stderr):**
```bash
adapter_log_debug "Debug: $var"       # Only if WTR_ADAPTER_DEBUG=1
adapter_log_info "Information"        # Status updates
adapter_log_warn "Warning message"    # Warnings
adapter_log_error "Error message"     # Errors
```

**Command Management:**
```bash
adapter_check_command "tool"           # Test if command exists
adapter_get_tool "cmd1" "cmd2" "cmd3"  # Find first available
adapter_find_command "pattern"         # Find by name pattern
```

**Path Operations:**
```bash
adapter_validate_path "/path"          # Check exists and accessible
adapter_resolve_path "/path"           # Resolve symlinks
```

**Execution:**
```bash
adapter_exec cmd arg1 arg2             # Runs in foreground (terminal editors)
adapter_exec_bg cmd arg1 arg2          # Runs in background (GUI editors)
```

**Configuration:**
```bash
adapter_load_config "~/.my_config"     # Source config file
adapter_get_env "VAR" "default_value"  # Get with fallback
```

**Validation:**
```bash
adapter_require_env "API_KEY"          # Error if env var empty
adapter_validate_api_key "key_string"  # Check key format
```

**Utilities:**
```bash
adapter_check_network                  # Test network connectivity
adapter_print_diagnostics              # Print debug info
```

## Best Practices

### For Adapter Users

1. **Configure Once**: Set defaults in config
   ```bash
   git wtr config set wtr.editor.default cursor
   git wtr config set wtr.ai.default aider
   ```

2. **Use Environment Variables** for sensitive data
   ```bash
   export CLAUDE_API_KEY="..."
   export GEMINI_API_KEY="..."
   ```

3. **Verify Availability**:
   ```bash
   adapters/editor/vscode.sh check
   adapters/ai/claude.sh check
   ```

4. **Debug Issues**:
   ```bash
   export WTR_ADAPTER_DEBUG=1
   git wtr create feature --editor cursor
   ```

### For Adapter Developers

1. **Always Use lib.sh**:
   - Ensures consistency
   - Provides tested utilities
   - Makes maintenance easier

2. **Validate All Input**:
   - Check paths exist
   - Validate API key format
   - Verify tool installation

3. **Provide Helpful Errors**:
   - Show installation instructions
   - Suggest configuration steps
   - Indicate API key requirements

4. **Support Standard Commands**:
   - `open|start` - Launch the tool
   - `check|status` - Verify configuration
   - `version` - Show version info
   - `help` - Show usage

5. **Handle Edge Cases**:
   - Missing tools (exit 127)
   - Permission errors (exit 126)
   - API errors (log details)
   - Network issues (provide guidance)

6. **Test Thoroughly**:
   - Test with missing tools
   - Test with bad paths
   - Test with missing API keys
   - Test with `WTR_ADAPTER_DEBUG=1`

7. **Documentation is Code**:
   - Clear help output
   - Usage examples
   - Setup instructions

## Troubleshooting

### Common Issues

**"Tool not found" error:**
```bash
# Check if tool is installed
which my-tool

# Verify it's in PATH
echo $PATH

# Try adapter check command
adapters/editor/my-tool.sh check

# Enable debug for details
WTR_ADAPTER_DEBUG=1 adapters/editor/my-tool.sh open .
```

**"Invalid path" error:**
```bash
# Check path exists
ls -la /path/to/worktree

# Try with absolute path
adapters/editor/vscode.sh open /full/path/to/worktree

# Verify permissions
ls -ld /path/to/worktree
```

**"API key not found" (AI adapters):**
```bash
# Verify key is set
echo $CLAUDE_API_KEY

# Check config files
cat ~/.config/wtr/claude 2>/dev/null

# Test with check command
adapters/ai/claude.sh check
```

**Permission denied:**
```bash
# Make adapter executable
chmod +x adapters/editor/my-tool.sh

# Verify
ls -l adapters/editor/my-tool.sh
```

### Debug Mode

Enable comprehensive debugging:

```bash
# Method 1: Environment variable
export WTR_ADAPTER_DEBUG=1

# Method 2: Per-command
WTR_ADAPTER_DEBUG=1 adapters/editor/vscode.sh open .

# Method 3: With error capturing
WTR_ADAPTER_DEBUG=1 adapters/ai/claude.sh analyze . 2>&1 | tee debug.log
```

Debug output includes:
- Command invocations
- Path resolutions
- API calls
- Configuration loading
- Tool detection steps

## Reference

- **lib.sh**: [Complete adapter library](/workspaces/wtr/adapters/lib.sh)
- **Editor adapters**: [14 pre-built editor adapters](/workspaces/wtr/adapters/editor/)
- **AI adapters**: [9 pre-built AI integrations](/workspaces/wtr/adapters/ai/)
- **Contributing**: See [CONTRIBUTING.md](/workspaces/wtr/CONTRIBUTING.md)

## Adapter Checklist

Use this when creating new adapters:

- [ ] Adapter sources `lib.sh`
- [ ] Implements `open` command
- [ ] Implements `check` command
- [ ] Implements `version` command  
- [ ] Implements `help` command
- [ ] Uses `adapter_log_*` functions
- [ ] Validates input paths
- [ ] Handles missing tools gracefully
- [ ] Exits with correct codes (0=success, 1=error, 127=not found)
- [ ] Has descriptive header comment
- [ ] Tested with `WTR_ADAPTER_DEBUG=1`
- [ ] Works without `lib.sh` present (graceful fallback)