#!/bin/bash
# wtr CI/CD Integration Example
# Demonstrates using wtr in CI/CD pipelines
#
# This example shows how to:
# - Run tests on multiple branches in parallel
# - Automate worktree setup in CI
# - Validate changes across branches
# - Cleanup after test runs

set -e

# Example CI/CD environment variables
# (would be set by GitHub Actions, GitLab CI, Jenkins, etc.)
CI_BRANCH="${CI_BRANCH:-main}"
CI_PR_NUMBER="${CI_PR_NUMBER:-0}"
CI_BUILD_ID="${CI_BUILD_ID:-000}"

echo "🚀 wtr CI/CD Integration Example"
echo "================================="
echo ""
echo "CI Variables:"
echo "  Branch: $CI_BRANCH"
echo "  PR: $CI_PR_NUMBER"
echo "  Build: $CI_BUILD_ID"
echo ""

# Function: Setup worktree for PR testing
setup_pr_test() {
    local pr_number="$1"
    local worktree_name="pr-$pr_number"
    
    echo "[CI] Setting up PR testing for PR #$pr_number..."
    
    # Create worktree
    wtr new "$worktree_name" 2>/dev/null || true
    
    # Install dependencies
    echo "[CI] Installing dependencies..."
    wtr run "$worktree_name" "npm install" || wtr run "$worktree_name" "pip install -r requirements.txt" || true
    
    return 0
}

# Function: Run comprehensive tests
run_tests() {
    local worktree_name="$1"
    
    echo "[CI] Running tests in $worktree_name..."
    
    # Run unit tests
    echo "[CI] Running unit tests..."
    if wtr run "$worktree_name" "npm test" 2>/dev/null; then
        echo "[CI] ✓ Unit tests passed"
    else
        echo "[CI] ✗ Unit tests failed"
        return 1
    fi
    
    # Run linting
    echo "[CI] Running linter..."
    if wtr run "$worktree_name" "npm run lint" 2>/dev/null; then
        echo "[CI] ✓ Linting passed"
    else
        echo "[CI] ✗ Linting failed"
        return 1
    fi
    
    # Run build
    echo "[CI] Running build..."
    if wtr run "$worktree_name" "npm run build" 2>/dev/null; then
        echo "[CI] ✓ Build passed"
    else
        echo "[CI] ✗ Build failed"
        return 1
    fi
    
    return 0
}

# Function: Integration tests
run_integration_tests() {
    local worktree1="$1"
    local worktree2="$2"
    
    echo "[CI] Running integration tests..."
    echo "[CI] Testing $worktree1 vs $worktree2"
    
    # Example: Compare API versions
    echo "[CI] Checking API compatibility..."
    # wtr run "$worktree1" "npm run test:integration:v1"
    # wtr run "$worktree2" "npm run test:integration:v2"
    
    return 0
}

# Function: Generate test report
generate_report() {
    local worktree_name="$1"
    local report_file="test-report-${CI_BUILD_ID}.json"
    
    echo "[CI] Generating test report..."
    
    # Example: Extract coverage info
    # wtr run "$worktree_name" "npm run test:coverage" > "$report_file"
    
    echo "[CI] Report saved to: $report_file"
}

# Function: Cleanup
cleanup_worktrees() {
    echo "[CI] Cleaning up worktrees..."
    
    wtr list | while read -r worktree_id; do
        if [[ "$worktree_id" == pr-* ]] || [[ "$worktree_id" == ci-* ]]; then
            echo "[CI] Removing: $worktree_id"
            wtr remove "$worktree_id" 2>/dev/null || true
        fi
    done
}

# Main CI workflow
main() {
    echo "[CI] Starting CI job..."
    echo ""
    
    # For PR validation
    if [ "$CI_PR_NUMBER" -gt 0 ]; then
        echo "[CI] Running PR validation workflow..."
        
        # Setup PR worktree
        PR_WORKTREE="pr-$CI_PR_NUMBER"
        if ! setup_pr_test "$CI_PR_NUMBER"; then
            echo "[CI] ✗ Setup failed"
            exit 1
        fi
        
        # Run tests
        if ! run_tests "$PR_WORKTREE"; then
            echo "[CI] ✗ Tests failed"
            cleanup_worktrees
            exit 1
        fi
        
        # Generate report
        generate_report "$PR_WORKTREE"
        
    # For merge validation
    else
        echo "[CI] Running merge validation workflow..."
        
        # Create worktree for current branch
        BRANCH_WORKTREE="ci-branch-${CI_BUILD_ID}"
        wtr new "$BRANCH_WORKTREE" -b "$CI_BRANCH" 2>/dev/null || true
        
        # Install and test
        if ! run_tests "$BRANCH_WORKTREE"; then
            echo "[CI] ✗ Tests failed"
            cleanup_worktrees
            exit 1
        fi
    fi
    
    echo ""
    echo "[CI] ✓ All checks passed!"
    echo ""
    
    # Cleanup
    cleanup_worktrees
    
    echo "[CI] Job completed successfully"
}

# GitHub Actions example
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "[CI] Running in GitHub Actions"
    CI_BRANCH="$GITHUB_REF_NAME"
    CI_PR_NUMBER="${GITHUB_EVENT_NUMBER:-0}"
fi

# GitLab CI example
if [ -n "$GITLAB_CI" ]; then
    echo "[CI] Running in GitLab CI"
    CI_BRANCH="$CI_COMMIT_REF_NAME"
    CI_PR_NUMBER="${CI_MERGE_REQUEST_IID:-0}"
fi

# Jenkins example
if [ -n "$JENKINS_HOME" ]; then
    echo "[CI] Running in Jenkins"
    CI_BRANCH="${GIT_BRANCH##*/}"
    CI_PR_NUMBER="${CHANGE_ID:-0}"
fi

main
