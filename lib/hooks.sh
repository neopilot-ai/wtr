#!/usr/bin/env bash
# Hook execution system

# ── Hook trust model ────────────────────────────────────────────────────
# Hooks and executable defaults from .wtrconfig files (committed to
# repositories) require explicit user approval before use. This prevents
# malicious contributors from injecting arbitrary commands via shared config
# files.
#
# Trust state is stored in ~/.config/wtr/trusted/<key>
# where <key> binds the canonical repo root, the executing worktree's Git
# directory identities (worktree-specific, common and object database) and trusted content hash.
# The marker also records the reviewed HEAD commit; approval stays valid only
# while the current HEAD is that commit or a descendant, so history rewrites,
# replaced repositories and swapped Git directories require new approval.
# Trust approves command definitions, including any code they delegate to; it
# does not pin script contents, dependencies or repository snapshot state.

_WTR_TRUST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wtr/trusted"

# Read all trusted command definitions from a .wtrconfig file.
# Usage: _hooks_read_definitions <config_file>
_hooks_read_definitions() {
  local config_file="$1"
  # Hex keeps NUL record boundaries and trailing value newlines in shell variables.
  # Git emits key<LF>value<NUL>; unlike line records this encoding is injective.
  local hook_content
  hook_content=$(git config -z -f "$config_file" --get-regexp '^hooks\.|^defaults\.editor$|^defaults\.ai$' 2>/dev/null | od -An -v -tx1 | tr -d ' \n')
  [ -n "$hook_content" ] || return 1
  printf '%s\n' "$hook_content"
}

# Select values only from the captured definitions, never from the pathname.
# An empty key displays every record for the trust confirmation.
_hooks_definitions_get() {
  local definitions="$1" key="${2:-}" mode="${3:-all}" record record_key value last_value=""
  key=$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')
  while IFS= read -r -d '' record; do
    record_key="${record%%$'\n'*}"
    value=""
    case "$record" in *$'\n'*) value="${record#*$'\n'}" ;; esac
    if [ -z "$key" ]; then
      printf '%s = %q\n' "$record_key" "$value"
    elif [ "$record_key" = "$key" ]; then
      if [ "$mode" = last ]; then
        last_value="$value"
      else
        printf '%s\n' "$value"
      fi
    fi
  done < <(printf '%b' "$(printf '%s' "$definitions" | sed 's/../\\x&/g')")
  if [ "$mode" = last ]; then printf '%s\n' "$last_value"; fi
}

# Validate a captured snapshot against its repository-scoped marker.
_hooks_snapshot_is_trusted() {
  local config_file="$1" definitions="$2" trust_path
  [ -n "$definitions" ] || return 0
  trust_path=$(_hooks_reviewed_trust_path "$config_file" "$definitions") || return 1
  _hooks_marker_matches_config "$trust_path" "$config_file"
}

# Compute a content hash for trusted command definitions.
# Usage: _hooks_content_hash <hook_content>
_hooks_content_hash() {
  local hook_content="$1"
  [ -n "$hook_content" ] || return 1
  printf '%s\n' "$hook_content" | shasum -a 256 | cut -d' ' -f1
}

# Compute a content hash of all current trusted command entries in a .wtrconfig file.
# Usage: _hooks_current_content_hash <config_file>
_hooks_current_content_hash() {
  local config_file="$1"
  local hook_content
  hook_content=$(_hooks_read_definitions "$config_file") || return 1
  _hooks_content_hash "$hook_content"
}

# Backward-compatible alias used by tests and older call sites.
_hooks_file_hash() {
  _hooks_current_content_hash "$1"
}

# Resolve the canonical repository root for a .wtrconfig file
# Usage: _hooks_repo_root <config_file>
_hooks_repo_root() {
  local config_file="$1"
  (
    cd "$(dirname "$config_file")" 2>/dev/null &&
    pwd -P
  )
}

