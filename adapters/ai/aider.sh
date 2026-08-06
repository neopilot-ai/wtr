#!/usr/bin/env bash
# wtr Aider AI Adapter
# Opens a worktree in Aider (AI pair programming)
#
# Aider is an AI-powered pair programming tool that improves your code
# More info: https://aider.chat

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

# Find Aider command
find_aider_cmd() {
    adapter_get_tool "aider" || return 1
}

# Open in Aider
open_aider() {
    local target="$1"
    shift
    local args=("$@")
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local aider_cmd
    aider_cmd=$(find_aider_cmd) || {
        adapter_log_error "Aider not found"
        echo ""
        echo "Installation: pip install aider-chat"
        exit 127
    }
    
    adapter_log_debug "Using Aider command: $aider_cmd"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Starting Aider in: $target"
    
    # Change to target directory and run aider
    (cd "$target" && adapter_exec "$aider_cmd" "${args[@]}")
}

# Check if Aider is installed
check_aider() {
    if find_aider_cmd >/dev/null 2>&1; then
        local aider_cmd
        aider_cmd=$(find_aider_cmd)
        local version
        version=$("$aider_cmd" --version 2>/dev/null || echo "unknown")
        adapter_log_info "Aider found: $version"
        return 0
    else
        adapter_log_error "Aider not found"
        return 1
    fi
}

# Get Aider version
get_version() {
    local aider_cmd
    aider_cmd=$(find_aider_cmd) || return 1
    "$aider_cmd" --version 2>/dev/null || echo "unknown"
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
            open_aider "$target" "$@"
            ;;
        check)
            check_aider
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Aider Adapter"
            echo "Usage: aider.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|start <path> [args]  Start Aider in specified path"
            echo "  check                     Check if Aider is installed"
            echo "  version                   Show Aider version"
            echo "  help                      Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG         Set to 1 to enable debug logging"
            echo "  AIDER_MODEL               Override default AI model"
            echo ""
            echo "Examples:"
            echo "  aider.sh open /path/to/repo"
            echo "  aider.sh open /path/to/repo --map-tokens 1024"
            echo ""
            echo "More info: https://aider.chat"
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
