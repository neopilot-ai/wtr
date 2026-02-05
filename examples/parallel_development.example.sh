#!/bin/bash
# wtr Parallel Development Example
# Demonstrates working on multiple features simultaneously
#
# This example shows how to:
# - Create multiple feature branches in parallel
# - Switch between features quickly
# - Run tests independently for each feature
# - Keep development contexts isolated

set -e

# Configuration
FEATURES=(
    "auth-login:feature/user-auth"
    "api-v2:feature/api-v2"
    "ui-redesign:feature/ui-redesign"
)

# Parse features into arrays
FEATURE_NAMES=()
FEATURE_BRANCHES=()
for feature in "${FEATURES[@]}"; do
    IFS=':' read -r name branch <<<"$feature"
    FEATURE_NAMES+=("$name")
    FEATURE_BRANCHES+=("$branch")
done

echo "🚀 wtr Parallel Development Example"
echo "===================================="
echo ""

# Step 1: Create worktrees for all features
echo "📁 Step 1: Creating worktrees for ${#FEATURE_NAMES[@]} features..."
for i in "${!FEATURE_NAMES[@]}"; do
    name="${FEATURE_NAMES[$i]}"
    branch="${FEATURE_BRANCHES[$i]}"
    echo "  Creating: $name ($branch)"
    wtr new "$name" -b "$branch" || echo "  (Worktree may already exist)"
done
echo ""

# Step 2: Show status of all features
echo "📊 Step 2: Current feature status..."
echo "Available features:"
wtr list | while read -r id; do
    path=$(wtr go "$id")
    echo "  ✓ $id → $path"
done
echo ""

# Step 3: Run setup in each feature worktree
echo "⚙️  Step 3: Running setup in each worktree..."
for name in "${FEATURE_NAMES[@]}"; do
    echo "  Installing dependencies for $name..."
    wtr run "$name" "npm install" || echo "    (skip if not applicable)"
done
echo ""

# Step 4: Interactive feature switching
echo "🔄 Step 4: Interactive feature switching"
echo ""

show_feature_menu() {
    echo "Choose a feature to work on:"
    for i in "${!FEATURE_NAMES[@]}"; do
        echo "  $((i + 1))) ${FEATURE_NAMES[$i]}"
    done
    echo "  0) Exit"
}

while true; do
    echo ""
    show_feature_menu
    read -p "Enter number: " choice
    
    if [ "$choice" -eq 0 ] 2>/dev/null; then
        echo "Exiting..."
        break
    elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#FEATURE_NAMES[@]}" ] 2>/dev/null; then
        idx=$((choice - 1))
        feature="${FEATURE_NAMES[$idx]}"
        path=$(wtr go "$feature")
        
        echo ""
        echo "📂 Switching to: $feature"
        echo "📍 Path: $path"
        echo ""
        echo "To navigate: cd $path"
        echo "Or edit: wtr editor $feature"
        echo "Or run tests: wtr run $feature npm test"
        echo ""
        
        read -p "Edit in VS Code? (y/n) " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            wtr editor "$feature"
        fi
    else
        echo "Invalid choice"
    fi
done

echo ""
echo "✅ Done! Your features are still running in worktrees."
echo "To resume: wtr list && wtr go <feature-name>"
