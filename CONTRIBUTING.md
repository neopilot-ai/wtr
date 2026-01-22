# Contributing to wtr

Thank you for your interest in contributing to wtr!

## Design Principles
1. **Cross-platform first** - Code must work on macOS, Linux, and Windows Git Bash.
2. **No external dependencies** - Only require git and basic POSIX shell utilities.
3. **Configuration over flags** - Users set defaults once, then use simple commands.
4. **Fail safely** - Validate inputs, check return codes, provide clear error messages.
5. **Stay modular** - Keep functions small, focused, and reusable.
6. **User-friendly** - Prioritize good UX with clear output and helpful error messages.

## Development Workflow
1. Fork and clone the repository.
2. Make your changes in a feature branch.
3. Test your changes manually and with BATS.
4. Submit a pull request.

## Coding Standards
- Use **2 spaces** for indentation.
- Use `snake_case` for function and local variable names.
- Use `UPPER_SNAKE_CASE` for global constants.
- Always quote variables: `"$VAR"`.
- Use `local` for all variables inside functions.
- Prefer `printf` over `echo` for portability, or use `echo -e` if supported.

## Testing Checklist
Before submitting a PR, ensure you have tested:
- Creating worktrees with various branch names (with/without slashes).
- Removing worktrees (with/without branch deletion).
- Configuration set/get/unset.
- Editor and AI tool integration.
- File copying and directory copying logic.
- Shell completions.
