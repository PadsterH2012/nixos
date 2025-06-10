#!/bin/bash

# Universal NixOS Configuration Export Script
# Exports current NixOS config to Git with network settings and hostname capture
# Usage: curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash

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

# GitHub Authentication - Load from config file first, then environment
GITHUB_USERNAME="${GITHUB_USERNAME:-PadsterH2012}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Try multiple config file locations
CONFIG_LOCATIONS=(
    "$HOME/.nixos-export-config"
    "/etc/nixos-export-config"
    "/root/.nixos-export-config"
    "$(dirname "$0")/.nixos-export-config"
)

for config_file in "${CONFIG_LOCATIONS[@]}"; do
    if [ -f "$config_file" ] && [ -r "$config_file" ]; then
        echo "Loading config from: $config_file" >&2
        source "$config_file"
        break
    fi
done

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

    # Configure Git to disable interactive prompts
    export GIT_TERMINAL_PROMPT=0
    export GIT_ASKPASS=/bin/echo
    export SSH_ASKPASS=/bin/echo
    export GCM_INTERACTIVE=never

    # Disable Git credential helpers that might cause popups
    git config --global credential.helper ""

    # Prepare repository URL with authentication if token is provided
    local auth_url="$REPO_URL"
    if [ -n "$GITHUB_TOKEN" ]; then
        # Convert https://github.com/user/repo.git to https://username:token@github.com/user/repo.git
        auth_url=$(echo "$REPO_URL" | sed "s|https://github.com/|https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/|")
        echo -e "   ${INFO} Using authenticated access (non-interactive)"
    else
        echo -e "   ${WARNING} No GitHub token provided - may fail for private repositories"
        echo -e "   ${INFO} Set GITHUB_TOKEN environment variable for authentication"
    fi

    # Clone the repository with explicit non-interactive settings
    if GIT_TERMINAL_PROMPT=0 git clone "$auth_url" "$REPO_DIR" 2>/dev/null; then
        echo -e "   ${CHECK} Repository cloned successfully"
    else
        echo -e "   ${CROSS} Failed to clone repository"
        if [ -z "$GITHUB_TOKEN" ]; then
            echo -e "   ${INFO} For private repositories, set your GitHub token:"
            echo -e "   ${CYAN}export GITHUB_TOKEN='your_personal_access_token'${NC}"
        else
            echo -e "   ${INFO} Check your token permissions and repository access"
        fi
        echo -e "   ${INFO} Creating new repository structure..."
        mkdir -p "$REPO_DIR"
        cd "$REPO_DIR"
        git init
        git remote add origin "$REPO_URL" 2>/dev/null || true
    fi

    cd "$REPO_DIR"
    echo
}

