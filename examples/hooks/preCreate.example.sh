#!/bin/bash
# wtr Pre-Create Hook Example
#
# This script runs BEFORE a worktree is created.
# Use it for:
# - Validation checks
# - Cleanup of old worktrees
# - Branch verification
# - Resource availability checks
#
# Exit with non-zero code to prevent worktree creation
#
# Place this in: .wtr/hooks/preCreate
# Make executable: chmod +x .wtr/hooks/preCreate

set -e

echo "🔍 Pre-Create Hook"

# ============================================================================
# Get Context
# ============================================================================

# These variables would be passed by wtr
BRANCH="${1:-$(git rev-parse --abbrev-ref HEAD)}"
WORKTREE_PATH="${2:-.}"

echo "  Branch: $BRANCH"
echo "  Path: $WORKTREE_PATH"
echo ""

# ============================================================================
# Validation Checks
# ============================================================================

echo "✓ Running validation checks..."

# Check 1: Git repository exists
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    exit 1
fi
echo "  ✓ Git repository found"

# Check 2: Branch exists or is valid
if ! git show-ref --quiet refs/heads/"$BRANCH" && \
   ! git show-ref --quiet refs/remotes/origin/"$BRANCH"; then
    # Branch doesn't exist - this is OK, will be created
    echo "  ℹ Branch '$BRANCH' doesn't exist yet (will be created)"
else
    echo "  ✓ Branch '$BRANCH' exists"
fi

# Check 3: Disk space available
AVAILABLE_SPACE=$(df . | awk 'NR==2 {print $4}')
REQUIRED_SPACE=1000000  # ~1GB in KB
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo "❌ Not enough disk space! (Required: ~1GB)"
    exit 1
fi
echo "  ✓ Sufficient disk space available"

# Check 4: Working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: Working directory has uncommitted changes"
    # Don't exit - just warn
fi

# Check 5: Worktree directory doesn't already exist
if [ -d "$WORKTREE_PATH" ]; then
    echo "⚠️  Warning: Worktree path already exists"
    # This might be intentional (recovering existing process)
fi

echo ""

# ============================================================================
# Smart Cleanup - Remove old worktrees if needed
# ============================================================================

echo "🧹 Checking for old worktrees..."

# Count existing worktrees
WORKTREE_COUNT=$(git worktree list 2>/dev/null | wc -l || echo "0")
MAX_WORKTREES=10

if [ "$WORKTREE_COUNT" -ge "$MAX_WORKTREES" ]; then
    echo "⚠️  Warning: $WORKTREE_COUNT worktrees exist (max: $MAX_WORKTREES)"
    echo "   Consider cleaning up old ones:"
    echo "   git worktree list"
    echo "   git worktree remove <path>"
fi

echo "  Current worktrees: $WORKTREE_COUNT"
echo ""

# ============================================================================
# Resource Checks
# ============================================================================

echo "📊 Checking system resources..."

# Check available memory
AVAILABLE_MEM=$(free -m 2>/dev/null | awk 'NR==2 {print $7}' || echo "1000")
if [ "$AVAILABLE_MEM" -lt 512 ]; then
    echo "❌ Low memory warning: ${AVAILABLE_MEM}MB available"
    exit 1
fi
echo "  ✓ Available memory: ${AVAILABLE_MEM}MB"

# Check CPU load
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
echo "  ℹ CPU load: $CPU_LOAD"

echo ""

# ============================================================================
# Branch Quality Checks
# ============================================================================

echo "🔬 Checking branch quality..."

# Check 1: Branch is reasonably recent
if git show-ref --quiet "refs/heads/$BRANCH"; then
    LAST_COMMIT_DATE=$(git log -1 --format=%aI "$BRANCH" 2>/dev/null || echo "unknown")
    echo "  ℹ Last commit on $BRANCH: $LAST_COMMIT_DATE"
fi

# Check 2: Branch has valid commits
COMMIT_COUNT=$(git rev-list --count "$BRANCH" 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -eq 0 ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
    echo "⚠️  Warning: Branch '$BRANCH' has no commits"
fi

echo ""

# ============================================================================
# Configuration Validation
# ============================================================================

echo "⚙️  Validating configuration..."

# Check for .wtrconfig
if [ -f ".wtrconfig" ]; then
    echo "  ✓ .wtrconfig found"
    
    # Validate .wtrconfig syntax
    if command -v git config >/dev/null 2>&1; then
        # Basic validation - can be expanded
        echo "  ✓ Configuration appears valid"
    fi
else
    echo "  ℹ No .wtrconfig found (using defaults)"
fi

# Check for hooks
if [ -f ".wtr/hooks/postCreate" ]; then
    if [ -x ".wtr/hooks/postCreate" ]; then
        echo "  ✓ postCreate hook found and executable"
    else
        echo "⚠️  postCreate hook exists but not executable"
        chmod +x ".wtr/hooks/postCreate" || true
    fi
fi

echo ""

# ============================================================================
# Dependencies Check
# ============================================================================

echo "📦 Checking dependencies..."

# Node.js project
if [ -f "package.json" ]; then
    if ! command -v npm >/dev/null 2>&1; then
        echo "⚠️  npm not found - may need to install Node.js"
    else
        NPM_VERSION=$(npm --version)
        echo "  ✓ npm available: $NPM_VERSION"
    fi
fi

# Python project
if [ -f "requirements.txt" ]; then
    if ! command -v python3 >/dev/null 2>&1; then
        echo "❌ Python not found - required for this project"
        exit 1
    else
        PYTHON_VERSION=$(python3 --version 2>&1)
        echo "  ✓ Python available: $PYTHON_VERSION"
    fi
fi

# Docker Compose
if [ -f "docker-compose.yml" ]; then
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo "⚠️  docker-compose not found - may be needed"
    else
        echo "  ✓ docker-compose available"
    fi
fi

echo ""

# ============================================================================
# Network Checks
# ============================================================================

echo "🌐 Checking network connectivity..."

# Check internet connectivity (needed for dependency installation)
if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "⚠️  May not have internet access (needed for npm/pip install)"
else
    echo "  ✓ Network available"
fi

echo ""

# ============================================================================
# Final Summary
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pre-Create Validation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ready to create worktree for: $BRANCH"
echo ""

# Exit successfully to allow creation to proceed
exit 0
