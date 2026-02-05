#!/bin/bash
# wtr Post-Create Hook Example
# 
# This script runs INSIDE a newly created worktree after creation.
# Use it to:
# - Install dependencies
# - Run build steps
# - Setup environment
# - Run initial tests
# - Configure the worktree
#
# Place this in: .wtr/hooks/postCreate
# Make executable: chmod +x .wtr/hooks/postCreate

set -e  # Exit on error

# Get the current branch (available via wtr)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_DIR=$(pwd)

echo "🔧 Post-Create Hook Running in: $CURRENT_DIR"
echo "   Branch: $BRANCH"
echo ""

# ============================================================================
# Environment Detection
# ============================================================================

detect_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "requirements.txt" ] && [ -f "manage.py" ]; then
        echo "django"
    elif [ -f "requirements.txt" ]; then
        echo "python"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

PROJECT_TYPE=$(detect_project_type)
echo "📦 Project Type: $PROJECT_TYPE"
echo ""

# ============================================================================
# Node.js / JavaScript Setup
# ============================================================================

setup_node() {
    echo "📦 Setting up Node.js environment..."
    
    # Detect package manager
    if [ -f "pnpm-lock.yaml" ]; then
        echo "  Using pnpm..."
        pnpm install --frozen-lockfile || pnpm install
    elif [ -f "yarn.lock" ]; then
        echo "  Using yarn..."
        yarn install --frozen-lockfile || yarn install
    else
        echo "  Using npm..."
        npm install
    fi
    
    # Build if build script exists
    if grep -q '"build"' package.json; then
        echo "  Building project..."
        npm run build
    fi
    
    # Run setup script if it exists
    if grep -q '"setup"' package.json; then
        echo "  Running setup..."
        npm run setup
    fi
}

# ============================================================================
# Python Setup
# ============================================================================