create_machine_config() {
    echo -e "${BLUE}${INFO} Creating machine-specific configuration...${NC}"

    # Determine machine directory name (prefer MAC-based if available)
    if [ -n "$PRIMARY_MAC" ] && [ "$PRIMARY_MAC" != "unknown" ]; then
        MACHINE_DIR="hosts/$PRIMARY_MAC"
        echo -e "   ${CHECK} Using MAC-based directory: ${GREEN}$MACHINE_DIR${NC}"
    else
        MACHINE_DIR="$HOSTNAME"
        echo -e "   ${CHECK} Using hostname-based directory: ${GREEN}$MACHINE_DIR${NC}"
    fi

    mkdir -p "$MACHINE_DIR"

    # Copy NixOS configuration (try multiple sources)
    CONFIG_COPIED=false

    # Try Flatpak host access first
    if [ -d "$HOST_CONFIG_SOURCE" ]; then
        cp -r "$HOST_CONFIG_SOURCE"/* "$MACHINE_DIR/" 2>/dev/null || true
        echo -e "   ${CHECK} Copied NixOS configuration from host filesystem"
        CONFIG_COPIED=true
    # Try standard location
    elif [ -d "$CONFIG_SOURCE" ]; then
        cp -r "$CONFIG_SOURCE"/* "$MACHINE_DIR/" 2>/dev/null || true
        echo -e "   ${CHECK} Copied NixOS configuration from standard location"
        CONFIG_COPIED=true
    fi

    # Check for flake files in repository root
    if [ -f "/mnt/network_repo/nixos/flake.nix" ]; then
        cp "/mnt/network_repo/nixos/flake.nix" "$MACHINE_DIR/" 2>/dev/null || true
        echo -e "   ${CHECK} Copied flake.nix"
    fi

    if [ -f "/mnt/network_repo/nixos/flake.lock" ]; then
        cp "/mnt/network_repo/nixos/flake.lock" "$MACHINE_DIR/" 2>/dev/null || true
        echo -e "   ${CHECK} Copied flake.lock"
    fi

    # Copy any additional nix files from repository root
    find "/mnt/network_repo/nixos" -maxdepth 1 -name "*.nix" -exec cp {} "$MACHINE_DIR/" \; 2>/dev/null || true

    if [ "$CONFIG_COPIED" = false ]; then
        echo -e "   ${WARNING} No NixOS configuration found in standard locations"
        echo -e "   ${INFO} Checked: $CONFIG_SOURCE, $HOST_CONFIG_SOURCE"
    fi
    
    # Create machine info file
    cat > "$MACHINE_DIR/machine-info.yaml" << EOF
# Machine Information for $HOSTNAME
# Generated on $(date)

machine:
  hostname: "$HOSTNAME"
  primary_mac: "$PRIMARY_MAC"
  primary_interface: "$PRIMARY_INTERFACE_REAL"
  all_macs: "$ALL_MACS"
  nixos_version: "$NIXOS_VERSION"
  export_date: "$(date -Iseconds)"
  config_type: "$([ -f "$MACHINE_DIR/flake.nix" ] && echo "flakes" || echo "traditional")"

network:
  primary_ip: "$PRIMARY_IP"
  primary_interface: "$PRIMARY_INTERFACE"
  gateway: "$GATEWAY"
  dns_servers: "$DNS_SERVERS"
  network_type: "$NETWORK_TYPE"
  
# Network configuration for NixOS
# Copy this to your networking.nix if using static IP
nixos_network_config: |
  networking = {
    hostName = "$HOSTNAME";
    # For DHCP (recommended):
    networkmanager.enable = true;
    
    # For static IP (uncomment and modify if needed):
    # interfaces.$PRIMARY_INTERFACE = {
    #   ipv4.addresses = [{
    #     address = "$PRIMARY_IP";
    #     prefixLength = 24;  # Adjust as needed
    #   }];
    # };
    # defaultGateway = "$GATEWAY";
    # nameservers = [ $(echo "$DNS_SERVERS" | sed 's/ /" "/g' | sed 's/^/"/' | sed 's/$/"/' ) ];
  };
EOF
    
    echo -e "   ${CHECK} Created machine info file"
    
    # Create deployment script
    cat > "$MACHINE_DIR/deploy.sh" << EOF
#!/bin/bash

# NixOS Configuration Deployment Script
# Auto-generated for $HOSTNAME ($PRIMARY_MAC)

set -e

echo "🚀 Deploying NixOS configuration..."

# Check if running on correct machine
EXPECTED_HOSTNAME="$HOSTNAME"
EXPECTED_MAC="$PRIMARY_MAC"
CURRENT_HOSTNAME=\$(hostname)
CURRENT_MAC=\$(cat /sys/class/net/*/address 2>/dev/null | grep -v "00:00:00:00:00:00" | head -1)

if [ "\$CURRENT_HOSTNAME" != "\$EXPECTED_HOSTNAME" ]; then
    echo "⚠️  Warning: Expected hostname '\$EXPECTED_HOSTNAME' but current is '\$CURRENT_HOSTNAME'"
fi

if [ "\$CURRENT_MAC" != "\$EXPECTED_MAC" ]; then
    echo "⚠️  Warning: Expected MAC '\$EXPECTED_MAC' but current is '\$CURRENT_MAC'"
fi

