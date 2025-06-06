# Augment Code Settings Configuration for NixOS
# Captures and preserves Augment Code extension settings and MCP integration

{ config, pkgs, ... }:

{
  # Create Augment Code settings preservation script
  environment.etc."vscode/backup-augment-settings.sh" = {
    text = ''
      #!/bin/bash
      # Backup Augment Code settings from Flatpak VS Code
      
      echo "📦 Backing up Augment Code settings..."
      
      AUGMENT_SOURCE="$HOME/.var/app/com.visualstudio.code/config/Code/User/globalStorage/augment.vscode-augment"
      BACKUP_DIR="$HOME/augment-settings-backup"
      
      if [ -d "$AUGMENT_SOURCE" ]; then
          mkdir -p "$BACKUP_DIR"
          cp -r "$AUGMENT_SOURCE" "$BACKUP_DIR/"
          echo "✅ Augment settings backed up to: $BACKUP_DIR"
          
          # Create a summary of what was backed up
          echo "Backup created on: $(date)" > "$BACKUP_DIR/backup-info.txt"
          echo "Source: $AUGMENT_SOURCE" >> "$BACKUP_DIR/backup-info.txt"
          echo "Contents:" >> "$BACKUP_DIR/backup-info.txt"
          find "$BACKUP_DIR/augment.vscode-augment" -type f >> "$BACKUP_DIR/backup-info.txt"
      else
          echo "❌ No Augment settings found to backup"
      fi
    '';
    mode = "0755";
  };

  # Create Augment Code settings restoration script
  environment.etc."vscode/restore-augment-settings.sh" = {
    text = ''
      #!/bin/bash
      # Restore Augment Code settings to Flatpak VS Code
      
      echo "🔄 Restoring Augment Code settings..."
      
      BACKUP_DIR="$HOME/augment-settings-backup"
      AUGMENT_TARGET="$HOME/.var/app/com.visualstudio.code/config/Code/User/globalStorage"
      
      if [ -d "$BACKUP_DIR/augment.vscode-augment" ]; then
          mkdir -p "$AUGMENT_TARGET"
          cp -r "$BACKUP_DIR/augment.vscode-augment" "$AUGMENT_TARGET/"
          echo "✅ Augment settings restored"
          echo "Target: $AUGMENT_TARGET/augment.vscode-augment"
      else
          echo "❌ No Augment backup found at: $BACKUP_DIR"
          echo "Run backup script first or configure Augment manually"
      fi
    '';
    mode = "0755";
  };

  # Create Augment + MCP integration setup script
  environment.etc."vscode/setup-augment-mcp.sh" = {
    text = ''
      #!/bin/bash
      # Complete Augment Code + MCP setup for VS Code
      
      echo "🚀 Setting up Augment Code with MCP integration..."
      echo ""
      
      # Color codes
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      YELLOW='\033[1;33m'
      NC='\033[0m'
      
      # Ensure VS Code config directory exists
      VSCODE_CONFIG="$HOME/.var/app/com.visualstudio.code/config/Code/User"
      mkdir -p "$VSCODE_CONFIG"
      
      # 1. Setup MCP servers globally
      echo -e "''${BLUE}📡 Setting up MCP servers...''${NC}"
      if [ -f /etc/vscode/setup-global-mcp.sh ]; then
          /etc/vscode/setup-global-mcp.sh
      else
          echo -e "''${YELLOW}⚠️  Warning''${NC}: MCP setup script not found"
      fi
      
      # 2. Create VS Code user settings with Augment preferences
      echo -e "''${BLUE}⚙️  Creating user settings...''${NC}"
      cat > "$VSCODE_CONFIG/settings.json" << 'EOF'
{
  "editor.fontSize": 14,
  "editor.fontFamily": "'Source Code Pro', 'Droid Sans Mono', monospace",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.wordWrap": "on",
  "editor.minimap.enabled": true,
  "workbench.colorTheme": "Dark+ (default dark)",
  "workbench.iconTheme": "vs-seti",
  "terminal.integrated.fontSize": 14,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "augment.enableTelemetry": false,
  "augment.enableAnalytics": false,
  "augment.autoIndex": true,
  "augment.mcpServers": {
    "central-obsidian": {
      "url": "http://10.202.28.111:9090/obsidian-mcp-tools/sse"
    },
    "central-rpg": {
      "url": "http://10.202.28.111:9090/rpg-tools/sse"
    },
    "central-search": {
      "url": "http://10.202.28.111:9090/brave-search/sse"
    },
    "central-memory": {
      "url": "http://10.202.28.111:9090/memory/sse"
    },
    "central-mongodb": {
      "url": "http://10.202.28.111:9090/mongodb/sse"
    },
    "central-context7": {
      "url": "http://10.202.28.111:9090/Context7/sse"
    },
    "central-jenkins": {
      "url": "http://10.202.28.111:9090/jenkins-mcp/sse"
    }
  }
}
EOF
      
      # 3. Restore Augment settings if backup exists
      echo -e "''${BLUE}🔄 Checking for Augment settings backup...''${NC}"
      if [ -f /etc/vscode/restore-augment-settings.sh ]; then
          /etc/vscode/restore-augment-settings.sh
      fi
      
      # 4. Create workspace template with MCP
      echo -e "''${BLUE}📋 Creating workspace template...''${NC}"
      mkdir -p "$HOME/workspace-template/.vscode"
      cp /etc/vscode/mcp.json "$HOME/workspace-template/.vscode/mcp.json" 2>/dev/null || echo "MCP template not found"
      
      echo ""
      echo -e "''${GREEN}✅ Augment Code + MCP setup complete!''${NC}"
      echo ""
      echo "📋 CONFIGURATION SUMMARY:"
      echo "========================"
      echo "• User settings: $VSCODE_CONFIG/settings.json"
      echo "• MCP config: $VSCODE_CONFIG/mcp.json"
      echo "• Augment storage: $VSCODE_CONFIG/globalStorage/augment.vscode-augment/"
      echo "• Workspace template: $HOME/workspace-template/"
      echo ""
      echo "🚀 NEXT STEPS:"
      echo "1. Launch VS Code: flatpak run com.visualstudio.code"
      echo "2. Sign in to Augment Code (OAuth should work)"
      echo "3. MCP servers will be automatically available"
      echo "4. Use agent mode to access MCP tools"
    '';
    mode = "0755";
  };

  # Create Augment Code configuration documentation
  environment.etc."vscode/augment-config-info.md" = {
    text = ''
      # Augment Code Configuration
      
      ## Overview
      This configuration preserves Augment Code settings and integrates with centralized MCP servers.
      
      ## Settings Locations
      
      ### Flatpak VS Code Augment Settings
      - **Global Storage**: `~/.var/app/com.visualstudio.code/config/Code/User/globalStorage/augment.vscode-augment/`
      - **User Settings**: `~/.var/app/com.visualstudio.code/config/Code/User/settings.json`
      - **MCP Config**: `~/.var/app/com.visualstudio.code/config/Code/User/mcp.json`
      
      ## Captured Settings Structure
      
      ### Task Storage
      - Agent edit manifests
      - Conversation tasks and history
      - Task state management
      
      ### User Assets
      - Agent edits storage
      - Task storage with UUIDs
      - Conversation metadata
      
      ## MCP Integration
      
      ### Configured Servers
      All 7 centralized MCP servers are automatically configured:
      - Obsidian, RPG Tools, Search, Memory, MongoDB, Context7, Jenkins
      
      ### Settings Integration
      MCP servers are configured in both:
      - Global VS Code settings (`augment.mcpServers`)
      - Workspace-specific `.vscode/mcp.json`
      
      ## Setup Scripts
      
      ### Complete Setup
      ```bash
      /etc/vscode/setup-augment-mcp.sh
      ```
      
      ### Backup Current Settings
      ```bash
      /etc/vscode/backup-augment-settings.sh
      ```
      
      ### Restore Settings
      ```bash
      /etc/vscode/restore-augment-settings.sh
      ```
      
      ## OAuth Authentication
      
      - OAuth is working with Flatpak VS Code
      - Authentication tokens stored in keyring
      - MCP servers accessible after authentication
      
      ## Usage
      
      1. **Install extensions** via setup script
      2. **Configure MCP servers** automatically
      3. **Sign in to Augment** (OAuth working)
      4. **Use agent mode** with MCP tools
      5. **Access all 7 MCP servers** through natural language
      
      ## Troubleshooting
      
      - Ensure MCP proxy (10.202.28.111:9090) is accessible
      - Check Augment settings panel for MCP server status
      - Verify OAuth authentication is working
      - Restart VS Code after configuration changes
    '';
    mode = "0644";
  };
}
