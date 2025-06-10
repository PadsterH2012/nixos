#!/bin/bash

# Remote VS Code OAuth Test Runner
# This script runs the VS Code OAuth diagnostic test on a remote NixOS machine via SSH

set -e

# Configuration
REMOTE_HOST=""
REMOTE_USER=""
SSH_KEY=""

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

echo "🚀 Remote VS Code OAuth Test Runner"
echo "===================================="
echo ""

# Get connection details if not provided
if [[ -z "$REMOTE_HOST" ]]; then
    echo "Enter the NixOS machine details:"
    read -p "Hostname/IP: " REMOTE_HOST
    read -p "Username: " REMOTE_USER
    read -p "SSH key path (optional, press enter for default): " SSH_KEY
fi

# Build SSH command
SSH_CMD="ssh"
if [[ -n "$SSH_KEY" ]]; then
    SSH_CMD="$SSH_CMD -i $SSH_KEY"
fi
SSH_CMD="$SSH_CMD $REMOTE_USER@$REMOTE_HOST"

echo ""
print_status "INFO" "Connecting to: $REMOTE_USER@$REMOTE_HOST"
print_status "INFO" "Testing SSH connection..."

# Test SSH connection
if $SSH_CMD "echo 'SSH connection successful'" >/dev/null 2>&1; then
    print_status "PASS" "SSH connection established"
else
    print_status "FAIL" "SSH connection failed"
    echo "Please check:"
    echo "- Hostname/IP is correct"
    echo "- Username is correct"
    echo "- SSH key is correct (if using key auth)"
    echo "- SSH service is running on remote machine"
    exit 1
fi

echo ""
print_status "INFO" "Uploading and running diagnostic script..."

# Upload and run the diagnostic script
cat vscode_oauth_test_script.sh | $SSH_CMD 'cat > /tmp/vscode_oauth_test.sh && chmod +x /tmp/vscode_oauth_test.sh && /tmp/vscode_oauth_test.sh'

echo ""
print_status "INFO" "Diagnostic complete"

# Offer to run additional tests
echo ""
echo "🔧 Additional Tests Available:"
echo "1. Test vscode:// URL handling"
echo "2. Check VS Code extension directory"
echo "3. Test keyring access"
echo "4. Generate detailed system report"
echo "5. Exit"
echo ""

while true; do
    read -p "Select an option (1-5): " choice
    case $choice in
        1)
            echo "Testing vscode:// URL handling..."
            $SSH_CMD 'DISPLAY=:0 xdg-open "vscode://test/auth?code=test123" 2>&1 || echo "URL handling test failed"'
            ;;
        2)
            echo "Checking VS Code extension directory..."
            $SSH_CMD 'ls -la ~/.vscode/extensions/ 2>/dev/null || echo "No VS Code extensions directory found"'
            ;;
        3)
            echo "Testing keyring access..."
            $SSH_CMD 'secret-tool store --label="test" test test && secret-tool lookup test test && secret-tool clear test test 2>/dev/null || echo "Keyring test failed"'
            ;;
        4)
            echo "Generating detailed system report..."
            $SSH_CMD 'echo "=== NIXOS CONFIGURATION ===" && cat /etc/nixos/configuration.nix 2>/dev/null | head -50; echo "=== INSTALLED PACKAGES ===" && nix-env -q 2>/dev/null | head -20; echo "=== RUNNING SERVICES ===" && systemctl list-units --type=service --state=running | grep -E "(keyring|gnome|code)" || echo "No relevant services found"'
            ;;
        5)
            print_status "INFO" "Exiting"
            break
            ;;
        *)
            echo "Invalid option. Please select 1-5."
            ;;
    esac
    echo ""
done

echo ""
echo "📋 NEXT STEPS"
echo "=============="
echo "Based on the diagnostic results:"
echo ""
echo "1. If libsecret is missing:"
echo "   - Add 'libsecret' to environment.systemPackages in /etc/nixos/configuration.nix"
echo "   - Run: sudo nixos-rebuild switch"
echo ""
echo "2. If protocol handler is not registered:"
echo "   - Add 'x-scheme-handler/vscode;' to VS Code desktop file MimeType"
echo "   - Run: update-desktop-database ~/.local/share/applications"
echo ""
echo "3. If keyring is not running:"
echo "   - Check PAM configuration in desktop.nix"
echo "   - Ensure services.gnome.gnome-keyring.enable = true"
echo ""
echo "4. Test OAuth flow:"
echo "   - Open VS Code"
echo "   - Try Augment Code authentication"
echo "   - Check if browser redirects work"
echo ""
echo "🔄 Re-run this script after making changes to verify fixes."
echo ""
