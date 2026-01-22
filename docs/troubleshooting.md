# Troubleshooting Guide

This guide provides solutions for common issues and answers to frequently asked questions about wtr.

## Installation Issues

### `git wtr` is not a git command
**Symptoms:** Running `git wtr <cmd>` returns `git: 'wtr' is not a git command.`

**Solution:**
1.  Verify the installation path: `ls -la ~/.local/bin/git-wtr`.
2.  Ensure `~/.local/bin` is in your `PATH`.
3.  On macOS, you may need to restart your terminal or run `source ~/.zshrc`.
4.  Try running the direct binary to see if it works: `~/.wtr/bin/wtr --version`.

### `Permission denied` during installation
**Symptoms:** `Permission denied` error when running `./install.sh`.

**Solution:**
1.  Make sure the script is executable: `chmod +x install.sh`.
2.  If the script tries to create symlinks in `/usr/local/bin` and fails, it should fallback to `~/.local/bin`. Ensure you have write permissions for your home directory.

## Worktree Issues

### `Fatal: ... already exists`
**Symptoms:** Git fails to create a worktree because a directory or branch already exists.

**Solution:**
1.  Check if you have an old worktree folder that wasn't properly removed: `git worktree prune`.
2.  If you want to use the same branch for a different purpose, use the `--force` and `--name` flags:
    `git wtr new feature-abc --force --name variant-2`

### Branch names with slashes
**Symptoms:** You want to create a worktree for `feature/login` but the folder name looks strange or fails.

**Solution:**
wtr automatically sanitizes branch names by replacing `/` with `-`. A branch named `feature/login` will be placed in a folder named `feature-login`. This is by design to ensure cross-platform compatibility.

### Worktrees inside the repository
**Symptoms:** You created a worktree and now `git status` shows it as an untracked directory.

**Solution:**
By default, wtr tries to create worktrees as **sibling directories** (e.g., `../your-repo-worktrees/`). If you prefer them inside your repo (e.g., in a `.worktrees/` folder), you must add that folder to your `.gitignore`:
```bash
echo ".worktrees/" >> .gitignore
git wtr config set wtr.worktrees.dir ".worktrees" --local
```

## Tool Integration (Editor/AI)

### Editor/AI tool fails to open
**Symptoms:** Configured tool doesn't launch, but no error is shown.

**Solution:**
1.  Run `git wtr doctor` to check if the tool is in your `PATH`.
2.  If you are using a custom editor command, ensure it works from the shell directly.
3.  Check if you have the correct adapter name. Run `git wtr adapter` to see available options.

### VS Code/Cursor workspace isn't used
**Symptoms:** VS Code opens the folder but doesn't load the `.code-workspace` file.

**Solution:**
1.  Ensure the `.code-workspace` file is in the root of your repository.
2.  Check your config: `git wtr config get wtr.editor.workspace`. It should be empty (for auto-detection) or point to the correct relative path.

### AI Tool API Keys
**Symptoms:** Errors like `CLAUDE_API_KEY not set` or `GEMINI_API_KEY not set`.

**Solution:**
1.  Most AI adapters require an API key to be set in your environment.
2.  You can export them in your shell profile (`.zshrc` or `.bash_profile`):
    ```bash
    export GEMINI_API_KEY="your-key-here"
    export CLAUDE_API_KEY="your-key-here"
    ```
3.  Alternatively, you can create a config file at `~/.config/neopilot/gemini` or `~/.config/neopilot/claude` with the following content:
    ```bash
    GEMINI_API_KEY="your-key-here"
    ```

## Git Version Issues

### "Unknown option: --show-current"
**Symptoms:** Errors relating to `branch --show-current`.

**Solution:**
This occurs on older versions of Git (pre-2.22). wtr includes fallbacks for these versions, but ensure your Git is at least version 2.5.0. Updating Git is highly recommended for the best experience.

## Debugging

If you encounter an issue not listed here, you can enable debug logging to see what's happening under the hood:

```bash
WTR_DEBUG=1 git wtr <command>
```

You can also specify a log file for persistent history:
```bash
export WTR_LOG_FILE="/tmp/wtr.log"
git wtr new test-debug
```

## Getting Help

If you're still stuck:
1.  Run `git wtr help` for a list of all commands and options.
2.  Check the documentation in `docs/`.
3.  Search or open an issue on the [GitHub repository](https://github.com/neopilot-ai/wtr).
