# MCP Server Configuration for VS Code
# Centralized MCP servers via proxy at 10.202.28.111:9090

{ config, pkgs, ... }:

{
  # Create global MCP configuration template
  environment.etc."vscode/mcp.json" = {
    text = builtins.toJSON {
      mcpServers = {
        central-obsidian = {
          url = "http://10.202.28.111:9090/obsidian-mcp-tools/sse";
        };
        central-rpg = {
          url = "http://10.202.28.111:9090/rpg-tools/sse";
        };
        central-search = {
          url = "http://10.202.28.111:9090/brave-search/sse";
        };
        central-memory = {
          url = "http://10.202.28.111:9090/memory/sse";
        };
        central-mongodb = {
          url = "http://10.202.28.111:9090/mongodb/sse";
        };
        central-context7 = {
          url = "http://10.202.28.111:9090/Context7/sse";
        };
        central-jenkins = {
          url = "http://10.202.28.111:9090/jenkins-mcp/sse";
        };
      };
    };
    mode = "0644";
  };

  # Create workspace template with MCP configuration
  environment.etc."vscode/workspace-mcp-template.code-workspace" = {
    text = builtins.toJSON {
      folders = [
        {
          path = ".";
        }
      ];
      settings = {
        # Workspace-specific settings
        "files.exclude" = {
          "**/.git" = true;
          "**/.DS_Store" = true;
          "**/node_modules" = true;
          "**/__pycache__" = true;
        };
      };
      extensions = {
        recommendations = [
          "augment.vscode-augment"
          "github.copilot"
          "github.copilot-chat"
          "ms-python.python"
          "bbenoist.nix"
        ];
      };
    };
    mode = "0644";
  };

  # Create MCP setup script for users
  environment.etc."vscode/setup-mcp-servers.sh" = {
    text = ''
      #!/bin/bash
      # MCP Server Setup Script for VS Code Workspaces
      
      echo "🔧 Setting up MCP servers for VS Code workspace..."
      echo ""
      
      # Color codes
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      YELLOW='\033[1;33m'
      NC='\033[0m'
      
      # Check if we're in a workspace directory
      if [ ! -d ".vscode" ]; then
          echo -e "''${BLUE}ℹ️  INFO''${NC}: Creating .vscode directory..."
          mkdir -p .vscode
      fi
      
      # Copy MCP configuration to workspace
      echo -e "''${BLUE}📋 Copying''${NC}: MCP configuration to workspace..."
      cp /etc/vscode/mcp.json .vscode/mcp.json
      
      # Set proper permissions
      chmod 644 .vscode/mcp.json
      
      echo -e "''${GREEN}✅ SUCCESS''${NC}: MCP servers configured for this workspace"
      echo ""
      echo "📡 CONFIGURED MCP SERVERS:"
      echo "========================="
      echo "• central-obsidian  - Obsidian notes management"
      echo "• central-rpg       - RPG tools and monsters"
      echo "• central-search    - Brave web search"
      echo "• central-memory    - Knowledge graph memory"
      echo "• central-mongodb   - MongoDB operations"
      echo "• central-context7  - Code context engine"
      echo "• central-jenkins   - Jenkins CI/CD"
      echo ""
      echo "🌐 Proxy Server: 10.202.28.111:9090"
      echo ""
      echo "🚀 USAGE:"
      echo "1. Open VS Code in this workspace"
      echo "2. Use Augment Code with MCP server tools"
      echo "3. MCP servers are automatically available"
      echo ""
      echo -e "''${YELLOW}💡 TIP''${NC}: MCP configuration is in .vscode/mcp.json"
    '';
    mode = "0755";
  };

  # Create global MCP setup script for all workspaces
  environment.etc."vscode/setup-global-mcp.sh" = {
    text = ''
      #!/bin/bash
      # Global MCP Setup Script - applies to all VS Code workspaces
      
      echo "🌐 Setting up global MCP configuration..."
      echo ""
      
      # Color codes
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      RED='\033[0;31m'
      NC='\033[0m'
      
      # Check if Flatpak VS Code is installed
      if ! flatpak list | grep -q com.visualstudio.code; then
          echo -e "''${RED}❌ ERROR''${NC}: Flatpak VS Code not installed"
          echo "Please install it first: flatpak install flathub com.visualstudio.code"
          exit 1
      fi
      
      # Create VS Code config directory in Flatpak sandbox
      VSCODE_CONFIG_DIR="$HOME/.var/app/com.visualstudio.code/config/Code/User"
      mkdir -p "$VSCODE_CONFIG_DIR"
      
      # Copy MCP configuration to VS Code user directory
      echo -e "''${BLUE}📋 Installing''${NC}: Global MCP configuration..."
      cp /etc/vscode/mcp.json "$VSCODE_CONFIG_DIR/mcp.json"
      
      # Set proper permissions
      chmod 644 "$VSCODE_CONFIG_DIR/mcp.json"
      
      echo -e "''${GREEN}✅ SUCCESS''${NC}: Global MCP configuration installed"
      echo ""
      echo "📍 Configuration Location:"
      echo "$VSCODE_CONFIG_DIR/mcp.json"
      echo ""
      echo "🔄 Restart VS Code to apply changes"
    '';
    mode = "0755";
  };

  # Create MCP server documentation
  environment.etc."vscode/mcp-servers-info.md" = {
    text = ''
      # MCP Servers Configuration
      
      ## Overview
      This configuration connects VS Code to centralized MCP servers via proxy at `10.202.28.111:9090`.
      
      ## Available MCP Servers
      
      ### 🗒️ central-obsidian
      - **URL**: http://10.202.28.111:9090/obsidian-mcp-tools/sse
      - **Purpose**: Obsidian notes management and knowledge base operations
      - **Tools**: Note creation, search, linking, vault management
      
      ### 🎲 central-rpg
      - **URL**: http://10.202.28.111:9090/rpg-tools/sse
      - **Purpose**: RPG tools and monster management
      - **Tools**: Monster database, character management, campaign tools
      
      ### 🔍 central-search
      - **URL**: http://10.202.28.111:9090/brave-search/sse
      - **Purpose**: Web search capabilities via Brave Search API
      - **Tools**: Web search, content retrieval, research assistance
      
      ### 🧠 central-memory
      - **URL**: http://10.202.28.111:9090/memory/sse
      - **Purpose**: Knowledge graph and memory management
      - **Tools**: Entity storage, relationship mapping, context retention
      
      ### 🗄️ central-mongodb
      - **URL**: http://10.202.28.111:9090/mongodb/sse
      - **Purpose**: MongoDB database operations
      - **Tools**: Database queries, document management, collection operations
      
      ### 📚 central-context7
      - **URL**: http://10.202.28.111:9090/Context7/sse
      - **Purpose**: Code context engine and documentation
      - **Tools**: Code analysis, documentation retrieval, context understanding
      
      ### 🔧 central-jenkins
      - **URL**: http://10.202.28.111:9090/jenkins-mcp/sse
      - **Purpose**: Jenkins CI/CD operations
      - **Tools**: Build management, job control, pipeline operations
      
      ## Setup Instructions
      
      ### For Individual Workspaces
      ```bash
      cd your-workspace
      /etc/vscode/setup-mcp-servers.sh
      ```
      
      ### For Global Configuration
      ```bash
      /etc/vscode/setup-global-mcp.sh
      ```
      
      ## Configuration Files
      
      - **Global Template**: `/etc/vscode/mcp.json`
      - **Workspace Config**: `.vscode/mcp.json` (created by setup script)
      - **User Config**: `~/.var/app/com.visualstudio.code/config/Code/User/mcp.json`
      
      ## Usage with Augment Code
      
      1. Open VS Code with Augment Code extension
      2. MCP servers are automatically detected
      3. Use Augment's agent mode to access MCP tools
      4. Tools are available through natural language commands
      
      ## Troubleshooting
      
      - Ensure proxy server (10.202.28.111:9090) is accessible
      - Check network connectivity to MCP proxy
      - Restart VS Code after configuration changes
      - Verify MCP configuration in Augment settings panel
    '';
    mode = "0644";
  };
}
