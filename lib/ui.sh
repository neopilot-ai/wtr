# ui.sh - UI helpers

# Prompt for a single line of input
prompt_input() {
  local prompt="$1"
  local ans
  # Using stderr for prompt so stdout remains clean for assignment
  printf "%s " "$prompt" >&2
  read -r ans
  echo "$ans"
}

# Prompt for a yes/no question
prompt_yes_no() {
  local prompt="$1"
  local ans
  while true; do
    printf "%s [y/N]: " "$prompt" >&2
    read -r ans
    case "$ans" in
      [Yy]*) return 0 ;;
      [Nn]*|"") return 1 ;;
      *) echo "Please answer yes or no." >&2 ;;
    esac
  done
}

# Open a path in the system's file browser
open_in_gui() {
  local path="$1"
  case "$(detect_os)" in
    macos)
      open "$path"
      ;;
    linux)
      if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$path"
      else
        log_warn "xdg-open not found, cannot open GUI"
      fi
      ;;
    windows)
      start "" "$path"
      ;;
    *)
      log_warn "Unsupported platform for opening GUI"
      ;;
  esac
}

# Print a formatted table
# Expects column widths as first arg (comma-separated), then data lines
# Each data line should be tab-separated
print_table() {
  local widths_str="$1"
  shift
  local IFS=','
  read -ra widths <<< "$widths_str"
  
  # Print header
  local line="$1"
  shift
  local IFS=$'\t'
  read -ra cols <<< "$line"
  
  printf "${BOLD}"
  for i in "${!cols[@]}"; do
    printf "%-${widths[$i]}s  " "${cols[$i]}"
  done
  printf "${RESET}\n"
  
  # Print separator
  for i in "${!widths[@]}"; do
    printf "%-${widths[$i]}s  " "$(printf '%.0s-' $(seq 1 "${widths[$i]}"))"
  done
  printf "\n"
  
  # Print rows
  while [ $# -gt 0 ]; do
    line="$1"
    shift
    local IFS=$'\t'
    read -ra cols <<< "$line"
    for i in "${!cols[@]}"; do
      printf "%-${widths[$i]}b  " "${cols[$i]}"
    done
    printf "\n"
  done
}

# Prompt to select a worktree from the list
# Returns the selected identifier
prompt_select_worktree() {
  local header="${1:-Select worktree:}"
  local repo_root base_dir prefix
  repo_root=$(discover_repo_root) || return 1
  base_dir=$(resolve_base_dir "$repo_root")
  prefix=$(cfg_default wtr.worktrees.prefix WTR_WORKTREES_PREFIX "")

  # Get list of worktrees (ID\tBranch\tPath)
  local list=()
  local i=1
  
  # Always include main repo
  local main_branch
  main_branch=$(current_branch "$repo_root")
  list+=("1\t$main_branch\t(main repo)")
  
  if [ -d "$base_dir" ]; then
    while read -r dir; do
      local branch folder
      branch=$(current_branch "$dir")
      folder=$(basename "$dir")
      # Strip prefix from folder to get ID
      local id="${folder#$prefix}"
      list+=("$id\t$branch\t$folder")
    done < <(find "$base_dir" -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null)
  fi

  if command -v fzf >/dev/null 2>&1; then
    local selected
    selected=$(printf "%s\n" "${list[@]}" | column -t -s $'\t' | fzf --header "$header" --height 40% --reverse --cycle)
    [ -z "$selected" ] && return 1
    echo "$selected" | awk '{print $1}'
  else
    echo "$header" >&2
    local j=1
    for item in "${list[@]}"; do
      local id branch desc
      id=$(echo "$item" | cut -f1)
      branch=$(echo "$item" | cut -f2)
      desc=$(echo "$item" | cut -f3)
      printf "%2d) %-15s %s\n" "$j" "$branch" "$desc" >&2
      j=$((j+1))
    done
    
    local choice
    choice=$(prompt_input "Choice [1-$((j-1))]:")
    [ -z "$choice" ] && return 1
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$j" ]; then
      echo "${list[$((choice-1))]}" | cut -f1
    else
      log_error "Invalid choice"
      return 1
    fi
  fi
}

# Legacy alias
confirm() {
  prompt_yes_no "$1"
}
