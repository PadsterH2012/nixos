#!/bin/bash

# NixOS Configuration Deployment Script
# Auto-generated for nixos-dev-cinnamon (bc:24:11:b3:15:31)

set -e

echo "🚀 Deploying NixOS configuration..."

# Check if running on correct machine
EXPECTED_HOSTNAME="nixos-dev-cinnamon"
EXPECTED_MAC="bc:24:11:b3:15:31"
CURRENT_HOSTNAME=$(hostname)
CURRENT_MAC=$(cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | head -1)

if [ "$CURRENT_HOSTNAME" != "$EXPECTED_HOSTNAME" ]; then
    echo "⚠️  Warning: Expected hostname '$EXPECTED_HOSTNAME' but current is '$CURRENT_HOSTNAME'"
fi

if [ "$CURRENT_MAC" != "$EXPECTED_MAC" ]; then
    echo "⚠️  Warning: Expected MAC '$EXPECTED_MAC' but current is '$CURRENT_MAC'"
fi

if [ "$CURRENT_HOSTNAME" != "$EXPECTED_HOSTNAME" ] || [ "$CURRENT_MAC" != "$EXPECTED_MAC" ]; then
    echo "Continue deployment anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
fi

# Detect configuration type
if [ -f "flake.nix" ]; then
    echo "📦 Detected flakes-based configuration"
    CONFIG_TYPE="flakes"
else
    echo "📦 Detected traditional NixOS configuration"
    CONFIG_TYPE="traditional"
fi

# Backup current configuration
echo "📦 Backing up current configuration..."
sudo cp -r /etc/nixos /etc/nixos.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

# Copy new configuration
echo "📋 Copying new configuration..."
if [ "$CONFIG_TYPE" = "flakes" ]; then
    # For flakes, copy all files to /etc/nixos
    sudo cp -r ./* /etc/nixos/ 2>/dev/null || true

    # Also copy to repository location if it exists
    if [ -d "/mnt/network_repo/nixos" ]; then
        sudo cp -r ./* /mnt/network_repo/nixos/ 2>/dev/null || true
        echo "📋 Updated repository configuration"
    fi
else
    # Traditional configuration
    sudo cp -r ./* /etc/nixos/ 2>/dev/null || true
fi

# Rebuild system
echo "🔧 Rebuilding NixOS..."
if [ "$CONFIG_TYPE" = "flakes" ]; then
    sudo nixos-rebuild switch --flake .#$CURRENT_HOSTNAME 2>/dev/null || sudo nixos-rebuild switch
else
    sudo nixos-rebuild switch
fi

echo "✅ Deployment complete!"
echo "🔄 Please reboot if kernel or major system changes were made"
