#!/bin/bash

# Test Inventory Setup
# Test connectivity to your inventory hosts

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INVENTORY_FILE="$PROJECT_DIR/sample-configs/inventory/inventory.ini"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Semaphore Inventory Test"
echo "========================\n"

# Check if inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
    echo -e "${RED}✗ Inventory file not found: $INVENTORY_FILE${NC}"
    exit 1
fi

# Parse inventory and test connectivity
echo "Checking hosts from inventory..."
echo

# Extract hostnames (very simple parsing - assumes "hostname ansible_host=IP" format)
grep -E "^\w+\." "$INVENTORY_FILE" | while read line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # Extract hostname and IP
    hostname=$(echo "$line" | awk '{print $1}')
    ip=$(echo "$line" | grep -oE "ansible_host=[0-9.]+" | cut -d= -f2)
    
    if [ -n "$ip" ]; then
        echo -n "Testing $hostname ($ip)... "
        if ping -c 1 -W 2 "$ip" &> /dev/null; then
            echo -e "${GREEN}✓ Reachable${NC}"
        else
            echo -e "${RED}✗ Unreachable${NC}"
        fi
    fi
done

echo
echo "Test complete"
echo
echo "To use Ansible directly, run:"
echo "ansible all -i $INVENTORY_FILE -m ping"
