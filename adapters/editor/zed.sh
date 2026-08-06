#!/usr/bin/env bash
# wtr Zed Editor Adapter
# Opens a worktree in Zed (modern code editor)
#
# Zed is a high-performance code editor written in Rust
# More info: https://zed.dev

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

# Find Zed command (try common installation paths)
find_zed_cmd() {
    local zed_bin="zed"
    
    # Check PATH first
    if command -v "$zed_bin" >/dev/null 2>&1; then
        echo "$zed_bin"
        return 0
    fi
    
    # Try common installation paths
    local paths=(
        "$HOME/.local/bin/zed"
        "/opt/zed/zed"
        "/Applications/Zed.app/Contents/MacOS/zed"
    )
    
    for path in "${paths[@]}"; do
        if [ -x "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Open in Zed
open_zed() {
    local target="$1"
    local workspace_file="${2:-}"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local zed_cmd
    zed_cmd=$(find_zed_cmd) || {
        adapter_log_error "Zed not found"
        echo ""
        echo "Installation: https://zed.dev"
        exit 127
    }
    
    adapter_log_debug "Using Zed command: $zed_cmd"
    adapter_log_debug "Opening: $target"
    
    # If workspace file specified, use it
    if [ -n "$workspace_file" ] && [ -f "$workspace_file" ]; then
        adapter_log_debug "Opening workspace: $workspace_file"
        adapter_exec_bg "$zed_cmd" "$workspace_file"
    else
        # Check for workspace file in directory
        if [ -f "$target/zed.code-workspace" ]; then
            adapter_log_debug "Found zed.code-workspace file"
            adapter_exec_bg "$zed_cmd" "$target/zed.code-workspace"
        else
            adapter_exec_bg "$zed_cmd" "$target"
        fi
    fi
    
    adapter_log_info "Zed opening with: $target"
    return 0
}

# Check if Zed is installed
check_zed() {
    if find_zed_cmd >/dev/null 2>&1; then
        local zed_cmd
        zed_cmd=$(find_zed_cmd)
        local version
        version=$("$zed_cmd" --version 2>/dev/null || echo "unknown")
        adapter_log_info "Zed found: $version"
        return 0
    else
        adapter_log_error "Zed not found"
        return 1
    fi
}

# Get Zed version
get_version() {
    local zed_cmd
    zed_cmd=$(find_zed_cmd) || return 1
    "$zed_cmd" --version 2>/dev/null || echo "unknown"
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
            open_zed "$target" "$workspace"
            ;;
        check)
            check_zed
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Zed Adapter"
            echo "Usage: zed.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path> [workspace]  Open path in Zed"
            echo "  check                    Check if Zed is installed"
            echo "  version                  Show Zed version"
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
if [ $# -gt 0 ]; then
    main "$@"
fi
