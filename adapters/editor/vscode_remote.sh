#!/usr/bin/env bash
# wtr VS Code Remote Adapter
# Opens a worktree in VS Code with remote support
#
# Supports:
# - Remote containers (Docker, DevContainers)
# - SSH remote execution
# - Windows Subsystem for Linux (WSL)
# - Regular local development

# Enable debug mode with: WTR_ADAPTER_DEBUG=1
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADAPTERS_DIR="$(dirname "$SCRIPT_DIR")"

# Source adapter library if available
if [ -f "$ADAPTERS_DIR/lib.sh" ]; then
    # shellcheck source=/dev/null
    source "$ADAPTERS_DIR/lib.sh"
fi

# Find VS Code command
find_vscode_cmd() {
    adapter_get_tool "code" "codium" "code-insiders" || return 1
}

# Detect execution context
detect_context() {
    # Check if inside Docker/container
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        echo "container"
        return 0
    fi
    
    # Check if running under WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
        return 0
    fi
    
    # Check if SSH remote env is set
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]; then
        echo "ssh-remote"
        return 0
    fi
    
    echo "local"
}

# Check for devcontainer configuration
has_devcontainer() {
    local target="$1"
    [ -f "$target/.devcontainer/devcontainer.json" ]
}

# Open in VS Code Remote
open_vscode_remote() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local vscode_cmd
    vscode_cmd=$(find_vscode_cmd) || {
        adapter_log_error "VS Code not found"
        echo ""
        echo "Installation: https://code.visualstudio.com"
        exit 127
    }
    
    adapter_log_debug "Using VS Code command: $vscode_cmd"
    
    local context
    context=$(detect_context)
    adapter_log_debug "Detected context: $context"
    
    # Determine how to open based on context and config
    case "$context" in
        container)
            adapter_log_info "Container detected - opening with VS Code (local)"
            adapter_exec_bg "$vscode_cmd" "$target"
            ;;
        wsl)
            adapter_log_info "WSL detected - opening with VS Code Remote WSL"
            adapter_exec_bg "$vscode_cmd" --remote wsl+Debian "$target"
            ;;
        ssh-remote)
            adapter_log_info "SSH remote detected"
            if has_devcontainer "$target"; then
                adapter_log_debug "DevContainer config found"
                adapter_exec_bg "$vscode_cmd" --remote-mode=open \
                    --folder-uri="vscode-remote://dev-container%2B$(echo -n "$target" | xxd -p)$target" "$target"
            else
                adapter_log_debug "Opening regular SSH remote"
                local hostname
                hostname=$(hostname)
                adapter_exec_bg "$vscode_cmd" "$target"
            fi
            ;;
        local)
            # Check for devcontainer in local context
            if has_devcontainer "$target"; then
                adapter_log_info "DevContainer config found - opening with VS Code Remote Containers"
                adapter_exec_bg "$vscode_cmd" "$target"
            else
                adapter_log_info "Opening local path with VS Code"
                adapter_exec_bg "$vscode_cmd" "$target"
            fi
            ;;
    esac
}

# Check if VS Code Remote is properly configured
check_vscode_remote() {
    if find_vscode_cmd >/dev/null 2>&1; then
        local vscode_cmd
        vscode_cmd=$(find_vscode_cmd)
        local version
        version=$("$vscode_cmd" --version 2>/dev/null | head -1 || echo "unknown")
        adapter_log_info "VS Code found: $version"
        
        local context
        context=$(detect_context)
        adapter_log_info "Execution context: $context"
        
        return 0
    else
        adapter_log_error "VS Code not found"
        return 1
    fi
}

# Get VS Code Remote version
get_version() {
    local vscode_cmd
    vscode_cmd=$(find_vscode_cmd) || return 1
    "$vscode_cmd" --version 2>/dev/null | head -1 || echo "unknown"
}

# ============================================================================
# Main Command Handler
# ============================================================================

main() {
    local cmd="$1"
    shift || { adapter_log_error "No command specified"; exit 1; }
    
    case "$cmd" in
        open)
            local target="${1:-.}"
            open_vscode_remote "$target"
            ;;
        check)
            check_vscode_remote
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr VS Code Remote Adapter"
            echo "Usage: vscode_remote.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in VS Code with remote support"
            echo "  check        Check VS Code and remote configuration"
            echo "  version      Show VS Code version"
            echo "  help         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            echo ""
            echo "Supported Remotes:"
            echo "  - Local development (automatic)"
            echo "  - Docker/DevContainers (auto-detected)"
            echo "  - WSL (auto-detected)"
            echo "  - SSH (via SSH_CONNECTION/SSH_CLIENT)"
            ;;
        *)
            adapter_log_error "Unknown command: $cmd"
            echo "Try: $0 help"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac
