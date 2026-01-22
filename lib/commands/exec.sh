#!/bin/bash
# exec.sh - Execute in a worktree

cmd_exec() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr exec <branch> [options] -- <command>

Execute a command in a specific worktree.

Arguments:
  branch              Branch/worktree name

Options:
  -h, --help          Show this help message

Examples:
  wtr exec feature/ui -- npm run build
  wtr exec main -- git pull
EOF
      return 0
      ;;
  esac

  log_info "exec command: $*"
}
