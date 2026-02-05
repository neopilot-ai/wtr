#!/usr/bin/env bash
# test/verify.sh - basic manual verification for wtr

set -e

# Setup test environment
TMP=$(mktemp -d)
echo "Using temporary repo: $TMP"
cd "$TMP"
git init -b main
git config user.email "test@example.com"
git config user.name "Test User"
echo "initial content" > README.md
git add README.md
git commit -m "initial commit"

# Path to wtr
BOP="/Users/neopilot/Projects/wtr/bin/wtr"

echo "--- Testing: config set/get ---"
"$BOP" config set wtr.test.key "hello-world" --local
VAL=$("$BOP" config get wtr.test.key)
if [ "$VAL" = "hello-world" ]; then
  echo "[PASS] config set/get"
else
  echo "[FAIL] config set/get (got: $VAL)"
  exit 1
fi

echo "--- Testing: create (new) worktree ---"
"$BOP" create test-feature --yes
if [ -d ".worktrees/test-feature" ]; then
  echo "[PASS] create worktree directory"
else
  echo "[FAIL] worktree directory not found"
  exit 1
fi

echo "--- Testing: list worktrees ---"
"$BOP" list | grep "test-feature"
echo "[PASS] list worktrees"

echo "--- Testing: run command in worktree ---"
"$BOP" run test-feature ls -a | grep "README.md"
echo "[PASS] run command"

echo "--- Testing: remove worktree ---"
"$BOP" rm test-feature --yes
if [ ! -d ".worktrees/test-feature" ]; then
  echo "[PASS] remove worktree"
else
  echo "[FAIL] worktree directory still exists"
  exit 1
fi

echo "--- ALL TESTS PASSED ---"
rm -rf "$TMP"
