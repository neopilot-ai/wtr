#!/bin/bash
# lib/commands/add.sh - Create and add a new worktree
# Aliases: add, create, new -> calls cmd_create (defined in bin/wtr)

cmd_add() {
  cmd_create "$@"
}
