#!/usr/bin/env bash
# lib/core/worktree.sh - git worktree manipulation helpers

# Discover the absolute path to the repo root
discover_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# Resolve the base directory for worktrees (can be configured)
resolve_base_dir() {
  local repo_root="$1"
  local repo_name
  repo_name=$(basename "$repo_root")
  local configured
  configured=$(cfg_get "wtr.worktrees.dir")
  if [ -n "$configured" ]; then
    # If absolute, use as is. If relative, join with repo root.
    if [[ "$configured" == /* ]]; then
      echo "$configured"
    else
      echo "$repo_root/$configured"
    fi
  else
    # Default: sibling directory to repo root
    echo "$(dirname "$repo_root")/${repo_name}-worktrees"
  fi
}

# Resolve the default branch of the repository
resolve_default_branch() {
  local repo_root="$1"
  local configured
  configured=$(cfg_get "wtr.defaultBranch")
  if [ -n "$configured" ] && [ "$configured" != "auto" ]; then
    echo "$configured"
    return 0
  fi

  # Auto-detection
  local default
  default=$(git -C "$repo_root" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
  [ -z "$default" ] && default=$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -z "$default" ] && default="main"
  echo "$default"
}

# Sanitize branch name for use as a folder name
sanitize_branch_name() {
  local name="$1"
  # Replace slashes and other unsafe chars with dashes, then collapse multiple dashes
  echo "$name" | sed 's|[/\\:*?"<>|]| - |g' | tr -s ' ' '-' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# Get current branch of a directory
current_branch() {
  local dir="$1"
  git -C "$dir" branch --show-current 2>/dev/null || git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Get status of a worktree (clean/dirty)
worktree_status() {
  local dir="$1"
  if [ -z "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    echo "clean"
  else
    echo "dirty"
  fi
}

# List all branches that have worktrees attached (excluding main)
list_worktree_branches() {
  local base_dir="$1"
  local prefix="$2"
  if [ -d "$base_dir" ]; then
    find "$base_dir" -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null | while read -r dir; do
      current_branch "$dir"
    done
  fi
}

# Resolve an identifier (ID or branch name) to worktree info
# Returns: is_main_repo<tab>path<tab>branch
resolve_target() {
  local id="$1"
  local repo_root="$2"
  local base_dir="$3"
  local prefix="$4"

  if [ "$id" = "1" ]; then
    local branch
    branch=$(current_branch "$repo_root")
    printf "1\t%s\t%s\n" "$repo_root" "$branch"
    return 0
  fi

  # Search in .worktrees
  if [ -d "$base_dir" ]; then
    # Try direct matches first
    local matches
    matches=$(find "$base_dir" -maxdepth 1 -type d -name "${prefix}${id}" 2>/dev/null)
    if [ -z "$matches" ]; then
      # Search by branch name
      find "$base_dir" -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null | while read -r dir; do
        local branch
        branch=$(current_branch "$dir")
        if [ "$branch" = "$id" ]; then
          printf "0\t%s\t%s\n" "$dir" "$branch"
          return 0
        fi
      done
    else
      # Direct match found
      for dir in $matches; do
        local branch
        branch=$(current_branch "$dir")
        printf "0\t%s\t%s\n" "$dir" "$branch"
        return 0
      done
    fi
  fi

  log_error "Worktree not found for: $id"
  return 1
}

# Create a new worktree
create_worktree() {
  local base_dir="$1"
  local prefix="$2"
  local branch="$3"
  local from_ref="$4"
  local track_mode="$5"
  local skip_fetch="$6"
  local force="$7"
  local custom_name="$8"

  local folder_name
  if [ -n "$custom_name" ]; then
    folder_name="${prefix}$(sanitize_branch_name "$branch")-${custom_name}"
  else
    folder_name="${prefix}$(sanitize_branch_name "$branch")"
  fi

  local path="$base_dir/$folder_name"

  if [ -d "$path" ] && [ "$force" -eq 0 ]; then
    log_error "Worktree directory already exists: $path"
    return 1
  fi

  # Fetch if requested
  if [ "$skip_fetch" -eq 0 ]; then
    log_step "Fetching from origin..."
    git fetch origin "$from_ref" 2>/dev/null || true
  fi

  # Prepare git worktree add command
  local args=()
  [ "$force" -eq 1 ] && args+=("--force")

  # Tracking mode
  case "$track_mode" in
    remote) args+=("--track") ;;
    none) args+=("--no-track") ;;
  esac

  # Create worktree
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    log_info "Branch '$branch' exists, checkout existing"
    git worktree add "${args[@]}" "$path" "$branch" >&2
  else
    log_info "Creating new branch '$branch' from '$from_ref'"
    git worktree add "${args[@]}" -b "$branch" "$path" "$from_ref" >&2
  fi

  echo "$path"
}

# Remove a worktree
remove_worktree() {
  local path="$1"
  local force="$2"

  local args=()
  [ "$force" -eq 1 ] && args+=("--force")

  if git worktree remove "${args[@]}" "$path"; then
    log_info "Worktree removed from git"
    # Sometimes empty dirs remain
    [ -d "$path" ] && rmdir "$path" 2>/dev/null || true
    return 0
  else
    log_error "Failed to remove worktree"
    return 1
  fi
}