# Return the stat-based birth identity of a directory, or fail when the
# filesystem cannot provide a trustworthy birth time. GNU %W is whole seconds
# even with precision; %w retains birth nanoseconds. Do not use a
# repository-controlled config value or file as an identity token.
_hooks_dir_birth_identity() {
  local dir="$1"
  local identity birth_time
  identity=$(LC_ALL=C TZ=UTC stat -c '%d:%i:%W:%w' "$dir" 2>/dev/null) ||
    identity=$(LC_ALL=C stat -f '%d:%i:%.9FB' "$dir" 2>/dev/null) || return 1
  birth_time="${identity#*:*:}"
  birth_time="${birth_time%%:*}"
  case "$birth_time" in
    ''|0|0.*|*[!0-9.]*) return 1 ;;
  esac
  printf '%s\n' "$identity"
}

# Identify this repository instance, rather than just its reusable path.
# Bind BOTH Git directory instances: the worktree-specific Git directory
# (--git-dir, e.g. <common>/worktrees/<name> for linked worktrees) and the
# common Git directory (--git-common-dir). Approval granted in one worktree
# therefore does not authorize hooks running in another worktree of the same
# repository. Require known birth times and preserve nanoseconds to distinguish
# rapid inode reuse. Filesystems without birth times fail closed.
# <dir> may be any directory inside the target worktree.
_hooks_repo_identity() {
  local context_dir="$1"
  local worktree_dir common_dir objects_dir wt_identity common_identity objects_identity
  worktree_dir=$(git -C "$context_dir" rev-parse --git-dir 2>/dev/null) || return 1
  common_dir=$(git -C "$context_dir" rev-parse --git-common-dir 2>/dev/null) || return 1
  objects_dir=$(git -C "$context_dir" rev-parse --git-path objects 2>/dev/null) || return 1
  worktree_dir=$(cd "$context_dir" && cd "$worktree_dir" && pwd -P) || return 1
  common_dir=$(cd "$context_dir" && cd "$common_dir" && pwd -P) || return 1
  objects_dir=$(cd "$context_dir" && cd "$objects_dir" && pwd -P) || return 1
  wt_identity=$(_hooks_dir_birth_identity "$worktree_dir") || return 1
  common_identity=$(_hooks_dir_birth_identity "$common_dir") || return 1
  objects_identity=$(_hooks_dir_birth_identity "$objects_dir") || return 1
  printf '%s\n%s\n%s\n%s\n%s\n%s\n' "$worktree_dir" "$wt_identity" "$common_dir" "$common_identity" "$objects_dir" "$objects_identity"
}

# Print the full commit SHA that HEAD points to in the repo containing <dir>.
# Usage: _hooks_head_commit [dir]
_hooks_head_commit() {
  local dir="${1:-.}"
  git -C "$dir" rev-parse --verify HEAD 2>/dev/null
}

# Return 0 when <ancestor> is HEAD itself or one of its ancestors in the repo
# containing <dir>. Ancestry is proven against raw commit objects only:
# replace refs are disabled, lazy promisor fetches are disabled, grafts are
# neutralized and the commit-graph is bypassed, so derived history sources
# cannot forge parentage. Missing objects, unborn HEAD or unrelated history
# all fail closed.
# Usage: _hooks_head_descends_from <ancestor_sha> [dir]
_hooks_head_descends_from() {
  local ancestor="$1" dir="${2:-.}"
  case "$ancestor" in
    ''|*[!0-9a-fA-F]*) return 1 ;;
  esac
  GIT_NO_REPLACE_OBJECTS=1 GIT_NO_LAZY_FETCH=1 GIT_GRAFT_FILE=/dev/null \
    git -c core.commitGraph=false -C "$dir" merge-base --is-ancestor "$ancestor" HEAD 2>/dev/null
}

# Resolve the canonical path for a .wtrconfig file
# Usage: _hooks_canonical_config_path <config_file>
_hooks_canonical_config_path() {
  local config_file="$1"
  local repo_root
  repo_root=$(_hooks_repo_root "$config_file") || return 1
  printf '%s/%s\n' "$repo_root" "$(basename "$config_file")"
}

