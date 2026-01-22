#!/usr/bin/env bats
# test/adapters/adapter-detect.bats - Test adapter detection

setup() {
  export WTR_DIR="$BATS_TEST_DIRNAME/../.."
}

# Test that common adapters exist
@test "adapter-detect: vscode adapter exists" {
  [ -f "$WTR_DIR/adapters/editor/vscode.sh" ]
}

@test "adapter-detect: cursor adapter exists" {
  [ -f "$WTR_DIR/adapters/editor/cursor.sh" ]
}

@test "adapter-detect: vim adapter exists" {
  [ -f "$WTR_DIR/adapters/editor/vim.sh" ]
}

@test "adapter-detect: claude ai adapter exists" {
  [ -f "$WTR_DIR/adapters/ai/claude.sh" ]
}

@test "adapter-detect: copilot ai adapter exists" {
  [ -f "$WTR_DIR/adapters/ai/copilot.sh" ]
}

# Test manifest exists
@test "adapter-detect: manifest.sh exists" {
  [ -f "$WTR_DIR/adapters/manifest.sh" ]
}
