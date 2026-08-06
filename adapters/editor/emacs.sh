#!/usr/bin/env bash
# wtr Emacs Editor Adapter
# Opens a worktree in Emacs
#
# Supports both emacsclient (for existing daemon) and emacs (standalone)
# Uses non-blocking mode with emacsclient if available for better UX

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

# Find Emacs client (preferred) or Emacs
find_emacs_cmd() {
    if command -v emacsclient >/dev/null 2>&1; then
        echo "emacsclient"
        return 0
    elif command -v emacs >/dev/null 2>&1; then
        echo "emacs"
        return 0
    fi
    return 1
}

# Get which Emacs implementation is available
get_emacs_type() {
    if command -v emacsclient >/dev/null 2>&1; then
        echo "client"
    elif command -v emacs >/dev/null 2>&1; then
        echo "standalone"
    else
        echo "none"
    fi
}

# Open in Emacs
open_emacs() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local emacs_cmd
    emacs_cmd=$(find_emacs_cmd) || {
        adapter_log_error "Emacs not found in PATH"
        echo ""
        echo "Installation options:"
        echo "  macOS:  brew install emacs"
        echo "  Ubuntu: sudo apt-get install emacs"
        echo "  Manual: https://www.gnu.org/software/emacs/"
        exit 127
    }
    
    adapter_log_debug "Using Emacs command: $emacs_cmd"
    adapter_log_debug "Opening: $target"
    
    local emacs_type
    emacs_type=$(get_emacs_type)
    
    case "$emacs_type" in
        client)
            # Use emacsclient for non-blocking mode
            adapter_log_info "Opening in Emacs daemon via emacsclient: $target"
            adapter_exec_bg emacsclient -n "$target"
            ;;
        standalone)
            # Use emacs directly
            adapter_log_info "Opening in Emacs: $target"
            adapter_exec_bg emacs "$target"
            ;;
        *)
            adapter_log_error "No suitable Emacs implementation found"
            return 1
            ;;
    esac
}

# Check if Emacs is installed
check_emacs() {
    local emacs_type
    emacs_type=$(get_emacs_type)
    
    case "$emacs_type" in
        client)
            local version
            version=$(emacsclient --version 2>/dev/null | head -1 || echo "unknown")
            adapter_log_info "Emacs (via emacsclient) found: $version"
            return 0
            ;;
        standalone)
            local version
            version=$(emacs --version 2>/dev/null | head -1 || echo "unknown")
            adapter_log_info "Emacs (standalone) found: $version"
            return 0
            ;;
        *)
            adapter_log_error "Emacs not found"
            return 1
            ;;
    esac
}

# Get Emacs version
get_version() {
    if command -v emacsclient >/dev/null 2>&1; then
        emacsclient --version 2>/dev/null | head -1 || echo "unknown"
    elif command -v emacs >/dev/null 2>&1; then
        emacs --version 2>/dev/null | head -1 || echo "unknown"
    else
        echo "unknown"
    fi
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
            open_emacs "$target"
            ;;
        check)
            check_emacs
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Emacs Adapter"
            echo "Usage: emacs.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in Emacs"
            echo "  check        Check if Emacs is installed"
            echo "  version      Show Emacs version"
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
