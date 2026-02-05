#!/usr/bin/env bash
# wtr VS Code Editor Adapter
# Opens a worktree in Visual Studio Code
#
# Supports:
# - VS Code Remote (SSH, Dev Containers, WSL)
# - Workspace files (.code-workspace)
# - Multiple VS Code instances

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

# Find VS Code command (try multiple names)
find_vscode_cmd() {
    local vscode_cmd
    vscode_cmd=$(adapter_get_tool "code" "codium" "code-insiders") || return 1
    echo "$vscode_cmd"
}

# Open in VS Code
open_vscode() {
    local target="$1"
    local workspace_file="${2:-}"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local vscode_cmd
    vscode_cmd=$(find_vscode_cmd) || {
        adapter_log_error "VS Code not found in PATH"
        echo ""
        echo "Installation options:"
        echo "  macOS:  brew install --cask visual-studio-code"
        echo "  Ubuntu: sudo snap install code --classic"
        echo "  Manual: https://code.visualstudio.com"
        exit 127
    }
    
    adapter_log_debug "Using VS Code command: $vscode_cmd"
    adapter_log_debug "Opening: $target"
    
    # If workspace file specified, use it
    if [ -n "$workspace_file" ] && [ -f "$workspace_file" ]; then
        adapter_log_debug "Opening workspace: $workspace_file"
        adapter_exec_bg "$vscode_cmd" "$workspace_file"
    else
        # Check for workspace file in directory
        if [ -f "$target/.code-workspace" ]; then
            adapter_log_debug "Found .code-workspace file"
            adapter_exec_bg "$vscode_cmd" "$target/.code-workspace"
        else
            adapter_exec_bg "$vscode_cmd" "$target"
        fi
    fi
    
    adapter_log_info "VS Code opening with: $target"
    return 0
}

# Check if VS Code is installed and available
check_vscode() {
    if find_vscode_cmd >/dev/null 2>&1; then
        local vscode_cmd
        vscode_cmd=$(find_vscode_cmd)
        local version
        version=$("$vscode_cmd" --version 2>/dev/null | head -1 || echo "unknown")
        adapter_log_info "VS Code found: $version"
        return 0
    else
        adapter_log_error "VS Code not found"
        return 1
    fi
}

# Get VS Code version
get_version() {
    local vscode_cmd
    vscode_cmd=$(find_vscode_cmd) || return 1
    "$vscode_cmd" --version 2>/dev/null || echo "unknown"
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
            local workspace="${2:-}"
            open_vscode "$target" "$workspace"
            ;;
        check)
            check_vscode
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr VS Code Adapter"
            echo "Usage: vscode.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path> [workspace]  Open path in VS Code"
            echo "  check                    Check if VS Code is installed"
            echo "  version                  Show VS Code version"
            echo "  help                     Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            ;;
        *)
            adapter_log_error "Unknown command: $cmd"
            echo "Try: $0 help"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
