#!/usr/bin/env bash
# pre-remove.sh - Example pre-removal hook for wtr
# This script runs inside the worktree that is ABOUT to be removed.

set -e

echo "==> Pre-removal hook: Checking for unsaved work..."

# 1. Check for uncommitted changes
if ! git diff --quiet; then
    echo "WARNING: There are uncommitted changes in this worktree!"
    # git status -s
    # exit 1 # Uncomment to block removal if changes exist
fi

# 2. Check for untracked files
if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "WARNING: There are untracked files in this worktree!"
    # exit 1 # Uncomment to block removal if untracked files exist
fi

# 3. Prompt for confirmation if NOT running in clean/automated mode
if [ "${WTR_NON_INTERACTIVE:-}" != "1" ]; then
    printf "Are you sure you want to delete this worktree? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Removal aborted by user."
        exit 1
    fi
fi

echo "==> Proceeding with removal..."
