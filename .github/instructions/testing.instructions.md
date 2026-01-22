# Testing Instructions

## Manual Testing Checklist
- [ ] **Create Worktrees**: Test simple names (`feature`), names with slashes (`feature/auth`), and existing branches.
- [ ] **Removal**: Test removal with/without `--delete-branch` and verify directory cleanup.
- [ ] **Go/Navigate**: Verify `cd "$(git wtr go <id>)"` works for main repo and worktrees.
- [ ] **Run Command**: Verify `git wtr run <id> <cmd>` executes in the correct directory.
- [ ] **Copying**: Test file and directory copying with include/exclude glob patterns.
- [ ] **Hooks**: Verify postCreate, preRemove, and postRemove hooks trigger correctly.
- [ ] **Adapters**: Verify editor and AI tool launching.
- [ ] **Completions**: Test Tab completion in Bash, Zsh, and Fish.

## Automated Verification
- Run `bats test/*.bats` for unit tests.
- Run `./test/verify.sh` for an end-to-end smoke test.
