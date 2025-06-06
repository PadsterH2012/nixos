#!/bin/bash

# VS Code Flatpak Installation Script for OAuth Compatibility
# This script installs VS Code via Flatpak which typically has better OAuth support

set -e

echo "🚀 Installing VS Code via Flatpak for OAuth Compatibility"
echo "========================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS") echo -e "${GREEN}✅ PASS${NC}: $message" ;;
        "FAIL") echo -e "${RED}❌ FAIL${NC}: $message" ;;
        "WARN") echo -e "${YELLOW}⚠️  WARN${NC}: $message" ;;
        "INFO") echo -e "${BLUE}ℹ️  INFO${NC}: $message" ;;
    esac
}

# Check if Flatpak is available
if ! command -v flatpak >/dev/null 2>&1; then
    print_status "FAIL" "Flatpak is not installed. Please run 'sudo nixos-rebuild switch' first."
    exit 1
fi

print_status "PASS" "Flatpak is available"

# Add Flathub repository if not already added
print_status "INFO" "Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install VS Code via Flatpak
print_status "INFO" "Installing VS Code via Flatpak..."
flatpak install -y flathub com.visualstudio.code

# Create desktop shortcut for Flatpak VS Code
print_status "INFO" "Creating desktop shortcut..."
mkdir -p ~/Desktop
cat > ~/Desktop/VS\ Code\ Flatpak.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code (Flatpak)
Comment=Code Editing. Redefined. (OAuth Compatible)
Exec=flatpak run com.visualstudio.code %U
Icon=com.visualstudio.code
Terminal=false
Categories=Development;IDE;
StartupNotify=true
MimeType=text/plain;inode/directory;x-scheme-handler/vscode;
EOF

chmod +x ~/Desktop/VS\ Code\ Flatpak.desktop

# Create command alias
print_status "INFO" "Creating command alias..."
echo 'alias code-flatpak="flatpak run com.visualstudio.code"' >> ~/.bashrc

print_status "PASS" "VS Code Flatpak installation complete!"
echo ""
echo "🎯 USAGE INSTRUCTIONS"
echo "===================="
echo "1. Launch VS Code: Click 'VS Code (Flatpak)' on desktop"
echo "2. Or use command: flatpak run com.visualstudio.code"
echo "3. Or use alias: code-flatpak (after restarting terminal)"
echo ""
echo "🔐 OAUTH TESTING"
echo "================"
echo "1. Open VS Code via Flatpak"
echo "2. Try Augment Code authentication"
echo "3. OAuth should work properly in Flatpak environment"
echo ""
echo "📋 NOTES"
echo "========="
echo "- Flatpak VS Code runs in a sandbox with proper OAuth support"
echo "- Extensions are stored separately from native VS Code"
echo "- You can run both native and Flatpak VS Code side by side"
echo "- If OAuth works in Flatpak, you can use it as your primary VS Code"
echo ""
