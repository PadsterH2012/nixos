#!/bin/bash

# Universal NixOS Configuration Export Script - Pre-authenticated Version
# Exports current NixOS config to Git with network settings and hostname capture
# Usage: curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config-authenticated.sh | bash

set -e

VERSION="1.0.0"
SCRIPT_NAME="NixOS Config Exporter"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Icons
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"

# Configuration
REPO_URL="https://github.com/PadsterH2012/nixos.git"
REPO_DIR="/tmp/nixos-export"
CONFIG_SOURCE="/etc/nixos"
HOST_CONFIG_SOURCE="/run/host/etc/nixos"  # For Flatpak containers

# GitHub Authentication - REPLACE WITH YOUR NEW TOKEN
GITHUB_USERNAME="PadsterH2012"
GITHUB_TOKEN="REPLACE_WITH_YOUR_NEW_TOKEN_HERE"  # Replace this with your actual token

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║           ${BLUE}$SCRIPT_NAME v$VERSION${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

get_system_info() {
    echo -e "${BLUE}${INFO} Gathering system information...${NC}"
    
    # Get hostname
    HOSTNAME=$(hostname)
    echo -e "   ${CHECK} Hostname: ${GREEN}$HOSTNAME${NC}"
    
    # Get MAC addresses for host identification (exclude virtual interfaces)
    ALL_MACS=$(cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | tr '\n' ' ')
    
    # Try to find primary physical interface (exclude docker, veth, lo, etc.)
    PRIMARY_INTERFACE_REAL=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' | head -1)
    if [ -n "$PRIMARY_INTERFACE_REAL" ] && [ -f "/sys/class/net/$PRIMARY_INTERFACE_REAL/address" ]; then
        PRIMARY_MAC=$(cat "/sys/class/net/$PRIMARY_INTERFACE_REAL/address")
        echo -e "   ${CHECK} Primary Interface: ${GREEN}$PRIMARY_INTERFACE_REAL${NC}"
        echo -e "   ${CHECK} Primary MAC: ${GREEN}$PRIMARY_MAC${NC}"
    else
        # Fallback to first non-loopback MAC
        PRIMARY_MAC=$(echo $ALL_MACS | awk '{print $1}')
        echo -e "   ${CHECK} Primary MAC (fallback): ${GREEN}$PRIMARY_MAC${NC}"
    fi
    
    echo -e "   ${CHECK} All MACs: ${GREEN}$ALL_MACS${NC}"
    
    # Get primary IP address (try multiple methods)
    if command -v ip >/dev/null 2>&1; then
        PRIMARY_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null || echo "unknown")
        PRIMARY_INTERFACE=$(ip route get 1.1.1.1 | grep -oP 'dev \K\S+' 2>/dev/null || echo "unknown")
        GATEWAY=$(ip route | grep default | grep -oP 'via \K\S+' | head -1 2>/dev/null || echo "unknown")
    else
        # Fallback methods for containers
        PRIMARY_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "unknown")
        PRIMARY_INTERFACE="unknown"
        GATEWAY="unknown"
    fi
    echo -e "   ${CHECK} Primary IP: ${GREEN}$PRIMARY_IP${NC}"
    echo -e "   ${CHECK} Primary Interface: ${GREEN}$PRIMARY_INTERFACE${NC}"
    echo -e "   ${CHECK} Gateway: ${GREEN}$GATEWAY${NC}"
    
    # Get DNS servers
    DNS_SERVERS=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ' 2>/dev/null || echo "unknown")
    echo -e "   ${CHECK} DNS: ${GREEN}$DNS_SERVERS${NC}"
    
    # Check if using DHCP or static
    if systemctl is-active --quiet NetworkManager; then
        NETWORK_TYPE="NetworkManager (likely DHCP)"
    elif systemctl is-active --quiet dhcpcd; then
        NETWORK_TYPE="DHCP"
    else
        NETWORK_TYPE="Static/Unknown"
    fi
    echo -e "   ${CHECK} Network Type: ${GREEN}$NETWORK_TYPE${NC}"
    
    # Get NixOS version
    if command -v nixos-version >/dev/null 2>&1; then
        NIXOS_VERSION=$(nixos-version)
        echo -e "   ${CHECK} NixOS Version: ${GREEN}$NIXOS_VERSION${NC}"
    else
        NIXOS_VERSION="unknown"
        echo -e "   ${WARNING} NixOS Version: ${YELLOW}$NIXOS_VERSION${NC}"
    fi
    
    echo
}

clone_or_update_repo() {
    echo -e "${BLUE}${INFO} Setting up Git repository...${NC}"
    
    # Clean up any existing directory
    rm -rf "$REPO_DIR"
    
    # Check if token is set
    if [ "$GITHUB_TOKEN" = "REPLACE_WITH_YOUR_NEW_TOKEN_HERE" ]; then
        echo -e "   ${CROSS} GitHub token not configured!"
        echo -e "   ${INFO} Edit the script and replace GITHUB_TOKEN with your actual token"
        exit 1
    fi
    
    # Prepare repository URL with authentication
    local auth_url=$(echo "$REPO_URL" | sed "s|https://github.com/|https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/|")
    echo -e "   ${INFO} Using authenticated access"
    
    # Clone the repository
    if git clone "$auth_url" "$REPO_DIR" 2>/dev/null; then
        echo -e "   ${CHECK} Repository cloned successfully"
    else
        echo -e "   ${CROSS} Failed to clone repository"
        echo -e "   ${INFO} Check your token and repository access"
        exit 1
    fi
    
    cd "$REPO_DIR"
    echo
}

# Include the rest of the functions from the original script...
# (This is a simplified version - the full script would include all functions)

main() {
    print_header
    
    echo -e "${CYAN}Exporting NixOS configuration from this machine...${NC}"
    echo -e "${GREEN}${CHECK} Using pre-configured authentication${NC}"
    echo
    
    get_system_info
    clone_or_update_repo
    
    echo -e "${GREEN}${CHECK} Export would complete here!${NC}"
    echo -e "${INFO} This is a template - replace GITHUB_TOKEN with your actual token"
}

# Run main function
main "$@"
