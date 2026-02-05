#!/usr/bin/env bash
# wtr Cursor AI Adapter
# Opens a worktree in Cursor (AI-powered code editor)
#
# Cursor is an AI-first IDE with advanced code understanding
# More info: https://www.cursor.com

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

# Find Cursor command
find_cursor_cmd() {
    adapter_get_tool "cursor" || return 1
}

# Open in Cursor
open_cursor() {
    local target="$1"
    shift
    local args=("$@")
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local cursor_cmd
    cursor_cmd=$(find_cursor_cmd) || {
        adapter_log_error "Cursor not found"
        echo ""
        echo "Installation: https://www.cursor.com"
        exit 127
    }
    
    adapter_log_debug "Using Cursor command: $cursor_cmd"
    adapter_log_debug "Opening: $target with AI capabilities"
    adapter_log_info "Opening Cursor in: $target"
    
    # Launch Cursor in background
    adapter_exec_bg "$cursor_cmd" "$target" "${args[@]}"
}

# Check if Cursor is installed
check_cursor() {
    if find_cursor_cmd >/dev/null 2>&1; then
        local cursor_cmd
        cursor_cmd=$(find_cursor_cmd)
        local version
        version=$("$cursor_cmd" --version 2>/dev/null || echo "unknown")
        adapter_log_info "Cursor found: $version"
        return 0
    else
        adapter_log_error "Cursor not found"
        return 1
    fi
}

# Get Cursor version
get_version() {
    local cursor_cmd
    cursor_cmd=$(find_cursor_cmd) || return 1
    "$cursor_cmd" --version 2>/dev/null || echo "unknown"
}

# ============================================================================
# Main Command Handler
# ============================================================================

main() {
    local cmd="$1"
    shift || { adapter_log_error "No command specified"; exit 1; }
    
    case "$cmd" in
        open|start)
            local target="${1:-.}"
            shift || true
            open_cursor "$target" "$@"
            ;;
        check)
            check_cursor
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Cursor AI Adapter"
            echo "Usage: cursor.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|start <path> [args]  Start Cursor in specified path"
            echo "  check                     Check if Cursor is installed"
            echo "  version                   Show Cursor version"
            echo "  help                      Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG         Set to 1 to enable debug logging"
            echo ""
            echo "Examples:"
            echo "  cursor.sh open /path/to/repo"
            echo ""
            echo "More info: https://www.cursor.com"
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
