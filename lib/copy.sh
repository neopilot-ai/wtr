# copy.sh - selective copy helpers

# Enable extended globbing if using bash
if [ -n "$BASH_VERSION" ]; then
  shopt -s globstar extglob 2>/dev/null || true
fi

# Parse a pattern file (like .gitignore or .worktreeinclude)
parse_pattern_file() {
  local file="$1"
  if [ -f "$file" ]; then
    # Remove comments and empty lines, and trim whitespace
    grep -v '^#' "$file" | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || true
  fi
}

# Check if a file matches a list of patterns (newline separated)
matches_patterns() {
  local file="$1"
  local patterns="$2"
  
  [ -z "$patterns" ] && return 1

  # Ensure globstar is set for this context
  [ -n "$BASH_VERSION" ] && shopt -s globstar extglob 2>/dev/null

  while read -r p || [ -n "$p" ]; do
    [ -z "$p" ] && continue
    
    # Trim whitespace
    p="${p#"${p%%[![:space:]]*}"}"
    p="${p%"${p##*[![:space:]]}"}"
    
    [ -z "$p" ] && continue

    # Simple glob match
    # shellcheck disable=SC2053
    if [[ "$file" == $p ]]; then
      return 0
    fi
    
    # Also handle patterns that match directories (e.g. "dist/")
    if [[ "$p" == */ ]]; then
      local dir_p="${p%/}"
      if [[ "$file" == "$dir_p"/* ]] || [[ "$file" == "$dir_p" ]]; then
        return 0
      fi
    fi
  done <<< "$patterns"
  
  return 1
}

# Copy files matching patterns from src to dst
copy_patterns() {
  local src="$1"
  local dst="$2"
  local patterns="$3"
  local exclude_patterns="${4:-}"
  local dry_run="${5:-false}"
  local verbose="${6:-false}"

  [ -z "$patterns" ] && return 0

  # Ensure dst exists
  [ "$dry_run" = "false" ] && mkdir -p "$dst"

  # We use git ls-files if possible to respect .gitignore
  # Fallback to find if not a git repo
  local files
  if git -C "$src" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get all tracked and untracked (but not ignored) files
    files=$(git -C "$src" ls-files --cached --others --exclude-standard)
  else
    files=$(cd "$src" && find . -type f | sed 's|^./||')
  fi

  while read -r f || [ -n "$f" ]; do
    [ -z "$f" ] && continue

    # Check includes
    if matches_patterns "$f" "$patterns"; then
      # Check excludes
      if [ -n "$exclude_patterns" ] && matches_patterns "$f" "$exclude_patterns"; then
        continue
      fi

      if [ "$dry_run" = "true" ]; then
        [ "$verbose" = "true" ] && echo "[dry-run] Copying $f"
      else
        mkdir -p "$(dirname "$dst/$f")"
        cp -p "$src/$f" "$dst/$f" 2>/dev/null || log_warn "Failed to copy $f"
        [ "$verbose" = "true" ] && echo "Copied $f"
      fi
    fi
  done <<< "$files"
  
  return 0
}

# Copy entire directories (typically git-ignored ones)
copy_directories() {
  local src="$1"
  local dst="$2"
  local includes="$3"
  local excludes="${4:-}"

  [ -z "$includes" ] && return 0
  
  if [ ! -d "$src" ]; then
    log_error "Source directory does not exist: $src"
    return 1
  fi
  
  if [ ! -d "$dst" ]; then
    if ! mkdir -p "$dst"; then
      log_error "Failed to create destination directory: $dst"
      return 1
    fi
  fi

  local count=0
  echo "$includes" | while read -r d; do
    [ -z "$d" ] && continue
    [ ! -d "$src/$d" ] && { log_debug "Directory not found: $src/$d"; continue; }

    # Skip if excluded
    local skip=0
    if [ -n "$excludes" ]; then
      while read -r e; do
        [ -z "$e" ] && continue
        # shellcheck disable=SC2053
        if [[ "$d" == $e ]]; then
          skip=1
          break
        fi
      done <<< "$excludes"
    fi
    [ "$skip" -eq 1 ] && { log_debug "Directory excluded: $d"; continue; }

    if ! { mkdir -p "$(dirname "$dst/$d")" && cp -Rp "$src/$d" "$dst/$d"; }; then
      log_warn "Failed to copy directory: $d"
      continue
    fi
    
    count=$((count + 1))
    log_debug "Copied directory: $d"
  done
  
  log_info "Copied $count directories"
}

# Legacy alias
copy_files_to_worktree() {
  local src_dir="$1"
  local dst_dir="$2"
  local files_csv="$3"
  IFS=',' read -r -a files <<< "$files_csv"
  local patterns=""
  for f in "${files[@]}"; do
    patterns="${patterns}${patterns:+$'\n'}${f}"
  done
  copy_patterns "$src_dir" "$dst_dir" "$patterns" "" "false" "true"
}
