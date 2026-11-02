#!/bin/sh
# Example setup script for git wtr configuration
# Customize this for your project

set -e

echo "🔧 Configuring git wtr for this repository..."

# Worktree settings
git config --local wtr.worktrees.prefix ""
git config --local wtr.defaultBranch "auto"

# Editor (change to your preference: cursor, vscode, zed)
# git config --local wtr.editor.default cursor

# File copying (add patterns for your project)
# git config --local --add wtr.copy.include "**/.env.example"
# git config --local --add wtr.copy.include "**/CLAUDE.md"

# Hooks (customize for your build system)
# git config --local --add wtr.hook.postCreate "npm install"
# git config --local --add wtr.hook.postCreate "npm run build"

# Or for pnpm projects:
# git config --local --add wtr.hook.postCreate "pnpm install"
# git config --local --add wtr.hook.postCreate "pnpm run build"

# Or for other tools:
# git config --local --add wtr.hook.postCreate "bundle install"
# git config --local --add wtr.hook.postCreate "cargo build"

echo "✅ git wtr configured!"
echo ""
echo "View config with: git config --local --list | grep wtr"
echo "Create a worktree with: git wtr new my-feature"
