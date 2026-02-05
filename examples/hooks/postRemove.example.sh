#!/bin/bash
# wtr Post-Remove Hook Example
#
# This script runs AFTER a worktree has been removed.
# Use it for:
# - Final cleanup
# - Pushing commits
# - Notifying team
# - Archiving data
# - Git maintenance
#
# Place this in: .wtr/hooks/postRemove
# Make executable: chmod +x .wtr/hooks/postRemove

set -e

echo "🧹 Post-Remove Hook"

# ============================================================================
# Context
# ============================================================================

WORKTREE_ID="${1:-unknown}"
WORKTREE_PATH="${2:-unknown}"
BRANCH="${3:-(not specified)}"

echo "  Removed Worktree: $WORKTREE_ID"
echo "  Former Path: $WORKTREE_PATH"
echo "  Branch: $BRANCH"
echo ""

# ============================================================================
# Git Maintenance
# ============================================================================

echo "🔧 Performing Git maintenance..."

# Prune old worktree references
if git worktree prune 2>/dev/null; then
    echo "  ✓ Pruned old worktree references"
fi

# Garbage collection
if git gc --auto >/dev/null 2>&1; then
    echo "  ✓ Ran garbage collection"
fi

# Clean up remote tracking branches
git remote prune origin 2>/dev/null || true

echo ""

# ============================================================================
# Branch Cleanup (Optional)
# ============================================================================

# Option 1: Keep branch (default - safe)
# Branches remain in git so commits aren't lost

# Option 2: Delete merged branches (uncomment to enable)
cleanup_merged_branches() {
    echo "🌳 Checking for merged branches..."
    
    # Only clean if we deleted the actual branch
    if [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ] && [ "$BRANCH" != "develop" ]; then
        # Check if branch is merged to main
        if git branch -r --merged origin/main | grep -q "origin/$BRANCH"; then
            echo "  ℹ Branch '$BRANCH' is merged to main"
            
            # Ask user (if interactive)
            if [ -t 0 ]; then
                read -p "  Delete branch '$BRANCH'? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    git branch -d "$BRANCH" 2>/dev/null || true
                    git push origin --delete "$BRANCH" 2>/dev/null || true
                    echo "  ✓ Deleted branch '$BRANCH'"
                fi
            fi
        fi
    fi
}

# Uncomment to enable automatic cleanup of merged branches:
# cleanup_merged_branches

echo ""

# ============================================================================
# Cleanup Temporary Files
# ============================================================================

echo "🗑️  Cleaning up temporary files..."

# Remove any lock files from the worktree
if [ -d ".git/worktrees/$WORKTREE_ID" ]; then
    rm -rf ".git/worktrees/$WORKTREE_ID" 2>/dev/null || true
    echo "  ✓ Removed worktree tracking info"
fi

echo ""

# ============================================================================
# Push Commits (Optional)
# ============================================================================

# Option: Auto-push commits from deleted worktree
auto_push_commits() {
    echo "📤 Checking if commits need pushing..."
    
    # This would only work if branch is still available
    if git show-ref --quiet refs/heads/"$BRANCH"; then
        # Check if branch has unpushed commits
        UNPUSHED=$(git log --oneline "origin/$BRANCH".."$BRANCH" 2>/dev/null | wc -l || echo "0")
        
        if [ "$UNPUSHED" -gt 0 ]; then
            echo "  ℹ Branch '$BRANCH' has $UNPUSHED unpushed commits"
            
            read -p "  Push commits? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git push origin "$BRANCH"
                echo "  ✓ Pushed commits"
            fi
        fi
    fi
}

# Uncomment to enable auto-push check:
# auto_push_commits

echo ""

# ============================================================================
# Notifications
# ============================================================================

echo "📢 Post-Removal Summary"
echo ""

# Summary statistics
ACTIVE_WORKTREES=$(git worktree list 2>/dev/null | wc -l || echo "0")
echo "Active worktrees remaining: $ACTIVE_WORKTREES"

