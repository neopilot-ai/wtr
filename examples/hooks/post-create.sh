#!/usr/bin/env bash
# post-create.sh - Example post-creation hook for wtr
# This script runs inside the NEW worktree directory.

set -e

echo "==> Post-creation hook: Preparing worktree..."

# 1. Copy environment files if they don't exist
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

# 2. Install dependencies based on project type
if [ -f "package.json" ]; then
    if command -v pnpm >/dev/null 2>&1; then
        echo "Running pnpm install..."
        pnpm install
    elif command -v npm >/dev/null 2>&1; then
        echo "Running npm install..."
        npm install
    fi
elif [ -f "requirements.txt" ]; then
    if [ -d ".venv" ]; then
        echo "Updating python dependencies in .venv..."
        ./.venv/bin/pip install -r requirements.txt
    fi
fi

# 3. Mark as initialized
echo "$(date)" > .wtr_initialized

echo "==> Worktree is ready!"
