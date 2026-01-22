#!/bin/bash
# .wtr/hooks/pre-remove.sh - Hook executed before worktree removal

# This script runs before a worktree is removed.
# It receives these environment variables:
#   REPO_ROOT       - Main repository root
#   WORKTREE_PATH   - Path to the worktree being removed
#   BRANCH          - Branch name

# Exit on error (hook failure will abort unless --force is used)
set -e

# Example: Stash uncommitted changes if needed
# if ! git diff --quiet; then
#   echo "Stashing uncommitted changes..."
#   git stash
# fi

# Example: Run cleanup tasks
# echo "Cleaning up temporary files..."
# rm -rf .cache dist build
