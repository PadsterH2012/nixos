#!/bin/bash

# Force Deploy NixOS Configuration
# Bypasses MAC address checks and deploys directly

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Force Deploy NixOS Configuration${NC}"
echo

# Get current system info
CURRENT_HOSTNAME=$(hostname)
echo -e "${BLUE}Current hostname:${NC} $CURRENT_HOSTNAME"

# Get primary interface MAC
PRIMARY_IFACE=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' | head -1)
CURRENT_MAC=$(cat "/sys/class/net/$PRIMARY_IFACE/address")

echo -e "${BLUE}Primary interface:${NC} $PRIMARY_IFACE"
echo -e "${BLUE}Primary MAC:${NC} $CURRENT_MAC"
echo

# Check if config exists
CONFIG_DIR="hosts/$CURRENT_MAC"
echo -e "${BLUE}Looking for configuration:${NC} $CONFIG_DIR"

# Clone the repository
TEMP_DIR="/tmp/nixos-force-deploy"
rm -rf "$TEMP_DIR"
echo -e "${BLUE}Cloning repository...${NC}"

git clone --depth 1 https://github.com/PadsterH2012/nixos.git "$TEMP_DIR" 2>/dev/null

cd "$TEMP_DIR"

if [ -d "$CONFIG_DIR" ]; then
    echo -e "${GREEN}✅ Found configuration directory${NC}"
    
    # Show what's in the directory
    echo -e "${BLUE}Configuration files:${NC}"
    ls -la "$CONFIG_DIR/"
    echo
    
    # Backup current config
    echo -e "${BLUE}📦 Backing up current configuration...${NC}"
    sudo cp -r /etc/nixos /etc/nixos.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
    
    # Copy new configuration
    echo -e "${BLUE}📋 Copying new configuration...${NC}"
    sudo cp -r "$CONFIG_DIR"/* /etc/nixos/
    
    # Check configuration syntax
    echo -e "${BLUE}🔍 Checking configuration syntax...${NC}"
    if sudo nixos-rebuild dry-build >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Configuration syntax is valid${NC}"
        
        # Rebuild system
        echo -e "${BLUE}🔧 Rebuilding NixOS...${NC}"
        sudo nixos-rebuild switch
        
        echo -e "${GREEN}✅ Deployment complete!${NC}"
        echo -e "${BLUE}🔄 Please reboot if kernel or major system changes were made${NC}"
    else
        echo -e "${RED}❌ Configuration has syntax errors${NC}"
        echo -e "${YELLOW}Running dry-build to show errors:${NC}"
        sudo nixos-rebuild dry-build
        exit 1
    fi
else
    echo -e "${RED}❌ Configuration directory not found: $CONFIG_DIR${NC}"
    echo
    echo -e "${BLUE}Available configurations:${NC}"
    ls -la hosts/ 2>/dev/null || echo "No hosts directory found"
    echo
    echo -e "${YELLOW}You may need to export your configuration first:${NC}"
    echo -e "${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR"
