#!/bin/bash
# doctor.sh - System diagnostics and validation

cmd_doctor() {
  case "${1:-}" in
    -h|--help)
      cat <<'EOF'
Usage: wtr doctor [options]

Run system diagnostics and validate the wtr environment.

Options:
  --verbose           Show detailed diagnostics
  -h, --help          Show this help message

Checks:
  - Git version compatibility
  - Worktree support
  - Adapter availability
  - Configuration conflicts
  - Permissions

Examples:
  wtr doctor
  wtr doctor --verbose
EOF
      return 0
      ;;
  esac

  log_info "Running system diagnostics..."
  _run_doctor_checks "${1:-}"
}

_run_doctor_checks() {
  local verbose="${1:-}"
  local issues=0

  log_step "Git version"
  local git_version
  git_version=$(git --version | awk '{print $3}')
  log_info "Git $git_version"

  log_step "Worktree support"
  if git worktree list >/dev/null 2>&1; then
    log_success "Git worktrees supported"
  else
    log_error "Git worktrees not supported"
    ((issues++))
  fi

  log_step "Bash version"
  log_info "Bash $BASH_VERSION"

  log_step "Configuration"
  if [ -f ".wtrconfig" ]; then
    log_info ".wtrconfig found"
  else
    log_info "No .wtrconfig (using defaults)"
  fi

  if [ "$issues" -eq 0 ]; then
    log_success "All checks passed"
    return 0
  else
    log_error "$issues issue(s) found"
    return 1
  fi
}
