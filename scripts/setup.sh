#!/bin/bash

# Semaphore Setup Script
# This script automates the setup and deployment of Semaphore

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}  Semaphore Local Setup Script${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

# Check prerequisites
check_requirements() {
    echo -e "${YELLOW}Checking requirements...${NC}"
    
    local requirements=(
        "docker:Docker"
        "docker-compose:Docker Compose"
    )
    
    for cmd_check in "${requirements[@]}"; do
        IFS=':' read -r cmd name <<< "$cmd_check"
        if command -v "$cmd" &> /dev/null; then
            version=$($cmd --version 2>&1 | head -1)
            echo -e "${GREEN}✓${NC} $name: $version"
        else
            echo -e "${RED}✗${NC} $name not found. Please install it first."
            return 1
        fi
    done
    
    echo -e "${GREEN}All requirements met!${NC}\n"
    return 0
}

# Start services
start_services() {
    echo -e "${YELLOW}Starting Semaphore services...${NC}"
    cd "$PROJECT_DIR"
    
    # Check if containers already running
    if docker-compose ps | grep -q semaphore-web; then
        echo -e "${YELLOW}Semaphore is already running.${NC}"
        read -p "Do you want to restart? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down
        else
            return 0
        fi
    fi
    
    docker-compose up -d
    
    echo -e "${GREEN}✓${NC} Services started\n"
}

# Wait for services to be healthy
wait_for_services() {
    echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker-compose exec -T semaphore curl -f http://localhost:3000 &> /dev/null; then
            echo -e "${GREEN}✓${NC} Services are healthy\n"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    echo -e "\n${RED}✗${NC} Services failed to become healthy\n"
    return 1
}

# Show access information
show_info() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${GREEN}Semaphore is ready!${NC}\n"
    
    echo -e "${YELLOW}Access Information:${NC}"
    echo -e "  URL: ${BLUE}http://localhost:3000${NC}"
    echo -e "  Admin User: ${BLUE}admin${NC}"
    echo -e "  Admin Password: ${BLUE}changeme${NC}\n"
    
    echo -e "${YELLOW}⚠️  IMPORTANT:${NC}"
    echo "  1. Change the admin password immediately!"
    echo "  2. Configure SSH keys for your target machines"
    echo "  3. Update inventory file with your hosts"
    echo "  4. Create projects linked to your playbooks\n"
    
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "  • View logs: docker-compose logs -f"
    echo "  • Stop services: docker-compose down"
    echo "  • Reset database: docker-compose down -v && docker-compose up -d\n"
    
    echo -e "${YELLOW}Quick start guide:${NC}"
    echo "  1. Open http://localhost:3000"
    echo "  2. Go to Settings → SSH Keys"
    echo "  3. Add your SSH key for target machines"
    echo "  4. Create an Inventory"
    echo "  5. Create a Project"
    echo "  6. Select and run a playbook\n"
    
    echo -e "${BLUE}════════════════════════════════════════${NC}\n"
}

# Main execution
main() {
    if ! check_requirements; then
        exit 1
    fi
    
    if ! start_services; then
        echo -e "${RED}Failed to start services${NC}"
        exit 1
    fi
    
    if ! wait_for_services; then
        echo -e "${RED}Services did not become healthy${NC}"
        docker-compose logs
        exit 1
    fi
    
    show_info
}

main "$@"
