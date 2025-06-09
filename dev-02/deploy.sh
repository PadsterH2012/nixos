#!/bin/bash

# NixOS dev-02 Configuration Deployment Script
# Deploys Cinnamon desktop environment with development tools and XRDP support

set -e  # Exit on any error

echo "=========================================="
echo "NixOS dev-02 Configuration Deployment"
echo "Cinnamon Desktop + Development Tools"
echo "=========================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "Please run this script as a regular user (it will use sudo when needed)"
   exit 1
fi

# Backup existing configuration
echo "📦 Backing up existing NixOS configuration..."
if [ -f /etc/nixos/configuration.nix ]; then
    sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created"
fi

# Create necessary directories
echo "📁 Creating directory structure..."
sudo mkdir -p /etc/nixos/modules /etc/nixos/services /etc/nixos/applications

# Download all configuration files
echo "⬇️  Downloading configuration files from GitHub..."

BASE_URL="https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos"

# Main configuration
echo "  - configuration.nix"
sudo curl -s -o /etc/nixos/configuration.nix "$BASE_URL/configuration.nix"

# Modules
echo "  - modules/hardware.nix"
sudo curl -s -o /etc/nixos/modules/hardware.nix "$BASE_URL/modules/hardware.nix"

echo "  - modules/networking.nix"
sudo curl -s -o /etc/nixos/modules/networking.nix "$BASE_URL/modules/networking.nix"

echo "  - modules/localization.nix"
sudo curl -s -o /etc/nixos/modules/localization.nix "$BASE_URL/modules/localization.nix"

echo "  - modules/desktop.nix"
sudo curl -s -o /etc/nixos/modules/desktop.nix "$BASE_URL/modules/desktop.nix"

echo "  - modules/development.nix"
sudo curl -s -o /etc/nixos/modules/development.nix "$BASE_URL/modules/development.nix"

# Services
echo "  - services/audio.nix"
sudo curl -s -o /etc/nixos/services/audio.nix "$BASE_URL/services/audio.nix"

echo "  - services/nfs.nix"
sudo curl -s -o /etc/nixos/services/nfs.nix "$BASE_URL/services/nfs.nix"

echo "  - services/remote-access.nix"
sudo curl -s -o /etc/nixos/services/remote-access.nix "$BASE_URL/services/remote-access.nix"

echo "  - services/auto-update.nix"
sudo curl -s -o /etc/nixos/services/auto-update.nix "$BASE_URL/services/auto-update.nix"

# Applications
echo "  - applications/vscode.nix"
sudo curl -s -o /etc/nixos/applications/vscode.nix "$BASE_URL/applications/vscode.nix"

echo "  - applications/vscode-extensions.nix"
sudo curl -s -o /etc/nixos/applications/vscode-extensions.nix "$BASE_URL/applications/vscode-extensions.nix"

echo "  - applications/mcp-config.nix"
sudo curl -s -o /etc/nixos/applications/mcp-config.nix "$BASE_URL/applications/mcp-config.nix"

echo "  - applications/augment-settings.nix"
sudo curl -s -o /etc/nixos/applications/augment-settings.nix "$BASE_URL/applications/augment-settings.nix"

echo "  - applications/git.nix"
sudo curl -s -o /etc/nixos/applications/git.nix "$BASE_URL/applications/git.nix"

echo "  - applications/terminal.nix"
sudo curl -s -o /etc/nixos/applications/terminal.nix "$BASE_URL/applications/terminal.nix"

echo "✅ All files downloaded successfully"

# Verify files exist
echo "🔍 Verifying downloaded files..."
REQUIRED_FILES=(
    "/etc/nixos/configuration.nix"
    "/etc/nixos/modules/hardware.nix"
    "/etc/nixos/modules/networking.nix"
    "/etc/nixos/modules/localization.nix"
    "/etc/nixos/modules/desktop.nix"
    "/etc/nixos/modules/development.nix"
    "/etc/nixos/services/audio.nix"
    "/etc/nixos/services/nfs.nix"
    "/etc/nixos/services/remote-access.nix"
    "/etc/nixos/services/auto-update.nix"
    "/etc/nixos/applications/vscode.nix"
    "/etc/nixos/applications/vscode-extensions.nix"
    "/etc/nixos/applications/mcp-config.nix"
    "/etc/nixos/applications/augment-settings.nix"
    "/etc/nixos/applications/git.nix"
    "/etc/nixos/applications/terminal.nix"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: $file not found"
        exit 1
    fi
done

echo "✅ All required files verified"

# Show what will be deployed
echo ""
echo "📋 Configuration Summary:"
echo "  - Desktop: Cinnamon (modern, XRDP-compatible)"
echo "  - Development: VS Code, Git, Docker, Node.js/npm/npx, Python"
echo "  - Remote Access: SSH + XRDP"
echo "  - Audio: PipeWire"
echo "  - Localization: UK (en_GB)"
echo "  - User: paddy (remember to set password)"
echo ""

# Ask for confirmation
# read -p "🚀 Ready to deploy? This will rebuild your NixOS system. Continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Apply the configuration
echo "🔧 Applying NixOS configuration..."
echo "This may take several minutes to download and build packages..."
sudo nixos-rebuild switch

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📝 Next Steps:"
echo "1. Set password for user 'paddy': sudo passwd paddy"
echo "2. Reboot the system: sudo reboot"
echo "3. Connect via XRDP on port 3389"
echo "4. Login with user 'paddy' and your password"
echo ""
echo "🖥️  XRDP Access:"
echo "   - Use any RDP client to connect to this machine"
echo "   - Port: 3389 (automatically opened in firewall)"
echo "   - User: paddy"
echo "   - You'll get a full Cinnamon desktop with all development tools"
echo ""
echo "🛠️  Development Tools Available:"
echo "   - VS Code: 'code' command or desktop shortcut"
echo "   - Terminal: 'gnome-terminal' or desktop shortcut"
echo "   - Docker: 'docker' command (user paddy is in docker group)"
echo "   - Git: 'git' command"
echo "   - Node.js: 'node', 'npm', 'npx' commands"
echo ""
echo "If you don't see the taskbar/menu in XRDP, run:"
echo "sudo /etc/xrdp/start-cinnamon-desktop.sh"
echo ""
echo "Happy coding! 🚀"
