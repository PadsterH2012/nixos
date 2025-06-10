#!/bin/bash

# VS Code OAuth Authentication Test Script for NixOS
# This script diagnoses and tests OAuth authentication issues
# Run via SSH: ssh user@nixos-machine 'bash -s' < vscode_oauth_test_script.sh

set -e

echo "🔍 VS Code OAuth Authentication Diagnostic Script"
echo "=================================================="
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if a package is installed
check_package() {
    local package=$1
    if command -v "$package" >/dev/null 2>&1; then
        print_status "PASS" "$package is installed"
        return 0
    else
        print_status "FAIL" "$package is NOT installed"
        return 1
    fi
}

# Function to check if a library is available
check_library() {
    local lib=$1
    if ldconfig -p | grep -q "$lib"; then
        print_status "PASS" "Library $lib is available"
        return 0
    else
        print_status "FAIL" "Library $lib is NOT available"
        return 1
    fi
}

echo "🔧 SYSTEM INFORMATION"
echo "====================="
print_status "INFO" "NixOS Version: $(nixos-version 2>/dev/null || echo 'Unknown')"
print_status "INFO" "Desktop Environment: $XDG_CURRENT_DESKTOP"
print_status "INFO" "Display: $DISPLAY"
print_status "INFO" "Session Type: $XDG_SESSION_TYPE"
echo ""

echo "📦 PACKAGE CHECKS"
echo "=================="
check_package "code"
check_package "gnome-keyring"
check_package "seahorse"
echo ""

echo "📚 LIBRARY CHECKS"
echo "=================="
check_library "libsecret"
check_library "libgnome-keyring"
echo ""

echo "🔐 KEYRING STATUS"
echo "=================="
if pgrep -x "gnome-keyring-d" > /dev/null; then
    print_status "PASS" "GNOME Keyring daemon is running"
else
    print_status "FAIL" "GNOME Keyring daemon is NOT running"
fi

# Check if keyring is unlocked
if command -v secret-tool >/dev/null 2>&1; then
    if secret-tool lookup test test 2>/dev/null; then
        print_status "PASS" "Keyring is accessible"
    else
        print_status "WARN" "Keyring may be locked or inaccessible"
    fi
else
    print_status "WARN" "secret-tool not available for keyring testing"
fi
echo ""

echo "🖥️ DESKTOP FILE CHECKS"
echo "======================="
# Check VS Code desktop files
vscode_desktop_files=(
    "/usr/share/applications/code.desktop"
    "/home/$(whoami)/.local/share/applications/code.desktop"
    "/etc/nixos/skel/Desktop/Visual Studio Code.desktop"
)

for desktop_file in "${vscode_desktop_files[@]}"; do
    if [[ -f "$desktop_file" ]]; then
        print_status "PASS" "Found desktop file: $desktop_file"
        if grep -q "x-scheme-handler/vscode" "$desktop_file" 2>/dev/null; then
            print_status "PASS" "Protocol handler registered in $desktop_file"
        else
            print_status "FAIL" "Protocol handler NOT registered in $desktop_file"
        fi
    else
        print_status "INFO" "Desktop file not found: $desktop_file"
    fi
done
echo ""

echo "🌐 PROTOCOL HANDLER TESTS"
echo "=========================="
# Test xdg-mime associations
if command -v xdg-mime >/dev/null 2>&1; then
    vscode_handler=$(xdg-mime query default x-scheme-handler/vscode 2>/dev/null || echo "none")
    if [[ "$vscode_handler" != "none" && "$vscode_handler" != "" ]]; then
        print_status "PASS" "vscode:// protocol handler: $vscode_handler"
    else
        print_status "FAIL" "vscode:// protocol handler NOT configured"
    fi
else
    print_status "WARN" "xdg-mime not available for protocol testing"
fi
echo ""

echo "🔍 VS CODE CONFIGURATION"
echo "========================="
# Check VS Code installation
if command -v code >/dev/null 2>&1; then
    code_version=$(code --version 2>/dev/null | head -n1 || echo "Unknown")
    print_status "INFO" "VS Code version: $code_version"
    
    # Check if VS Code can access keyring
    if [[ -d "/home/$(whoami)/.config/Code" ]]; then
        print_status "PASS" "VS Code config directory exists"
    else
        print_status "WARN" "VS Code config directory not found"
    fi
else
    print_status "FAIL" "VS Code is not installed or not in PATH"
fi
echo ""

echo "🧪 OAUTH SIMULATION TESTS"
echo "=========================="
# Test if we can create a test vscode:// URL handler
test_url="vscode://test/auth?code=test123&state=test456"
print_status "INFO" "Testing URL: $test_url"

# Try to handle the URL
if command -v xdg-open >/dev/null 2>&1; then
    print_status "INFO" "Attempting to handle vscode:// URL with xdg-open..."
    # Note: This won't actually open VS Code in SSH session, but will test the handler
    timeout 5s xdg-open "$test_url" 2>/dev/null && \
        print_status "PASS" "xdg-open accepted vscode:// URL" || \
        print_status "FAIL" "xdg-open failed to handle vscode:// URL"
