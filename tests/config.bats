#!/usr/bin/env bats
# Tests for lib/config.sh — key mapping, cfg_list helpers, formatting
load test_helper

setup() {
  source "$PROJECT_ROOT/lib/config.sh"
}

teardown() {
  if [ -n "${TEST_REPO:-}" ]; then
    teardown_integration_repo
    unset TEST_REPO TEST_WORKTREES_DIR
  fi
}

# ── Key mapping ──────────────────────────────────────────────────────────────

@test "cfg_map_to_file_key maps wtr.copy.include to copy.include" {
  result=$(cfg_map_to_file_key "wtr.copy.include")
  [ "$result" = "copy.include" ]
}

@test "cfg_map_to_file_key maps wtr.editor.default to defaults.editor" {
  result=$(cfg_map_to_file_key "wtr.editor.default")
  [ "$result" = "defaults.editor" ]
}

@test "cfg_map_to_file_key returns empty for unknown key" {
  result=$(cfg_map_to_file_key "wtr.nonexistent")
  [ -z "$result" ]
}

@test "cfg_map_from_file_key maps copy.include to wtr.copy.include" {
  result=$(cfg_map_from_file_key "copy.include")
  [ "$result" = "wtr.copy.include" ]
}

@test "cfg_map_from_file_key maps defaults.editor to wtr.editor.default" {
  result=$(cfg_map_from_file_key "defaults.editor")
  [ "$result" = "wtr.editor.default" ]
}

@test "cfg_map_from_file_key passes through wtr.* keys" {
  result=$(cfg_map_from_file_key "wtr.copy.include")
  [ "$result" = "wtr.copy.include" ]
}

@test "cfg_map_from_file_key returns empty for unknown non-wtr key" {
  result=$(cfg_map_from_file_key "totally.unknown")
  [ -z "$result" ]
}

@test "round-trip: all _CFG_KEY_MAP entries are bidirectional" {
  for pair in "${_CFG_KEY_MAP[@]}"; do
    local wtr_key="${pair%%|*}"
    local file_key="${pair#*|}"

    local mapped_file
    mapped_file=$(cfg_map_to_file_key "$wtr_key")
    [ "$mapped_file" = "$file_key" ]

    local mapped_wtr
    mapped_wtr=$(cfg_map_from_file_key "$file_key")
    [ "$mapped_wtr" = "$wtr_key" ]
  done
}

# ── Known key detection ──────────────────────────────────────────────────────

@test "_cfg_is_known_key returns 0 for wtr.copy.include" {
  _cfg_is_known_key "wtr.copy.include"
}

@test "_cfg_is_known_key returns 0 for wtr.hook.postCd" {
  _cfg_is_known_key "wtr.hook.postCd"
}

@test "_cfg_is_known_key returns 1 for unknown key" {
  ! _cfg_is_known_key "wtr.nonexistent"
}

# ── Boolean values ───────────────────────────────────────────────────────────

@test "cfg_bool uses Git boolean parsing for nonzero integers" {
  setup_integration_repo
  git -C "$TEST_REPO" config wtr.sparse.inherit 2

  cfg_bool wtr.sparse.inherit false
}

@test "cfg_bool skips an unsupported worktree config scope" {
  _cfg_read_bool() {
    [ "${2:-}" = "--worktree" ] && return 3
    [ "${2:-}" = "--local" ] && { printf "true"; return 0; }
    return 1
  }

  cfg_bool wtr.sparse.inherit false
}

# ── cfg_list deduplication ───────────────────────────────────────────────────

@test "_cfg_list_add_entry adds entry to result" {
  _cfg_list_seen=""
  _cfg_list_result=""
  _cfg_list_add_entry "local" "wtr.editor.default" "vscode"
  [[ "$_cfg_list_result" == *"wtr.editor.default"* ]]
  [[ "$_cfg_list_result" == *"vscode"* ]]
  [[ "$_cfg_list_result" == *"local"* ]]
}

@test "_cfg_list_add_entry deduplicates same key+value" {
  _cfg_list_seen=""
  _cfg_list_result=""
  _cfg_list_add_entry "local" "wtr.editor.default" "vscode"
  _cfg_list_add_entry "global" "wtr.editor.default" "vscode"
  # Should only appear once (local takes priority)
  local count
  count=$(printf '%s' "$_cfg_list_result" | grep -c "wtr.editor.default" || true)
  [ "$count" -eq 1 ]
}

@test "_cfg_list_add_entry allows same key with different values" {
  _cfg_list_seen=""
  _cfg_list_result=""
  _cfg_list_add_entry "local" "wtr.copy.include" ".env*"
  _cfg_list_add_entry "local" "wtr.copy.include" "*.config.js"
  local count
  count=$(printf '%s' "$_cfg_list_result" | grep -c "wtr.copy.include" || true)
  [ "$count" -eq 2 ]
}

# ── cfg_list formatting ─────────────────────────────────────────────────────

@test "_cfg_list_format shows message for empty output" {
  result=$(_cfg_list_format "")
  [ "$result" = "No wtr configuration found" ]
}

@test "_cfg_list_format formats scoped output (space-delimited)" {
  result=$(_cfg_list_format "wtr.editor.default vscode")
  [[ "$result" == *"wtr.editor.default"* ]]
  [[ "$result" == *"= vscode"* ]]
}

@test "_cfg_list_format formats auto output (unit-separator-delimited)" {
  local us=$'\x1f'
  local input="wtr.editor.default${us}vscode${us}local"
  result=$(_cfg_list_format "$input")
  [[ "$result" == *"wtr.editor.default"* ]]
  [[ "$result" == *"vscode"* ]]
  [[ "$result" == *"[local]"* ]]
}

# ── Repo context integration ─────────────────────────────────────────────────

@test "_resolve_main_repo_root returns the repo root from a subdirectory" {
  setup_integration_repo
  mkdir -p "$TEST_REPO/subdir/nested"
  cd "$TEST_REPO/subdir/nested"
  local expected
  expected=$(cd "$TEST_REPO" && pwd -P)

  result=$(_resolve_main_repo_root)
  [ "$result" = "$expected" ]
}

@test "_wtrconfig_path points at the repo root from a subdirectory" {
  setup_integration_repo
  mkdir -p "$TEST_REPO/subdir/nested"
  cd "$TEST_REPO/subdir/nested"
  local expected
  expected="$(cd "$TEST_REPO" && pwd -P)/.wtrconfig"

  result=$(_wtrconfig_path)
  [ "$result" = "$expected" ]
}
