#!/bin/bash
# list.sh - List all worktrees

cmd_list() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr list [options]

List all Git worktrees in the current repository.

Options:
  --long              Show detailed information
  --porcelain         Machine-readable output
  -h, --help          Show this help message

Examples:
  wtr list
  wtr list --long
EOF
      return 0
      ;;
  esac

  log_info "list command: $*"
}
