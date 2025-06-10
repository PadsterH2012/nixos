#!/bin/bash

# Fix networking.hostName conflict in NixOS configuration

set -e

echo "🔧 Fixing networking.hostName conflict..."

# Check if the file exists
if [ ! -f "/etc/nixos/modules/networking.nix" ]; then
    echo "❌ /etc/nixos/modules/networking.nix not found"
    exit 1
fi

echo "📋 Current networking.nix content:"
cat -n /etc/nixos/modules/networking.nix
echo

# Backup the file
sudo cp /etc/nixos/modules/networking.nix /etc/nixos/modules/networking.nix.backup.$(date +%Y%m%d-%H%M%S)
echo "📦 Backup created"

# Get current hostname
CURRENT_HOSTNAME=$(hostname)
echo "🖥️  Current hostname: $CURRENT_HOSTNAME"

# Create a clean networking.nix file
sudo tee /etc/nixos/modules/networking.nix > /dev/null << EOF
# Network configuration module
# Auto-fixed on $(date)

{ config, pkgs, ... }:

{
  networking = {
    hostName = "$CURRENT_HOSTNAME";
    networkmanager.enable = true;
    
    # Enable firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPorts = [ ];
    };
  };
}
EOF

echo "✅ Fixed networking.nix with hostname: $CURRENT_HOSTNAME"
echo

# Test the configuration
echo "🧪 Testing configuration..."
if sudo nixos-rebuild dry-build >/dev/null 2>&1; then
    echo "✅ Configuration syntax is now valid"
    echo
    echo "🚀 Ready to rebuild. Run:"
    echo "sudo nixos-rebuild switch"
else
    echo "❌ Still has syntax errors. Running dry-build:"
    sudo nixos-rebuild dry-build
fi
