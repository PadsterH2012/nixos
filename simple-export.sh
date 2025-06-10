#!/bin/bash

# Simple NixOS Configuration Export
# Step 1: Create config file with your token
# Step 2: Run export

set -e

# Step 1: Create config file
create_config() {
    echo "Step 1: Creating authentication config..."
    echo 'export GITHUB_USERNAME="PadsterH2012"' > ~/.nixos-export-config
    echo 'export GITHUB_TOKEN="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"' >> ~/.nixos-export-config
    chmod 600 ~/.nixos-export-config
    echo "✅ Config created: ~/.nixos-export-config"
}

# Step 2: Export configuration
export_config() {
    echo "Step 2: Exporting NixOS configuration..."
    
    # Load config
    source ~/.nixos-export-config
    
    # Disable interactive prompts
    export GIT_TERMINAL_PROMPT=0
    export GIT_ASKPASS=/bin/echo
    
    # Get system info
    HOSTNAME=$(hostname)
    PRIMARY_MAC=$(cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | head -1)
    
    # Clone repo
    REPO_DIR="/tmp/nixos-export"
    rm -rf "$REPO_DIR"
    
    AUTH_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/PadsterH2012/nixos.git"
    git clone "$AUTH_URL" "$REPO_DIR" 2>/dev/null
    
    cd "$REPO_DIR"
    
    # Copy config
    MACHINE_DIR="hosts/$PRIMARY_MAC"
    mkdir -p "$MACHINE_DIR"
    
    if [ -d "/run/host/etc/nixos" ]; then
        cp -r /run/host/etc/nixos/* "$MACHINE_DIR/"
    elif [ -d "/etc/nixos" ]; then
        cp -r /etc/nixos/* "$MACHINE_DIR/"
    fi
    
    # Commit and push
    git config user.name "NixOS Exporter"
    git config user.email "nixos@$HOSTNAME"
    git add .
    git commit -m "Export from $HOSTNAME ($PRIMARY_MAC)" 2>/dev/null || true
    git push origin main 2>/dev/null
    
    echo "✅ Export complete: hosts/$PRIMARY_MAC"
}

# Run both steps
create_config
export_config

echo "🎉 Done!"
