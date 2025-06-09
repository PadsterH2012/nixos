#!/bin/bash

# Fix Node.js PATH for VS Code Flatpak
# Run this from the NixOS host system (not from within VS Code)

echo "🔧 Fixing Node.js PATH for VS Code Flatpak"
echo "=========================================="

# Find the most recent Node.js installation in Nix store
NODEJS_PATH=$(find /nix/store -name "nodejs-*" -type d | grep -E "nodejs-[0-9]" | sort -V | tail -1)

if [ -z "$NODEJS_PATH" ]; then
    echo "❌ No Node.js installation found in Nix store"
    exit 1
fi

NODEJS_BIN="$NODEJS_PATH/bin"

echo "📦 Found Node.js at: $NODEJS_BIN"

# Verify Node.js works
if [ -x "$NODEJS_BIN/node" ]; then
    echo "✅ Node.js version: $($NODEJS_BIN/node --version)"
else
    echo "❌ Node.js binary not executable at $NODEJS_BIN/node"
    exit 1
fi

# Update Flatpak PATH to include the specific Node.js path
echo "🔧 Updating VS Code Flatpak PATH..."

flatpak override --user --env=PATH="$NODEJS_BIN:/app/bin:/usr/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin" com.visualstudio.code

if [ $? -eq 0 ]; then
    echo "✅ PATH updated successfully!"
    echo "📍 Node.js will be available at: $NODEJS_BIN/node"
    echo "📍 npm will be available at: $NODEJS_BIN/npm"
    echo "📍 npx will be available at: $NODEJS_BIN/npx"
    echo
    echo "🔄 Please restart VS Code:"
    echo "   flatpak kill com.visualstudio.code"
    echo "   flatpak run com.visualstudio.code"
    echo
    echo "🧪 Then test with:"
    echo "   node --version"
    echo "   npm --version"
    echo "   npx --version"
else
    echo "❌ Failed to update PATH"
    exit 1
fi
