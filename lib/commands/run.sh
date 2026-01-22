#!/bin/bash
# run.sh - Run commands across worktrees

cmd_run() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr run [options] -- <command>

Run a command in a specific worktree or all worktrees.

Options:
  --all               Run in all worktrees
  --parallel          Run commands in parallel
  -h, --help          Show this help message

Examples:
  wtr run -- npm test
  wtr run --all -- git status
EOF
      return 0
      ;;
  esac

  log_info "run command: $*"
}
