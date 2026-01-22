#!/usr/bin/env bats

setup() {
  TMP=$(mktemp -d)
  cd "$TMP"
  git init >/dev/null
  mkdir -p repo
  cd repo
  git init >/dev/null
  # create initial commit
  git config --local init.defaultBranch main
  git commit --allow-empty -m "init" >/dev/null
  
  # Mock 'code' for vscode adapter
  mkdir -p "$TMP/bin"
  echo "#!/bin/bash" > "$TMP/bin/code"
  chmod +x "$TMP/bin/code"
  export PATH="$TMP/bin:$PATH"

  # symlink the cli to PATH (adjust path to your project during CI)
  BOP="$BATS_TEST_DIRNAME/../bin/wtr"
  [ -f "$BOP" ] || skip "wtr binary not found at $BOP"
  
  # Configure wtr to use .worktrees inside repo (legacy/test mode)
  "$BOP" config set wtr.worktrees.dir ".worktrees" --local
}

teardown() {
  rm -rf "$TMP"
}

@test "create worktree (dry-run) succeeds without side effects" {
  "$BOP" config set wtr.editor.default vscode --local
  NEOPILOT_DRY_RUN=1 run "$BOP" create feature/test --editor
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "dry-run" ]]
}

@test "create worktree with invalid editor fails" {
  "$BOP" config set wtr.editor.default nonexistent-editor --local
  run "$BOP" create feature/test-fail --editor
  [ "$status" -ne 0 ]
  [[ "${output}" =~ "unknown editor" || "${output}" =~ "not available" ]]
}

@test "create worktree with copy list" {
  # Create test files to copy
  echo "test" > .env
  git add .env
  git commit -m "Add .env" >/dev/null
  
  # Configure copy
  "$BOP" config add wtr.copy.include ".env" --local
  
  NEOPILOT_DRY_RUN=1 run "$BOP" create feature/test-copy
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "copy" ]]
  [[ "${output}" =~ ".env" ]]
}

@test "create worktree with AI integration" {
  "$BOP" config set wtr.ai.default aider --local
  NEOPILOT_DRY_RUN=1 run "$BOP" create feature/test-ai --ai
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "aider" ]]
}
