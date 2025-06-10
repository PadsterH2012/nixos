# MCP Server Configuration
# Centralized MCP server definitions for all AI agents

{ config, pkgs, ... }:

{
  # MCP server packages
  environment.systemPackages = with pkgs; [
    # MCP remote client
    nodePackages.npm
    nodejs
  ];

  # MCP server configuration files for all AI agents
  system.activationScripts.mcp-server-configs = ''
    # Create MCP configuration directories
    mkdir -p /home/paddy/.config/augment
    mkdir -p /home/paddy/.config/claude-desktop
    mkdir -p /home/paddy/.config/cline
    mkdir -p /home/paddy/.var/app/com.visualstudio.code/config/Code/User
    mkdir -p /home/paddy/.config/Code/User
    
    # Define MCP servers configuration
    MCP_CONFIG='{
      "mcpServers": {
        "central-proxmox": {
          "command": "npx",
          "args": [
            "-y",
            "mcp-remote",
            "http://10.202.28.111:9090/proxmox-mcp/sse",
            "--allow-http"
          ]
        },
        "neo-mcp-proxy-control": {
          "command": "npx",
          "args": [
            "-y",
            "mcp-remote",
            "http://10.202.28.182:3000/mcp-proxy/sse",
            "--allow-http"
          ]
        },
        "memory-mcp": {
          "command": "npx",
          "args": [
            "-y",
            "@modelcontextprotocol/server-memory"
          ]
        },
        "filesystem-mcp": {
          "command": "npx",
          "args": [
            "-y",
            "@modelcontextprotocol/server-filesystem",
            "/home/paddy",
            "/mnt/network_repo"
          ]
        },
        "brave-search": {
          "command": "npx",
          "args": [
            "-y",
            "@modelcontextprotocol/server-brave-search"
          ],
          "env": {
            "BRAVE_API_KEY": "your-brave-api-key-here"
          }
        }
      }
    }'
    
    # Augment Code MCP configuration
    echo "$MCP_CONFIG" > /home/paddy/.config/augment/mcp-servers.json
    
    # Claude Desktop MCP configuration
    echo "$MCP_CONFIG" > /home/paddy/.config/claude-desktop/claude_desktop_config.json
    
    # Cline MCP configuration
    echo "$MCP_CONFIG" > /home/paddy/.config/cline/mcp-servers.json
    
    # VS Code Flatpak MCP configuration
    echo "$MCP_CONFIG" > /home/paddy/.var/app/com.visualstudio.code/config/Code/User/mcp-servers.json
    
    # VS Code Native MCP configuration
    echo "$MCP_CONFIG" > /home/paddy/.config/Code/User/mcp-servers.json
    
    # Create MCP test script
    cat > /home/paddy/.local/bin/test-mcp-servers << 'EOF'
#!/bin/bash
echo "🧪 Testing MCP Server Connections..."

echo "📡 Testing Proxmox MCP..."
if curl -s --connect-timeout 5 http://10.202.28.111:9090/proxmox-mcp/health >/dev/null 2>&1; then
    echo "✅ Proxmox MCP: Available"
else
    echo "❌ Proxmox MCP: Not available"
fi

echo "📡 Testing MCP Proxy Control..."
if curl -s --connect-timeout 5 http://10.202.28.182:3000/mcp-proxy/health >/dev/null 2>&1; then
    echo "✅ MCP Proxy Control: Available"
else
    echo "❌ MCP Proxy Control: Not available"
fi

echo "📦 Testing NPX MCP packages..."
if npx --version >/dev/null 2>&1; then
    echo "✅ NPX: Available"
    echo "📋 Available MCP packages:"
    echo "  - @modelcontextprotocol/server-memory"
    echo "  - @modelcontextprotocol/server-filesystem"
    echo "  - @modelcontextprotocol/server-brave-search"
    echo "  - mcp-remote"
else
    echo "❌ NPX: Not available"
fi

echo ""
echo "📁 MCP Configuration Files:"
echo "  - Augment: ~/.config/augment/mcp-servers.json"
echo "  - Claude: ~/.config/claude-desktop/claude_desktop_config.json"
echo "  - Cline: ~/.config/cline/mcp-servers.json"
echo "  - VS Code: ~/.var/app/com.visualstudio.code/config/Code/User/mcp-servers.json"
EOF

    chmod +x /home/paddy/.local/bin/test-mcp-servers
    
    # Set proper ownership
    chown -R paddy:users /home/paddy/.config/augment 2>/dev/null || true
    chown -R paddy:users /home/paddy/.config/claude-desktop 2>/dev/null || true
    chown -R paddy:users /home/paddy/.config/cline 2>/dev/null || true
    chown -R paddy:users /home/paddy/.config/Code 2>/dev/null || true
    chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/config 2>/dev/null || true
    chown paddy:users /home/paddy/.local/bin/test-mcp-servers 2>/dev/null || true
    
    echo "✅ MCP server configurations created for all AI agents"
    echo "🧪 Run 'test-mcp-servers' to verify MCP connectivity"
  '';

  # Shell aliases for MCP management
  environment.shellAliases = {
    mcp-test = "test-mcp-servers";
    mcp-config = "cat ~/.config/augment/mcp-servers.json | jq .";
    mcp-proxmox = "curl -s http://10.202.28.111:9090/proxmox-mcp/health";
    mcp-proxy = "curl -s http://10.202.28.182:3000/mcp-proxy/health";
  };

  # Environment variables for MCP
  environment.variables = {
    MCP_CONFIG_DIR = "/home/paddy/.config";
    MCP_PROXMOX_URL = "http://10.202.28.111:9090/proxmox-mcp/sse";
    MCP_PROXY_URL = "http://10.202.28.182:3000/mcp-proxy/sse";
  };
}
