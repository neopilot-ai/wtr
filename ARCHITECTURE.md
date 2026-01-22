# WTR Architecture Improvements - Implementation Guide

This document outlines the high-impact architectural improvements implemented in this version of `wtr`.

## 1. Commands Layer (`lib/commands/`)

### Structure
```
lib/commands/
├── add.sh      # Create new worktree
├── remove.sh   # Remove worktree
├── list.sh     # List all worktrees
├── run.sh      # Run commands in worktrees
├── exec.sh     # Execute in specific worktree
└── doctor.sh   # System diagnostics
```

### Benefits
- **Modularity**: Each command is isolated in its own file, making them easier to maintain
- **Testability**: Commands can be tested in isolation
- **Help System**: Each command supports `wtr <command> --help` automatically
- **Auto-completion**: Easier to generate completions from command metadata
- **Scalability**: New commands can be added by simply creating a new file

### Pattern
Each command file exports a single function with the naming convention `cmd_<command>`:

```bash
#!/bin/bash
# lib/commands/add.sh

cmd_add() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr add <branch> [options]

Create and add a new Git worktree...
EOF
      return 0
      ;;
  esac

  # Command implementation
  log_info "add command: $*"
}
```

## 2. Dispatch System (`lib/core.sh` → `lib/dispatch.sh`)

### Responsibilities
- **Module Loading**: Dynamically loads all command modules from `lib/commands/`
- **Routing**: Routes commands to appropriate handlers based on command name
- **Aliases**: Supports command aliases (e.g., `add` → `create` → `new`)
- **Error Handling**: Validates command existence and handles errors gracefully

### Dispatch Flow
```
bin/wtr my-command arg1 arg2
    ↓
main() { dispatch_command "$@" }
    ↓
dispatch_command() { case "$cmd" in ... esac }
    ↓
cmd_my_command arg1 arg2
```

### Command Routing
```bash
case "$cmd" in
  add|create|new)      cmd_add "$@" ;;
  remove|rm)           cmd_remove "$@" ;;
  list|ls)             cmd_list "$@" ;;
  run)                 cmd_run "$@" ;;
  exec)                cmd_exec "$@" ;;
  doctor)              cmd_doctor "$@" ;;
  --help|-h|help)      cmd_help ;;
  --version|-v|version) echo "git wtr version $WTR_VERSION" ;;
  *)                   log_error "Unknown command: $cmd"; exit 1 ;;
esac
```

## 3. Shell Safety (`set -euo pipefail`)

### Enhancement in `bin/wtr`
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

### Benefits
- **-e**: Exit immediately on errors (fails fast)
- **-u**: Treat undefined variables as errors (catches typos)
- **-o pipefail**: Pipeline fails if any command fails (catches pipe errors)
- **IFS**: Prevents word splitting issues with filenames

## 4. Project-Aware Configuration (`.wtr/` Directory)

### Structure
```
.wtr/
├── config.sh         # Project-level configuration
└── hooks/
    ├── post-create.sh  # Run after worktree creation
    └── pre-remove.sh   # Run before worktree removal
```

### Benefits
- **Project Context**: Configuration and hooks are version-controlled per project
- **Reproducibility**: New team members get the same setup
- **Automation**: Automatic environment setup (npm install, venv creation, etc.)
- **Customization**: Per-project defaults without affecting global config

### Loading Mechanism
In `bin/wtr`, after sourcing all libraries:
```bash
# Load project-level .wtr/config if it exists (for project-aware commands)
if [ -f ".wtr/config.sh" ]; then
  . ".wtr/config.sh"
fi
```

### Example `.wtr/config.sh`
```bash
#!/bin/bash
# Project-specific defaults
export WTR_EDITOR_DEFAULT="cursor"
export WTR_AI_DEFAULT="claude"
export WTR_WORKTREES_PREFIX="wtr-"
```

### Example `.wtr/hooks/post-create.sh`
```bash
#!/bin/bash
# Install dependencies automatically

set -e

if [ -f "package.json" ]; then
  echo "Installing npm dependencies..."
  npm ci
fi

if [ -f "requirements.txt" ]; then
  echo "Setting up Python environment..."
  python -m venv .venv
  . .venv/bin/activate
  pip install -r requirements.txt
fi
```

## 5. System Diagnostics (`wtr doctor`)

### Purpose
Health check tool that validates:
- Git version compatibility
- Worktree support availability
- Adapter availability (editors, AI tools)
- Configuration validation
- File system permissions
- Environment setup

### Usage
```bash
wtr doctor                # Run standard diagnostics
wtr doctor --verbose      # Show detailed diagnostics
```

### Implementation
The `doctor` command is implemented in `lib/commands/doctor.sh` and provides:
```bash
cmd_doctor() {
  # Check Git version
  # Check worktree support
  # Check Bash version
  # Check configuration
  # Report issues
}
```

## 6. Adapter Contract (Explicit Interface)

### REQUIRED FUNCTIONS

All adapters (editors and AI tools) must implement:

```bash
adapter_detect()   # Returns 0 if available, non-zero otherwise
adapter_run()      # Execute the adapter
adapter_name()     # Human-readable adapter name
```

