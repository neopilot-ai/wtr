#!/bin/bash
# Test config command availability

set -e

# Create temp directory for testing
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

cd "$TEST_DIR"
git init >/dev/null 2>&1

# Initialize git config
git config user.email "test@example.com"
git config user.name "Test User"

# Test the wtr config command
WTR_BIN="${1:-/workspaces/wtr/bin/wtr}"

echo "Testing wtr config command..."
echo "Binary: $WTR_BIN"
echo ""

# Test 1: config set
echo "Test 1: config set wtr.test.value hello"
"$WTR_BIN" config set wtr.test.value hello --local
echo "✓ PASS"
echo ""

# Test 2: config get
echo "Test 2: config get wtr.test.value"
RESULT=$("$WTR_BIN" config get wtr.test.value)
if [ "$RESULT" = "hello" ]; then
  echo "✓ PASS (got: $RESULT)"
else
  echo "✗ FAIL (expected: hello, got: $RESULT)"
  exit 1
fi
echo ""

# Test 3: config list
echo "Test 3: config list | grep wtr.test.value"
"$WTR_BIN" config list | grep -q "wtr.test.value=hello"
echo "✓ PASS"
echo ""

echo "All tests passed! ✓"
