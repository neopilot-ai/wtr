#!/bin/bash
# add.sh - Create and add a new worktree

cmd_add() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr add <branch> [options]

Create and add a new Git worktree for the given branch.

Arguments:
  branch              Branch name or ref to create worktree from

Options:
  --from <branch>     Base branch (default: main/master)
  --track             Track upstream branch
  --no-fetch          Skip git fetch before creating
  -h, --help          Show this help message

Examples:
  wtr add feature/new-ui
  wtr add hotfix/urgent --from main --track
EOF
      return 0
      ;;
  esac

  # Placeholder for actual command implementation
  # This will be filled from existing cmd_create logic
  log_info "add command: $*"
}