# Compute the repo-scoped trust key for reviewed trusted command content.
# The Git directory identity is resolved for the worktree containing the
# current directory, so approval is bound to the worktree the hooks run in.
# Usage: _hooks_reviewed_trust_key <config_file> <hook_content> [repo_identity]
_hooks_reviewed_trust_key() {
  local config_file="$1"
  local hook_content="$2"
  local repo_identity="${3:-}"
  local hash repo_root
  hash=$(_hooks_content_hash "$hook_content") || return 1
  repo_root=$(_hooks_repo_root "$config_file") || return 1
  if [ -z "$repo_identity" ]; then
    repo_identity=$(_hooks_repo_identity "$(pwd -P)") || return 1
  fi
  printf 'v5\n%s\n%s\n%s\n' "$repo_root" "$repo_identity" "$hash" | shasum -a 256 | cut -d' ' -f1
}

# Compute the repo-scoped trust key for the current trusted command content
# Usage: _hooks_current_trust_key <config_file>
_hooks_current_trust_key() {
  local config_file="$1"
  local hook_content
  hook_content=$(_hooks_read_definitions "$config_file") || return 1
  _hooks_reviewed_trust_key "$config_file" "$hook_content"
}

# Backward-compatible alias used by existing call sites.
_hooks_trust_key() {
  _hooks_current_trust_key "$1"
}

# Resolve the trust marker path for reviewed trusted command content
# Usage: _hooks_reviewed_trust_path <config_file> <hook_content> [repo_identity]
_hooks_reviewed_trust_path() {
  local config_file="$1"
  local hook_content="$2"
  local repo_identity="${3:-}"
  local trust_key
  trust_key=$(_hooks_reviewed_trust_key "$config_file" "$hook_content" "$repo_identity") || return 1
  printf '%s/%s\n' "$_WTR_TRUST_DIR" "$trust_key"
}

# Resolve the trust marker path for a .wtrconfig file
# Usage: _hooks_current_trust_path <config_file>
_hooks_current_trust_path() {
  local config_file="$1"
  local trust_key
  trust_key=$(_hooks_current_trust_key "$config_file") || return 1
  printf '%s/%s\n' "$_WTR_TRUST_DIR" "$trust_key"
}

# Backward-compatible aliases used by existing call sites.
_hooks_trust_path() {
  _hooks_current_trust_path "$1"
}

_hooks_trust_path_for_content() {
  _hooks_reviewed_trust_path "$1" "$2"
}

# Check whether a trust marker matches the canonical config path and that the
# reviewed commit it records is still HEAD or an ancestor of it.
# Marker format: "<canonical config path>\n<reviewed commit sha>".
# Usage: _hooks_marker_matches_config <trust_path> <config_file>
_hooks_marker_matches_config() {
  local trust_path="$1"
  local config_file="$2"
  local marker_content canonical_config_file marker_path reviewed_commit

  [ -f "$trust_path" ] || return 1
  marker_content="$(cat "$trust_path" 2>/dev/null)" || return 1
  canonical_config_file=$(_hooks_canonical_config_path "$config_file") || return 1
  marker_path="${marker_content%%$'\n'*}"
  reviewed_commit="${marker_content#*$'\n'}"
  [ "$marker_path" = "$canonical_config_file" ] || return 1
  _hooks_head_descends_from "$reviewed_commit" "."
}

# Check if .wtrconfig command definitions are trusted for the current repository
# Usage: _hooks_are_trusted <config_file>
# Returns: 0 if trusted (or no trusted command definitions), 1 if untrusted
_hooks_are_trusted() {
  local config_file="$1"
  [ ! -f "$config_file" ] && return 0

  local hook_content trust_path
  hook_content=$(_hooks_read_definitions "$config_file") || return 0
  _hooks_snapshot_is_trusted "$config_file" "$hook_content"
}

