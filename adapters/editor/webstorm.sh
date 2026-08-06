#!/usr/bin/env bash
# wtr WebStorm Editor Adapter
# Opens a worktree in WebStorm (JavaScript/TypeScript IDE)
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

# Find WebStorm command (CLI or native)
find_webstorm_cmd() {
    # Try command line tool first
    if command -v webstorm >/dev/null 2>&1; then
        echo "webstorm"
        return 0
    fi
    
    # Try macOS native app
    if [ -d "/Applications/WebStorm.app" ]; then
        echo "open-macos-webstorm"
        return 0
    fi
    
    return 1
}

# Get the launcher type
get_webstorm_type() {
    local cmd
    cmd=$(find_webstorm_cmd) || return 1
    echo "$cmd"
}

# Open in WebStorm
open_webstorm() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local webstorm_type
    webstorm_type=$(get_webstorm_type) || {
        adapter_log_error "WebStorm not found"
        echo ""
        echo "Installation: https://www.jetbrains.com/webstorm/"
        exit 127
    }
    
    adapter_log_debug "Using WebStorm launcher: $webstorm_type"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Opening in WebStorm: $target"
    
    case "$webstorm_type" in
        webstorm)
            adapter_exec_bg webstorm "$target"
            ;;
        open-macos-webstorm)
            adapter_exec_bg open -a "WebStorm" "$target"
            ;;
        *)
            adapter_log_error "Unknown WebStorm launcher: $webstorm_type"
            return 1
            ;;
    esac
}

# Check if WebStorm is installed
check_webstorm() {
    local webstorm_type
    webstorm_type=$(get_webstorm_type) || {
        adapter_log_error "WebStorm not found"
        return 1
    }
    
    case "$webstorm_type" in
        webstorm)
            local version
            version=$(webstorm --version 2>/dev/null | head -1 || echo "unknown")
            adapter_log_info "WebStorm found: $version"
            ;;
        open-macos-webstorm)
            adapter_log_info "WebStorm found (macOS native app)"
            ;;
    esac
    return 0
}

# Get version
get_version() {
    local webstorm_type
    webstorm_type=$(get_webstorm_type) || return 1
    
    case "$webstorm_type" in
        webstorm)
            webstorm --version 2>/dev/null | head -1 || echo "unknown"
            ;;
        open-macos-webstorm)
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
            open_webstorm "$target"
            ;;
        check)
            check_webstorm
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr WebStorm Adapter"
            echo "Usage: webstorm.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in WebStorm"
            echo "  check        Check if WebStorm is installed"
            echo "  version      Show WebStorm version"
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
