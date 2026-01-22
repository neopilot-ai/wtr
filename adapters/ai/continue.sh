#!/usr/bin/env bash
# Continue.dev AI integration adapter

cmd="$1"
worktree="$2"

case "$cmd" in
    open|start)
        echo "🤖 Continue.dev usually runs inside your editor (VS Code/JetBrains)."
        echo "Switching to your configured editor to use Continue..."
        # This is a bit recursive, but often users want to 'launch' it.
        # For now, we just suggest using the editor command.
        echo "Try: git wtr editor $(basename "$worktree")"
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac
