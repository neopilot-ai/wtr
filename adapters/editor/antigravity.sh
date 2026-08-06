#!/usr/bin/env bash
# wtr Antigravity Editor Adapter
# Opens a worktree in Antigravity (cloud-based code editor)
#
# Antigravity is a modern, cloud-based alternative to traditional editors
# More info: https://antigravity.dev

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

# Find Antigravity command
find_antigravity_cmd() {
    adapter_get_tool "antigravity" || return 1
}

# Open in Antigravity
open_antigravity() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local antigravity_cmd
    antigravity_cmd=$(find_antigravity_cmd) || {
        adapter_log_error "Antigravity CLI not found"
        echo ""
        echo "Installation: https://antigravity.dev"
        exit 127
    }
    
    adapter_log_debug "Using Antigravity command: $antigravity_cmd"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Opening in Antigravity: $target"
    
    adapter_exec_bg "$antigravity_cmd" "$target"
    return 0
}

# Check if Antigravity is installed
check_antigravity() {
    if find_antigravity_cmd >/dev/null 2>&1; then
        local antigravity_cmd
        antigravity_cmd=$(find_antigravity_cmd)
        local version
        version=$("$antigravity_cmd" --version 2>/dev/null || echo "unknown")
        adapter_log_info "Antigravity found: $version"
        return 0
    else
        adapter_log_error "Antigravity not found"
        return 1
    fi
}

# Get Antigravity version
get_version() {
    local antigravity_cmd
    antigravity_cmd=$(find_antigravity_cmd) || return 1
    "$antigravity_cmd" --version 2>/dev/null || echo "unknown"
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
            open_antigravity "$target"
            ;;
        check)
            check_antigravity
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Antigravity Adapter"
            echo "Usage: antigravity.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in Antigravity"
            echo "  check        Check if Antigravity is installed"
            echo "  version      Show Antigravity version"
            echo "  help         Show this help"
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
