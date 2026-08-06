#!/usr/bin/env bash
# wtr Continue.dev AI Adapter
# Integrates with Continue.dev (IDE-embedded AI assistant)
#
# Continue.dev runs inside your editor (VS Code, JetBrains IDEs, etc.)
# More info: https://continue.dev

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

# Find configuration or detect setup
detect_continue_setup() {
    # Check for Continue config in common locations
    if [ -d "$HOME/.continue" ]; then
        echo "found"
        return 0
    elif [ -d "$HOME/.config/continue" ]; then
        echo "found"
        return 0
    else
        echo "not-configured"
        return 1
    fi
}

# Get recommended editor with Continue support
get_recommended_editor() {
    # Check available editors
    if command -v code >/dev/null 2>&1; then
        echo "VS Code"
    elif command -v webstorm >/dev/null 2>&1; then
        echo "WebStorm"
    elif command -v idea >/dev/null 2>&1; then
        echo "IntelliJ IDEA"
    elif command -v pycharm >/dev/null 2>&1; then
        echo "PyCharm"
    else
        echo "VS Code"
    fi
}

# Open Continue in configured editor
open_continue() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    local setup_status
    setup_status=$(detect_continue_setup)
    
    if [ "$setup_status" != "found" ]; then
        adapter_log_warn "Continue.dev not fully configured"
        echo ""
        echo "To use Continue.dev:"
        echo "1. Install Continue.dev extension in your editor"
        echo "2. Configure your LLM provider (OpenAI, Anthropic, etc.)"
        echo "3. Visit https://continue.dev/docs for setup instructions"
        echo ""
        return 1
    fi
    
    local editor
    editor=$(get_recommended_editor)
    adapter_log_info "Continue.dev runs inside your editor: $editor"
    adapter_log_info "Opening $target in $editor with Continue.dev support"
    
    echo "Continue.dev is integrated into your editor. Open $target with your configured editor:"
    echo "  - For VS Code: code $target"
    echo "  - For JetBrains:  webstorm $target"
    echo ""
    echo "Then use Continue.dev's chat interface with Ctrl+L (or Cmd+L on macOS)"
}

# Check Continue configuration
check_continue() {
    local setup_status
    setup_status=$(detect_continue_setup)
    
    if [ "$setup_status" = "found" ]; then
        adapter_log_info "Continue.dev appears to be configured"
        
        # Check for config file
        if [ -f "$HOME/.continue/config.py" ]; then
            adapter_log_info "Config file found at ~/.continue/config.py"
        fi
        return 0
    else
        adapter_log_warn "Continue.dev not configured"
        echo ""
        echo "To set up Continue.dev:"
        echo "1. Visit https://continue.dev/docs/quickstart"
        echo "2. Install for your editor:"
        echo "   - VS Code: Continue.dev extension"
        echo "   - JetBrains IDEs: Continue Plugin"
        echo "   - Others: Check https://continue.dev"
        echo "3. Configure LLM provider in ~/.continue/config.py"
        return 1
    fi
}

# Get setup instructions
show_setup_instructions() {
    echo "Continue.dev Setup Instructions"
    echo "==============================="
    echo ""
    echo "Continue.dev is an extensible AI assistant for your code editor."
    echo ""
    echo "1. Install Extension:"
    echo "   VS Code:     Marketplace > 'Continue'"
    echo "   JetBrains:   Plugins > Search 'Continue'"
    echo "   Others:      Check https://continue.dev"
    echo ""
    echo "2. Configure LLM:"
    echo "   Edit ~/.continue/config.py with your LLM settings"
    echo ""
    echo "3. Restart Editor"
    echo ""
    echo "4. Use Continue:"
    echo "   - Open Chat: Ctrl+L (or Cmd+L on macOS)"
    echo "   - Select Code: Highlight and ask about it"
    echo ""
    echo "More: https://continue.dev/docs"
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
            open_continue "$target"
            ;;
        check|setup)
            check_continue
            ;;
        install)
            show_setup_instructions
            ;;
        help|--help|-h)
            echo "wtr Continue.dev Adapter"
            echo "Usage: continue.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|start <path>  Show how to open path with Continue.dev"
            echo "  check|setup        Check Continue.dev configuration"
            echo "  install            Show installation instructions"
            echo "  help               Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG  Set to 1 to enable debug logging"
            echo ""
            echo "About Continue.dev:"
            echo "  Continue.dev is an IDE-embedded AI assistant that runs inside"
            echo "  your editor (VS Code, JetBrains, etc.) as an extension."
            echo ""
            echo "More info: https://continue.dev"
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
