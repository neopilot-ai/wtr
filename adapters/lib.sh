#!/usr/bin/env bash
# wtr Adapter Library - Utility functions for all adapters
# Source this file in your adapter for common functionality
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Color codes for output
ADAPTER_RED='\033[0;31m'
ADAPTER_GREEN='\033[0;32m'
ADAPTER_YELLOW='\033[1;33m'
ADAPTER_BLUE='\033[0;34m'
ADAPTER_NC='\033[0m' # No Color

# Debug mode (set WTR_ADAPTER_DEBUG=1 to enable)
ADAPTER_DEBUG="${WTR_ADAPTER_DEBUG:-0}"

# ============================================================================
# Logging Functions
# ============================================================================

adapter_log_debug() {
    if [ "$ADAPTER_DEBUG" = "1" ]; then
        echo -e "${ADAPTER_BLUE}[DEBUG]${ADAPTER_NC} $*" >&2
    fi
}

adapter_log_info() {
    echo -e "${ADAPTER_GREEN}[INFO]${ADAPTER_NC} $*" >&2
}

adapter_log_warn() {
    echo -e "${ADAPTER_YELLOW}[WARN]${ADAPTER_NC} $*" >&2
}

adapter_log_error() {
    echo -e "${ADAPTER_RED}[ERROR]${ADAPTER_NC} $*" >&2
}

# ============================================================================
# Command Checking
# ============================================================================

# Check if a command is available in PATH
adapter_check_command() {
    local cmd="$1"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        adapter_log_debug "Command found: $cmd"
        return 0
    else
        adapter_log_debug "Command not found: $cmd"
        return 1
    fi
}

# Check multiple commands, return first one found
adapter_find_command() {
    local commands=("$@")
    
    for cmd in "${commands[@]}"; do
        if adapter_check_command "$cmd"; then
            echo "$cmd"
            return 0
        fi
    done
    
    return 1
}

# ============================================================================
# Installation Hints
# ============================================================================

# Provide installation hint for missing command
adapter_install_hint() {
    local tool="$1"
    local help_url="${2:-https://github.com/neopilot-ai/wtr}"
    
    adapter_log_error "Required tool not found: $tool"
    echo ""
    echo "Installation:"
    echo "  macOS:  brew install $tool"
    echo "  Ubuntu: sudo apt install $tool"
    echo "  Linux:  Consult your package manager"
    echo ""
    echo "More info: $help_url"
}

# ============================================================================
# Path Validation
# ============================================================================

# Validate that a path exists and is accessible
adapter_validate_path() {
    local path="$1"
    
    if [ ! -d "$path" ]; then
        adapter_log_error "Path not found or not accessible: $path"
        return 1
    fi
    
    if [ ! -x "$path" ]; then
        adapter_log_debug "Path is not executable: $path"
    fi
    
    return 0
}

# Get absolute path from relative path
adapter_resolve_path() {
    local path="$1"
    
    if [ -z "$path" ]; then
        echo "$PWD"
        return 0
    fi
    
    if [ -d "$path" ]; then
        cd "$path" || return 1
        pwd
        cd - >/dev/null || return 1
    else
        echo "$path"
    fi
}

# ============================================================================
# Environment Configuration
# ============================================================================

# Load configuration from file
# Looks in: ~/.config/wtr/<adapter>, ~/.<adapter>rc, ./<adapter>rc
adapter_load_config() {
    local adapter_name="$1"
    
    local config_paths=(
        "$HOME/.config/wtr/$adapter_name"
        "$HOME/.${adapter_name}rc"
        ".${adapter_name}rc"
        "$PWD/.${adapter_name}rc"
    )
    
    for config in "${config_paths[@]}"; do
        if [ -f "$config" ]; then
            adapter_log_debug "Loading config from: $config"
            # shellcheck source=/dev/null
            source "$config"
            return 0
        fi
    done
    
    adapter_log_debug "No config found for: $adapter_name"
    return 1
}

# Get environment variable with fallback
adapter_get_env() {
    local var_name="$1"
    local default="${2:-}"
    local env_value
    
    env_value="${!var_name:-$default}"
    
    if [ -n "$env_value" ]; then
        echo "$env_value"
        return 0
    fi
    
    return 1
}

# ============================================================================
# Tool Management
# ============================================================================

# Get tool version
adapter_get_version() {
    local cmd="$1"
    local version_flag="${2:---version}"
    
    if ! adapter_check_command "$cmd"; then
        return 1
    fi
    
    "$cmd" "$version_flag" 2>/dev/null || echo "unknown"
}

