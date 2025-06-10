#!/bin/bash

# Smart NixOS Configuration Deploy Script
# Automatically detects primary interface MAC and deploys matching config

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Smart NixOS Configuration Deploy${NC}"
echo

# Get current system info
CURRENT_HOSTNAME=$(hostname)
echo -e "${BLUE}Current hostname:${NC} $CURRENT_HOSTNAME"

# Get primary interface MAC (exclude Docker, loopback, etc.)
get_primary_mac() {
    if command -v ip >/dev/null 2>&1; then
        # Try to get MAC from primary interface first
        PRIMARY_IFACE=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' | head -1)
        if [ -n "$PRIMARY_IFACE" ] && [ -f "/sys/class/net/$PRIMARY_IFACE/address" ]; then
            cat "/sys/class/net/$PRIMARY_IFACE/address"
        else
            # Fallback: exclude common virtual interfaces
            cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | grep -v "02:42:" | head -1
        fi
    else
        # Fallback: exclude common virtual interfaces
        cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | grep -v "02:42:" | head -1
    fi
}

# Get primary interface info
PRIMARY_IFACE=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' | head -1)
CURRENT_MAC=$(get_primary_mac)

echo -e "${BLUE}Primary interface:${NC} $PRIMARY_IFACE"
echo -e "${BLUE}Primary MAC:${NC} $CURRENT_MAC"
echo

# Check if config exists for this MAC
REPO_URL="https://github.com/PadsterH2012/nixos.git"
CONFIG_URL="https://raw.githubusercontent.com/PadsterH2012/nixos/main/hosts/$CURRENT_MAC/deploy.sh"

echo -e "${BLUE}Checking for configuration...${NC}"
echo -e "${BLUE}Looking for:${NC} $CONFIG_URL"

# Check if deploy.sh exists
if curl -s --head "$CONFIG_URL" | grep -q "200 OK"; then
    echo -e "${GREEN}✅ Found deploy script for MAC: $CURRENT_MAC${NC}"
    echo

    echo -e "${BLUE}Downloading and executing deploy script...${NC}"
    curl -sSL "$CONFIG_URL" | bash
else
    # Check if the directory exists but no deploy.sh
    DIR_URL="https://api.github.com/repos/PadsterH2012/nixos/contents/hosts/$CURRENT_MAC"
    if curl -s "$DIR_URL" | grep -q '"name"'; then
        echo -e "${YELLOW}⚠️  Configuration directory exists but no deploy.sh found${NC}"
        echo -e "${BLUE}Creating deploy script and deploying...${NC}"

        # Download configuration files and deploy manually
        TEMP_DIR="/tmp/nixos-deploy-$CURRENT_MAC"
        rm -rf "$TEMP_DIR"
        mkdir -p "$TEMP_DIR"

        # Clone just the specific directory
        git clone --depth 1 --filter=blob:none --sparse https://github.com/PadsterH2012/nixos.git "$TEMP_DIR"
        cd "$TEMP_DIR"
        git sparse-checkout set "hosts/$CURRENT_MAC"

        if [ -d "hosts/$CURRENT_MAC" ]; then
            echo -e "${GREEN}✅ Found configuration files${NC}"

            # Backup current config
            sudo cp -r /etc/nixos /etc/nixos.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

            # Copy new configuration
            sudo cp -r "hosts/$CURRENT_MAC"/* /etc/nixos/

            # Rebuild
            echo -e "${BLUE}🔧 Rebuilding NixOS...${NC}"
            sudo nixos-rebuild switch

            echo -e "${GREEN}✅ Deployment complete!${NC}"
        else
            echo -e "${RED}❌ Configuration directory not found${NC}"
        fi

        # Cleanup
        rm -rf "$TEMP_DIR"
    else
        echo -e "${YELLOW}⚠️  No configuration found for MAC: $CURRENT_MAC${NC}"
    fi
    echo
    echo -e "${BLUE}Available configurations:${NC}"
    
    # Try to list available hosts
    if curl -s "https://api.github.com/repos/PadsterH2012/nixos/contents/hosts" 2>/dev/null | grep -q '"name"'; then
        curl -s "https://api.github.com/repos/PadsterH2012/nixos/contents/hosts" | grep '"name"' | cut -d'"' -f4 | while read mac; do
            echo -e "   • $mac"
        done
    else
        echo -e "   ${YELLOW}Unable to list available configurations${NC}"
    fi
    
    echo
    echo -e "${BLUE}Options:${NC}"
    echo -e "   1. Export current config: ${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash${NC}"
    echo -e "   2. Deploy specific MAC: ${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/hosts/MAC-ADDRESS/deploy.sh | bash${NC}"
fi
