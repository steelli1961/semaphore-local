#!/bin/bash

# SSH Key Setup Script
# This script helps generate and configure SSH keys for Semaphore

KEY_DIR="$HOME/.ssh"
KEY_NAME="semaphore_key"
KEY_PATH="$KEY_DIR/$KEY_NAME"

echo "SSH Key Setup for Semaphore"
echo "============================\n"

# Create .ssh directory if it doesn't exist
if [ ! -d "$KEY_DIR" ]; then
    mkdir -p "$KEY_DIR"
    chmod 700 "$KEY_DIR"
    echo "Created $KEY_DIR"
fi

# Check if key already exists
if [ -f "$KEY_PATH" ]; then
    echo "SSH key already exists at $KEY_PATH"
    read -p "Do you want to regenerate it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Generate new SSH key
echo "Generating new SSH key..."
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "semaphore-local"

if [ $? -eq 0 ]; then
    echo "✓ SSH key generated successfully"
    chmod 600 "$KEY_PATH"
    chmod 644 "$KEY_PATH.pub"
    
    echo "\nKey location: $KEY_PATH"
    echo "Public key location: $KEY_PATH.pub"
    
    echo "\nTo add this key to your target machines, run:"
    echo "ssh-copy-id -i $KEY_PATH.pub user@target-machine"
    
    echo "\nOr manually add the public key to ~/.ssh/authorized_keys on target machines:"
    echo "cat $KEY_PATH.pub | ssh user@target-machine 'cat >> ~/.ssh/authorized_keys'"
    
else
    echo "✗ Failed to generate SSH key"
    exit 1
fi
