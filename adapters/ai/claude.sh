#!/usr/bin/env bash
# wtr Claude AI Adapter
# Provides access to Claude API for analysis and suggestions
#
# Claude is Anthropic's AI model with extended context windows
# More info: https://www.anthropic.com/claude

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
CLAUDE_MODEL="${CLAUDE_MODEL:-claude-3-5-sonnet-20241022}"
CLAUDE_API_ENDPOINT="https://api.anthropic.com/v1"
CLAUDE_API_VERSION="2023-06-01"

# Load API key from environment or config file
load_api_key() {
    # Check environment variable first
    if [ -n "$CLAUDE_API_KEY" ]; then
        echo "$CLAUDE_API_KEY"
        return 0
    fi
    
    # Try config file locations
    local config_locations=(
        "$HOME/.config/wtr/claude"
        "$HOME/.config/neopilot/claude"
        "$HOME/.anthropic/api_key"
        "$HOME/.claude/api_key"
    )
    
    for config_file in "${config_locations[@]}"; do
        if [ -f "$config_file" ]; then
            cat "$config_file" | tr -d ' \n'
            return 0
        fi
    done
    
    return 1
}

# Make API call to Claude
claude_api_call() {
    local endpoint="$1"
    local data="$2"
    local api_key="$3"
    
    adapter_log_debug "Making API request to: $CLAUDE_API_ENDPOINT/$endpoint"
    
    local response
    response=$(curl -s -X POST "$CLAUDE_API_ENDPOINT/$endpoint" \
        -H "x-api-key: $api_key" \
        -H "anthropic-version: $CLAUDE_API_VERSION" \
        -H "Content-Type: application/json" \
        -d "$data" 2>/dev/null)
    
    echo "$response"
}

# Get project analysis
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
        adapter_log_error "Claude API key not found"
        echo ""
        echo "Set up Claude API key:"
        echo "  1. Get key from: https://console.anthropic.com"
        echo "  2. Set environment: export CLAUDE_API_KEY='your-key'"
        echo "  3. Or save to: $HOME/.config/wtr/claude"
        exit 127
    }
    
    adapter_log_info "Analyzing project in: $target"
    adapter_log_debug "Using model: $CLAUDE_MODEL"
    
    # Build project analysis prompt
    local prompt=""
    local recent_changes=""
    local file_count=0
    local readme_content=""
    
    # Get recent git commits
    if [ -d "$target/.git" ]; then
        recent_changes=$(cd "$target" && git log -n 5 --pretty=format:"%h - %s (%an, %ar)" 2>/dev/null || echo "")
        if [ -n "$recent_changes" ]; then
            prompt="Recent changes:\n$recent_changes\n\n"
        fi
    fi
    
    # Get project structure
    if [ -f "$target/README.md" ]; then
        readme_content=$(head -n 50 "$target/README.md" 2>/dev/null || echo "")
        prompt+="Project README:\n$readme_content\n\n"
    fi
    
    prompt+="Based on this project context, what should I work on next? Please provide specific suggestions."
    
    adapter_log_debug "Sending prompt to Claude"
    
    # Make API call
    local request_body
    request_body=$(jq -n \
        --arg model "$CLAUDE_MODEL" \
        --arg prompt "$prompt" \
        '{
            model: $model,
            max_tokens: 1024,
            messages: [
                {role: "user", content: $prompt}
            ]
        }')
    
    local response
    response=$(claude_api_call "messages" "$request_body" "$api_key")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        adapter_log_error "Claude API error:"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
    
    # Extract and display response
    adapter_log_info "Claude analysis complete"
    echo ""
    echo "🤖 Claude's suggestions:"
    echo "$response" | jq -r '.content[0].text' 2>/dev/null || echo "Unable to parse response"
}

# Check Claude configuration
check_claude() {
    if load_api_key >/dev/null 2>&1; then
        adapter_log_info "Claude API key is configured"
        adapter_log_info "Using model: $CLAUDE_MODEL"
        return 0
    else
        adapter_log_error "Claude API key not configured"
        return 1
    fi
}

# Open Claude web interface
open_web_interface() {
    adapter_log_info "Opening Claude web interface"
    
    if command -v xdg-open >/dev/null 2>&1; then
        adapter_exec_bg xdg-open "https://claude.ai"
    elif command -v open >/dev/null 2>&1; then
        adapter_exec_bg open "https://claude.ai"
    elif [ -n "$BROWSER" ]; then
        adapter_exec_bg "$BROWSER" "https://claude.ai"
    else
        adapter_log_warn "Unable to auto-open browser"
        echo "Visit: https://claude.ai"
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
        web|chat)
            open_web_interface
            ;;
        check|status)
            check_claude
            ;;
        version)
            echo "$CLAUDE_MODEL"
            ;;
        help|--help|-h)
            echo "wtr Claude AI Adapter"
            echo "Usage: claude.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|analyze <path>  Analyze project and get Claude suggestions"
            echo "  web|chat             Open Claude web interface"
            echo "  check|status         Check Claude API configuration"
            echo "  version              Show Claude model in use"
            echo "  help                 Show this help"
            echo ""
            echo "Configuration:"
            echo "  Set CLAUDE_API_KEY environment variable"
            echo "  Or save key to: ~/.config/wtr/claude"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG    Set to 1 to enable debug logging"
            echo "  CLAUDE_API_KEY       Your Anthropic API key"
            echo "  CLAUDE_MODEL         Override default model (default: claude-3-5-sonnet-20241022)"
            echo ""
            echo "Get API Key:"
            echo "  https://console.anthropic.com"
            echo ""
            echo "More info: https://www.anthropic.com/claude"
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
