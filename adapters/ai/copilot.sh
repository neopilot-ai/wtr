#!/usr/bin/env bash
# wtr GitHub Copilot AI Adapter
# Integrates with GitHub Copilot for code generation and assistance
#
# GitHub Copilot requires GitHub CLI (gh) for authentication
# More info: https://github.com/features/copilot

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

# Configuration
COPILOT_API_URL="https://api.openai.com/v1"

# Check for GitHub CLI
check_github_cli() {
    if command -v gh >/dev/null 2>&1; then
        adapter_log_debug "GitHub CLI found"
        return 0
    else
        adapter_log_error "GitHub CLI (gh) not found"
        return 1
    fi
}

# Get GitHub authentication token
get_github_token() {
    if ! check_github_cli; then
        adapter_log_error "GitHub CLI required"
        return 1
    fi
    
    adapter_log_debug "Getting GitHub token from CLI"
    gh auth token 2>/dev/null || return 1
}

# Check Copilot configuration
check_copilot() {
    if ! check_github_cli; then
        adapter_log_error "GitHub CLI is required"
        echo ""
        echo "Installation:"
        echo "  macOS:  brew install gh"
        echo "  Ubuntu: sudo apt-get install gh"
        echo "  Manual: https://cli.github.com"
        return 1
    fi
    
    # Check if authenticated
    if gh auth status >/dev/null 2>&1; then
        adapter_log_info "GitHub CLI authenticated"
        adapter_log_info "Copilot integration available"
        return 0
    else
        adapter_log_error "GitHub CLI not authenticated"
        echo ""
        echo "Authenticate with: gh auth login"
        return 1
    fi
}

# Open Copilot (typically in editor or web)
open_copilot() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    # Check GitHub CLI
    if ! check_github_cli; then
        adapter_log_error "GitHub CLI is required for Copilot integration"
        return 1
    fi
    
    adapter_log_info "GitHub Copilot runs inside VS Code via extension"
    adapter_log_info "Use 'editor' adapter to open with Copilot support"
    echo ""
    echo "To use GitHub Copilot:"
    echo "1. Open directory with VS Code: code $target"
    echo "2. Install Copilot extension from VS Code marketplace"
    echo "3. Authenticate with GitHub"
    echo "4. Ask Copilot questions with Ctrl+I"
    echo ""
    echo "More: https://github.com/features/copilot"
}

# Get Copilot status
get_status() {
    if check_copilot >/dev/null 2>&1; then
        adapter_log_info "Copilot is configured and ready"
        return 0
    else
        adapter_log_warn "Copilot not fully configured"
        return 1
    fi
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
            open_copilot "$target"
            ;;
        check|status)
            check_copilot
            ;;
        help|--help|-h)
            echo "wtr GitHub Copilot Adapter"
            echo "Usage: copilot.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open <path>   Show Copilot setup for directory"
            echo "  check|status  Check Copilot configuration"
            echo "  help          Show this help"
            echo ""
            echo "Requirements:"
            echo "  - GitHub CLI (gh) installed and authenticated"
            echo "  - GitHub Copilot subscription or free trial"
            echo "  - VS Code with Copilot extension (recommended)"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG  Set to 1 to enable debug logging"
            echo ""
            echo "Setup:"
            echo "  1. Install GitHub CLI: https://cli.github.com"
            echo "  2. Authenticate: gh auth login"
            echo "  3. Install VS Code Copilot extension"
            echo "  4. Open your repo with: code <path>"
            echo ""
            echo "More info: https://github.com/features/copilot"
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
