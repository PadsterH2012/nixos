#!/bin/bash

# Apply Augment MCP Settings to Current VS Code Instance
# This script adds MCP server configuration to Augment Code settings

set -e

echo "🔧 Applying Augment MCP Settings to Current VS Code"
echo "=================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if Flatpak VS Code is available
if ! flatpak list | grep -q com.visualstudio.code; then
    print_status "FAIL" "Flatpak VS Code not installed"
    exit 1
fi

print_status "PASS" "Flatpak VS Code found"

# Define settings file location
SETTINGS_FILE="$HOME/.var/app/com.visualstudio.code/config/Code/User/settings.json"
SETTINGS_DIR="$(dirname "$SETTINGS_FILE")"

# Create settings directory if it doesn't exist
mkdir -p "$SETTINGS_DIR"

# Check if settings.json exists
if [ -f "$SETTINGS_FILE" ]; then
    print_status "INFO" "Existing settings.json found, creating backup..."
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    print_status "PASS" "Backup created"
else
    print_status "INFO" "No existing settings.json, creating new one"
fi

# Create the settings.json with Augment MCP configuration
print_status "INFO" "Creating settings.json with Augment MCP servers..."

cat > "$SETTINGS_FILE" << 'EOF'
{
  "editor.fontSize": 14,
  "editor.fontFamily": "'Source Code Pro', 'Droid Sans Mono', monospace",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.wordWrap": "on",
  "editor.minimap.enabled": true,
  "editor.rulers": [80, 120],
  "workbench.colorTheme": "Dark+ (default dark)",
  "workbench.iconTheme": "vs-seti",
  "workbench.startupEditor": "newUntitledFile",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.cursorBlinking": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "git.autofetch": true,
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

print_status "PASS" "Settings.json created with Augment MCP configuration"

# Set proper permissions
chmod 644 "$SETTINGS_FILE"

print_status "INFO" "Configuration applied successfully!"
echo ""
echo "📋 CONFIGURATION SUMMARY"
echo "========================"
echo "Settings file: $SETTINGS_FILE"
echo ""
echo "🔧 CONFIGURED MCP SERVERS:"
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
echo "🚀 NEXT STEPS:"
echo "1. Restart VS Code: flatpak run com.visualstudio.code"
echo "2. Open Augment settings panel (gear icon)"
echo "3. Verify MCP servers are detected"
echo "4. Test MCP functionality in agent mode"
echo ""
echo "💡 TIP: MCP servers should now appear in Augment's settings panel"
echo "      and be available for use in agent mode conversations."
echo ""
print_status "PASS" "Augment MCP configuration complete!"
