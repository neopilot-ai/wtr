#!/usr/bin/env bash
# wtr Nano Editor Adapter
# Opens a worktree in Nano (simple terminal editor)
#
# Nano runs in the foreground, blocking until exit.
# Use Ctrl+X to exit and save changes.

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

# Find Nano command
find_nano_cmd() {
    adapter_get_tool "nano" || return 1
}

# Open in Nano
open_nano() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local nano_cmd
    nano_cmd=$(find_nano_cmd) || {
        adapter_log_error "Nano not found in PATH"
        echo ""
        echo "Installation options:"
        echo "  macOS:  brew install nano"
        echo "  Ubuntu: sudo apt-get install nano"
        echo "  Manual: https://www.nano-editor.org"
        exit 127
    }
    
    adapter_log_debug "Using Nano command: $nano_cmd"
    adapter_log_debug "Opening: $target"
    
    adapter_log_info "Opening in Nano: $target"
    
    # Run Nano in foreground (blocks until editor exits)
    adapter_exec "$nano_cmd" "$target"
}

# Check if Nano is installed
check_nano() {
    if find_nano_cmd >/dev/null 2>&1; then
        local nano_cmd
        nano_cmd=$(find_nano_cmd)
        local version
        version=$("$nano_cmd" --version 2>/dev/null | head -1 || echo "unknown")
        adapter_log_info "Nano found: $version"
        return 0
    else
        adapter_log_error "Nano not found"
        return 1
    fi
}

# Get Nano version
get_version() {
    local nano_cmd
    nano_cmd=$(find_nano_cmd) || return 1
    "$nano_cmd" --version 2>/dev/null | head -1 || echo "unknown"
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
            open_nano "$target"
            ;;
        check)
            check_nano
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Nano Adapter"
            echo "Usage: nano.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in Nano (blocks until exit)"
            echo "  check        Check if Nano is installed"
            echo "  version      Show Nano version"
            echo "  help         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            echo ""
            echo "Tips:"
            echo "  - In Nano, use Ctrl+X to save and quit"
            echo "  - Use Ctrl+O to save without quitting"
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
