#!/bin/bash

# Node.js Environment Test Script for NixOS dev-02
# This script helps diagnose Node.js availability issues

echo "🔍 Node.js Environment Diagnostic Test"
echo "======================================"
echo

# Test 1: Check if running as interactive shell
echo "1. Shell Environment:"
if [[ $- == *i* ]]; then
    echo "   ✅ Interactive shell detected"
else
    echo "   ⚠️  Non-interactive shell detected"
fi
echo "   Shell: $0"
echo "   SHELL: $SHELL"
echo

# Test 2: Check current PATH
echo "2. Current PATH:"
echo "   $PATH"
echo

# Test 3: Check for Node.js in PATH
echo "3. Node.js Detection:"
if command -v node >/dev/null 2>&1; then
    echo "   ✅ node command found: $(which node)"
    echo "   Version: $(node --version)"
else
    echo "   ❌ node command not found in PATH"
fi

if command -v npm >/dev/null 2>&1; then
    echo "   ✅ npm command found: $(which npm)"
    echo "   Version: $(npm --version)"
else
    echo "   ❌ npm command not found in PATH"
fi

if command -v npx >/dev/null 2>&1; then
    echo "   ✅ npx command found: $(which npx)"
else
    echo "   ❌ npx command not found in PATH"
fi
echo

# Test 4: Check NixOS store paths
echo "4. NixOS Store Paths:"
if [ -d "/nix/store" ]; then
    echo "   ✅ Nix store available"
    NODE_PATHS=$(find /nix/store -name "node" -type f -executable 2>/dev/null | head -5)
    if [ -n "$NODE_PATHS" ]; then
        echo "   📦 Found Node.js installations:"
        echo "$NODE_PATHS" | sed 's/^/      /'
    else
        echo "   ❌ No Node.js installations found in Nix store"
    fi
else
    echo "   ❌ Nix store not found"
fi
echo

# Test 5: Check environment variables
echo "5. Environment Variables:"
echo "   NODE_PATH: ${NODE_PATH:-'(not set)'}"
echo "   HOME: ${HOME:-'(not set)'}"
echo "   USER: ${USER:-'(not set)'}"
echo

# Test 6: Test with explicit path
echo "6. Direct Path Test:"
for node_path in /run/current-system/sw/bin/node /nix/var/nix/profiles/default/bin/node; do
    if [ -x "$node_path" ]; then
        echo "   ✅ Found executable: $node_path"
        echo "   Version: $($node_path --version 2>/dev/null || echo 'Failed to get version')"
    else
        echo "   ❌ Not found: $node_path"
    fi
done
echo

# Test 7: Profile loading test
echo "7. Profile Loading:"
if [ -f /etc/profile ]; then
    echo "   ✅ /etc/profile exists"
else
    echo "   ❌ /etc/profile missing"
fi

if [ -f ~/.bashrc ]; then
    echo "   ✅ ~/.bashrc exists"
else
    echo "   ⚠️  ~/.bashrc missing"
fi

if [ -f ~/.profile ]; then
    echo "   ✅ ~/.profile exists"
else
    echo "   ⚠️  ~/.profile missing"
fi
echo

# Test 8: Suggested fixes
echo "8. Suggested Solutions:"
echo "   💡 For scripts, try:"
echo "      source /etc/profile"
echo "      export PATH=\"/run/current-system/sw/bin:\$PATH\""
echo
echo "   💡 For immediate fix:"
echo "      sudo nixos-rebuild switch"
echo "      source ~/.bashrc"
echo
echo "   💡 For MCP servers, use full path:"
echo "      /run/current-system/sw/bin/npx -y @upstash/context7-mcp@latest"
echo

echo "🏁 Diagnostic complete!"
