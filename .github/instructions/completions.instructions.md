# Shell Completion Guidelines

- When adding a new command or flag, update ALL three:
  - `completions/wtr.bash`
  - `completions/_git-wtr` (Zsh)
  - `completions/git-wtr.fish`
- Command completion should dynamically list available branches and worktree IDs.
- Follow the existing formatting and structure for each shell's completion engine.
