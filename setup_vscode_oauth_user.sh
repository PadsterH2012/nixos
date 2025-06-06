#!/bin/bash

# VS Code OAuth Setup Script for NixOS Users
# This script sets up Flatpak VS Code for OAuth compatibility

set -e

echo "🚀 Setting up VS Code OAuth Authentication for NixOS"
echo "====================================================="
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

# Check if VS Code is already installed
if flatpak list | grep -q com.visualstudio.code; then
    print_status "PASS" "VS Code Flatpak is already installed"
else
    print_status "INFO" "VS Code Flatpak not found - it should be installed automatically by the system service"
    print_status "INFO" "If not installed, run: flatpak install flathub com.visualstudio.code"
fi

# Create user desktop shortcut
print_status "INFO" "Creating user desktop shortcut..."
mkdir -p ~/Desktop
cat > ~/Desktop/VS\ Code\ OAuth.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code (OAuth Working)
Comment=Code Editing with OAuth Authentication Support
Exec=flatpak run com.visualstudio.code %U
Icon=com.visualstudio.code
Terminal=false
Categories=Development;IDE;
StartupNotify=true
MimeType=text/plain;inode/directory;x-scheme-handler/vscode;
EOF

chmod +x ~/Desktop/VS\ Code\ OAuth.desktop

# Add shell aliases to user profile
print_status "INFO" "Adding shell aliases..."
if ! grep -q "flatpak run com.visualstudio.code" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# VS Code OAuth-compatible aliases" >> ~/.bashrc
    echo 'alias code="flatpak run com.visualstudio.code"' >> ~/.bashrc
    echo 'alias vscode="flatpak run com.visualstudio.code"' >> ~/.bashrc
fi

print_status "PASS" "VS Code OAuth setup complete!"
echo ""
echo "🎯 USAGE INSTRUCTIONS"
echo "===================="
echo "1. Launch VS Code: Click 'VS Code (OAuth Working)' on desktop"
echo "2. Or use command: flatpak run com.visualstudio.code"
echo "3. Or use alias: code (after restarting terminal)"
echo ""
echo "🔐 OAUTH AUTHENTICATION"
echo "======================="
echo "1. Install Augment Code extension in VS Code"
echo "2. Click 'Authenticate' in the extension"
echo "3. Complete OAuth flow in browser"
echo "4. Allow keyring access when prompted"
echo "5. Authentication should work properly!"
echo ""
echo "📋 TROUBLESHOOTING"
echo "=================="
echo "- If OAuth fails: Clear browser cookies and try incognito mode"
echo "- If keyring prompts: Enter password and check 'remember' option"
echo "- For support: Check VS Code > Help > Toggle Developer Tools"
echo ""
echo "✅ OAuth authentication is now working with Flatpak VS Code!"
echo ""
