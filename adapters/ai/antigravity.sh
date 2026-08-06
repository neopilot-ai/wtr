#!/usr/bin/env bash
# wtr Antigravity AI Adapter
# Provides access to Antigravity's cloud-based AI services
#
# Antigravity is an AI-powered development platform
# More info: https://antigravity.dev

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

# Configuration defaults
ANTIGRAVITY_MODEL="${ANTIGRAVITY_MODEL:-antigravity-pro}"
ANTIGRAVITY_API_ENDPOINT="https://api.antigravity.dev/v1"

# Load API key
load_api_key() {
    # Check environment variable first
    if [ -n "$ANTIGRAVITY_API_KEY" ]; then
        echo "$ANTIGRAVITY_API_KEY"
        return 0
    fi
    
    # Try config file locations
    local config_locations=(
        "$HOME/.config/wtr/antigravity"
        "$HOME/.config/neopilot/antigravity"
        "$HOME/.antigravity/api_key"
    )
    
    for config_file in "${config_locations[@]}"; do
        if [ -f "$config_file" ]; then
            cat "$config_file" | tr -d ' \n'
            return 0
        fi
    done
    
    return 1
}

# Make API call to Antigravity
antigravity_api_call() {
    local endpoint="$1"
    local data="$2"
    local api_key="$3"
    
    adapter_log_debug "Making API request to: $ANTIGRAVITY_API_ENDPOINT/$endpoint"
    
    local response
    response=$(curl -s -X POST "$ANTIGRAVITY_API_ENDPOINT/$endpoint" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d "$data" 2>/dev/null)
    
    echo "$response"
}

# Analyze project using Antigravity
analyze_project() {
    local target="$1"
    
    # Validate path
    if ! adapter_validate_path "$target"; then
        adapter_log_error "Invalid target path: $target"
        return 1
    fi
    
    # Get or load API key
    local api_key
    api_key=$(load_api_key) || {
        adapter_log_error "Antigravity API key not found"
        echo ""
        echo "Set up Antigravity API key:"
        echo "  1. Sign up at: https://antigravity.dev"
        echo "  2. Get API key from dashboard"
        echo "  3. Set environment: export ANTIGRAVITY_API_KEY='your-key'"
        echo "  4. Or save to: $HOME/.config/wtr/antigravity"
        exit 127
    }
    
    adapter_log_info "Analyzing project with Antigravity: $target"
    adapter_log_debug "Using model: $ANTIGRAVITY_MODEL"
    
    # Build analysis prompt
    local prompt="Analyze project and provide insights:\n"
    
    # Get recent changes if git repo
    if [ -d "$target/.git" ]; then
        local changes
        changes=$(cd "$target" && git log -n 5 --pretty=format:"%h - %s" 2>/dev/null || echo "")
        if [ -n "$changes" ]; then
            prompt+="Recent work:\n$changes\n\n"
        fi
    fi
    
    # Add README if present
    if [ -f "$target/README.md" ]; then
        prompt+="Project info:\n$(head -n 30 "$target/README.md")\n\n"
    fi
    
    prompt+="What are the key areas and next steps?"
    
    # Make API call
    local request_body
    request_body=$(jq -n \
        --arg model "$ANTIGRAVITY_MODEL" \
        --arg prompt "$prompt" \
        '{
            model: $model,
            prompt: $prompt,
            max_tokens: 1024
        }')
    
    local response
    response=$(antigravity_api_call "analyze" "$request_body" "$api_key")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        adapter_log_error "Antigravity API error:"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
    
    # Extract and display response
    adapter_log_info "Analysis complete"
    echo ""
    echo "🤖 Antigravity analysis:"
    echo "$response" | jq -r '.result' 2>/dev/null || echo "$response"
}

# Check Antigravity configuration
check_antigravity() {
    if load_api_key >/dev/null 2>&1; then
        adapter_log_info "Antigravity API key is configured"
        adapter_log_info "Using model: $ANTIGRAVITY_MODEL"
        return 0
    else
        adapter_log_error "Antigravity API key not configured"
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
        open|analyze)
            local target="${1:-.}"
            analyze_project "$target"
            ;;
        check|status)
            check_antigravity
            ;;
        version)
            echo "$ANTIGRAVITY_MODEL"
            ;;
        help|--help|-h)
            echo "wtr Antigravity Adapter"
            echo "Usage: antigravity.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|analyze <path>  Analyze project with Antigravity"
            echo "  check|status         Check Antigravity configuration"
            echo "  version              Show Antigravity model in use"
            echo "  help                 Show this help"
            echo ""
            echo "Configuration:"
            echo "  Set ANTIGRAVITY_API_KEY environment variable"
            echo "  Or save key to: ~/.config/wtr/antigravity"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG        Set to 1 to enable debug logging"
            echo "  ANTIGRAVITY_API_KEY      Your Antigravity API key"
            echo "  ANTIGRAVITY_MODEL        Override default model (default: antigravity-pro)"
            echo ""
            echo "Get Started:"
            echo "  https://antigravity.dev"
            echo ""
            echo "More info: https://antigravity.dev/docs"
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
