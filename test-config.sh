#!/bin/bash

# Simple configuration test script
# Tests the NixOS configuration for syntax errors

set -e

ENVIRONMENT=${1:-dev-02}

echo "🔍 Testing NixOS configuration: $ENVIRONMENT"

# Check if configuration directory exists
if [[ ! -d "$ENVIRONMENT/nixos" ]]; then
    echo "❌ Configuration directory not found: $ENVIRONMENT/nixos"
    exit 1
fi

# Check if main configuration file exists
if [[ ! -f "$ENVIRONMENT/nixos/configuration.nix" ]]; then
    echo "❌ Main configuration file not found: $ENVIRONMENT/nixos/configuration.nix"
    exit 1
fi

echo "✅ Configuration files found"

# Check for common syntax issues
echo "🔍 Checking for common syntax issues..."

# Check for missing semicolons
if grep -r "^[[:space:]]*[^#]*}[[:space:]]*$" "$ENVIRONMENT/nixos" --include="*.nix" | grep -v "};"; then
    echo "⚠️  Warning: Found potential missing semicolons"
fi

# Check for unmatched braces
for file in $(find "$ENVIRONMENT/nixos" -name "*.nix"); do
    open_braces=$(grep -o "{" "$file" | wc -l)
    close_braces=$(grep -o "}" "$file" | wc -l)
    if [[ $open_braces -ne $close_braces ]]; then
        echo "⚠️  Warning: Unmatched braces in $file (open: $open_braces, close: $close_braces)"
    fi
done

echo "✅ Basic syntax checks completed"

# List all configuration files
echo "📁 Configuration structure:"
find "$ENVIRONMENT/nixos" -name "*.nix" | sort

echo ""
echo "🎯 Configuration test completed!"
echo "💡 To apply this configuration:"
echo "   sudo cp -r $ENVIRONMENT/nixos/* /etc/nixos/"
echo "   sudo nixos-rebuild test"
echo "   sudo nixos-rebuild switch"
