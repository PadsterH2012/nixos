#!/bin/bash

# VS Code Flatpak Development Permissions Setup
# Grants full system access to Flatpak VS Code for development work
# Run this script from the host NixOS system (not from within VS Code)

set -e

echo "🔧 Setting up VS Code Flatpak for Full Development Access"
echo "======================================================="
echo

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ Please run this script as a regular user (not root)${NC}"
   exit 1
fi

# Check if flatpak is available
if ! command -v flatpak >/dev/null 2>&1; then
    echo -e "${RED}❌ Flatpak not found. Please install flatpak first.${NC}"
    exit 1
fi

# Check if VS Code Flatpak is installed
if ! flatpak list | grep -q com.visualstudio.code; then
    echo -e "${YELLOW}⚠️  VS Code Flatpak not found. Installing...${NC}"
    flatpak install -y flathub com.visualstudio.code
fi

echo -e "${BLUE}📋 Current VS Code Flatpak permissions:${NC}"
flatpak info --show-permissions com.visualstudio.code || echo "No custom permissions set"
echo

echo -e "${BLUE}🔓 Granting full development permissions...${NC}"

# Grant comprehensive filesystem access
echo "  📁 Granting filesystem access..."
flatpak override --user --filesystem=host com.visualstudio.code
flatpak override --user --filesystem=host-etc com.visualstudio.code
flatpak override --user --filesystem=/tmp com.visualstudio.code

# Grant network access
echo "  🌐 Granting network access..."
flatpak override --user --share=network com.visualstudio.code

# Grant device access
echo "  🖥️  Granting device access..."
flatpak override --user --device=all com.visualstudio.code

# Grant system bus access for development tools
echo "  🚌 Granting system bus access..."
flatpak override --user --system-talk-name=org.freedesktop.systemd1 com.visualstudio.code
flatpak override --user --system-talk-name=org.freedesktop.login1 com.visualstudio.code

# Grant session bus access
echo "  💬 Granting session bus access..."
flatpak override --user --talk-name=org.freedesktop.secrets com.visualstudio.code
flatpak override --user --talk-name=org.gnome.keyring com.visualstudio.code

# Grant environment access
echo "  🌍 Granting environment access..."
flatpak override --user --env=PATH=/app/bin:/usr/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin com.visualstudio.code
flatpak override --user --env=NODE_PATH=/run/current-system/sw/lib/node_modules com.visualstudio.code

# Grant socket access
echo "  🔌 Granting socket access..."
flatpak override --user --socket=x11 com.visualstudio.code
flatpak override --user --socket=wayland com.visualstudio.code
flatpak override --user --socket=pulseaudio com.visualstudio.code
flatpak override --user --socket=session-bus com.visualstudio.code
flatpak override --user --socket=system-bus com.visualstudio.code

echo
echo -e "${GREEN}✅ VS Code Flatpak permissions updated!${NC}"
echo

echo -e "${BLUE}📋 New permissions summary:${NC}"
flatpak info --show-permissions com.visualstudio.code
echo

echo -e "${YELLOW}🔄 Please restart VS Code for changes to take effect:${NC}"
echo "  1. Close all VS Code windows"
echo "  2. Run: flatpak kill com.visualstudio.code"
echo "  3. Restart VS Code: flatpak run com.visualstudio.code"
echo

echo -e "${GREEN}🎯 VS Code now has full development access while keeping OAuth functionality!${NC}"
echo
echo -e "${BLUE}💡 Development capabilities now available:${NC}"
echo "  ✅ Full filesystem access (including /nix/store)"
echo "  ✅ Network access for package managers"
echo "  ✅ Device access for hardware debugging"
echo "  ✅ System service access"
echo "  ✅ Environment variables from host"
echo "  ✅ OAuth authentication (preserved)"
echo
echo -e "${BLUE}🛠️  Test your setup:${NC}"
echo "  • Node.js: Should now find system Node.js"
echo "  • Docker: Should access host Docker daemon"
echo "  • Git: Should access host Git configuration"
echo "  • File system: Should access all host directories"
echo
echo "Happy coding! 🚀"
