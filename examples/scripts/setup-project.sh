#!/usr/bin/env bash
# setup-project.sh - Initialize wtr in a new repository
# Usage: ./setup-project.sh

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not a git repository."
    exit 1
fi

cd "$REPO_ROOT"

echo "==> Initializing wtr in $REPO_ROOT..."

# 1. Create directory structure
mkdir -p .wtr/hooks

# 2. Copy example config if it doesn't exist
if [ ! -f ".wtrconfig" ]; then
    echo "Creating .wtrconfig..."
    cat > .wtrconfig <<EOF
[copy]
    include = .env.example
    # includeDirs = node_modules

[hooks]
    postCreate = "./.wtr/hooks/post-create.sh"
    preRemove = "./.wtr/hooks/pre-remove.sh"
EOF
fi

# 3. Create basic hooks
if [ ! -f ".wtr/hooks/post-create.sh" ]; then
    echo "Creating .wtr/hooks/post-create.sh..."
    cat > .wtr/hooks/post-create.sh <<EOF
#!/usr/bin/env bash
set -e
echo "Created worktree: \$(pwd)"
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    cp .env.example .env
    echo "Initialized .env"
fi
EOF
    chmod +x .wtr/hooks/post-create.sh
fi

echo "==> Done! wtr is configured for this project."
echo "You can now commit .wtrconfig and .wtr/hooks/"
