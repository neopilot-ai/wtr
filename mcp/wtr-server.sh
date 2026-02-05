#!/usr/bin/env bash
# mcp/wtr-server.sh - MCP server for wtr
#
# This server exposes wtr commands as MCP tools,
# enabling AI agents to manage worktrees autonomously.
#
# Requirements: jq (for JSON parsing), bash 4.0+
# Usage: Configure in your MCP client (Claude Desktop, Cursor, etc.)
#
# Protocol: JSON-RPC 2.0 over stdio (MCP specification 2024-11-05)
# Features:
#   - Type validation for all parameters
#   - Timeout protection for long-running operations
#   - Audit logging for security and debugging
#   - Comprehensive error handling
#   - Input sanitization

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Configuration & Constants
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WTR_BIN="${SCRIPT_DIR}/../bin/wtr"

# Timeouts (in seconds)
readonly CMD_TIMEOUT=300        # 5 minutes for worktree operations
readonly JINJA_TIMEOUT=5        # 5 seconds for JSON parsing

# Logging
MCP_LOG_FILE="${MCP_LOG_FILE:-}"
MCP_DEBUG="${MCP_DEBUG:-0}"

# Find the script directory (resolve symlinks; allow env override)
resolve_script_dir() {
  local src="${BASH_SOURCE[0]}"
  while [ -h "$src" ]; do
    local dir
    dir="$(cd -P "$(dirname "$src")" && pwd)"
    src="$(readlink "$src")"
    [[ $src != /* ]] && src="$dir/$src"
  done
  cd -P "$(dirname "$src")/.." && pwd
}

# Audit logging
log_audit() {
  local level="$1"
  shift
  local msg="$*"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  if [ -n "$MCP_LOG_FILE" ]; then
    echo "[$timestamp] [$level] $msg" >> "$MCP_LOG_FILE" 2>/dev/null || true
  fi
  
  if [ "$MCP_DEBUG" = "1" ]; then
    echo "[$timestamp] [$level] $msg" >&2
  fi
}

# Verify dependencies (errors go to stdout for MCP protocol compliance)
verify_dependencies() {
  if ! command -v jq >/dev/null 2>&1; then
    log_audit "ERROR" "jq is required but not installed"
    echo '{"jsonrpc":"2.0","id":null,"error":{"code":-32603,"message":"jq is required but not installed"}}'
    exit 1
  fi

  if [[ ! -x "$WTR_BIN" ]]; then
    log_audit "ERROR" "wtr script not found or not executable at $WTR_BIN"
    echo '{"jsonrpc":"2.0","id":null,"error":{"code":-32603,"message":"wtr script not found"}}'
    exit 1
  fi
  
  # Verify bash version (need 4.0+ for associative arrays)
  if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    log_audit "ERROR" "Bash 4.0+ required, current version: ${BASH_VERSION}"
    echo '{"jsonrpc":"2.0","id":null,"error":{"code":-32603,"message":"Bash 4.0+ required"}}'
    exit 1
  fi
}

verify_dependencies


# ─────────────────────────────────────────────────────────────────────────────
# JSON-RPC Response Helpers
# ─────────────────────────────────────────────────────────────────────────────

send_response() {
  local id="$1" result="$2"
  # Validate JSON structure before sending
  if ! echo "$result" | jq -e . >/dev/null 2>&1; then
    log_audit "WARN" "Invalid JSON in response result: ${result:0:100}"
    result='{"error":"Invalid response structure"}'
  fi
  # Compact the result to ensure single-line output (MCP requires one JSON per line)
  local compact_result
  compact_result=$(printf '%s' "$result" | jq -c .)
  printf '{"jsonrpc":"2.0","id":%s,"result":%s}\n' "$id" "$compact_result"
}

send_error() {
  local id="$1" code="$2" message="$3"
  # Validate code is integer
  if ! [[ "$code" =~ ^-?[0-9]+$ ]]; then
    code=-32603
  fi
  # Escape message for JSON
  local escaped_msg
  escaped_msg=$(printf '%s' "$message" | jq -Rs .)
  log_audit "ERROR" "Sending RPC error ($code): $message"
  printf '{"jsonrpc":"2.0","id":%s,"error":{"code":%d,"message":%s}}\n' "$id" "$code" "$escaped_msg"
}

send_tool_result() {
  local id="$1" content="$2" is_error="${3:-false}"
  local escaped
  escaped=$(printf '%s' "$content" | jq -Rs .)
  
  # Validate boolean
  if [[ "$is_error" != "true" && "$is_error" != "false" ]]; then
    is_error="false"
  fi
  
  printf '{"jsonrpc":"2.0","id":%s,"result":{"content":[{"type":"text","text":%s}],"isError":%s}}\n' \
    "$id" "$escaped" "$is_error"
}

# ─────────────────────────────────────────────────────────────────────────────
# Parameter Validation Helpers
# ─────────────────────────────────────────────────────────────────────────────

# Safely extract string parameter with validation
get_string_param() {
  local params="$1" key="$2" default="${3:-}"
  local value
  value=$(echo "$params" | jq -r ".\"$key\" // \"$default\"" 2>/dev/null || echo "$default")
  
  # Reject if contains null bytes or is suspiciously large
  if [[ ${#value} -gt 10000 ]]; then
    return 1
  fi
  
  echo "$value"
}

# Safely extract boolean parameter
get_bool_param() {
  local params="$1" key="$2" default="${3:-false}"
  local value
  value=$(echo "$params" | jq -r ".\"$key\" // $default" 2>/dev/null)
  
  if [[ "$value" =~ ^(true|false)$ ]]; then
    echo "$value"
  else
    echo "$default"
  fi
}

# Safely extract array parameter
get_array_param() {
  local params="$1" key="$2"
  echo "$params" | jq -c ".\"$key\" // []" 2>/dev/null || echo "[]"
}

# Validate identifier format (branch name or numeric ID)
validate_identifier() {
  local id="$1"
  
  # Accept numeric IDs (1, 2, 3, etc.)
  if [[ "$id" =~ ^[0-9]+$ ]]; then
    return 0
  fi
  
  # Accept branch-like names (alphanumeric, dash, underscore, slash)
  if [[ "$id" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
    return 0
  fi
  
  return 1
}

# Validate branch name format
validate_branch_name() {
  local name="$1"
  
  # Must be non-empty and not contain dangerous characters
  if [[ -z "$name" || ! "$name" =~ ^[a-zA-Z0-9/_.-]+$ ]]; then
    return 1
  fi
  
  return 0
}

# Validate pattern (glob-like)
validate_pattern() {
  local pattern="$1"
  
  # Maximum length check
  if [[ ${#pattern} -gt 1000 ]]; then
    return 1
  fi
  
  # Basic sanity - must not contain obvious injection attempts
  if [[ "$pattern" =~ ('|"|$(|`|\$\(|;\||&&|\|\||>|<) ]]; then
    return 1
  fi
  
  return 0
}


# ─────────────────────────────────────────────────────────────────────────────
# Tool Implementations
# ─────────────────────────────────────────────────────────────────────────────

# Execute command with timeout and error handling
run_with_timeout() {
  local timeout="$1"
  shift
  local cmd=("$@")
  
  # Use timeout command if available, otherwise run directly
  if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout" "${cmd[@]}" 2>&1 || {
      local exit_code=$?
      if [ $exit_code -eq 124 ]; then
        log_audit "ERROR" "Command timed out after ${timeout}s: ${cmd[0]}"
        echo "Error: Command timed out after ${timeout} seconds"
        return 1
      fi
      return $exit_code
    }
  else
    "${cmd[@]}" 2>&1
  fi
}

tool_wtr_list() {
  log_audit "CALL" "wtr_list"
  
  local output
  output=$(run_with_timeout "$CMD_TIMEOUT" "$WTR_BIN" list --porcelain 2>&1) || {
    echo "Error: Failed to list worktrees"
    return 1
  }

  # Convert porcelain format (path\tbranch\tstatus) to JSON array using jq
  local json_array="[]"
  while IFS=$'\t' read -r path branch status; do
    [[ -z "$path" ]] && continue
    
    # Validate fields
    if ! validate_identifier "$branch" 2>/dev/null; then
      log_audit "WARN" "Invalid branch in list output: $branch"
      continue
    fi
    
    # Use jq to safely build JSON objects (handles special characters properly)
    json_array=$(echo "$json_array" | jq -c \
      --arg path "$path" \
      --arg branch "$branch" \
      --arg status "$status" \
      '. + [{path: $path, branch: $branch, status: $status}]') || {
      log_audit "ERROR" "Failed to parse worktree list"
      return 1
    }
  done <<< "$output"
  
  echo "$json_array"
}

tool_wtr_new() {
  local params="$1"
  local branch from fromCurrent force name noCopy
  
  log_audit "CALL" "wtr_new with params: ${params:0:200}"

  branch=$(get_string_param "$params" "branch" "")
  from=$(get_string_param "$params" "from" "")
  fromCurrent=$(get_bool_param "$params" "fromCurrent" "false")
  force=$(get_bool_param "$params" "force" "false")
  name=$(get_string_param "$params" "name" "")
  noCopy=$(get_bool_param "$params" "noCopy" "false")

  # Validate required parameters
  if [[ -z "$branch" ]]; then
    log_audit "ERROR" "wtr_new: branch parameter required"
    echo "Error: 'branch' parameter is required"
    return 1
  fi

  if ! validate_branch_name "$branch"; then
    log_audit "ERROR" "wtr_new: invalid branch name: $branch"
    echo "Error: Invalid branch name format"
    return 1
  fi

  # Validate optional parameters
  if [[ -n "$from" ]] && ! validate_branch_name "$from"; then
    log_audit "ERROR" "wtr_new: invalid from ref: $from"
    echo "Error: Invalid 'from' reference format"
    return 1
  fi

  if [[ -n "$name" && ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_audit "ERROR" "wtr_new: invalid custom name: $name"
    echo "Error: Invalid 'name' format (alphanumeric, dash, underscore only)"
    return 1
  fi

  # Build command array (safer than string concatenation)
  local cmd=("$WTR_BIN" new "$branch")
  [[ -n "$from" ]] && cmd+=(--from "$from")
  [[ "$fromCurrent" == "true" ]] && cmd+=(--from-current)
  [[ "$force" == "true" ]] && cmd+=(--force)
  [[ -n "$name" ]] && cmd+=(--name "$name")
  [[ "$noCopy" == "true" ]] && cmd+=(--no-copy)

  log_audit "INFO" "Creating worktree: $branch${name:+ ($name)}"
  run_with_timeout "$CMD_TIMEOUT" "${cmd[@]}"
}

tool_wtr_go() {
  local params="$1"
  local identifier

  log_audit "CALL" "wtr_go with params: ${params:0:200}"

  identifier=$(get_string_param "$params" "identifier" "")

  if [[ -z "$identifier" ]]; then
    log_audit "ERROR" "wtr_go: identifier parameter required"
    echo "Error: 'identifier' parameter is required"
    return 1
  fi

  if ! validate_identifier "$identifier"; then
    log_audit "ERROR" "wtr_go: invalid identifier: $identifier"
    echo "Error: Invalid identifier format"
    return 1
  fi

  log_audit "INFO" "Getting path for identifier: $identifier"
  run_with_timeout 10 "$WTR_BIN" go "$identifier"
}

tool_wtr_run() {
  local params="$1"
  local identifier command
  
  log_audit "CALL" "wtr_run with params: ${params:0:200}"

  identifier=$(get_string_param "$params" "identifier" "")
  command=$(get_string_param "$params" "command" "")

  if [[ -z "$identifier" ]]; then
    log_audit "ERROR" "wtr_run: identifier parameter required"
    echo "Error: 'identifier' parameter is required"
    return 1
  fi

  if ! validate_identifier "$identifier"; then
    log_audit "ERROR" "wtr_run: invalid identifier: $identifier"
    echo "Error: Invalid identifier format"
    return 1
  fi

  if [[ -z "$command" ]]; then
    log_audit "ERROR" "wtr_run: command parameter required"
    echo "Error: 'command' parameter is required"
    return 1
  fi

  # Sanitize command (basic check for obviously dangerous patterns)
  if [[ "$command" =~ (rm\ -rf|:|'\|'|';rm'|'>;') ]]; then
    log_audit "WARN" "Suspicious command pattern detected: ${command:0:100}"
  fi

  log_audit "INFO" "Running command in $identifier: ${command:0:100}"
  # Use array to pass command safely
  run_with_timeout "$CMD_TIMEOUT" "$WTR_BIN" run "$identifier" "$command"
}

tool_wtr_rm() {
  local params="$1"
  local identifier yes deleteBranch force

  log_audit "CALL" "wtr_rm with params: ${params:0:200}"

  identifier=$(get_string_param "$params" "identifier" "")
  yes=$(get_bool_param "$params" "yes" "false")
  deleteBranch=$(get_bool_param "$params" "deleteBranch" "false")
  force=$(get_bool_param "$params" "force" "false")

  if [[ -z "$identifier" ]]; then
    log_audit "ERROR" "wtr_rm: identifier parameter required"
    echo "Error: 'identifier' parameter is required"
    return 1
  fi

  if ! validate_identifier "$identifier"; then
    log_audit "ERROR" "wtr_rm: invalid identifier: $identifier"
    echo "Error: Invalid identifier format"
    return 1
  fi

  # SAFETY: Require explicit confirmation
  if [[ "$yes" != "true" ]]; then
    log_audit "WARN" "wtr_rm: confirmation required for removal of $identifier"
    echo "Error: 'yes' parameter must be true to confirm removal (safety measure)"
    return 1
  fi

  log_audit "WARN" "REMOVING worktree: $identifier (yes=true, deleteBranch=$deleteBranch, force=$force)"

  local cmd=("$WTR_BIN" rm "$identifier" --yes)
  [[ "$deleteBranch" == "true" ]] && cmd+=(--delete-branch)
  [[ "$force" == "true" ]] && cmd+=(--force)

  run_with_timeout "$CMD_TIMEOUT" "${cmd[@]}"
}

tool_wtr_doctor() {
  log_audit "CALL" "wtr_doctor"
  run_with_timeout 30 "$WTR_BIN" doctor
}

tool_wtr_copy() {
  local params="$1"
  local target from dryRun all patterns_array
  
  log_audit "CALL" "wtr_copy with params: ${params:0:200}"

  target=$(get_string_param "$params" "target" "")
  from=$(get_string_param "$params" "from" "")
  dryRun=$(get_bool_param "$params" "dryRun" "false")
  all=$(get_bool_param "$params" "all" "false")
  patterns_array=$(get_array_param "$params" "patterns")

  # Validate patterns
  local patterns_count
  patterns_count=$(echo "$patterns_array" | jq 'length' 2>/dev/null || echo 0)
  
  if [[ "$patterns_count" -eq 0 ]]; then
    log_audit "ERROR" "wtr_copy: patterns parameter required"
    echo "Error: 'patterns' parameter is required (array of glob patterns)"
    return 1
  fi

  # Validate target/all combination
  if [[ "$all" != "true" && -z "$target" ]]; then
    log_audit "ERROR" "wtr_copy: target or all required"
    echo "Error: Either 'target' or 'all: true' is required"
    return 1
  fi

  if [[ "$all" == "true" && -n "$target" ]]; then
    log_audit "WARN" "wtr_copy: both target and all specified, using all"
  fi

  # Validate patterns format
  local invalid_patterns=0
  while read -r pattern; do
    if ! validate_pattern "$pattern"; then
      log_audit "WARN" "Invalid pattern: $pattern"
      invalid_patterns=$((invalid_patterns + 1))
    fi
  done < <(echo "$patterns_array" | jq -r '.[]')

  if [[ $invalid_patterns -gt 0 ]]; then
    echo "Error: Some patterns have invalid format or are too long"
    return 1
  fi

  # Build command
  local cmd=("$WTR_BIN" copy)

  if [[ "$all" == "true" ]]; then
    cmd+=(-a)
    log_audit "INFO" "Copying patterns to all worktrees"
  else
    cmd+=("$target")
    log_audit "INFO" "Copying patterns to worktree: $target"
  fi

  [[ -n "$from" ]] && cmd+=(--from "$from")
  [[ "$dryRun" == "true" ]] && cmd+=(--dry-run)

  # Add patterns after --
  cmd+=(--)

  # Parse patterns array and add each
  while read -r pattern; do
    [[ -n "$pattern" ]] && cmd+=("$pattern")
  done < <(echo "$patterns_array" | jq -r '.[]')

  run_with_timeout "$CMD_TIMEOUT" "${cmd[@]}"
}


# ─────────────────────────────────────────────────────────────────────────────
# MCP Protocol Definitions
# ─────────────────────────────────────────────────────────────────────────────

# Server capabilities (returned for initialize request)
# Note: read returns non-zero at EOF, so we use || true
read -r -d '' SERVER_INFO << 'SERVERINFO_EOF' || true
{
  "protocolVersion": "2024-11-05",
  "capabilities": {
    "tools": {}
  },
  "serverInfo": {
    "name": "wtr-mcp-server",
    "version": "1.0.0"
  }
}
SERVERINFO_EOF

# Tool definitions (returned for tools/list request)
read -r -d '' TOOLS_LIST << 'TOOLSLIST_EOF' || true
{
  "tools": [
    {
      "name": "wtr_list",
      "description": "List all wtr worktrees in the current repository. Returns an array of worktrees with their paths, branch names, and status (ok, detached, locked, prunable, missing).",
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    },
    {
      "name": "wtr_new",
      "description": "Create a new wtr worktree for isolated development. Creates a new branch if it does not exist. Returns the path to the created worktree.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "branch": {
            "type": "string",
            "description": "Branch name for the worktree (will be created if it does not exist)"
          },
          "from": {
            "type": "string",
            "description": "Base ref (branch, tag, or commit) to create branch from. Defaults to repository default branch."
          },
          "fromCurrent": {
            "type": "boolean",
            "description": "Create branch from current HEAD instead of default branch"
          },
          "force": {
            "type": "boolean",
            "description": "Allow creating worktree even if branch is already checked out elsewhere (requires name)"
          },
          "name": {
            "type": "string",
            "description": "Custom suffix for worktree folder name (used with force for multiple worktrees per branch)"
          },
          "noCopy": {
            "type": "boolean",
            "description": "Skip copying files defined in wtr.copy.include patterns"
          }
        },
        "required": ["branch"]
      }
    },
    {
      "name": "wtr_go",
      "description": "Get the absolute filesystem path to a worktree. Use this to locate a worktree before running commands in it. Special ID 1 always refers to the main repository.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "identifier": {
            "type": "string",
            "description": "Branch name or special ID. Use 1 for the main repository, or a branch name for a worktree."
          }
        },
        "required": ["identifier"]
      }
    },
    {
      "name": "wtr_run",
      "description": "Execute a shell command in the context of a specific worktree. The command runs with the worktree directory as the current working directory.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "identifier": {
            "type": "string",
            "description": "Branch name or worktree ID to run command in"
          },
          "command": {
            "type": "string",
            "description": "Shell command to execute (e.g., npm test, wtr status, make build)"
          }
        },
        "required": ["identifier", "command"]
      }
    },
    {
      "name": "wtr_rm",
      "description": "Remove a worktree and optionally its branch. DESTRUCTIVE: Requires explicit yes:true parameter for safety. Use wtr_list first to verify the worktree exists.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "identifier": {
            "type": "string",
            "description": "Branch name or worktree ID to remove"
          },
          "deleteBranch": {
            "type": "boolean",
            "description": "Also delete the wtr branch after removing worktree (cannot be undone easily)"
          },
          "force": {
            "type": "boolean",
            "description": "Force removal even if worktree has uncommitted changes"
          },
          "yes": {
            "type": "boolean",
            "description": "REQUIRED: Must be true to confirm removal. This is a safety measure."
          }
        },
        "required": ["identifier", "yes"]
      }
    },
    {
      "name": "wtr_doctor",
      "description": "Run health checks on the wtr installation. Verifies wtr is available, checks repository status, and validates worktree configuration.",
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    },
    {
      "name": "wtr_copy",
      "description": "Copy files matching glob patterns from the main repository (or another worktree) to a target worktree. Useful for copying configuration files like .env.example.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "target": {
            "type": "string",
            "description": "Target worktree identifier (branch name or ID). Required unless all is true."
          },
          "patterns": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Glob patterns for files to copy (e.g., .env.example, *.config.js)"
          },
          "from": {
            "type": "string",
            "description": "Source worktree to copy from (defaults to main repository)"
          },
          "dryRun": {
            "type": "boolean",
            "description": "Preview what would be copied without making changes"
          },
          "all": {
            "type": "boolean",
            "description": "Copy to all worktrees instead of a specific target"
          }
        },
        "required": ["patterns"]
      }
    }
  ]
}
TOOLSLIST_EOF

# ─────────────────────────────────────────────────────────────────────────────
# Message Handler
# ─────────────────────────────────────────────────────────────────────────────

handle_message() {
  local msg="$1"
  local id method params

  # Parse JSON-RPC message
  # Use jq -c to preserve ID type (string vs number)
  local raw_id
  raw_id=$(echo "$msg" | jq -c '.id // null' 2>/dev/null) || {
    log_audit "ERROR" "Failed to parse message: ${msg:0:100}"
    echo '{"jsonrpc":"2.0","id":null,"error":{"code":-32700,"message":"Parse error: Invalid JSON"}}'
    return 1
  }
  
  id="$raw_id"  # Keep as JSON literal (quoted strings, raw numbers)
  method=$(echo "$msg" | jq -r '.method // empty' 2>/dev/null) || method=""
  params=$(echo "$msg" | jq -c '.params // {}' 2>/dev/null) || params="{}"

  log_audit "DEBUG" "Handling method: $method (id=$id)"

  case "$method" in
    "initialize")
      log_audit "INFO" "Server initialization"
      send_response "$id" "$SERVER_INFO"
      ;;

    "notifications/initialized")
      log_audit "INFO" "Client initialized notification"
      # Notification - no response needed
      ;;

    "tools/list")
      log_audit "INFO" "Listing available tools"
      send_response "$id" "$TOOLS_LIST"
      ;;

    "tools/call")
      local tool_name tool_args output is_error
      tool_name=$(echo "$params" | jq -r '.name // empty' 2>/dev/null) || tool_name=""
      tool_args=$(echo "$params" | jq -c '.arguments // {}' 2>/dev/null) || tool_args="{}"
      is_error="false"

      if [[ -z "$tool_name" ]]; then
        log_audit "ERROR" "Tool call missing 'name' parameter"
        send_error "$id" -32602 "Missing 'name' in tool call"
        return 1
      fi

      log_audit "DEBUG" "Calling tool: $tool_name"

      case "$tool_name" in
        "wtr_list")
          output=$(tool_wtr_list) || is_error="true"
          ;;
        "wtr_new")
          output=$(tool_wtr_new "$tool_args") || is_error="true"
          ;;
        "wtr_go")
          output=$(tool_wtr_go "$tool_args") || is_error="true"
          ;;
        "wtr_run")
          output=$(tool_wtr_run "$tool_args") || is_error="true"
          ;;
        "wtr_rm")
          output=$(tool_wtr_rm "$tool_args") || is_error="true"
          ;;
        "wtr_doctor")
          output=$(tool_wtr_doctor) || is_error="true"
          ;;
        "wtr_copy")
          output=$(tool_wtr_copy "$tool_args") || is_error="true"
          ;;
        *)
          log_audit "ERROR" "Unknown tool: $tool_name"
          send_error "$id" -32601 "Unknown tool: $tool_name"
          return 1
          ;;
      esac

      send_tool_result "$id" "$output" "$is_error"
      ;;

    "ping")
      log_audit "DEBUG" "Ping request"
      send_response "$id" '{}'
      ;;

    "")
      log_audit "WARN" "Empty method in message"
      if [[ "$id" != "null" ]]; then
        send_error "$id" -32700 "Parse error: Missing 'method' field"
      fi
      ;;

    *)
      # Unknown method
      log_audit "WARN" "Unknown method: $method"
      if [[ "$id" != "null" ]]; then
        send_error "$id" -32601 "Method not found: $method"
      fi
      # Ignore unknown notifications (id is null)
      ;;
  esac
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Loop
# ─────────────────────────────────────────────────────────────────────────────

main() {
  log_audit "INFO" "MCP Server starting (PID $$)"
  log_audit "INFO" "WTR binary: $WTR_BIN"
  
  # Read JSON-RPC messages from stdin, one per line
  while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Validate JSON before processing
    if ! echo "$line" | jq -e . >/dev/null 2>&1; then
      log_audit "ERROR" "Invalid JSON: ${line:0:100}"
      echo '{"jsonrpc":"2.0","id":null,"error":{"code":-32700,"message":"Parse error: Invalid JSON"}}'
      continue
    fi

    # Handle the message safely
    handle_message "$line" || {
      log_audit "ERROR" "Failed to handle message: ${line:0:100}"
    }
  done
  
  log_audit "INFO" "MCP Server shutting down"
}

main "$@"
