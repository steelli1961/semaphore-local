#!/bin/bash

# Cleanup Script
# Remove Semaphore containers, volumes, and data

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}╔════════════════════════════════════════╗${NC}"
echo -e "${RED}║   Semaphore Cleanup Warning           ║${NC}"
echo -e "${RED}╚════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}This will:${NC}"
echo "  • Stop all containers"
echo "  • Remove containers"
echo "  • Delete all volumes (DATABASE WILL BE LOST)"
echo "  • Keep configuration and playbook files\n"

read -p "Are you sure? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo -e "\n${YELLOW}Stopping and removing containers...${NC}"
docker-compose down -v

echo -e "${GREEN}✓ Cleanup complete${NC}\n"
echo "To restart: docker-compose up -d"
