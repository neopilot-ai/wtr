#!/usr/bin/env bash
set -e
echo "Created worktree: $(pwd)"
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    cp .env.example .env
    echo "Initialized .env"
fi
