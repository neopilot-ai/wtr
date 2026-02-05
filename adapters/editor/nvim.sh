#!/usr/bin/env bash
# wtr Neovim Editor Adapter
# Opens a worktree in Neovim (modern Vim fork)
#
# Neovim runs in the foreground, blocking until exit.
# Use :wq or :qa within Neovim to close and return to wtr.

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

# Find Neovim command
find_nvim_cmd() {
    adapter_get_tool "nvim" "neovim" || return 1
}

# Open in Neovim
open_nvim() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local nvim_cmd
    nvim_cmd=$(find_nvim_cmd) || {
        adapter_log_error "Neovim not found in PATH"
        echo ""
        echo "Installation options:"
        echo "  macOS:  brew install neovim"
        echo "  Ubuntu: sudo apt-get install neovim"
        echo "  Ubuntu PPA: sudo add-apt-repository ppa:neovim-ppa/unstable"
        echo "  Manual: https://neovim.io"
        exit 127
    }
    
    adapter_log_debug "Using Neovim command: $nvim_cmd"
    adapter_log_debug "Opening: $target"
    
    # Change to target for relative paths to work correctly
    if [ -d "$target" ]; then
        adapter_log_info "Opening directory in Neovim: $target"
        (cd "$target" && adapter_exec "$nvim_cmd")
    else
        adapter_log_info "Opening file in Neovim: $target"
        adapter_exec "$nvim_cmd" "$target"
    fi
}

# Check if Neovim is installed
check_nvim() {
    if find_nvim_cmd >/dev/null 2>&1; then
        local nvim_cmd
        nvim_cmd=$(find_nvim_cmd)
        local version
        version=$("$nvim_cmd" --version 2>/dev/null | head -1 || echo "unknown")
        adapter_log_info "Neovim found: $version"
        return 0
    else
        adapter_log_error "Neovim not found"
        return 1
    fi
}

# Get Neovim version
get_version() {
    local nvim_cmd
    nvim_cmd=$(find_nvim_cmd) || return 1
    "$nvim_cmd" --version 2>/dev/null | head -1 || echo "unknown"
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
            open_nvim "$target"
            ;;
        check)
            check_nvim
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Neovim Adapter"
            echo "Usage: nvim.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>  Open path in Neovim (blocks until exit)"
            echo "  check        Check if Neovim is installed"
            echo "  version      Show Neovim version"
            echo "  help         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            echo ""
            echo "Tips:"
            echo "  - In Neovim, use :wq to save and quit"
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