# Check if tool is available and get fallback if not
adapter_get_tool() {
    local tool_name="$1"
    shift
    local fallback_tools=("$@")
    
    if adapter_check_command "$tool_name"; then
        echo "$tool_name"
        return 0
    fi
    
    # Try fallback tools
    for tool in "${fallback_tools[@]}"; do
        if adapter_check_command "$tool"; then
            adapter_log_warn "Using fallback tool: $tool (preferred: $tool_name)"
            echo "$tool"
            return 0
        fi
    done
    
    return 1
}

# ============================================================================
# Execution Helpers
# ============================================================================

# Execute command safely with error handling
adapter_exec() {
    local cmd="$1"
    shift
    local args=("$@")
    
    adapter_log_debug "Executing: $cmd ${args[*]}"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        adapter_log_error "Command not available: $cmd"
        return 1
    fi
    
    "$cmd" "${args[@]}" 2>&1 || return $?
}

# Execute in background (for GUI apps)
adapter_exec_bg() {
    local cmd="$1"
    shift
    local args=("$@")
    
    adapter_log_debug "Executing in background: $cmd ${args[*]}"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        adapter_log_error "Command not available: $cmd"
        return 1
    fi
    
    "$cmd" "${args[@]}" >/dev/null 2>&1 &
    return 0
}

# ============================================================================
# Validation Helpers
# ============================================================================

# Validate required environment variables
adapter_require_env() {
    local var_name="$1"
    local description="${2:-}"
    
    local value="${!var_name:-}"
    
    if [ -z "$value" ]; then
        adapter_log_error "Required environment variable not set: $var_name"
        if [ -n "$description" ]; then
            echo "Description: $description" >&2
        fi
        return 1
    fi
    
    adapter_log_debug "Environment variable set: $var_name"
    return 0
}

# Validate API key format (basic validation)
adapter_validate_api_key() {
    local key="$1"
    local key_name="${2:-API Key}"
    
    if [ -z "$key" ]; then
        adapter_log_error "$key_name is empty"
        return 1
    fi
    
    if [ ${#key} -lt 10 ]; then
        adapter_log_warn "$key_name seems too short (< 10 chars)"
        return 1
    fi
    
    adapter_log_debug "$key_name validation passed"
    return 0
}

# ============================================================================
# Network Helpers
# ============================================================================

# Check network connectivity
adapter_check_network() {
    local test_host="${1:-8.8.8.8}"
    
    if timeout 2 bash -c "echo >/dev/tcp/$test_host/443" 2>/dev/null; then
        adapter_log_debug "Network connectivity check passed"
        return 0
    else
        adapter_log_warn "Network connectivity may be limited"
        return 1
    fi
}

# ============================================================================
# JSON Helpers (if jq is available)
# ============================================================================

# Parse JSON value (requires jq)
adapter_json_get() {
    local json="$1"
    local key="$2"
    
    if ! command -v jq >/dev/null 2>&1; then
        adapter_log_warn "jq not found, cannot parse JSON"
        return 1
    fi
    
    echo "$json" | jq -r "$key" 2>/dev/null || return 1
}

# ============================================================================
# Diagnostic Helpers
# ============================================================================

# Print system information for debugging
adapter_print_diagnostics() {
    local adapter_name="$1"
    
    echo "Adapter Diagnostics for: $adapter_name" >&2
    echo "======================================" >&2
    echo "OS: $(uname -s)" >&2
    echo "Shell: $SHELL" >&2
    echo "PATH: $PATH" >&2
    echo "CWD: $(pwd)" >&2
    echo "DEBUG: $ADAPTER_DEBUG" >&2
    echo "======================================" >&2
}

# ============================================================================
# Exit Codes
# ============================================================================

# Standard exit codes
ADAPTER_SUCCESS=0
ADAPTER_ERROR=1
ADAPTER_NOT_FOUND=127
ADAPTER_NO_PERMISSION=126

export ADAPTER_SUCCESS ADAPTER_ERROR ADAPTER_NOT_FOUND ADAPTER_NO_PERMISSION

# ============================================================================
# Usage Template
# ============================================================================

# Print usage template for adapter developers
adapter_print_usage_template() {
    cat <<'EOF'
wtr Adapter Template

Set WTR_ADAPTER_DEBUG=1 to enable debug logging.

Usage:
  ./adapter.sh <command> [args...]

Commands:
  open          Open/launch in the tool
  check         Check if tool is available
  version       Get tool version
  help          Show this help

Examples:
  ./adapter.sh open /path/to/worktree
  ./adapter.sh check
  ./adapter.sh version
EOF
}

# ============================================================================
# End of Library
# ============================================================================
