#!/bin/bash
# .wtr/hooks/post-create.sh - Hook executed after worktree creation

# This script runs automatically in the newly created worktree after it's created.
# It receives these environment variables:
#   REPO_ROOT       - Main repository root
#   WORKTREE_PATH   - Path to the new worktree
#   BRANCH          - Branch name

# Exit on error (hook failure will abort unless --force is used)
set -e

# Example: Install npm dependencies if package.json exists
# if [ -f "package.json" ]; then
#   echo "Installing dependencies..."
#   npm ci
# fi

# Example: Setup Python virtual environment
# if [ -f "requirements.txt" ]; then
#   echo "Setting up Python environment..."
#   python -m venv .venv
#   . .venv/bin/activate
#   pip install -r requirements.txt
# fi
