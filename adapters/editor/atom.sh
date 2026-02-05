#!/usr/bin/env bash
# wtr Atom Editor Adapter
# Opens a worktree in Atom (GitHub's hackable text editor)
#
# Note: Atom is in maintenance mode as of December 2022
# Consider migrating to VS Code or other modern editors

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

# Find Atom command
find_atom_cmd() {
    adapter_get_tool "atom" || return 1
}

# Open in Atom
open_atom() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local atom_cmd
    atom_cmd=$(find_atom_cmd) || {
        adapter_log_error "Atom not found"
        echo ""
        echo "Installation: https://atom.io"
        echo "Note: Atom is in maintenance mode. Consider VS Code or other modern editors."
        exit 127
    }
    
    adapter_log_debug "Using Atom command: $atom_cmd"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Opening in Atom: $target"
    
    adapter_exec_bg "$atom_cmd" "$target"
    return 0
}

# Check if Atom is installed
check_atom() {
    if find_atom_cmd >/dev/null 2>&1; then
        local atom_cmd
        atom_cmd=$(find_atom_cmd)
        local version
        version=$("$atom_cmd" --version 2>/dev/null | head -1 || echo "unknown")
        adapter_log_info "Atom found: $version"
        adapter_log_warn "Note: Atom is in maintenance mode. Consider migrating to another editor."
        return 0
    else
        adapter_log_error "Atom not found"
        return 1
    fi
}

# Get Atom version
get_version() {
    local atom_cmd
    atom_cmd=$(find_atom_cmd) || return 1
    "$atom_cmd" --version 2>/dev/null | head -1 || echo "unknown"
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
            open_atom "$target"
            ;;
        check)
            check_atom
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Atom Adapter"
            echo "Usage: atom.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in Atom"
            echo "  check        Check if Atom is installed"
            echo "  version      Show Atom version"
            echo "  help         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            echo ""
            echo "Note: Atom is in maintenance mode. For a modern alternative:"
            echo "  - VS Code: https://code.visualstudio.com"
            echo "  - Zed: https://zed.dev"
            echo "  - Sublime Text: https://www.sublimetext.com"
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
