#!/usr/bin/env bats

setup() {
  TMP=$(mktemp -d)
  
  # Mock opencode
  mkdir -p "$TMP/bin"
  echo "#!/bin/bash" > "$TMP/bin/opencode"
  echo "echo 'MOCK_OPENCODE_CALLED with args: \$*'" >> "$TMP/bin/opencode"
  chmod +x "$TMP/bin/opencode"
  export PATH="$TMP/bin:$PATH"

  # Setup git repo
  cd "$TMP"
  git init >/dev/null
  git config --local init.defaultBranch main
  git commit --allow-empty -m "init" >/dev/null
  
  # Allow wtr to accept "current-branch" (which doesn't exist)? 
  # Actually, "current-branch" is just an argument. If we pass ".", it might work?
  # Or we need to create a dummy directory acting as worktree.
  mkdir -p "$TMP/worktree"
  
  # Setup wtr env
  BOP="$BATS_TEST_DIRNAME/../bin/wtr"

  # Configure wtr
  "$BOP" config set wtr.worktrees.dir ".worktrees" --local
}

teardown() {
  rm -rf "$TMP"
}

@test "opencode adapter: open command" {
  export WTR_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run "$BOP" ai 1 --ai opencode -- open --test-flag
  
  # It should find the mock opencode and run it
  [ "$status" -eq 0 ]
  [[ "$output" =~ "MOCK_OPENCODE_CALLED with args: --test-flag" ]]
}

@test "opencode adapter: analyze command" {
  export WTR_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run "$BOP" ai 1 --ai opencode -- analyze --deep
  
  [ "$status" -eq 0 ]
  [[ "$output" =~ "MOCK_OPENCODE_CALLED with args: analyze --deep" ]]
}
