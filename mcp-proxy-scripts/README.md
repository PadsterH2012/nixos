# MCP Proxy Scripts

Bridge your centralized HTTP/SSE MCP servers to command-line interfaces for Augment Code.

## Overview

This solution enables both **Roo Code** and **Augment Code** to access the same centralized MCP servers:

- **Roo Code**: Connects directly to HTTP/SSE endpoints (existing configuration)
- **Augment Code**: Uses SSH-based proxy scripts to access the same servers

## Architecture

```
┌─────────────────────────────────────────┐
│     Docker Host (10.202.28.111)        │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │     HTTP MCP Servers (:9090)       ││
│  │  obsidian, rpg, search, memory...   ││
│  └─────────────────────────────────────┘│
│                    │                    │
│  ┌─────────────────────────────────────┐│
│  │   Proxy Scripts (/opt/mcp-proxies) ││
│  │  Command-line → HTTP bridge        ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
                    │
            ┌───────┴───────┐
            │               │
            ▼               ▼
    ┌─────────────┐  ┌─────────────┐
    │ Dev Machine │  │ Dev Machine │
    │             │  │             │
    │ Roo Code ───┤  │ Roo Code ───┤
    │ (HTTP)      │  │ (HTTP)      │
    │             │  │             │
    │ Augment ────┤  │ Augment ────┤
    │ (SSH+CMD)   │  │ (SSH+CMD)   │
    └─────────────┘  └─────────────┘
```

## Files

### Core Scripts
- `mcp-http-proxy.js` - Generic HTTP-to-command-line bridge
- `package.json` - Node.js dependencies

### Individual Proxy Scripts
- `obsidian-proxy.js` - Obsidian MCP Tools
- `rpg-proxy.js` - RPG Tools
- `brave_search-proxy.js` - Brave Search
- `memory-proxy.js` - Memory/Knowledge Graph
- `mongodb-proxy.js` - MongoDB
- `context7-proxy.js` - Context7 Documentation
- `jenkins_mcp-proxy.js` - Jenkins
- `proxmox_mcp-proxy.js` - Proxmox

### Deployment
- `deploy.sh` - Automated deployment script
- `create-all-proxies.js` - Script generator

## Quick Start

1. **Deploy to Docker Host**:
   ```bash
   ./deploy.sh
   ```

2. **Restart VS Code** to load new Augment settings

3. **Test both extensions**:
   - Roo Code should continue working with existing HTTP configuration
   - Augment Code should now have access to all 8 MCP servers via SSH

## Manual Setup

If you prefer manual setup:

### 1. Copy Scripts to Docker Host
```bash
scp *.js paddy@10.202.28.111:/opt/mcp-proxies/
ssh paddy@10.202.28.111 "chmod +x /opt/mcp-proxies/*.js"
```

### 2. Install Dependencies on Docker Host
```bash
ssh paddy@10.202.28.111 "cd /opt/mcp-proxies && npm install node-fetch@3.3.2 eventsource@2.0.2"
```

### 3. Configure SSH Key Access
```bash
ssh-copy-id -i ~/.ssh/mcp_proxy_key paddy@10.202.28.111
```

## Configuration Files

### Roo Code (Existing)
Location: `~/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json`

```json
{
  "mcpServers": {
    "central-obsidian": {
      "type": "sse",
      "url": "http://10.202.28.111:9090/obsidian-mcp-tools/sse"
    }
  }
}
```

### Augment Code (New)
Location: `~/.vscode-server/data/User/settings.json`

```json
{
  "augment.advanced": {
    "mcpServers": [
      {
        "name": "central-obsidian",
        "command": "ssh",
        "args": [
          "paddy@10.202.28.111",
          "node",
          "/opt/mcp-proxies/obsidian-proxy.js"
        ]
      }
    ]
  }
}
```

## Troubleshooting

### SSH Connection Issues
```bash
# Test SSH connection
ssh -i ~/.ssh/mcp_proxy_key paddy@10.202.28.111 "echo 'Connection successful'"

# Check proxy scripts
ssh -i ~/.ssh/mcp_proxy_key paddy@10.202.28.111 "ls -la /opt/mcp-proxies"
```

### MCP Server Issues
```bash
# Test individual proxy
ssh paddy@10.202.28.111 "cd /opt/mcp-proxies && node obsidian-proxy.js"

# Check HTTP MCP servers
curl http://10.202.28.111:9090/obsidian-mcp-tools/sse
```

### VS Code Issues
1. Restart VS Code completely
2. Check Augment settings panel for MCP servers
3. Look for error messages in VS Code Developer Console

## Benefits

- ✅ **Centralized**: Single set of MCP servers for all dev machines
- ✅ **Dual Access**: Both Roo Code and Augment Code work
- ✅ **Scalable**: Easy to add new dev machines
- ✅ **Maintainable**: One infrastructure, multiple access methods
- ✅ **Secure**: SSH-based authentication

## Next Steps

1. Add to NixOS configuration for automatic deployment
2. Monitor performance and optimize if needed
3. Consider adding health checks and monitoring
4. Document team onboarding process
