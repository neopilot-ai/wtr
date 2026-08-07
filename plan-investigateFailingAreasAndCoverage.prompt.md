# Plan: Investigate failing areas and test coverage

## Status
In progress — investigation phase complete, test failures surfaced.

## Approach
Review repository for likely gaps and failing areas first, then patch the most
concrete issues and verify them. No guessing — drive fixes from actual test failures.

## Completed investigation steps
1. **Repo gap scan** — Reviewed repo for likely gaps/failing areas; no static problems found in initial pass.
2. **TODO/FIXME scan** — Grepped for `TODO|FIXME|XXX|BUG` across `**/{bin,lib,test,adapters}/**` → **127 results**.
3. **Static review** — Checked `bin/wtr`, `lib/core.sh`, `lib/core/worktree.sh`, `lib/commands/add.sh`, `lib/commands/remove.sh`, `lib/config.sh`, `lib/ui.sh`, `lib/copy.sh`, `bin/git-wtr`, `adapters/ai/opencode.sh`, `adapters/lib.sh` → no problems found via inspection.
4. **Test suite run** (`bats test/*.bats test/adapters/*.bats test/commands/*.bats`) → **33 failing tests** found.

## Root cause clusters (from failing tests)
- **MCP server tests** (`test/adapters/mcp-server.bats`) — 13 failures: `mcp/wtr-server.sh` referenced by tests is missing (`grep: .../mcp/wtr-server.sh: No such file or directory`). Tests source/assert a file that does not exist.
- **Dispatch/help tests** (`test/commands/dispatch.bats`) — 8 failures: `no arguments`, `--help`, `-h`, `help command` don't match expected usage output; `add`, `remove`, `list`, `doctor` command aliases exit non-zero.
- **Worktree create tests** (`test/001-worktree-create.bats`) — 4 failures: dry-run side effects, invalid editor, copy list, AI integration.
- **Worktree remove tests** (`test/002-worktree-remove.bats`) — 4 failures: non-existent worktree, existing worktree, force flag, dry run.
- **Error-handling tests** (`test/004-error-handling.bats`) — 3 failures: non-existent worktree graceful failure, cannot remove main, not-in-repo handling.
- **Adapter contract tests** (`test/adapters/adapter-contract.bats`) — 2 failures: editor (cursor) and AI (claude) adapters can be sourced.
- **Opencode adapter tests** (`test/003-adapter-opencode.bats`) — 2 failures: `open` and `analyze` commands.

## Key files to inspect next
- `test/adapters/mcp-server.bats` vs `mcp/` dir — confirm expected server file location
- `test/setup-test` — test harness/env setup, `WTR_DIR` and `NEOPILOT_*` handling
- `test/verify.sh` — manual E2E check
- `bin/wtr` `cmd_help`/`cmd_config`/`dispatch_command` regions (lines ~340–760, 1240–1410)
- `adapters/editor/cursor.sh`, `adapters/ai/claude.sh`

## Next steps
1. Fix the most concrete issue: locate/restore missing MCP server file or fix test path reference.
2. Patch dispatch/help output so `no args`/`--help`/`-h`/`help` match expected usage, and confirm command aliases exit 0.
3. Address create/remove/error-handling failures one cluster at a time, verifying with `bats` after each.
4. Re-run full suite until green; add coverage for any genuinely untested paths.
5. Re-run `./test/verify.sh` for end-to-end confirmation.

## Verification
- `bats test/*.bats test/adapters/*.bats test/commands/*.bats` — expect 0 failures (currently 33).
- `./test/verify.sh` — manual E2E check passes.
