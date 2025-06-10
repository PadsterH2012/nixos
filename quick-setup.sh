#!/bin/bash

# Quick Setup for NixOS Export Authentication
# Creates .nixos-export-config file for hands-off operation

echo "🔑 Setting up NixOS Export Authentication..."
echo

# Check if config already exists
if [ -f "$HOME/.nixos-export-config" ]; then
    echo "⚠️  Config file already exists: $HOME/.nixos-export-config"
    echo "Would you like to update it? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Keeping existing configuration"
        exit 0
    fi
fi

echo "📋 You need a GitHub Personal Access Token (PAT)"
echo
echo "🔑 To create one:"
echo "   1. Go to: https://github.com/settings/tokens"
echo "   2. Click 'Generate new token (classic)'"
echo "   3. Select scopes: repo (full control of private repositories)"
echo "   4. Copy the token (starts with ghp_)"
echo

echo "Enter your GitHub Personal Access Token:"
read -s token
echo

if [ -z "$token" ]; then
    echo "❌ No token provided"
    exit 1
fi

# Create config file
cat > "$HOME/.nixos-export-config" << EOF
# NixOS Export Configuration
# Auto-generated on $(date)
# Keep this file secure - it contains your GitHub token

export GITHUB_USERNAME="PadsterH2012"
export GITHUB_TOKEN="$token"
EOF

# Set secure permissions
chmod 600 "$HOME/.nixos-export-config"

echo "✅ Configuration saved to: $HOME/.nixos-export-config"
echo "✅ File permissions set to 600 (owner read/write only)"
echo

# Test the token
echo "🧪 Testing token..."
if curl -s -H "Authorization: token $token" https://api.github.com/user | grep -q '"login"'; then
    local username=$(curl -s -H "Authorization: token $token" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
    echo "✅ Token is valid for user: $username"
else
    echo "❌ Token appears to be invalid"
    echo "You may need to check the token or try again"
fi
echo

echo "🚀 Ready for hands-off export!"
echo "Now you can run:"
echo "curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash"
echo

echo "Would you like to test the export now? (y/N)"
read -r test_response
if [[ "$test_response" =~ ^[Yy]$ ]]; then
    echo "Running export test..."
    echo
    source "$HOME/.nixos-export-config"
    curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
fi