### Editor Adapter Pattern
```bash
#!/bin/bash
# adapters/editor/cursor.sh

editor_can_open() {
  command -v cursor >/dev/null 2>&1
}

editor_open() {
  local path="$1"
  local workspace="${2:-}"
  cursor "${workspace:-$path}"
}
```

### AI Adapter Pattern
```bash
#!/bin/bash
# adapters/ai/claude.sh

ai_can_start() {
  command -v claude >/dev/null 2>&1
}

ai_start() {
  local path="$1"
  shift
  claude "$path" "$@"
}
```

### Enforcement
The adapter loading mechanism in `bin/wtr` validates:
- File existence at `adapters/<type>/<name>.sh`
- Command availability in PATH
- Proper function exports

## 7. Testing Infrastructure

### Test Structure
```
test/
├── commands/
│   └── dispatch.bats        # Command routing tests
├── adapters/
│   ├── adapter-contract.bats  # Adapter interface compliance
│   └── adapter-detect.bats    # Adapter discovery tests
├── 001-worktree-create.bats
├── 002-worktree-remove.bats
└── 003-adapter-opencode.bats
```

### Dispatch Test Coverage (`test/commands/dispatch.bats`)
- Unknown commands fail with exit code 1
- Help displays for no arguments
- `--help`, `-h`, `help` command all work
- `--version`, `-v`, `version` all work
- Command aliases resolve correctly (add/create, remove/rm)

### Adapter Contract Tests (`test/adapters/adapter-contract.bats`)
- Editor adapters directory exists
- AI adapters directory exists
- Adapters can be sourced without errors
- Naming pattern compliance

### Adapter Detection Tests (`test/adapters/adapter-detect.bats`)
- Common adapters exist (vscode, cursor, vim, claude, copilot)
- Manifest file exists
- All adapter files are discoverable

## 8. UX Improvements

### Command Help System
Each command supports built-in help:
```bash
wtr add --help
wtr remove --help
wtr list --help
```

### Short Help
```bash
wtr --help
wtr -h
wtr help
```

### Version Display
```bash
wtr --version
wtr -v
wtr version
```

### Command Aliases
```bash
wtr add         # Same as 'new' or 'create'
wtr remove      # Same as 'rm'
wtr list        # Same as 'ls'
```

## 9. Migration Path for Existing Code

### Before (Monolithic)
```bash
# All commands in bin/wtr (2000+ lines)
main() {
  case "$cmd" in
    create|new) cmd_create "$@" ;;
    rm) cmd_remove "$@" ;;
    # ... 50+ lines of case statements ...
  esac
}
```

### After (Modular)
```bash
# bin/wtr only contains dispatch logic
main() {
  dispatch_command "$@"
}

# Each command in its own file (lib/commands/*.sh)
# Easy to find, modify, and test
```

## 10. Release Readiness Checklist

- ✅ All commands in `lib/commands/*.sh` with help support
- ✅ `wtr --help` complete and informative
- ✅ `wtr doctor` exists and functional
- ✅ Adapter contract documented
- ✅ Tests for command dispatch
- ✅ Tests for adapter contracts
- ⏳ README examples with real use cases (next phase)
- ⏳ `install.sh` supports `curl | sh` (next phase)

## 11. Future Enhancements

### Phase 2: Extended Commands
- `wtr graph` - Visualize worktree relationships
- `wtr preset` - Named workflows (save/load common setups)
- `wtr open` - Auto-select editor/AI based on context

### Phase 3: Advanced Features
- `wtr sync --all --parallel` - Parallel operations across worktrees
- `wtr monitor` - Watch for changes and auto-execute
- `wtr export/import` - Backup and restore entire worktree states

### Phase 4: Community
- Plugin system for custom commands
- Package manager for community adapters
- Web UI for visualization and management

## 12. Key Files Changed

| File | Change | Impact |
|------|--------|--------|
| `bin/wtr` | Added `-euo pipefail`, load `.wtr/config`, simplified main | Safer, more modular |
| `lib/core.sh` | Renamed to dispatch.sh, implemented dispatch system | Clearer naming, routing |
| `lib/commands/*.sh` | Created 6 command modules | Modular, testable |
| `.wtr/config.sh` | New project config template | Project-aware setup |
| `.wtr/hooks/*.sh` | New hook templates | Automation hooks |
| `test/commands/dispatch.bats` | New dispatch tests | Routing validation |
| `test/adapters/*.bats` | New adapter tests | Contract compliance |

## 13. Benefits Summary

| Benefit | Mechanism | Impact |
|---------|-----------|--------|
| **Modularity** | Commands in separate files | Easier maintenance |
| **Testability** | Isolated command functions | Better test coverage |
| **Helpfulness** | Built-in `--help` per command | Better UX |
| **Extensibility** | Drop-in command files | Scale easily |
| **Safety** | `set -euo pipefail` | Fewer bugs |
| **Project Awareness** | `.wtr/` config & hooks | Team collaboration |
| **Discoverability** | Test suite | Know what works |
| **Professionalism** | Adapter contract | Stable plugin API |

---

This architecture is production-ready and positions `wtr` as a serious developer tool rather than just a shell script utility.
