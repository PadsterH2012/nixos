#!/bin/bash

# MCP Proxy Deployment Script
# Deploys proxy scripts to Docker host and configures SSH access

set -e

DOCKER_HOST="10.202.28.111"
DOCKER_USER="root"
PROXY_DIR="/opt/mcp-proxies"
LOCAL_KEY="$HOME/.ssh/mcp_proxy_key"

echo "🚀 Deploying MCP Proxy Scripts to $DOCKER_HOST"

# Check if SSH key exists
if [ ! -f "$LOCAL_KEY" ]; then
    echo "❌ SSH key not found at $LOCAL_KEY"
    echo "Please run: ssh-keygen -t ed25519 -f $LOCAL_KEY -N '' -C 'mcp-proxy-access'"
    exit 1
fi

# Copy SSH key to Docker host
echo "📋 Copying SSH key to Docker host..."
ssh-copy-id -i "$LOCAL_KEY" "$DOCKER_USER@$DOCKER_HOST" || {
    echo "⚠️  SSH key copy failed. You may need to manually add the key."
    echo "Public key content:"
    cat "$LOCAL_KEY.pub"
    echo ""
    echo "Add this to ~/.ssh/authorized_keys on $DOCKER_HOST"
}

# Create proxy directory on Docker host
echo "📁 Creating proxy directory on Docker host..."
ssh -i "$LOCAL_KEY" "$DOCKER_USER@$DOCKER_HOST" "mkdir -p $PROXY_DIR"

# Install Node.js dependencies on Docker host
echo "📦 Installing Node.js dependencies on Docker host..."
ssh -i "$LOCAL_KEY" "$DOCKER_USER@$DOCKER_HOST" "cd $PROXY_DIR && npm init -y && npm install node-fetch@3.3.2 eventsource@2.0.2"

# Copy proxy scripts to Docker host
echo "📤 Copying proxy scripts to Docker host..."
scp -i "$LOCAL_KEY" *.js "$DOCKER_USER@$DOCKER_HOST:$PROXY_DIR/"

# Make scripts executable on Docker host
echo "🔧 Making scripts executable on Docker host..."
ssh -i "$LOCAL_KEY" "$DOCKER_USER@$DOCKER_HOST" "chmod +x $PROXY_DIR/*.js"

# Test SSH connection
echo "🧪 Testing SSH connection..."
if ssh -i "$LOCAL_KEY" "$DOCKER_USER@$DOCKER_HOST" "echo 'SSH connection successful'"; then
    echo "✅ SSH connection test passed"
else
    echo "❌ SSH connection test failed"
    exit 1
fi

# Update SSH config for easier access
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host mcp-proxy" "$SSH_CONFIG" 2>/dev/null; then
    echo "🔧 Adding SSH config entry..."
    cat >> "$SSH_CONFIG" << EOF

# MCP Proxy Host
Host mcp-proxy
    HostName $DOCKER_HOST
    User $DOCKER_USER
    IdentityFile $LOCAL_KEY
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
fi

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Restart VS Code to load new Augment settings"
echo "2. Test MCP servers in Augment Code"
echo "3. Both Roo Code and Augment Code should now access the same centralized MCP servers"
echo ""
echo "🔧 SSH connection details:"
echo "   Host: $DOCKER_HOST"
echo "   User: $DOCKER_USER"
echo "   Key: $LOCAL_KEY"
echo "   Proxy scripts: $PROXY_DIR"
echo ""
echo "🧪 Test command:"
echo "   ssh -i $LOCAL_KEY $DOCKER_USER@$DOCKER_HOST 'ls -la $PROXY_DIR'"
