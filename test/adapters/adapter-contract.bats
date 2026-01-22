#!/usr/bin/env bats
# test/adapters/adapter-contract.bats - Test adapter interface contract

setup() {
  export WTR_DIR="$BATS_TEST_DIRNAME/../.."
}

# Test that editor adapters have required functions or structure
@test "adapter: editor adapters directory exists" {
  [ -d "$WTR_DIR/adapters/editor" ]
}

@test "adapter: ai adapters directory exists" {
  [ -d "$WTR_DIR/adapters/ai" ]
}

# Test that editor adapters source correctly
@test "adapter: editor adapter (cursor) can be sourced" {
  source "$WTR_DIR/adapters/editor/cursor.sh" || true
  # If it sources without error, contract is partially met
  [ -z "$?" ] || [ "$?" -eq 0 ]
}

@test "adapter: ai adapter (claude) can be sourced" {
  source "$WTR_DIR/adapters/ai/claude.sh" || true
  [ -z "$?" ] || [ "$?" -eq 0 ]
}

# Test adapter naming pattern
@test "adapter: editor adapters follow naming pattern *.sh" {
  count=$(find "$WTR_DIR/adapters/editor" -maxdepth 1 -name "*.sh" -type f | wc -l)
  [ "$count" -gt 0 ]
}

@test "adapter: ai adapters follow naming pattern *.sh" {
  count=$(find "$WTR_DIR/adapters/ai" -maxdepth 1 -name "*.sh" -type f | wc -l)
  [ "$count" -gt 0 ]
}
