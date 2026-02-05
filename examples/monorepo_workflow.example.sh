#!/bin/bash
# wtr Monorepo Workflow Example
# Demonstrates wtr in monorepo environments (Turborepo, Nx, Lerna, etc.)
#
# This example shows how to:
# - Create worktrees while preserving monorepo dependencies
# - Manage package-specific workflows
# - Run builds across packages
# - Coordinate testing in monorepos

set -e

MONOREPO_TOOLS=("turborepo" "nx" "lerna")
WORKSPACE_PACKAGES=(
    "packages/core"
    "packages/ui"
    "packages/api"
    "packages/cli"
)

echo "🏗️  wtr Monorepo Workflow Example"
echo "=================================="
echo ""

# Detect monorepo tool
detect_monorepo_tool() {
    if [ -f "turbo.json" ]; then
        echo "turborepo"
    elif [ -f "nx.json" ]; then
        echo "nx"
    elif [ -f "lerna.json" ]; then
        echo "lerna"
    else
        echo "unknown"
    fi
}

MONOREPO_TOOL=$(detect_monorepo_tool)
echo "📦 Detected monorepo tool: $MONOREPO_TOOL"
echo ""

# Step 1: Create feature branch with preserved dependencies
echo "📁 Step 1: Creating feature branch for monorepo..."
FEATURE_BRANCH="feature/monorepo-update"
wtr new "$FEATURE_BRANCH" || echo "  (Worktree may already exist)"
echo ""

# Step 2: Install all dependencies
echo "📦 Step 2: Installing dependencies in worktree..."
wtr run "$FEATURE_BRANCH" "npm install" || echo "  (using npm, adjust for pnpm/yarn if needed)"
echo ""

# Step 3: Show available packages
if [ "$MONOREPO_TOOL" = "turborepo" ]; then
    echo "🔍 Step 3: Monorepo packages (Turborepo)..."
    wtr run "$FEATURE_BRANCH" "turbo list" 2>/dev/null || echo "  (turbo list not available)"
    
elif [ "$MONOREPO_TOOL" = "nx" ]; then
    echo "🔍 Step 3: Monorepo packages (Nx)..."
    wtr run "$FEATURE_BRANCH" "nx list" 2>/dev/null || echo "  (nx list not available)"
    
elif [ "$MONOREPO_TOOL" = "lerna" ]; then
    echo "🔍 Step 3: Monorepo packages (Lerna)..."
    wtr run "$FEATURE_BRANCH" "lerna list" 2>/dev/null || echo "  (lerna list not available)"
fi
echo ""

# Step 4: Example: Make changes to multiple packages
echo "📝 Step 4: Example workflow - Update multiple packages"
echo ""
echo "Interactive package selection:"
echo ""
for pkg in "${WORKSPACE_PACKAGES[@]}"; do
    echo "  - $pkg"
done
echo ""
read -p "Enter package to edit (e.g., packages/ui): " selected_package

if [ -n "$selected_package" ]; then
    echo ""
    echo "📂 Changes to make in: $selected_package"
    echo ""
    
    case "$MONOREPO_TOOL" in
        turborepo)
            echo "Example commands for Turborepo:"
            echo "  # Build single package"
            echo "  turbo run build --filter=$selected_package"
            echo ""
            echo "  # Test single package"
            echo "  turbo run test --filter=$selected_package"
            echo ""
            echo "  # Build with dependencies"
            echo "  turbo run build --filter=$selected_package..."
            ;;
        nx)
            echo "Example commands for Nx:"
            echo "  # Build single package"
            echo "  nx build $selected_package"
            echo ""
            echo "  # Test single package"
            echo "  nx test $selected_package"
            echo ""
            echo "  # Show affected packages"
            echo "  nx affected:graph"
            ;;
        lerna)
            echo "Example commands for Lerna:"
            echo "  # Build all packages"
            echo "  lerna run build"
            echo ""
            echo "  # Run tests for specific package"
            echo "  lerna run test --scope=$selected_package"
            echo ""
            echo "  # Version and publish"
            echo "  lerna version && lerna publish"
            ;;
        *)
            echo "Commands depend on your monorepo setup"
            ;;
    esac
    
    echo ""
    read -p "Run linting across all packages? (y/n) " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        if [ "$MONOREPO_TOOL" = "turborepo" ]; then
            wtr run "$FEATURE_BRANCH" "turbo run lint"
        elif [ "$MONOREPO_TOOL" = "nx" ]; then
            wtr run "$FEATURE_BRANCH" "nx run-many --target=lint --all"
        elif [ "$MONOREPO_TOOL" = "lerna" ]; then
            wtr run "$FEATURE_BRANCH" "lerna run lint"
        fi
    fi
fi

echo ""
echo "✅ Monorepo workflow complete!"
echo ""
echo "To continue working:"
echo "  wtr editor $FEATURE_BRANCH    # Open in editor"
echo "  wtr run $FEATURE_BRANCH <cmd> # Run any command"
echo "  cd \$(wtr go $FEATURE_BRANCH)  # Navigate directly"
echo ""
