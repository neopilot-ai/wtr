#!/usr/bin/env bash
# wtr IntelliJ IDEA Editor Adapter
# Opens a worktree in IntelliJ IDEA (Java IDE)
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

# Find IntelliJ IDEA command (CLI or native)
find_idea_cmd() {
    # Try command line tool first
    if command -v idea >/dev/null 2>&1; then
        echo "idea"
        return 0
    fi
    
    # Try macOS native app
    if [ -d "/Applications/IntelliJ IDEA.app" ]; then
        echo "open-macos-idea"
        return 0
    fi
    
    # Check for PyCharm (sometimes used as IDEA)
    if command -v charm >/dev/null 2>&1; then
        echo "charm"
        return 0
    fi
    
    return 1
}

# Get the launcher type
get_idea_type() {
    local cmd
    cmd=$(find_idea_cmd) || return 1
    echo "$cmd"
}

# Open in IntelliJ IDEA
open_idea() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local idea_type
    idea_type=$(get_idea_type) || {
        adapter_log_error "IntelliJ IDEA not found"
        echo ""
        echo "Installation: https://www.jetbrains.com/idea/"
        exit 127
    }
    
    adapter_log_debug "Using IntelliJ IDEA launcher: $idea_type"
    adapter_log_debug "Opening: $target"
    adapter_log_info "Opening in IntelliJ IDEA: $target"
    
    case "$idea_type" in
        idea)
            adapter_exec_bg idea "$target"
            ;;
        open-macos-idea)
            adapter_exec_bg open -a "IntelliJ IDEA" "$target"
            ;;
        charm)
            adapter_exec_bg charm "$target"
            ;;
        *)
            adapter_log_error "Unknown IntelliJ launcher: $idea_type"
            return 1
            ;;
    esac
}

# Check if IntelliJ IDEA is installed
check_idea() {
    local idea_type
    idea_type=$(get_idea_type) || {
        adapter_log_error "IntelliJ IDEA not found"
        return 1
    }
    
    case "$idea_type" in
        idea)
            local version
            version=$(idea --version 2>/dev/null | head -1 || echo "unknown")
            adapter_log_info "IntelliJ IDEA found: $version"
            ;;
        open-macos-idea)
            adapter_log_info "IntelliJ IDEA found (macOS native app)"
            ;;
        charm)
            adapter_log_info "IntelliJ IDEA found (PyCharm)"
            ;;
    esac
    return 0
}

# Get version
get_version() {
    local idea_type
    idea_type=$(get_idea_type) || return 1
    
    case "$idea_type" in
        idea)
            idea --version 2>/dev/null | head -1 || echo "unknown"
            ;;
        open-macos-idea)
            echo "macOS native (version unavailable)"
            ;;
        charm)
            charm --version 2>/dev/null | head -1 || echo "unknown"
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
            open_idea "$target"
            ;;
        check)
            check_idea
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr IntelliJ IDEA Adapter"
            echo "Usage: idea.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in IntelliJ IDEA"
            echo "  check        Check if IntelliJ IDEA is installed"
            echo "  version      Show IntelliJ IDEA version"
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