setup_python() {
    echo "📦 Setting up Python environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "  Creating virtual environment..."
        python -m venv venv
    fi
    
    # Activate virtual environment
    # shellcheck source=/dev/null
    source venv/bin/activate
    
    # Install dependencies
    if [ -f "requirements.txt" ]; then
        echo "  Installing requirements..."
        pip install -r requirements.txt
    fi
    
    # Django-specific setup
    if [ -f "manage.py" ]; then
        echo "  Running Django migrations..."
        python manage.py migrate --skip-checks || true
        
        if [ -d "fixtures" ]; then
            echo "  Loading test fixtures..."
            python manage.py loaddata fixtures/* || true
        fi
    fi
}

# ============================================================================
# Ruby Setup
# ============================================================================

setup_ruby() {
    echo "💎 Setting up Ruby environment..."
    
    # Install gems
    if [ -f "Gemfile" ]; then
        echo "  Installing gems..."
        bundle install
    fi
    
    # Rails-specific setup
    if [ -f "bin/rails" ]; then
        echo "  Running Rails setup..."
        bundle exec rails db:migrate || true
        bundle exec rails webpacker:install || true
    fi
}

# ============================================================================
# Go Setup
# ============================================================================

setup_go() {
    echo "🐹 Setting up Go environment..."
    
    echo "  Getting Go dependencies..."
    go mod download
    
    echo "  Building..."
    go build ./...
}

# ============================================================================
# Environment Configuration
# ============================================================================

setup_environment() {
    echo "⚙️  Setting up environment..."
    
    # Copy env file if it doesn't exist
    if [ -f ".env.example" ] && [ ! -f ".env" ]; then
        echo "  Creating .env from .env.example..."
        cp .env.example .env
    fi
    
    # Create .env.local if doesn't exist
    if [ -f ".env.local.example" ] && [ ! -f ".env.local" ]; then
        echo "  Creating .env.local from .env.local.example..."
        cp .env.local.example .env.local
    fi
    
    # Git hooks setup
    if [ -d ".githooks" ]; then
        echo "  Setting up git hooks..."
        git config core.hooksPath .githooks
    fi
}

# ============================================================================
# Database Setup (if applicable)
# ============================================================================

setup_database() {
    # Docker Compose support
    if [ -f "docker-compose.yml" ]; then
        read -p "Start services in docker-compose? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "  Starting Docker services..."
            docker-compose up -d
            sleep 5  # Wait for services to start
        fi
    fi
    
    # Database initialization for Django
    if [ -f "manage.py" ]; then
        if ! python manage.py migrate --check >/dev/null 2>&1; then
            echo "  Initializing database..."
            python manage.py migrate
        fi
    fi
}

# ============================================================================
# Development Server Setup
# ============================================================================

setup_dev_server() {
    # Optional: Start dev server in background (use with caution!)
    # This is more commonly done manually after the hook
    
    case "$PROJECT_TYPE" in
        node)
            if grep -q '"dev"' package.json; then
                echo ""
                echo "💡 To start dev server: npm run dev"
            fi
            ;;
        python)
            echo ""
            echo "💡 To start Django server: python manage.py runserver"
            ;;
        ruby)
            echo ""
            echo "💡 To start Rails server: bundle exec rails server"
            ;;
    esac
}

# ============================================================================
# Branch-Specific Setup
# ============================================================================

branch_specific_setup() {
    case "$BRANCH" in
        main | master)
            echo "✓ Main branch - skipping setup"
            ;;
        develop | development)
            echo "🔧 Development branch - full setup..."
            # Add development-specific setup here
            ;;
        feature/*)
            echo "🔧 Feature branch - standard setup..."
            # Add feature-specific setup here
            ;;
        hotfix/*)
            echo "⚡ Hotfix branch - minimal setup..."
            # Hotfix branches might need minimal setup
            ;;
    esac
}

# ============================================================================
# Testing Setup
# ============================================================================

run_initial_tests() {
    read -p "Run tests? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🧪 Running tests..."
        case "$PROJECT_TYPE" in
            node)
                npm test -- --passWithNoTests || true
                ;;
            python)
                python -m pytest . --collect-only >/dev/null 2>&1 || echo "  No tests configured"
                ;;
            ruby)
                bundle exec rspec spec || true
                ;;
            go)
                go test ./... || true
                ;;
        esac
    fi
}

# ============================================================================
# Health Check
# ============================================================================

health_check() {
    echo ""
    echo "✅ Health Check:"
    
    case "$PROJECT_TYPE" in
        node)
            if [ -f "package.json" ]; then
                echo "  ✓ package.json present"
            fi
            if [ -d "node_modules" ]; then
                echo "  ✓ Dependencies installed"
            fi
            if npm run build --dry-run >/dev/null 2>&1; then
                echo "  ✓ Build command valid"
            fi
            ;;
        python)
            if [ -f "requirements.txt" ]; then
                echo "  ✓ requirements.txt present"
            fi
            if [ -d "venv" ]; then
                echo "  ✓ Virtual environment created"
            fi
            ;;
    esac
}

# ============================================================================
# Completion Message
# ============================================================================

show_next_steps() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ Worktree Setup Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Next steps:"
    echo "  1. cd to worktree: cd $CURRENT_DIR"
    echo "  2. Make your changes"
    echo "  3. Test your changes"
    echo "  4. Commit and push: git push origin $BRANCH"
    echo ""
    echo "Useful commands:"
    case "$PROJECT_TYPE" in
        node)
            echo "  npm test           # Run tests"
            echo "  npm run dev        # Start dev server"
            echo "  npm run build      # Build for production"
            ;;
        python)
            echo "  python manage.py runserver  # Start Django"
            echo "  pytest                      # Run tests"
            ;;
    esac
    echo ""
}

# ============================================================================
# Error Handling
# ============================================================================

handle_error() {
    echo ""
    echo "❌ Setup encountered an error"
    echo "   Branch: $BRANCH"
    echo "   Directory: $CURRENT_DIR"
    echo ""
    echo "Troubleshooting:"
    echo "  - Check error messages above"
    echo "  - Run manual setup steps"
    echo "  - Check network/connectivity"
    echo "  - Review hooks in: .wtr/hooks/postCreate"
    echo ""
}

# ============================================================================
# Main Hook Execution
# ============================================================================

main() {
    # Setup based on project type
    case "$PROJECT_TYPE" in
        node)
            setup_node
            ;;
        django)
            setup_python
            setup_database
            ;;
        python)
            setup_python
            ;;
        ruby)
            setup_ruby
            ;;
        go)
            setup_go
            ;;
    esac
    
    # Always run these
    setup_environment
    branch_specific_setup
    
    # Optional: run tests
    # run_initial_tests
    
    # Health check
    health_check
    
    # Show next steps
    show_next_steps
}

# Run main function with error handling
if main; then
    echo "✓ Hook completed successfully"
    exit 0
else
    handle_error
    exit 1
fi
