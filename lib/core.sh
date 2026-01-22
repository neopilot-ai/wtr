# dispatch.sh - argument parsing and routing
# This file has been renamed from core.sh to dispatch.sh.

# Load all command modules from lib/commands/
for f in "$WTR_DIR/lib/commands"/*.sh; do
  [ -f "$f" ] && . "$f"
done

# Dispatch to command handler
dispatch_command() {
  local cmd="${1:-help}"
  
  # Extract command and remaining args
  shift 2>/dev/null || true
  
  case "$cmd" in
    # Aliases for add
    add|create|new)
      cmd_add "$@"
      ;;
    # Aliases for remove
    remove|rm)
      cmd_remove "$@"
      ;;
    # Aliases for list
    list|ls)
      cmd_list "$@"
      ;;
    # Direct commands
    run)
      cmd_run "$@"
      ;;
    exec)
      cmd_exec "$@"
      ;;
    doctor)
      cmd_doctor "$@"
      ;;
    # Help and version
    --help|-h|help)
      cmd_help
      ;;
    --version|-v|version)
      echo "git wtr version $WTR_VERSION"
      ;;
    *)
      log_error "Unknown command: $cmd"
      echo "Use 'wtr help' for available commands"
      exit 1
      ;;
  esac
}

cmd_help() {
  cat <<'EOF'
wtr - Modern Git Worktree Orchestration

Usage: wtr <command> [options]

Commands:
  add <branch>        Create a new worktree
  remove <branch>     Remove a worktree  
  list                List all worktrees
  run [options]       Run commands in worktrees
  exec <branch>       Execute in a worktree
  doctor              Run system diagnostics

Options:
  -h, --help          Show this help message
  -v, --version       Show version

Examples:
  wtr add feature/new-ui
  wtr list
  wtr doctor

For command-specific help:
  wtr <command> --help
EOF
}
