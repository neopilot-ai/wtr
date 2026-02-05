#!/bin/bash
# wtr Service Orchestration Example
# Demonstrates running multiple services in parallel using wtr worktrees
#
# This example shows how to:
# - Create worktrees for different services
# - Start services in parallel
# - Manage multiple service instances
# - Coordinate between services
# - Monitor and cleanup

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_ROOT="${1:-.}"
SERVICES=("api" "web" "worker" "scheduler")
BRANCHES=("main" "main" "main" "main")  # Branch for each service
PORTS=(3000 3001 3002 9000)               # Ports for each service
PIDS=()                                    # Process IDs for cleanup

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Cleanup on exit
cleanup() {
    log_warning "Cleaning up services..."
    
    # Kill background processes
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping process $pid..."
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    # Optional: Remove worktrees
    read -p "Remove worktrees? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for service in "${SERVICES[@]}"; do
            log_info "Removing worktree: $service"
            wtr remove "$service" || true
        done
    fi
    
    log_success "Cleanup complete"
}

# Setup trap for cleanup
trap cleanup EXIT INT TERM

# Main setup function
setup_services() {
    cd "$REPO_ROOT" || exit 1
    
    log_info "Setting up service worktrees..."
    
    # Create worktrees for each service
    for i in "${!SERVICES[@]}"; do
        service="${SERVICES[$i]}"
        branch="${BRANCHES[$i]}"
        
        log_info "Creating worktree for $service (branch: $branch)..."
        
        # Create worktree
        if wtr new "$service" -b "$branch" 2>/dev/null; then
            log_success "Created worktree: $service"
        else
            log_warning "Worktree $service may already exist"
        fi
    done
}

# Start a single service
start_service() {
    local service="$1"
    local port="$2"
    
    log_info "Starting $service on port $port..."
    
    # Get worktree path and change to it
    local work_path
    work_path=$(wtr go "$service")
    
    # Start service in background
    # This is a generic example - customize based on your services
    (
        cd "$work_path" || exit 1
        
        # Set environment
        export SERVICE_NAME="$service"
        export SERVICE_PORT="$port"
        
        # Example: Start a Node.js service
        if [ -f "package.json" ]; then
            npm start
        # Example: Start a Python service
        elif [ -f "requirements.txt" ]; then
            python -m uvicorn main:app --port "$port" --reload
        # Example: Start a generic service
        else
            echo "Starting $service on port $port"
            # Sleep to keep process alive (for demo)
            sleep infinity
        fi
    ) &
    
    local pid=$!
    PIDS+=("$pid")
    log_success "Started $service (PID: $pid)"
}

# Start all services
start_all_services() {
    log_info "Starting all services..."
    
    for i in "${!SERVICES[@]}"; do
        service="${SERVICES[$i]}"
        port="${PORTS[$i]}"
        
        start_service "$service" "$port"
        
        # Add delay between starts (helps prevent port conflicts)
        sleep 2
    done
    
    log_success "All services started"
}

# Health check for a service
check_service_health() {
    local service="$1"
    local port="$2"
    
    log_info "Checking health of $service (port $port)..."
    
    if timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null; then
        log_success "$service is healthy"
        return 0
    else
        log_error "$service is not responding"
        return 1
    fi
}

# Check all services
check_all_health() {
    log_info "Checking service health..."
    
    local all_healthy=true
    
    for i in "${!SERVICES[@]}"; do
        service="${SERVICES[$i]}"
        port="${PORTS[$i]}"
        
        if ! check_service_health "$service" "$port"; then
            all_healthy=false
        fi
    done
    
    if [ "$all_healthy" = true ]; then
        log_success "All services are healthy"
        return 0
    else
        log_error "Some services are unhealthy"
        return 1
    fi
}

# Show status of all services
show_status() {
    log_info "Service Status:"
    echo ""
    
    for i in "${!SERVICES[@]}"; do
        service="${SERVICES[$i]}"
        port="${PORTS[$i]}"
        
        # Get worktree path
        work_path=$(wtr go "$service" 2>/dev/null || echo "N/A")
        
        # Check if service process is running
        local status="unknown"
        if wtr run "$service" "echo 'ok'" >/dev/null 2>&1; then
            status="✓ ready"
        fi
        
        printf "  %-12s (port %5d) - %s\n" "$service" "$port" "$status"
    done
    
    echo ""
}

# Run tests in a service
run_service_tests() {
    local service="$1"
    
    log_info "Running tests for $service..."
    
    # Using wtr run to execute tests
    wtr run "$service" npm test || log_warning "Tests failed for $service"
}

# Run tests in all services
run_all_tests() {
    log_info "Running tests for all services..."
    
    for service in "${SERVICES[@]}"; do
        run_service_tests "$service"
    done
}

# View logs from a service
tail_service_logs() {
    local service="$1"
    
    log_info "Tailing logs for $service (Ctrl+C to exit)..."
    
    wtr run "$service" "tail -f /tmp/${service}.log 2>/dev/null || echo 'No logs yet'"
}

# Main menu
show_menu() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  wtr Service Orchestration Example"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1) Setup all service worktrees"
    echo "2) Start all services"
    echo "3) Check service health"
    echo "4) Show service status"
    echo "5) Run tests for all services"
    echo "6) Run command in service (interactive)"
    echo "7) List worktrees"
    echo "8) Exit"
    echo ""
}

# Interactive command runner
run_command_interactive() {
    echo ""
    echo "Available services: ${SERVICES[*]}"
    read -p "Enter service name: " service_name
    
    # Validate service
    if [[ ! " ${SERVICES[@]} " =~ " ${service_name} " ]]; then
        log_error "Service '$service_name' not found"
        return 1
    fi
    
    read -p "Enter command to run: " command
    
    log_info "Running in $service_name: $command"
    wtr run "$service_name" "$command"
}

# Main script
main() {
    log_info "wtr Service Orchestration Example"
    log_info "Repository: $REPO_ROOT"
    echo ""
    
    # Interactive menu
    while true; do
        show_menu
        read -p "Choose an option (1-8): " choice
        
        case $choice in
            1)
                setup_services
                ;;
            2)
                start_all_services
                log_info "Services are running. Press Ctrl+C to stop."
                wait
                ;;
            3)
                check_all_health
                ;;
            4)
                show_status
                ;;
            5)
                run_all_tests
                ;;
            6)
                run_command_interactive
                ;;
            7)
                log_info "Listing worktrees..."
                wtr list
                ;;
            8)
                log_info "Exiting..."
                break
                ;;
            *)
                log_error "Invalid option"
                ;;
        esac
    done
}

# Non-interactive mode (for CI/CD)
run_automated() {
    log_info "Running in automated mode..."
    
    # Setup
    setup_services
    
    # Start services
    start_all_services
    
    # Wait for services to stabilize
    sleep 5
    
    # Health check
    if check_all_health; then
        log_success "Service startup successful"
        
        # Run tests
        run_all_tests
        
        return 0
    else
        log_error "Service startup failed"
        return 1
    fi
}

# Entry point
if [ "$1" = "--automated" ]; then
    run_automated
else
    main
fi
