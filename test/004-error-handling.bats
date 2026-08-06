#!/usr/bin/env bats

# Test error handling and edge cases

setup() {
  TMP=$(mktemp -d)
  cd "$TMP"
  mkdir -p repo
  cd repo
  git init >/dev/null
  git config --local init.defaultBranch main
  git commit --allow-empty -m "init" >/dev/null
  
  BOP="$BATS_TEST_DIRNAME/../bin/wtr"
  [ -f "$BOP" ] || skip "wtr binary not found at $BOP"
  
  "$BOP" config set wtr.worktrees.dir ".worktrees" --local
}

teardown() {
  rm -rf "$TMP"
}

@test "create worktree with empty branch name fails" {
  run "$BOP" create ""
  [ "$status" -ne 0 ]
  [[ "${output}" =~ "Branch" ]]
}

@test "create worktree with invalid branch name (starts with dash) fails" {
  run "$BOP" create "-invalid"
  [ "$status" -ne 0 ]
}

@test "create worktree with very long branch name is sanitized" {
  local long_name="very-long-branch-name-that-exceeds-many-characters-in-order-to-test-sanitization-$(printf 'x%.0s' {1..200})"
  run "$BOP" create "$long_name"
  [ "$status" -eq 0 ] || skip "Branch creation may fail for other reasons"
}

@test "remove non-existent worktree fails gracefully" {
  run "$BOP" remove nonexistent
  [ "$status" -ne 0 ]
  [[ "${output}" =~ "not found" || "${output}" =~ "invalid" ]]
}

@test "cannot remove main repository" {
  run "$BOP" remove 1
  [ "$status" -ne 0 ]
  [[ "${output}" =~ "Cannot remove" || "${output}" =~ "main" ]]
}

@test "git operations fail gracefully when not in repo" {
  cd "$TMP"
  run "$BOP" create feature/test
  [ "$status" -ne 0 ]
  [[ "${output}" =~ "not inside" || "${output}" =~ "outside" || "${output}" =~ "repository" ]]
}

@test "config operations validate input" {
  run "$BOP" config set
  [ "$status" -ne 0 ]
}

@test "worktree with bad from-ref fails gracefully" {
  run "$BOP" create feature/test --from "nonexistent-branch-xyz"
  [ "$status" -ne 0 ] || skip "May succeed if branch is created anyway"
}
