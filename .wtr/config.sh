#!/bin/bash
# .wtr/config.sh - Project-level wtr configuration

# This file is sourced by bin/wtr if it exists.
# Use it to set project-specific defaults without affecting global config.

# Example configurations:
# export WTR_EDITOR_DEFAULT="cursor"
# export WTR_AI_DEFAULT="claude"
# export WTR_WORKTREES_DIR="./branches"
# export WTR_WORKTREES_PREFIX="wtr-"

# Project-specific hooks can be configured here by setting wtr.hook.* config values
# Example:
# git config wtr.hook.postCreate '.wtr/hooks/post-create.sh'
