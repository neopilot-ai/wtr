#!/usr/bin/env bash
# wtr PyCharm Editor Adapter
# Opens a worktree in PyCharm (Python IDE)
#
# Supports both CLI and native macOS app launch

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

# Find PyCharm command (CLI or native)
find_pycharm_cmd() {
    # Try command line tool first
    if command -v pycharm >/dev/null 2>&1; then
        echo "pycharm"
        return 0
    fi
    
    # Try alternative command name
    if command -v charm >/dev/null 2>&1; then
        echo "charm"
        return 0
    fi
    
    # Try macOS native app
    if [ -d "/Applications/PyCharm.app" ]; then
        echo "open-macos-pycharm"
        return 0
    fi
    
    return 1
}

# Get the launcher type
get_pycharm_type() {
    local cmd
    cmd=$(find_pycharm_cmd) || return 1
    echo "$cmd"
}

# Open in PyCharm
open_pycharm() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local pycharm_type
    pycharm_type=$(get_pycharm_type) || {
        adapter_log_error "PyCharm not found"
        echo ""
        echo "Installation: https://www.jetbrains.com/pycharm/"
        exit 127
    }
    
    adapter_log_debug "Using PyCharm launcher: $pycharm_type"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Opening in PyCharm: $target"
    
    case "$pycharm_type" in
        pycharm|charm)
            adapter_exec_bg "$pycharm_type" "$target"
            ;;
        open-macos-pycharm)
            adapter_exec_bg open -a "PyCharm" "$target"
            ;;
        *)
            adapter_log_error "Unknown PyCharm launcher: $pycharm_type"
            return 1
            ;;
    esac
}

# Check if PyCharm is installed
check_pycharm() {
    local pycharm_type
    pycharm_type=$(get_pycharm_type) || {
        adapter_log_error "PyCharm not found"
        return 1
    }
    
    case "$pycharm_type" in
        pycharm|charm)
            local version
            version=$("$pycharm_type" --version 2>/dev/null | head -1 || echo "unknown")
            adapter_log_info "PyCharm found: $version"
            ;;
        open-macos-pycharm)
            adapter_log_info "PyCharm found (macOS native app)"
            ;;
    esac
    return 0
}

# Get version
get_version() {
    local pycharm_type
    pycharm_type=$(get_pycharm_type) || return 1
    
    case "$pycharm_type" in
        pycharm|charm)
            "$pycharm_type" --version 2>/dev/null | head -1 || echo "unknown"
            ;;
        open-macos-pycharm)
            echo "macOS native (version unavailable)"
            ;;
    esac
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
            open_pycharm "$target"
            ;;
        check)
            check_pycharm
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr PyCharm Adapter"
            echo "Usage: pycharm.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in PyCharm"
            echo "  check        Check if PyCharm is installed"
            echo "  version      Show PyCharm version"
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
main "$@"