if [ "\$CURRENT_HOSTNAME" != "\$EXPECTED_HOSTNAME" ] || [ "\$CURRENT_MAC" != "\$EXPECTED_MAC" ]; then
    echo "Continue deployment anyway? (y/N)"
    read -r response
    if [[ ! "\$response" =~ ^[Yy]\$ ]]; then
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
sudo cp -r /etc/nixos /etc/nixos.backup.\$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

# Copy new configuration
echo "📋 Copying new configuration..."
if [ "\$CONFIG_TYPE" = "flakes" ]; then
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
if [ "\$CONFIG_TYPE" = "flakes" ]; then
    sudo nixos-rebuild switch --flake .#\$CURRENT_HOSTNAME 2>/dev/null || sudo nixos-rebuild switch
else
    sudo nixos-rebuild switch
fi

echo "✅ Deployment complete!"
echo "🔄 Please reboot if kernel or major system changes were made"
EOF
    
    chmod +x "$MACHINE_DIR/deploy.sh"
    echo -e "   ${CHECK} Created deployment script"
    
    # Create README for this machine
    cat > "$MACHINE_DIR/README.md" << EOF
# $HOSTNAME - NixOS Configuration

## Machine Information
- **Hostname**: $HOSTNAME
- **Primary MAC**: $PRIMARY_MAC
- **All MACs**: $ALL_MACS
- **Primary IP**: $PRIMARY_IP
- **NixOS Version**: $NIXOS_VERSION
- **Configuration Type**: $([ -f "$MACHINE_DIR/flake.nix" ] && echo "Flakes-based" || echo "Traditional")
- **Last Export**: $(date)

## Network Configuration
- **Interface**: $PRIMARY_INTERFACE
- **Gateway**: $GATEWAY
- **DNS**: $DNS_SERVERS
- **Type**: $NETWORK_TYPE

## Deployment

