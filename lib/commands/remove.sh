#!/bin/bash
# remove.sh - Remove a worktree

cmd_remove() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr remove <branch> [options]

Remove a Git worktree and optionally prune the branch.

Arguments:
  branch              Branch name to remove

Options:
  --force             Force removal even if dirty
  --prune             Delete the branch after removing worktree
  -h, --help          Show this help message

Examples:
  wtr remove feature/old
  wtr remove hotfix/done --prune
EOF
      return 0
      ;;
  esac

  log_info "remove command: $*"
}
