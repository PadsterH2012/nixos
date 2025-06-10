#!/bin/bash

# Completely Hands-Off NixOS Configuration Export Script
# No popups, no interactive prompts, no GUI authentication
# Usage: GITHUB_TOKEN='your_token' ./export-nixos-hands-off.sh

set -e

# Disable ALL interactive Git prompts and GUI helpers
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/echo
export SSH_ASKPASS=/bin/echo
export GCM_INTERACTIVE=never
export DISPLAY=""
unset SSH_AUTH_SOCK

# Disable Git credential helpers globally
git config --global credential.helper ""
git config --global core.askpass ""

VERSION="1.0.0"
SCRIPT_NAME="NixOS Config Exporter (Hands-Off)"

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

# Configuration
REPO_URL="https://github.com/PadsterH2012/nixos.git"
REPO_DIR="/tmp/nixos-export"
CONFIG_SOURCE="/etc/nixos"
HOST_CONFIG_SOURCE="/run/host/etc/nixos"

# GitHub Authentication
GITHUB_USERNAME="${GITHUB_USERNAME:-PadsterH2012}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║           ${BLUE}$SCRIPT_NAME v$VERSION${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

check_requirements() {
    echo -e "${BLUE}${INFO} Checking requirements...${NC}"
    
    # Check for required commands
    for cmd in git curl hostname; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "   ${CROSS} Missing required command: $cmd"
            exit 1
        fi
    done
    echo -e "   ${CHECK} All required commands available"
    
    # Check for GitHub token
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "   ${CROSS} GITHUB_TOKEN not set"
        echo -e "   ${INFO} Usage: GITHUB_TOKEN='your_token' $0"
        exit 1
    fi
    echo -e "   ${CHECK} GitHub token provided"
    
    # Validate token format
    if [[ ! "$GITHUB_TOKEN" =~ ^ghp_[a-zA-Z0-9]{36}$ ]]; then
        echo -e "   ${WARNING} Token format looks unusual (expected ghp_...)"
    fi
    
    echo
}

get_system_info() {
    echo -e "${BLUE}${INFO} Gathering system information...${NC}"
    
    # Get hostname
    HOSTNAME=$(hostname)
    echo -e "   ${CHECK} Hostname: ${GREEN}$HOSTNAME${NC}"
    
    # Get MAC addresses (exclude virtual interfaces)
    ALL_MACS=$(cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | tr '\n' ' ')
    
    # Find primary physical interface
    if command -v ip >/dev/null 2>&1; then
        PRIMARY_INTERFACE_REAL=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' | head -1)
        if [ -n "$PRIMARY_INTERFACE_REAL" ] && [ -f "/sys/class/net/$PRIMARY_INTERFACE_REAL/address" ]; then
            PRIMARY_MAC=$(cat "/sys/class/net/$PRIMARY_INTERFACE_REAL/address")
            echo -e "   ${CHECK} Primary Interface: ${GREEN}$PRIMARY_INTERFACE_REAL${NC}"
            echo -e "   ${CHECK} Primary MAC: ${GREEN}$PRIMARY_MAC${NC}"
        else
            PRIMARY_MAC=$(echo $ALL_MACS | awk '{print $1}')
            echo -e "   ${CHECK} Primary MAC (fallback): ${GREEN}$PRIMARY_MAC${NC}"
        fi
        
        PRIMARY_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null || echo "unknown")
        GATEWAY=$(ip route | grep default | grep -oP 'via \K\S+' | head -1 2>/dev/null || echo "unknown")
    else
        PRIMARY_MAC=$(echo $ALL_MACS | awk '{print $1}')
        PRIMARY_IP="unknown"
        GATEWAY="unknown"
    fi
    
    echo -e "   ${CHECK} Primary IP: ${GREEN}$PRIMARY_IP${NC}"
    echo -e "   ${CHECK} Gateway: ${GREEN}$GATEWAY${NC}"
    echo
}

clone_repo() {
    echo -e "${BLUE}${INFO} Cloning repository (non-interactive)...${NC}"
    
    # Clean up
    rm -rf "$REPO_DIR"
    
    # Create authenticated URL
    local auth_url=$(echo "$REPO_URL" | sed "s|https://github.com/|https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/|")
    
    # Clone with all non-interactive settings
    if timeout 30 git clone "$auth_url" "$REPO_DIR" >/dev/null 2>&1; then
        echo -e "   ${CHECK} Repository cloned successfully"
        cd "$REPO_DIR"
        return 0
    else
        echo -e "   ${CROSS} Failed to clone repository"
        echo -e "   ${INFO} Check your token and network connectivity"
        exit 1
    fi
}

copy_config() {
    echo -e "${BLUE}${INFO} Copying NixOS configuration...${NC}"
    
    # Determine machine directory
    MACHINE_DIR="hosts/$PRIMARY_MAC"
    mkdir -p "$MACHINE_DIR"
    echo -e "   ${CHECK} Created directory: ${GREEN}$MACHINE_DIR${NC}"
    
    # Copy configuration files
    local copied=false
    
    # Try Flatpak host access first
    if [ -d "$HOST_CONFIG_SOURCE" ]; then
        cp -r "$HOST_CONFIG_SOURCE"/* "$MACHINE_DIR/" 2>/dev/null && copied=true
        echo -e "   ${CHECK} Copied from host filesystem"
    elif [ -d "$CONFIG_SOURCE" ]; then
        cp -r "$CONFIG_SOURCE"/* "$MACHINE_DIR/" 2>/dev/null && copied=true
        echo -e "   ${CHECK} Copied from standard location"
    fi
    
    if [ "$copied" = false ]; then
        echo -e "   ${WARNING} No configuration files found"
        exit 1
    fi
    
    # Create machine info
    cat > "$MACHINE_DIR/machine-info.yaml" << EOF
machine:
  hostname: "$HOSTNAME"
  primary_mac: "$PRIMARY_MAC"
  export_date: "$(date -Iseconds)"
network:
  primary_ip: "$PRIMARY_IP"
  gateway: "$GATEWAY"
EOF
    
    echo -e "   ${CHECK} Created machine info file"
}

commit_and_push() {
    echo -e "${BLUE}${INFO} Committing and pushing changes...${NC}"
    
    # Configure git
    git config user.name "NixOS Exporter" 2>/dev/null || true
    git config user.email "nixos@$HOSTNAME" 2>/dev/null || true
    
    # Add and commit
    git add . >/dev/null 2>&1
    
    if git diff --staged --quiet; then
        echo -e "   ${INFO} No changes to commit"
        return 0
    fi
    
    git commit -m "Export from $HOSTNAME ($PRIMARY_MAC) - $(date)" >/dev/null 2>&1
    echo -e "   ${CHECK} Changes committed"
    
    # Push with timeout
    if timeout 30 git push origin main >/dev/null 2>&1; then
        echo -e "   ${CHECK} Changes pushed successfully"
    else
        echo -e "   ${CROSS} Failed to push changes"
        exit 1
    fi
}

main() {
    print_header
    echo -e "${CYAN}Hands-off NixOS configuration export...${NC}"
    echo
    
    check_requirements
    get_system_info
    clone_repo
    copy_config
    commit_and_push
    
    echo -e "${GREEN}${CHECK} Export completed successfully!${NC}"
    echo -e "${INFO} Configuration exported to: ${CYAN}hosts/$PRIMARY_MAC${NC}"
    echo -e "${INFO} Repository: ${CYAN}$REPO_URL${NC}"
    echo
}

main "$@"
