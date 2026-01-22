#!/usr/bin/env bats
# test/commands/dispatch.bats - Test command dispatch system

setup() {
  export WTR_DIR="$BATS_TEST_DIRNAME/../.."
  export PATH="$WTR_DIR/bin:$PATH"
}

# Test that unknown commands fail properly
@test "dispatch: unknown command fails with exit code 1" {
  run wtr nonexistent-command
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unknown command" ]]
}

# Test that help is displayed for no arguments
@test "dispatch: no arguments shows help" {
  run wtr
  [ "$status" -eq 0 ]
  [[ "$output" =~ "wtr - Modern Git Worktree" || "$output" =~ "Usage:" ]]
}

# Test that --help works
@test "dispatch: --help flag works" {
  run wtr --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "Commands:" ]]
}

# Test that -h works
@test "dispatch: -h flag works" {
  run wtr -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "Commands:" ]]
}

# Test that help command works
@test "dispatch: help command works" {
  run wtr help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "Commands:" ]]
}

# Test that version works
@test "dispatch: version command works" {
  run wtr version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "version" || "$output" =~ "git wtr" ]]
}

# Test that --version works
@test "dispatch: --version flag works" {
  run wtr --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "version" || "$output" =~ "git wtr" ]]
}

# Test that command aliases work (add -> create)
@test "dispatch: add command alias works" {
  run wtr add --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "branch" ]]
}

# Test that command aliases work (remove -> rm)
@test "dispatch: remove command alias works" {
  run wtr rm --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "branch" ]]
}

# Test that list command works
@test "dispatch: list command works" {
  run wtr list --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "worktree" ]]
}

# Test that doctor command works
@test "dispatch: doctor command works" {
  run wtr doctor --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" || "$output" =~ "diagnostic" ]]
}