# Append an audit record for a successful approval. History is best-effort:
# a logging failure must never affect the trust decision itself.
# Usage: _hooks_record_trust_history <config_file> <reviewed_commit> <trust_key>
_hooks_record_trust_history() {
  local config_file="$1" reviewed_commit="$2" trust_key="$3"
  local repo_root worktree_dir timestamp
  repo_root=$(_hooks_repo_root "$config_file") || repo_root=""
  worktree_dir=$(git -C "$(pwd -P)" rev-parse --git-dir 2>/dev/null) || worktree_dir=""
  if [ -n "$worktree_dir" ]; then
    worktree_dir=$(cd "$(pwd -P)" && cd "$worktree_dir" && pwd -P 2>/dev/null) || worktree_dir=""
  fi
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null) || timestamp=""
  printf '%s\t%s\t%s\t%s\t%s\n' "$timestamp" "$repo_root" "$worktree_dir" "$reviewed_commit" "$trust_key" \
    >> "$_WTR_TRUST_DIR/history.log" 2>/dev/null || true
}

# Write a trust marker binding the reviewed definitions to the canonical
# config path and the HEAD commit that was reviewed.
# Usage: _hooks_write_trust_marker <trust_path> <config_file> <reviewed_commit>
_hooks_write_trust_marker() {
  local trust_path="$1"
  local config_file="${2:-}"
  local reviewed_commit="${3:-}"
  local temp_path=""
  local canonical_config_file=""

  case "$reviewed_commit" in
    ''|*[!0-9a-fA-F]*) return 1 ;;
  esac

  mkdir -p "$_WTR_TRUST_DIR" || return 1
  canonical_config_file=$(_hooks_canonical_config_path "$config_file") || return 1
  temp_path="$(mktemp "$_WTR_TRUST_DIR/.trust.XXXXXX")" || return 1

  if ! printf '%s\n%s\n' "$canonical_config_file" "$reviewed_commit" > "$temp_path"; then
    rm -f "$temp_path"
    return 1
  fi

  if ! mv -f "$temp_path" "$trust_path"; then
    rm -f "$temp_path"
    return 1
  fi
  _hooks_record_trust_history "$config_file" "$reviewed_commit" "$(basename "$trust_path")"
}

# Mark .wtrconfig command definitions as trusted for the current worktree,
# recording the HEAD commit that was reviewed.
# Usage: _hooks_mark_trusted <config_file>
_hooks_mark_trusted() {
  local config_file="$1"
  local hook_content trust_path reviewed_commit
  hook_content=$(_hooks_read_definitions "$config_file") || return 0
  reviewed_commit=$(_hooks_head_commit ".") || return 1
  trust_path=$(_hooks_reviewed_trust_path "$config_file" "$hook_content") || return 1

  _hooks_write_trust_marker "$trust_path" "$config_file" "$reviewed_commit"
}

# Get hooks, filtering out untrusted .wtrconfig hooks with a warning
# Usage: _hooks_get_trusted <phase>
_hooks_get_trusted() {
  local phase="$1"

  # Always include hooks from git config (user controls their own .git/config)
  local git_hooks
  git_hooks=$(git config --get-all "wtr.hook.$phase" 2>/dev/null) || true

  # Check .wtrconfig trust before including its hooks
  local config_file
  config_file=$(_wtrconfig_path)
  local file_hooks=""

  if [ -n "$config_file" ] && [ -f "$config_file" ]; then
    local definitions
    definitions=$(_hooks_read_definitions "$config_file") || true
    file_hooks=$(_hooks_definitions_get "$definitions" "hooks.$phase")
    if ! _hooks_snapshot_is_trusted "$config_file" "$definitions"; then
      if [ -n "$file_hooks" ]; then
        log_warn "Untrusted .wtrconfig hooks for '$phase' phase — skipping"
        log_warn "Review hooks in $config_file, then run: git wtr trust"
      fi
      file_hooks=""
    fi
  fi

  # Merge and deduplicate
  {
    [ -n "$git_hooks" ] && printf '%s\n' "$git_hooks"
    [ -n "$file_hooks" ] && printf '%s\n' "$file_hooks"
  } | awk '!seen[$0]++'
}

