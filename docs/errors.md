# wtr Error Reference Guide

> Comprehensive reference for wtr error messages and their solutions.

---

## 📋 How to Use This Guide

Each error includes:
- **Error Message**: What you'll see
- **Causes**: Why this error occurred
- **Solutions**: How to fix it
- **Prevention**: How to avoid it

---

## 🔴 Critical Errors

### `fatal: not a git repository`

**Complete Message**:
```
fatal: not a git repository (or any parent directory): .git
```

**Cause**:
- Running wtr outside a Git repository
- Git repository was deleted or moved

**Solutions**:
```bash
# Navigate to your repository
cd /path/to/your/repo

# Or initialize a new one
git init
```

**Prevention**:
- Always run wtr inside a Git repository
- Keep repository structure intact

**Related**: [Setup Guide](setup.md)

---

### `error: git worktree list failed`

**Cause**:
- Git version doesn't support worktrees (< 2.5)
- Git installation corrupted
- File system permission issues

**Solutions**:
```bash
# Check Git version
git --version    # Should be 2.5 or later

# Update Git
brew upgrade git                    # macOS
sudo apt-get upgrade git            # Ubuntu/Debian

# Check file system permissions
ls -la .git/
chmod 755 .git
```

**Prevention**:
- Keep Git updated to 2.5+
- Run `wtr doctor` regularly

**Related**: [Platform Support](platforms.md)

---

### `error: cannot create worktree (branch already exists)`

**Complete Message**:
```
fatal: 'branch-name' is already checked out.
```

**Cause**:
- Branch is already in use by another worktree
- Branch is checked out in main repository

**Solutions**:
```bash
# Option 1: Use different branch
wtr new feature-new-name

# Option 2: Remove existing worktree
wtr remove feature-old-name
wtr new feature-name

# Option 3: Create from different base
wtr new feature-name -b other-branch
```

**Prevention**:
- Check `wtr list` before creating
- Use unique branch names per worktree

**Related**: [Basic Workflow](basic-workflow.md)

---

## ⚠️ Common Errors

### `Cannot find worktree: 'worktree-id'`

**Cause**:
- Worktree ID doesn't exist
- Worktree was manually deleted
- Typo in worktree ID

**Solutions**:
```bash
# List available worktrees
wtr list

# Find similar names
wtr list | grep pattern

# Use correct ID from list
wtr go feature-123    # instead of wtr go feature
```

**Prevention**:
- Use `wtr list` to verify IDs
- Use TAB completion if available

**Related**: [Quick Reference](quick-reference.md)

---

### `Permission denied: cannot create worktree at path`

**Causes**:
- No write permission in directory
- Disk is full
- Parent directory doesn't exist
- File already exists at that location

**Solutions**:
```bash
# Check permissions
ls -ld ~/work/worktrees

# Fix permissions
chmod 755 ~/work/worktrees

# Check disk space
df -h

# Use different directory
wtr new branch -p /different/path
```

**Prevention**:
- Ensure write permission in worktree directory
- Configure writable path: `git config wtr.directory ~/work`
- Monitor disk space

**Related**: [Configuration Guide](configuration.md)

---

### `File copy failed: No such file or directory`

**Causes**:
- Source files don't exist
- Pattern doesn't match any files
- Source file deleted before copy

**Solutions**:
```bash
# Check files exist
ls -la .env .npmrc

# Check .worktreeinclude patterns
cat .worktreeinclude

# Verify patterns match files
find . -name "*.local"

# Remove non-existent patterns
# Edit .worktreeinclude or run:
git config --unset wtr.copy
```

**Prevention**:
- Use only files that exist
- Test patterns: `find . -name "*.pattern"`
- Keep `.env` files in repository (use `.env.example`)

