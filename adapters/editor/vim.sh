#!/usr/bin/env bash
# wtr Vim Editor Adapter
# Opens a worktree in Vim (terminal editor)
#
# Vim runs in the foreground, blocking until exit.
# Use :wq or :xa within Vim to close and return to wtr.

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

# Find Vim command
find_vim_cmd() {
    adapter_get_tool "vim" || return 1
}

# Open in Vim
open_vim() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local vim_cmd
    vim_cmd=$(find_vim_cmd) || {
        adapter_log_error "Vim not found in PATH"
        echo ""
        echo "Installation options:"
        echo "  macOS:  brew install vim"
        echo "  Ubuntu: sudo apt-get install vim"
        echo "  Manual: https://www.vim.org"
        exit 127
    }
    
    adapter_log_debug "Using Vim command: $vim_cmd"
    adapter_log_debug "Opening: $target"
    
    # Check if target is a directory or file
    local vim_args=()
    if [ -d "$target" ]; then
        # For directories, open with netrw browser
        adapter_log_info "Opening directory in Vim: $target"
        vim_args=("$target")
    else
        adapter_log_info "Opening file in Vim: $target"
        vim_args=("$target")
    fi
    
    # Run Vim in foreground (blocks until editor exits)
    adapter_exec "$vim_cmd" "${vim_args[@]}"
}

# Check if Vim is installed
check_vim() {
    if find_vim_cmd >/dev/null 2>&1; then
        local vim_cmd
        vim_cmd=$(find_vim_cmd)
        local version
        version=$("$vim_cmd" --version 2>/dev/null | head -1 || echo "unknown")
        adapter_log_info "Vim found: $version"
        return 0
    else
        adapter_log_error "Vim not found"
        return 1
    fi
}

# Get Vim version
get_version() {
    local vim_cmd
    vim_cmd=$(find_vim_cmd) || return 1
    "$vim_cmd" --version 2>/dev/null | head -1 || echo "unknown"
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
            open_vim "$target"
            ;;
        check)
            check_vim
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Vim Adapter"
            echo "Usage: vim.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in Vim (blocks until exit)"
            echo "  check        Check if Vim is installed"
            echo "  version      Show Vim version"
            echo "  help         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            echo ""
            echo "Tips:"
            echo "  - In Vim, use :wq to save and quit"
            echo "  - Use :qa to close all windows"
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
