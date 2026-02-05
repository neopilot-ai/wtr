#!/bin/bash
# lib/commands/remove.sh - Remove a worktree  
# Aliases: remove, rm -> calls cmd_remove (defined in bin/wtr)

# Note: This is a placeholder. The actual cmd_remove function is defined
# in bin/wtr and will override this when sourced. This ensures the
# dispatcher can reference cmd_remove even if bin/wtr hasn't been loaded yet.
cmd_remove() {
  return 0  # Placeholder - will be overridden by bin/wtr
}
