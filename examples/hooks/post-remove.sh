#!/usr/bin/env bash
# post-remove.sh - Example post-removal hook for wtr
# This script runs in the MAIN repository root after a worktree is deleted.

set -e

# The path to the deleted worktree is passed as the first argument
WORKTREE_PATH="$1"

echo "==> Post-removal hook: Cleanup after $WORKTREE_PATH"

# Example: Clean up temporary databases or external resources
# if [ -f "scripts/cleanup_test_db.sh" ]; then
#     bash scripts/cleanup_test_db.sh "$WORKTREE_PATH"
# fi

echo "==> Cleanup complete."
