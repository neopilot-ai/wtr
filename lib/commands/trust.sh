#!/usr/bin/env bash
# Trust management for executable .wtrconfig commands

cmd_trust() {
  local config_file
  config_file=$(_wtrconfig_path)

  if [ -z "$config_file" ] || [ ! -f "$config_file" ]; then
    log_info "No .wtrconfig file found in this repository"
    return 0
  fi

  # Bind the definitions to the worktree and commit present before they are
  # read. Approval is per worktree: the Git directory identities and the
  # reviewed HEAD commit are captured in the current directory's context.
  local repo_identity reviewed_commit
  repo_identity=$(_hooks_repo_identity "$(pwd -P)") || return 1
  reviewed_commit=$(_hooks_head_commit ".") || {
    log_error "Cannot determine HEAD commit; approval requires a commit to review"
    return 1
  }

  # Show all trusted command entries from .wtrconfig
  local hook_content
  hook_content=$(_hooks_read_definitions "$config_file") || true

  if [ -z "$hook_content" ]; then
    log_info "No hooks or executable defaults defined in $config_file"
    return 0
  fi

  if _hooks_snapshot_is_trusted "$config_file" "$hook_content"; then
    log_info "Executable commands in $config_file are already trusted"
    log_info "Current trusted commands:"
    _hooks_definitions_get "$hook_content" >&2
    return 0
  fi

  local trust_path
  trust_path=$(_hooks_reviewed_trust_path "$config_file" "$hook_content" "$repo_identity") || {
    log_error "Failed to compute trust marker for $config_file"
    return 1
  }

  log_warn "The following executable commands are defined in $config_file:"
  echo "" >&2
  _hooks_definitions_get "$hook_content" >&2
  echo "" >&2
  log_warn "These commands will execute on your machine during wtr operations."
  log_warn "Approval includes scripts and programs they invoke; their contents are not pinned."

  if prompt_yes_no "Trust these commands?"; then
    if _hooks_write_trust_marker "$trust_path" "$config_file" "$reviewed_commit"; then
      local current_trust_path
      current_trust_path=$(_hooks_current_trust_path "$config_file") || true
      if [ "$current_trust_path" != "$trust_path" ] ||
        ! _hooks_head_descends_from "$reviewed_commit" "."; then
        log_warn "Executable commands, repository identity or HEAD changed during review; current commands remain untrusted"
        return 1
      fi
      log_info "Executable commands marked as trusted"
    else
      log_error "Failed to mark executable commands as trusted"
      return 1
    fi
  else
    log_info "Executable commands remain untrusted and will not run from .wtrconfig"
  fi
}