# Branches status
TOTAL_BRANCHES=$(git branch | wc -l || echo "0")
echo "Local branches: $TOTAL_BRANCHES"

echo ""

# ============================================================================
# Archive Logs (Optional)
# ============================================================================

archive_logs() {
    echo "📁 Archiving worktree logs..."
    
    # Create archive directory if it doesn't exist
    ARCHIVE_DIR=".wtr/archive"
    mkdir -p "$ARCHIVE_DIR"
    
    # Example: save git log of the worktree
    LOG_FILE="$ARCHIVE_DIR/${WORKTREE_ID}_$(date +%Y%m%d_%H%M%S).log"
    
    # Get last 20 commits from the branch
    if git show-ref --quiet refs/heads/"$BRANCH"; then
        git log --oneline -20 "$BRANCH" > "$LOG_FILE" 2>/dev/null || true
        echo "  ✓ Archived log to $LOG_FILE"
    fi
}

# Uncomment to enable log archiving:
# archive_logs

echo ""

# ============================================================================
# Disk Space Report
# ============================================================================

echo "💾 Disk Space Report"

# Total repo size
REPO_SIZE=$(du -sh . 2>/dev/null | cut -f1 || echo "unknown")
echo "Repository size: $REPO_SIZE"

# Worktrees total
WORKTREES_SIZE=$(du -sh .git/worktrees/ 2>/dev/null | cut -f1 || echo "0")
echo "Worktrees size: $WORKTREES_SIZE"

echo ""

# ============================================================================
# Team Notification (Optional)
# ============================================================================

notify_team() {
    echo "👥 Notifying team..."
    
    # Example: Create a comment/message file for team
    NOTIFICATION_FILE=".wtr/notifications/$(date +%s).txt"
    mkdir -p ".wtr/notifications"
    
    cat > "$NOTIFICATION_FILE" <<EOF
Worktree Removed: $WORKTREE_ID
Time: $(date)
Branch: $BRANCH
Former Path: $WORKTREE_PATH

Git Status:
- Active worktrees: $(git worktree list 2>/dev/null | wc -l || echo "0")
- Repository size: $REPO_SIZE

All commits preserved on branch: $BRANCH
EOF
    
    echo "  ✓ Notification saved to $NOTIFICATION_FILE"
    
    # Optional: Echo to stdout for logging
    # cat "$NOTIFICATION_FILE"
}

# Uncomment to enable team notifications:
# notify_team

echo ""

# ============================================================================
# Advanced Cleanup
# ============================================================================

advanced_cleanup() {
    echo "🔬 Advanced Cleanup"
    
    # Update git index
    git update-index --really-refresh >/dev/null 2>&1 || true
    
    # Optimize git pack files
    if git pack-refs --all >/dev/null 2>&1; then
        echo "  ✓ Optimized git pack files"
    fi
    
    # Clean up reflogs
    git reflog expire --all --expire=now >/dev/null 2>&1 || true
    git gc --aggressive >/dev/null 2>&1 || true
    
    echo "  ✓ Repository optimization complete"
}

# Uncomment for aggressive cleanup (slow but thorough):
# advanced_cleanup

echo ""

# ============================================================================
# Final Report
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Post-Remove Cleanup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Worktree Details:"
echo "  ID: $WORKTREE_ID"
echo "  Branch: $BRANCH"
echo "  Status: Removed"
echo ""

# Check for uncommitted changes in other worktrees
DIRTY_WORKTREES=$(git worktree list --porcelain 2>/dev/null | grep -c "branch" || echo "0")
if [ "$DIRTY_WORKTREES" -gt 0 ]; then
    echo "⚠️  Some worktrees may have uncommitted changes"
fi

echo ""
echo "Hints for next steps:"
echo "  - List remaining worktrees: git worktree list"
echo "  - Push commits: git push origin $BRANCH"
echo "  - Clean local branch: git branch -d $BRANCH"
echo ""

exit 0