**Related**: [Configuration Guide](configuration.md#copying-files)

---

### `Hook script failed: command not found`

**Causes**:
- Hook script uses unavailable commands
- Command not in PATH in hook context
- Script has syntax errors

**Solutions**:
```bash
# Test hook syntax
bash -n .wtr/hooks/postCreate

# Run hook manually
bash .wtr/hooks/postCreate

# Check PATH in hook
# Add to hook:
echo $PATH

# Use explicit paths
/usr/local/bin/npm install    # instead of: npm install

# Make script executable
chmod +x .wtr/hooks/postCreate
```

**Prevention**:
- Test hooks before committing
- Use full paths for commands
- Document required environment
- Make hooks executable: `chmod +x .wtr/hooks/*`

**Related**: [Hooks Guide](hooks.md)

---

### `Command failed with exit code: N`

**Cause**:
- Command in `wtr run` failed
- Test command returned non-zero exit code
- Compilation or build error

**Solutions**:
```bash
# Run command directly to see full error
cd $(wtr go worktree-id)
npm test    # See actual error message

# Try simpler command first
wtr run worktree-id echo "test"

# Check command syntax
wtr run worktree-id "your-command && echo success"
```

**Prevention**:
- Test commands before running via wtr
- Use error handling in scripts: `set -e`
- Check command exit codes: `echo $?`

**Related**: [wtr run guide](commands.md#run)

---

## 🔍 Configuration Errors

### `Configuration key not found: 'key-name'`

**Cause**:
- Configuration value hasn't been set
- Using wrong configuration key name
- Using preset that doesn't exist

**Solutions**:
```bash
# List all configuration
git config -l | grep wtr

# Set missing configuration
git config wtr.editor vim

# Check preset exists
git config wtr.preset.mypreset.branch
```

**Prevention**:
- Use `git config wtr.key` to set values
- Reference [Configuration Guide](configuration.md) for valid keys
- Test presets exist before using: `git config wtr.preset.<name>.branch`

**Related**: [Configuration Guide](configuration.md)

---

### `Invalid configuration value: 'value'`

**Causes**:
- Value doesn't match expected format
- Invalid editor/AI tool name
- Invalid branch name

**Solutions**:
```bash
# For editors, use valid names:
git config wtr.editor vim        # ✓ Valid
git config wtr.editor Code       # ✗ Use: vscode, code

# For branches, use valid Git references:
wtr new main                      # ✓ Valid branch
wtr new my-feature                # ✓ Valid branch name

# Check valid options
git config --help
```

**Prevention**:
- See [Configuration Guide](configuration.md) for valid values
- Use `wtr doctor` to validate setup
- Test configuration before using in production

**Related**: [Configuration Guide](configuration.md#valid-values)

---

## 🛠️ Advanced Errors

### `Repository corruption detected`

**Cause**:
- Git repository files corrupted
- Disk errors
- Interrupted git operations

**Solutions**:
```bash
# Check repository integrity
git fsck --full

# Repair repository
git fsck --full --fix=dangling

# If severely corrupted, use backup
rm -rf .git
git clone <backup-repository>
```

**Prevention**:
- Regular backups
- Avoid force-pushing to shared repos
- Monitor disk health
- Use `git gc` periodically

**Related**: [Troubleshooting Guide](troubleshooting.md)

---

### `Worktree lock conflict`

**Cause**:
- Another process using worktree
- Git operation interrupted
- Stale lock file

**Solutions**:
```bash
# Wait for operation to complete
sleep 10
wtr remove worktree-id

# Check for locked processes
lsof | grep worktree-id

# Remove stale lock
rm -f .git/worktrees/worktree-id/locked
```

**Prevention**:
- Avoid running multiple wtr commands simultaneously
- Use locking in scripts: `flock`
- Clean up properly on interruption

**Related**: [Troubleshooting Guide](troubleshooting.md)

---

## 🎯 Tool Integration Errors

### `Editor not found: 'editor-name'`

**Possible editors**:
- `vim`, `nvim` (Neovim)
- `vscode`, `code` (VS Code)
- `cursor` (Cursor)
- `emacs` (Emacs)
- `nano` (Nano)
- `sublime` (Sublime Text)
- `atom` (Atom, legacy)
- `idea` (IntelliJ IDEA)
- `pycharm` (PyCharm)
- `webstorm` (WebStorm)
- `zed` (Zed)

**Solutions**:
```bash
# Install editor
brew install vim                  # macOS
sudo apt-get install vim          # Ubuntu

# or for VS Code
brew install visual-studio-code   # macOS
https://code.visualstudio.com     # Others

# Configure in wtr
git config wtr.editor vim
```

**Prevention**:
- Install editor before configuring wtr
- Use [Adapters Guide](adapters.md) to check supported editors
- Test editor: `vim --version` or `code --version`

**Related**: [Adapters Guide](adapters.md#editors)

---

### `AI tool not found: 'tool-name'`

**Possible tools**:
- `claude` (Claude)
- `copilot` (GitHub Copilot)
- `cursor` (Cursor)
- `opencode` (OpenCode)
- `aider` (Aider)
- `continue` (Continue)
- `windsurf` (Codeium Windsurf)
- `gemini` (Google Gemini)

**Solutions**:
```bash
# Install AI tool
npm install -g aider-ai           # Aider

# Configure in wtr
git config wtr.ai aider
```

**Prevention**:
- Install AI tool before configuring
- Use [Adapters Guide](adapters.md#ai-tools) to check supported tools
- Verify installation: `which aider` or `aider --version`

**Related**: [Adapters Guide](adapters.md#ai-tools)

---

## 🚨 Exit Codes Reference

| Code | Meaning | Common Cause |
|------|---------|-------------|
| 0 | Success | Command completed successfully |
| 1 | General error | Unspecified error |
| 2 | Misuse of command | Invalid arguments |
| 126 | Cannot execute | Permission denied |
| 127 | Command not found | Tool not installed |
| 128 | Invalid exit code | Internal error |
| 130 | Interrupted (Ctrl+C) | User pressed Ctrl+C |

---

## 🔧 Diagnostic Commands

### Check System Setup
```bash
# Comprehensive diagnostics
wtr doctor

# Check Git version
git --version

# Check Bash version
bash --version

# Check required tools
which jq grep sed find
```

### Debug Specific Issues
```bash
# Enable verbose output
wtr new branch -v

# Run hook with debugging
bash -x .wtr/hooks/postCreate

# Check Git configuration
git config -l | grep wtr

# List all worktrees
wtr list --long
```

---

## 🆘 Getting Help

### If you still need help:

1. **Search here**: Use browser search (Ctrl+F) in this document
2. **Check FAQ**: [FAQ](faq.md) has common questions
3. **Read troubleshooting**: [Troubleshooting Guide](troubleshooting.md)
4. **Run diagnostics**: `wtr doctor`
5. **Report issue**: [GitHub Issues](https://github.com/neopilot-ai/wtr/issues)

### When reporting errors:

Provide:
```bash
wtr doctor                          # System info
wtr list                            # Worktree list
git config -l | grep wtr            # Configuration
echo $SHELL $BASH_VERSION           # Shell info
```

---

## 📝 Error Patterns Quick Reference

| Pattern | Cause | Solution |
|---------|-------|----------|
| `not a git repository` | Wrong directory | `cd` to repo root |
| `already checked out` | Branch in use | Use different branch |
| `Permission denied` | Access issue | Fix permissions or path |
| `No such file` | File doesn't exist | Check file patterns |
| `command not found` | Tool not installed | Install required tool |
| `exit code` | Command failed | Check command directly |

---

**Last Updated**: February 2026  
**Can't find your error?** [Report it on GitHub](https://github.com/neopilot-ai/wtr/issues)
