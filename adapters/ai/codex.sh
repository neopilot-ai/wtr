#!/usr/bin/env bash
# wtr OpenAI Codex AI Adapter
# Integrates with OpenAI's Codex
#
# Note: OpenAI Codex models have been deprecated in favor of GPT-4 and GPT-4 Turbo
# This adapter provides access to the OpenAI Playground

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

# Check for required tools
check_browser_available() {
    command -v xdg-open >/dev/null 2>&1 || \
    command -v open >/dev/null 2>&1 || \
    command -v "$(basename "$BROWSER")" >/dev/null 2>&1 2>/dev/null
}

# Open browser to OpenAI Playground
open_playground() {
    local url="https://platform.openai.com/playground"
    
    adapter_log_info "Opening OpenAI Playground: $url"
    
    if command -v xdg-open >/dev/null 2>&1; then
        adapter_exec_bg xdg-open "$url"
    elif command -v open >/dev/null 2>&1; then
        adapter_exec_bg open "$url"
    elif [ -n "$BROWSER" ]; then
        adapter_exec_bg "$BROWSER" "$url"
    else
        adapter_log_warn "Unable to auto-open browser"
        echo "Please visit: $url"
        return 1
    fi
}

# Check Codex status
check_codex() {
    adapter_log_warn "Note: OpenAI Codex models have been deprecated"
    adapter_log_info "Recommended alternatives:"
    echo "  - GPT-4 Turbo (latest and most capable)"
    echo "  - GPT-3.5 Turbo (fast and cost-effective)"
    echo "  - Cursor IDE (specialized for coding)"
    echo "  - Aider (CLI-based pair programming)"
    echo ""
    echo "For legacy Codex access, visit: https://platform.openai.com/playground"
}

# Get OpenAI API key status
check_api_key() {
    if [ -n "$OPENAI_API_KEY" ]; then
        adapter_log_info "OPENAI_API_KEY is set"
        return 0
    elif [ -f "$HOME/.openai/key" ]; then
        adapter_log_info "OpenAI key file found at ~/.openai/key"
        return 0
    else
        adapter_log_warn "No OpenAI API key found"
        echo ""
        echo "To use OpenAI services, set OPENAI_API_KEY:"
        echo "  export OPENAI_API_KEY='your-key-here'"
        echo ""
        echo "Get your key from: https://platform.openai.com/api-keys"
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
        open|playground)
            open_playground
            ;;
        check|status)
            check_codex
            check_api_key
            ;;
        help|--help|-h)
            echo "wtr OpenAI Codex Adapter"
            echo "Usage: codex.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|playground  Open OpenAI Playground in browser"
            echo "  check|status     Show Codex status and OpenAI configuration"
            echo "  help             Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG     Set to 1 to enable debug logging"
            echo "  OPENAI_API_KEY        Your OpenAI API key"
            echo "  BROWSER               Browser command to use for opening URLs"
            echo ""
            echo "Important:"
            echo "  OpenAI Codex models have been deprecated in favor of GPT-4 and GPT-4 Turbo."
            echo "  Use GPT-4 Turbo for superior coding assistance."
            echo ""
            echo "More info:"
            echo "  - GPT-4 Turbo: https://platform.openai.com/docs/guides/gpt-4"
            echo "  - API Keys: https://platform.openai.com/api-keys"
            echo "  - Playground: https://platform.openai.com/playground"
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