else
    print_status "WARN" "xdg-open not available for URL testing"
fi
echo ""

echo "🔧 ENVIRONMENT VARIABLES"
echo "========================="
env_vars=("XDG_DATA_DIRS" "XDG_CONFIG_DIRS" "PATH" "LD_LIBRARY_PATH")
for var in "${env_vars[@]}"; do
    if [[ -n "${!var}" ]]; then
        print_status "INFO" "$var: ${!var}"
    else
        print_status "WARN" "$var is not set"
    fi
done
echo ""

echo "📋 PROCESS INFORMATION"
echo "======================"
print_status "INFO" "Running processes related to VS Code and keyring:"
ps aux | grep -E "(code|keyring|gnome)" | grep -v grep | while read line; do
    print_status "INFO" "Process: $line"
done
echo ""

echo "🔍 DETAILED DIAGNOSTICS"
echo "======================="
# Check libsecret specifically
if pkg-config --exists libsecret-1 2>/dev/null; then
    libsecret_version=$(pkg-config --modversion libsecret-1 2>/dev/null)
    print_status "PASS" "libsecret-1 pkg-config available (version: $libsecret_version)"
else
    print_status "FAIL" "libsecret-1 pkg-config NOT available"
fi

# Check for VS Code specific libraries
if ldd "$(which code)" 2>/dev/null | grep -q libsecret; then
    print_status "PASS" "VS Code is linked against libsecret"
else
    print_status "WARN" "VS Code may not be linked against libsecret"
fi
echo ""

echo "🚀 RECOMMENDATIONS"
echo "=================="
echo "Based on the diagnostic results above:"
echo ""

# Generate recommendations based on findings
if ! command -v code >/dev/null 2>&1; then
    print_status "FAIL" "CRITICAL: VS Code is not installed"
fi

if ! ldconfig -p | grep -q libsecret; then
    print_status "FAIL" "CRITICAL: libsecret library is missing"
    echo "   → Add 'libsecret' to environment.systemPackages in configuration.nix"
fi

if ! pgrep -x "gnome-keyring-d" > /dev/null; then
    print_status "FAIL" "CRITICAL: GNOME Keyring daemon is not running"
    echo "   → Check PAM configuration and keyring service"
fi

vscode_handler=$(xdg-mime query default x-scheme-handler/vscode 2>/dev/null || echo "none")
if [[ "$vscode_handler" == "none" || "$vscode_handler" == "" ]]; then
    print_status "FAIL" "CRITICAL: vscode:// protocol handler not configured"
    echo "   → Add 'x-scheme-handler/vscode' to VS Code desktop file MimeType"
fi

echo ""
echo "🔧 AUTOMATED FIXES"
echo "=================="
echo "Would you like to attempt automated fixes? (y/n)"
read -r fix_response

if [[ "$fix_response" == "y" || "$fix_response" == "Y" ]]; then
    echo "Attempting automated fixes..."

    # Fix 1: Register vscode:// protocol handler
    if [[ "$vscode_handler" == "none" || "$vscode_handler" == "" ]]; then
        echo "Registering vscode:// protocol handler..."
        if command -v xdg-mime >/dev/null 2>&1; then
            xdg-mime default code.desktop x-scheme-handler/vscode 2>/dev/null && \
                print_status "PASS" "Registered vscode:// protocol handler" || \
                print_status "FAIL" "Failed to register protocol handler"
        fi
    fi

    # Fix 2: Update MIME database
    if command -v update-mime-database >/dev/null 2>&1; then
        update-mime-database ~/.local/share/mime 2>/dev/null && \
            print_status "PASS" "Updated MIME database" || \
            print_status "WARN" "Failed to update MIME database"
    fi

    # Fix 3: Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database ~/.local/share/applications 2>/dev/null && \
            print_status "PASS" "Updated desktop database" || \
            print_status "WARN" "Failed to update desktop database"
    fi

    echo "Automated fixes complete. Re-run this script to verify."
fi

echo ""
echo "📊 DIAGNOSTIC COMPLETE"
echo "======================"
echo "Timestamp: $(date)"
echo "Run this script again after making configuration changes to verify fixes."
echo ""

# Generate a summary report
echo "📄 SUMMARY REPORT"
echo "=================="
echo "Save this output for troubleshooting:"
echo "- Hostname: $(hostname)"
echo "- User: $(whoami)"
echo "- NixOS Version: $(nixos-version 2>/dev/null || echo 'Unknown')"
echo "- VS Code Version: $(code --version 2>/dev/null | head -n1 || echo 'Not installed')"
echo "- Desktop Environment: $XDG_CURRENT_DESKTOP"
echo "- Protocol Handler: $vscode_handler"
echo "- Keyring Status: $(pgrep -x "gnome-keyring-d" > /dev/null && echo 'Running' || echo 'Not running')"
echo "- libsecret Available: $(ldconfig -p | grep -q libsecret && echo 'Yes' || echo 'No')"
echo ""