# Report the outcome a successful hook phase will have without executing it.
# Usage: _hooks_phase_status <phase>
# Prints one of: none, ran, skipped-untrusted, partial
_hooks_phase_status() {
  local phase="$1"
  local git_hooks="" config_file="" file_hooks=""
  local has_runnable=0 has_untrusted=0

  git_hooks=$(git config --get-all "wtr.hook.$phase" 2>/dev/null) || true
  [ -n "$git_hooks" ] && has_runnable=1

  config_file=$(_wtrconfig_path) || true
  if [ -n "$config_file" ] && [ -f "$config_file" ]; then
    file_hooks=$(git config -f "$config_file" --get-all "hooks.$phase" 2>/dev/null) || true
    if [ -n "$file_hooks" ]; then
      if _hooks_are_trusted "$config_file"; then
        has_runnable=1
      else
        has_untrusted=1
      fi
    fi
  fi

  if [ "$has_runnable" -eq 1 ] && [ "$has_untrusted" -eq 1 ]; then
    printf "partial"
  elif [ "$has_runnable" -eq 1 ]; then
    printf "ran"
  elif [ "$has_untrusted" -eq 1 ]; then
    printf "skipped-untrusted"
  else
    printf "none"
  fi
}

# Run hooks for a specific phase
# Usage: run_hooks phase [env_vars...]
# Example: run_hooks postCreate REPO_ROOT="$root" WORKTREE_PATH="$path"
run_hooks() {
  local phase="$1"
  shift

  # Get hooks, filtering untrusted .wtrconfig hooks
  local hooks
  hooks=$(_hooks_get_trusted "$phase")

  if [ -z "$hooks" ]; then
    # No hooks configured for this phase
    return 0
  fi

  log_step "Running $phase hooks..."

  local hook_count=0
  local failed=0

  # Capture environment variable assignments in array to preserve quoting
  local envs=("$@")

  # Execute each hook in a subshell to isolate side effects
  while IFS= read -r hook; do
    [ -z "$hook" ] && continue

    hook_count=$((hook_count + 1))
    log_info "Hook $hook_count: $hook"

    # Run hook in subshell with properly quoted environment exports
    if (
      # Export each KEY=VALUE exactly as passed, safely quoted
      for kv in "${envs[@]}"; do
        # shellcheck disable=SC2163
        export "$kv"
      done
      # Execute the hook
      eval "$hook"
    ) </dev/null; then
      log_info "Hook $hook_count completed successfully"
    else
      local rc=$?
      log_error "Hook $hook_count failed with exit code $rc"
      failed=$((failed + 1))
    fi
  done <<EOF
$hooks
EOF

  if [ "$failed" -gt 0 ]; then
    log_warn "$failed hook(s) failed"
    return 1
  fi

  return 0
}

# Run hooks in a specific directory
# Usage: run_hooks_in phase directory [env_vars...]
run_hooks_in() {
  local phase="$1"
  local directory="$2"
  shift 2

  local old_pwd
  old_pwd=$(pwd)

  if [ ! -d "$directory" ]; then
    log_error "Directory does not exist: $directory"
    return 1
  fi

  cd "$directory" || return 1

  run_hooks "$phase" "$@"
  local result=$?

  cd "$old_pwd" || return 1

  return $result
}

# Run hooks in current shell without subshell isolation
# Env vars set by hooks (e.g., source ./vars.sh) persist in the calling shell.
# IMPORTANT: Call from within a subshell to avoid polluting the main script.
# Usage: run_hooks_export phase [env_vars...]
# Example: ( cd "$dir" && run_hooks_export postCd REPO_ROOT="$root" )
run_hooks_export() {
  local phase="$1"
  shift

  local hooks
  hooks=$(_hooks_get_trusted "$phase")

  if [ -z "$hooks" ]; then
    return 0
  fi

  log_step "Running $phase hooks..."

  # Export env vars so hooks and child processes can see them
  local kv
  for kv in "$@"; do
    # shellcheck disable=SC2163
    export "$kv"
  done

  local hook_count=0
  while IFS= read -r hook; do
    [ -z "$hook" ] && continue

    hook_count=$((hook_count + 1))
    log_info "Hook $hook_count: $hook"

    # eval directly (no subshell) so exports persist
    eval "$hook" </dev/null || log_warn "Hook $hook_count failed (continuing)"
  done <<EOF
$hooks
EOF
}