### Quick Deploy
\`\`\`bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/$MACHINE_DIR/deploy.sh | bash
\`\`\`

### Manual Deploy
\`\`\`bash
git clone https://github.com/PadsterH2012/nixos.git
cd nixos/$MACHINE_DIR
./deploy.sh
\`\`\`

## Files Structure
$(if [ -f "$MACHINE_DIR/flake.nix" ]; then
echo "- \`flake.nix\` - Nix flake configuration"
echo "- \`flake.lock\` - Flake lock file"
fi)
- \`configuration.nix\` - Main NixOS configuration
- \`hardware-configuration.nix\` - Hardware-specific settings
- \`modules/\` - Configuration modules
- \`services/\` - Service configurations
- \`applications/\` - Application configurations
- \`machine-info.yaml\` - Machine and network information
- \`deploy.sh\` - Deployment script
- \`README.md\` - This file

## Configuration Type
$(if [ -f "$MACHINE_DIR/flake.nix" ]; then
echo "This machine uses **Nix Flakes** for configuration management."
echo ""
echo "### Flake Commands"
echo "\`\`\`bash"
echo "# Rebuild with flakes"
echo "sudo nixos-rebuild switch --flake .#$HOSTNAME"
echo ""
echo "# Update flake inputs"
echo "nix flake update"
echo "\`\`\`"
else
echo "This machine uses **traditional NixOS** configuration management."
fi)

## Network Settings
Current configuration uses $NETWORK_TYPE. See \`machine-info.yaml\` for detailed network settings and NixOS configuration examples.

## MAC Address Identification
This configuration is identified by MAC address \`$PRIMARY_MAC\` for reliable machine targeting across hostname changes.
EOF
    
    echo -e "   ${CHECK} Created README file"
    echo
}

commit_and_push() {
    echo -e "${BLUE}${INFO} Committing changes to Git...${NC}"
    
    # Configure git if needed
    if ! git config user.name >/dev/null 2>&1; then
        git config user.name "NixOS Config Exporter"
        git config user.email "nixos-export@$(hostname)"
    fi
    
    # Add all files
    git add .
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        echo -e "   ${INFO} No changes to commit"
        return
    fi
    
    # Commit changes
    COMMIT_MSG="Export configuration from $HOSTNAME

Machine: $HOSTNAME
IP: $PRIMARY_IP
NixOS: $NIXOS_VERSION
Date: $(date)

Network:
- Interface: $PRIMARY_INTERFACE
- Gateway: $GATEWAY
- DNS: $DNS_SERVERS
- Type: $NETWORK_TYPE"
    
    git commit -m "$COMMIT_MSG"
    echo -e "   ${CHECK} Changes committed"
    
    # Push to repository
    local push_success=false

    # Ensure non-interactive Git operations
    export GIT_TERMINAL_PROMPT=0
    export GIT_ASKPASS=/bin/echo

    if [ -n "$GITHUB_TOKEN" ]; then
        # Set up authenticated remote for push
        local auth_url=$(echo "$REPO_URL" | sed "s|https://github.com/|https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/|")
        git remote set-url origin "$auth_url" 2>/dev/null || true

        # Push with explicit non-interactive settings
        if GIT_TERMINAL_PROMPT=0 git push origin main 2>/dev/null; then
            echo -e "   ${CHECK} Changes pushed to repository"
            push_success=true
        else
            echo -e "   ${WARNING} Failed to push changes"
            echo -e "   ${INFO} Check your token permissions and repository access"
            echo -e "   ${INFO} Changes are committed locally in: $REPO_DIR"
        fi
    else
        echo -e "   ${WARNING} No GitHub token provided - cannot push to private repository"
        echo -e "   ${INFO} Set GITHUB_TOKEN environment variable for authentication"
        echo -e "   ${INFO} Changes are committed locally in: $REPO_DIR"
    fi
    
    echo
}

cleanup() {
    echo -e "${BLUE}${INFO} Cleaning up...${NC}"
    # Keep the repo directory for manual inspection if push failed
    echo -e "   ${INFO} Repository available at: ${CYAN}$REPO_DIR${NC}"
    echo
}

main() {
    print_header

    echo -e "${CYAN}Exporting NixOS configuration from this machine...${NC}"
    echo

    # Check for GitHub authentication
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}${WARNING} GitHub token not found${NC}"
        echo -e "${INFO} For hands-off operation, create a config file:"
        echo -e "${CYAN}echo 'export GITHUB_TOKEN=\"ghp_your_token_here\"' > ~/.nixos-export-config${NC}"
        echo -e "${CYAN}chmod 600 ~/.nixos-export-config${NC}"
        echo
        echo -e "${INFO} Alternative locations checked:"
        for config_file in "${CONFIG_LOCATIONS[@]}"; do
            echo -e "   • $config_file"
        done
        echo
        echo -e "${INFO} Continuing without authentication (may fail for private repos)..."
        echo
    else
        echo -e "${GREEN}${CHECK} GitHub authentication loaded${NC}"
        echo
    fi

    # Check if running as root or with sudo access
    if [[ $EUID -eq 0 ]]; then
        echo -e "${WARNING} Running as root - this is fine but not required"
    elif ! sudo -n true 2>/dev/null; then
        echo -e "${INFO} This script may need sudo access for reading /etc/nixos"
    fi
    
    get_system_info
    clone_or_update_repo
    create_machine_config
    commit_and_push
    cleanup
    
    echo -e "${GREEN}${CHECK} Export complete!${NC}"
    echo
    echo -e "${BLUE}📋 Summary:${NC}"
    echo -e "   • Machine: ${GREEN}$HOSTNAME${NC}"
    echo -e "   • Configuration exported to: ${GREEN}$HOSTNAME/${NC}"
    echo -e "   • Repository: ${CYAN}$REPO_URL${NC}"
    echo
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo -e "   • View your config: ${CYAN}https://github.com/PadsterH2012/nixos/tree/main/$HOSTNAME${NC}"
    echo -e "   • Make changes via GitHub web interface or git clone"
    echo -e "   • Deploy to other machines: ${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/$HOSTNAME/deploy.sh | bash${NC}"
    echo
}

# Run main function
main "$@"
