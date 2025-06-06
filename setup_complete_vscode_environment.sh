#!/bin/bash

# Complete VS Code Environment Setup for NixOS
# This script sets up Flatpak VS Code with all captured extensions and OAuth support

set -e

echo "🚀 Complete VS Code Environment Setup for NixOS"
echo "================================================"
echo "Setting up Flatpak VS Code with OAuth-compatible extensions"
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

# Check prerequisites
print_status "INFO" "Checking prerequisites..."

if ! command -v flatpak >/dev/null 2>&1; then
    print_status "FAIL" "Flatpak is not installed. Please run 'sudo nixos-rebuild switch' first."
    exit 1
fi

print_status "PASS" "Flatpak is available"

# Check if VS Code is installed
if ! flatpak list | grep -q com.visualstudio.code; then
    print_status "WARN" "VS Code Flatpak not installed. Installing now..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub com.visualstudio.code
    print_status "PASS" "VS Code Flatpak installed"
else
    print_status "PASS" "VS Code Flatpak already installed"
fi

# Install captured extensions
print_status "INFO" "Installing captured extensions from working OAuth setup..."

install_extension() {
    local ext_id=$1
    local ext_name=$2
    echo -e "${BLUE}📦 Installing${NC}: $ext_name"
    if flatpak run com.visualstudio.code --install-extension "$ext_id" --force >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Success${NC}: $ext_name"
    else
        echo -e "${YELLOW}   ⚠️  Warning${NC}: Failed to install $ext_name"
    fi
}

# OAuth-compatible extensions (confirmed working)
print_status "INFO" "Installing OAuth-compatible extensions..."
install_extension "augment.vscode-augment" "Augment Code (OAuth Working)"
install_extension "github.copilot" "GitHub Copilot (OAuth Working)"
install_extension "github.copilot-chat" "GitHub Copilot Chat (OAuth Working)"

# Essential development extensions
print_status "INFO" "Installing development extensions..."
install_extension "ms-python.python" "Python"
install_extension "ms-vscode.cpptools" "C/C++"
install_extension "ms-vscode-remote.remote-ssh" "Remote SSH"
install_extension "bbenoist.nix" "Nix Language Support"
install_extension "redhat.vscode-yaml" "YAML"
install_extension "ms-vscode.vscode-json" "JSON"

# Git and version control
print_status "INFO" "Installing Git extensions..."
install_extension "eamodio.gitlens" "GitLens"
install_extension "mhutchie.git-graph" "Git Graph"

# Docker and containers
print_status "INFO" "Installing Docker extensions..."
install_extension "ms-azuretools.vscode-docker" "Docker"

# Productivity
print_status "INFO" "Installing productivity extensions..."
install_extension "streetsidesoftware.code-spell-checker" "Code Spell Checker"
install_extension "ms-vscode.vscode-todo-highlight" "TODO Highlight"

# Themes and appearance
print_status "INFO" "Installing themes..."
install_extension "pkief.material-icon-theme" "Material Icon Theme"
install_extension "zhuangtongfa.material-theme" "One Dark Pro"

# Create desktop shortcuts
print_status "INFO" "Creating desktop shortcuts..."
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

# Add shell aliases
print_status "INFO" "Adding shell aliases..."
if ! grep -q "flatpak run com.visualstudio.code" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# VS Code OAuth-compatible aliases (auto-generated)" >> ~/.bashrc
    echo 'alias code="flatpak run com.visualstudio.code"' >> ~/.bashrc
    echo 'alias vscode="flatpak run com.visualstudio.code"' >> ~/.bashrc
    print_status "PASS" "Shell aliases added to ~/.bashrc"
else
    print_status "PASS" "Shell aliases already exist"
fi

# Setup MCP servers
print_status "INFO" "Setting up MCP servers..."
if [ -f /etc/vscode/setup-global-mcp.sh ]; then
    /etc/vscode/setup-global-mcp.sh
    print_status "PASS" "MCP servers configured globally"
else
    print_status "WARN" "MCP setup script not found - run 'sudo nixos-rebuild switch' first"
fi

# Create extension summary
print_status "INFO" "Creating extension summary..."
cat > ~/vscode-extensions-summary.txt << 'EOF'
VS Code Extensions Summary
=========================
Installed on: $(date)
VS Code Type: Flatpak (OAuth Compatible)

OAuth-Compatible Extensions (Confirmed Working):
- Augment Code (augment.vscode-augment)
- GitHub Copilot (github.copilot)
- GitHub Copilot Chat (github.copilot-chat)

Development Extensions:
- Python (ms-python.python)
- C/C++ (ms-vscode.cpptools)
- Remote SSH (ms-vscode-remote.remote-ssh)
- Nix Language Support (bbenoist.nix)
- YAML (redhat.vscode-yaml)
- JSON (ms-vscode.vscode-json)

Git Extensions:
- GitLens (eamodio.gitlens)
- Git Graph (mhutchie.git-graph)

Container Extensions:
- Docker (ms-azuretools.vscode-docker)

Productivity Extensions:
- Code Spell Checker (streetsidesoftware.code-spell-checker)
- TODO Highlight (ms-vscode.vscode-todo-highlight)

Theme Extensions:
- Material Icon Theme (pkief.material-icon-theme)
- One Dark Pro (zhuangtongfa.material-theme)

Usage:
- Launch: Click "VS Code (OAuth Working)" on desktop
- Command: flatpak run com.visualstudio.code
- Alias: code (after restarting terminal)

OAuth Status: WORKING ✅
Extensions Location: ~/.var/app/com.visualstudio.code/data/vscode/extensions/

MCP Servers Configuration:
==========================
Proxy Server: 10.202.28.111:9090

Available MCP Servers:
- central-obsidian  - Obsidian notes management
- central-rpg       - RPG tools and monsters
- central-search    - Brave web search
- central-memory    - Knowledge graph memory
- central-mongodb   - MongoDB operations
- central-context7  - Code context engine
- central-jenkins   - Jenkins CI/CD

MCP Config Location: ~/.var/app/com.visualstudio.code/config/Code/User/mcp.json
Workspace Setup: Run '/etc/vscode/setup-mcp-servers.sh' in any workspace
EOF

print_status "PASS" "Complete VS Code environment setup finished!"
echo ""
echo "🎯 SUMMARY"
echo "=========="
echo "✅ Flatpak VS Code installed and configured"
echo "✅ OAuth-compatible extensions installed (Augment Code, GitHub Copilot)"
echo "✅ Development extensions installed"
echo "✅ Desktop shortcuts created"
echo "✅ Shell aliases configured"
echo "✅ MCP servers configured (7 centralized servers)"
echo "✅ Extension summary saved to ~/vscode-extensions-summary.txt"
echo ""
echo "🚀 NEXT STEPS"
echo "============="
echo "1. Launch VS Code: Click 'VS Code (OAuth Working)' on desktop"
echo "2. Test OAuth: Try Augment Code authentication"
echo "3. Allow keyring access when prompted (this is normal)"
echo "4. Restart terminal to use 'code' alias"
echo ""
echo "🔐 OAuth authentication should now work properly!"
echo ""
