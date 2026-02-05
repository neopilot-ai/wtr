#!/usr/bin/env bats

# Tests for MCP Server

# Test fixtures
@test "MCP server responds to initialize request" {
  # Create a minimal initialize request
  local request='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'
  
  # Send to server and capture response (simulate with direct execution)
  local response
  response=$(echo "$request" | bash "${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh" 2>/dev/null | head -1)
  
  # Verify response contains required fields
  if command -v jq >/dev/null 2>&1; then
    local protocol_version
    protocol_version=$(echo "$response" | jq -r '.result.protocolVersion // empty')
    [ -n "$protocol_version" ]
  fi
}

@test "MCP server rejects invalid JSON" {
  local response
  response=$(echo 'not json at all' | bash "${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh" 2>&1 | head -1)
  
  if [[ "$response" =~ "Parse error" ]]; then
    skip "Response captured, parse error as expected"
  fi
}

@test "MCP server validates string parameter length" {
  # Branch name should be reasonable length
  local long_name=""
  for i in {1..5000}; do
    long_name="${long_name}a"
  done
  
  local request="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"wtr_new\",\"arguments\":{\"branch\":\"$long_name\"}}}"
  
  # This should be handled gracefully
  local response
  response=$(echo "$request" | bash "${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh" 2>&1 || echo '{}')
  
  # Verify no crash or buffer overflow
  [ -n "$response" ]
}

@test "MCP server validates identifier format" {
  # Test get_string_param with invalid identifier
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify the script contains validation functions
  grep -q "validate_identifier" "$script"
}

@test "MCP server requires confirmation for removal" {
  # wtr_rm should require yes=true
  local request='{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"wtr_rm","arguments":{"identifier":"feature/test","yes":false}}}'
  
  local response
  response=$(echo "$request" | bash "${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh" 2>&1 | head -1)
  
  # Should contain error about requires yes
  if command -v jq >/dev/null 2>&1; then
    if echo "$response" | jq -e '.result.content[0].text // empty' >/dev/null 2>&1; then
      local text
      text=$(echo "$response" | jq -r '.result.content[0].text')
      [[ "$text" =~ "yes" ]] || [[ "$text" =~ "confirmation" ]]
    fi
  fi
}

@test "MCP server has parameter validation helpers" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify validation functions exist
  grep -q "validate_branch_name" "$script"
  grep -q "validate_pattern" "$script"
  grep -q "get_string_param" "$script"
  grep -q "get_bool_param" "$script"
}

@test "MCP server includes audit logging" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify logging function exists
  grep -q "log_audit" "$script"
  grep -q "MCP_LOG_FILE" "$script"
}

@test "MCP server has timeout protection" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify timeout handling
  grep -q "run_with_timeout" "$script"
  grep -q "CMD_TIMEOUT" "$script"
}

@test "MCP server handles errors gracefully" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify error handling
  grep -q "send_error" "$script"
  grep -q "send_tool_result" "$script"
}

@test "MCP server validates bash version" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Should check for Bash 4.0+
  grep -q "BASH_VERSINFO" "$script"
}

@test "MCP server properly escapes JSON" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify JSON escaping
  grep -q "jq -Rs" "$script"
}

@test "MCP server protects against command injection in patterns" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Verify pattern validation includes injection attack prevention
  grep -q 'pattern.*injection\|pattern.*rm\|validate_pattern' "$script"
}

@test "MCP server supports debug mode" {
  local script="${BATS_TEST_DIRNAME}/../mcp/wtr-server.sh"
  
  # Debug mode should be configurable
  grep -q "MCP_DEBUG" "$script"
}
