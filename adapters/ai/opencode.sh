#!/usr/bin/env bash
# wtr OpenCode AI Adapter
# Opens a worktree in OpenCode (AI-powered interpreter)
#
# OpenCode is an interpreter that understands and executes your code
# More info: https://github.com/opencode-ai/opencode

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

# Find OpenCode command
find_opencode_cmd() {
    adapter_get_tool "opencode" || return 1
}

# Open in OpenCode
open_opencode() {
    local target="$1"
    shift
    local args=("$@")
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local opencode_cmd
    opencode_cmd=$(find_opencode_cmd) || {
        adapter_log_error "OpenCode not found"
        echo ""
        echo "Installation: pip install opencode or check https://github.com/opencode-ai/opencode"
        exit 127
    }
    
    adapter_log_debug "Using OpenCode command: $opencode_cmd"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Starting OpenCode in: $target"
    
    # Change to target directory and run opencode
    (cd "$target" && adapter_exec "$opencode_cmd" "${args[@]}")
}

# Run analysis on the codebase
analyze_opencode() {
    local target="$1"
    shift
    local args=("$@")
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local opencode_cmd
    opencode_cmd=$(find_opencode_cmd) || {
        adapter_log_error "OpenCode not found"
        exit 127
    }
    
    adapter_log_debug "Running analysis with OpenCode on: $target"
    
    # Change to target directory and run analysis
    (cd "$target" && adapter_exec "$opencode_cmd" analyze "${args[@]}")
}

# Check if OpenCode is installed
check_opencode() {
    if find_opencode_cmd >/dev/null 2>&1; then
        local opencode_cmd
        opencode_cmd=$(find_opencode_cmd)
        local version
        version=$("$opencode_cmd" --version 2>/dev/null || echo "unknown")
        adapter_log_info "OpenCode found: $version"
        return 0
    else
        adapter_log_error "OpenCode not found"
        return 1
    fi
}

# Get OpenCode version
get_version() {
    local opencode_cmd
    opencode_cmd=$(find_opencode_cmd) || return 1
    "$opencode_cmd" --version 2>/dev/null || echo "unknown"
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
            open_opencode "$target" "$@"
            ;;
        analyze)
            local target="${1:-.}"
            shift || true
            analyze_opencode "$target" "$@"
            ;;
        check)
            check_opencode
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr OpenCode Adapter"
            echo "Usage: opencode.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|start <path> [args]  Start OpenCode in specified path"
            echo "  analyze <path> [args]     Run analysis on specified path"
            echo "  check                     Check if OpenCode is installed"
            echo "  version                   Show OpenCode version"
            echo "  help                      Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG         Set to 1 to enable debug logging"
            echo ""
            echo "Examples:"
            echo "  opencode.sh open /path/to/repo"
            echo "  opencode.sh analyze /path/to/repo"
            echo ""
            echo "More info: https://github.com/opencode-ai/opencode"
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
