#!/usr/bin/env bash
# wtr Google Gemini AI Adapter
# Provides access to Google's Gemini AI API
#
# Gemini is Google's advanced AI model with multimodal capabilities
# More info: https://ai.google.dev

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
GEMINI_MODEL="${GEMINI_MODEL:-gemini-1.5-pro}"
GEMINI_API_ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models"

# Load API key
load_api_key() {
    # Check environment variable first
    if [ -n "$GEMINI_API_KEY" ]; then
        echo "$GEMINI_API_KEY"
        return 0
    fi
    
    # Try config file locations
    local config_locations=(
        "$HOME/.config/wtr/gemini"
        "$HOME/.config/neopilot/gemini"
        "$HOME/.gemini/api_key"
    )
    
    for config_file in "${config_locations[@]}"; do
        if [ -f "$config_file" ]; then
            cat "$config_file" | tr -d ' \n'
            return 0
        fi
    done
    
    return 1
}

# Make API call to Gemini
gemini_api_call() {
    local data="$1"
    local api_key="$2"
    
    adapter_log_debug "Making API request to Gemini"
    
    local response
    response=$(curl -s -X POST "$GEMINI_API_ENDPOINT/${GEMINI_MODEL}:generateContent?key=${api_key}" \
        -H "Content-Type: application/json" \
        -d "$data" 2>/dev/null)
    
    echo "$response"
}

# Analyze project using Gemini
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
        adapter_log_error "Gemini API key not found"
        echo ""
        echo "Set up Gemini API key:"
        echo "  1. Get key from: https://ai.google.dev"
        echo "  2. Set environment: export GEMINI_API_KEY='your-key'"
        echo "  3. Or save to: $HOME/.config/wtr/gemini"
        exit 127
    }
    
    adapter_log_info "Analyzing project with Gemini: $target"
    adapter_log_debug "Using model: $GEMINI_MODEL"
    
    # Build analysis prompt
    local prompt="Analyze this project context and suggest next steps:\n"
    
    # Get recent changes if git repo
    if [ -d "$target/.git" ]; then
        local changes
        changes=$(cd "$target" && git log -n 5 --pretty=format:"%h - %s" 2>/dev/null || echo "")
        if [ -n "$changes" ]; then
            prompt+="Recent commits:\n$changes\n\n"
        fi
    fi
    
    # Add README if present
    if [ -f "$target/README.md" ]; then
        prompt+="README excerpt:\n$(head -n 30 "$target/README.md")\n\n"
    fi
    
    prompt+="What should I work on next?"
    
    # Make API call
    local request_body
    request_body=$(jq -n \
        --arg prompt "$prompt" \
        '{
            contents: [
                {role: "user", parts: [{text: $prompt}]}
            ]
        }')
    
    local response
    response=$(gemini_api_call "$request_body" "$api_key")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        adapter_log_error "Gemini API error:"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
    
    # Extract and display response
    adapter_log_info "Analysis complete"
    echo ""
    echo "🤖 Gemini's analysis:"
    echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "Unable to parse response"
}

# Check Gemini configuration
check_gemini() {
    if load_api_key >/dev/null 2>&1; then
        adapter_log_info "Gemini API key is configured"
        adapter_log_info "Using model: $GEMINI_MODEL"
        return 0
    else
        adapter_log_error "Gemini API key not configured"
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
            check_gemini
            ;;
        version)
            echo "$GEMINI_MODEL"
            ;;
        help|--help|-h)
            echo "wtr Google Gemini Adapter"
            echo "Usage: gemini.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  open|analyze <path>  Analyze project with Gemini"
            echo "  check|status         Check Gemini configuration"
            echo "  version              Show Gemini model in use"
            echo "  help                 Show this help"
            echo ""
            echo "Configuration:"
            echo "  Set GEMINI_API_KEY environment variable"
            echo "  Or save key to: ~/.config/wtr/gemini"
            echo ""
            echo "Environment Variables:"
            echo "  WTR_ADAPTER_DEBUG    Set to 1 to enable debug logging"
            echo "  GEMINI_API_KEY       Your Google Gemini API key"
            echo "  GEMINI_MODEL         Override default model (default: gemini-1.5-pro)"
            echo ""
            echo "Get API Key:"
            echo "  https://ai.google.dev"
            echo ""
            echo "More info: https://ai.google.dev"
            ;;
        *)
            adapter_log_error "Unknown command: $cmd"
            echo "Try: $0 help"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"            # Call Gemini API
            response=$(gemini_api '{
                "contents": [{
                    "parts": [{"text": "'"$prompt"'"}]
                }]
            }')
            
            # Extract and display the response
            echo "🤖 Gemini's suggestions:"
            echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "Error parsing response"
            
            # Open browser to Gemini's web interface
            if command -v xdg-open >/dev/null; then
                xdg-open "https://gemini.google.com/app" >/dev/null 2>&1 &
            elif command -v open >/dev/null; then
                open "https://gemini.google.com/app" >/dev/null 2>&1 &
            fi
        else
            echo "Worktree path does not exist: $worktree_path" >&2
            exit 1
        fi
        ;;
        
    analyze)
        # More detailed analysis of the codebase
        if [ -d "$worktree_path" ]; then
            cd "$worktree_path" || exit 1
            
            # Get code statistics
            file_count=$(find . -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" | wc -l)
            loc=$(find . -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" | xargs wc -l 2>/dev/null | tail -n 1 | awk '{print $1}')
            
            # Prepare analysis prompt
            prompt="Analyze this codebase and provide insights:\n"
            prompt+="- Files: $file_count\n"
            prompt+="- Lines of code: $loc\n\n"
            prompt+="Project structure:\n$(find . -type d -maxdepth 2 | sort | sed 's|[^/]*/|- |g' | head -n 20)\n\n"
            
            if [ -f "package.json" ]; then
                prompt+="Dependencies:\n$(jq -r '.dependencies | to_entries[] | .key + ": " + .value' package.json 2>/dev/null | head -n 10)\n\n"
            fi
            
            prompt+="What are the main components of this project? Any potential improvements or areas of concern?"
            
            # Call Gemini API
            response=$(gemini_api '{
                "contents": [{
                    "parts": [{"text": "'"$prompt"'"}]
                }]
            }')
            
            echo "📊 Codebase Analysis:"
            echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "Error parsing response"
        fi
        ;;
        
    *)
        echo "Unknown command: $cmd" >&2
        echo "Available commands: open, analyze" >&2
        exit 1
        ;;
esac
