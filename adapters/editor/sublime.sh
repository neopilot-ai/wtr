#!/usr/bin/env bash
# wtr Sublime Text Editor Adapter
# Opens a worktree in Sublime Text
#
# Sublime Text is a lightweight and powerful text editor
# More info: https://www.sublimetext.com

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

# Find Sublime Text command
find_sublime_cmd() {
    # Check PATH first
    if command -v subl >/dev/null 2>&1; then
        echo "subl"
        return 0
    fi
    
    # Common installation paths
    local paths=(
        "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
        "/Applications/Sublime Text 4.app/Contents/SharedSupport/bin/subl"
        "/opt/sublime_text/sublime_text"
        "/usr/local/bin/subl"
        "/usr/bin/subl"
    )
    
    for path in "${paths[@]}"; do
        if [ -x "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Open in Sublime Text
open_sublime() {
    local target="$1"
    local workspace_file="${2:-}"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local sublime_cmd
    sublime_cmd=$(find_sublime_cmd) || {
        adapter_log_error "Sublime Text not found"
        echo ""
        echo "Installation: https://www.sublimetext.com"
        exit 127
    }
    
    adapter_log_debug "Using Sublime Text command: $sublime_cmd"
    adapter_log_debug "Opening: $target"
    
    # If workspace file specified, use it
    if [ -n "$workspace_file" ] && [ -f "$workspace_file" ]; then
        adapter_log_debug "Opening workspace: $workspace_file"
        adapter_exec_bg "$sublime_cmd" "$workspace_file"
    else
        adapter_exec_bg "$sublime_cmd" "$target"
    fi
    
    adapter_log_info "Sublime Text opening with: $target"
    return 0
}

# Check if Sublime Text is installed
check_sublime() {
    if find_sublime_cmd >/dev/null 2>&1; then
        local sublime_cmd
        sublime_cmd=$(find_sublime_cmd)
        adapter_log_info "Sublime Text found: $sublime_cmd"
        return 0
    else
        adapter_log_error "Sublime Text not found"
        return 1
    fi
}

# Get Sublime Text version
get_version() {
    local sublime_cmd
    sublime_cmd=$(find_sublime_cmd) || return 1
    
    # Sublime doesn't have a standard --version flag in PATH mode
    # Just return installed status
    echo "Installed at: $sublime_cmd"
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
            local workspace="${2:-}"
            open_sublime "$target" "$workspace"
            ;;
        check)
            check_sublime
            ;;
        version)
            get_version
            ;;
        help|--help|-h)
            echo "wtr Sublime Text Adapter"
            echo "Usage: sublime.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path> [workspace]  Open path in Sublime Text"
            echo "  check                    Check if Sublime Text is installed"
            echo "  version                  Show Sublime Text path"
            echo "  help                     Show this help"
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
main "$@"    return 1
}

sublime_bin=$(find_sublime)

case "$cmd" in
    open)
        if ! command -v "$sublime_bin" >/dev/null 2>&1; then
            echo "Sublime Text not found. Please install it or add it to your PATH." >&2
            exit 1
        fi
        
        # Create project file if it doesn't exist
        local project_file="$worktree_path/$(basename "$worktree_path").sublime-project"
        if [ ! -f "$project_file" ]; then
            cat > "$project_file" << PROJECT_EOF
{
    "folders": [
        {
            "path": "."
        }
    ],
    "settings": {
        "tab_size": 2,
        "translate_tabs_to_spaces": true
    }
}
PROJECT_EOF
        fi
        
        # Open Sublime Text with the project
        "$sublime_bin" -a "$worktree_path" "$worktree_path" >/dev/null 2>&1 &
        ;;
        
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac
