#!/bin/bash

# Test VS Code Flatpak Development Access
# Run this script from within VS Code terminal to test permissions

echo "🧪 Testing VS Code Flatpak Development Access"
echo "============================================="
echo

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "   ${GREEN}✅ PASS${NC}"
    else
        echo -e "   ${RED}❌ FAIL${NC}"
    fi
}

echo -e "${BLUE}1. Testing Filesystem Access${NC}"
echo -n "   📁 Can access /nix/store: "
ls /nix/store >/dev/null 2>&1
test_result $?

echo -n "   📁 Can access host filesystem: "
ls /home >/dev/null 2>&1
test_result $?

echo -n "   📁 Can write to /tmp: "
touch /tmp/vscode-test-$$
test_result $?
rm -f /tmp/vscode-test-$$ 2>/dev/null

echo
echo -e "${BLUE}2. Testing Node.js Access${NC}"
echo -n "   📦 Node.js available: "
node --version >/dev/null 2>&1
test_result $?

echo -n "   📦 npm available: "
npm --version >/dev/null 2>&1
test_result $?

echo -n "   📦 npx available: "
npx --version >/dev/null 2>&1
test_result $?

if command -v node >/dev/null 2>&1; then
    echo "   📍 Node.js location: $(which node)"
    echo "   📍 Node.js version: $(node --version)"
fi

echo
echo -e "${BLUE}3. Testing Development Tools${NC}"
echo -n "   🔧 Git available: "
git --version >/dev/null 2>&1
test_result $?

echo -n "   🐳 Docker accessible: "
docker ps >/dev/null 2>&1
test_result $?

echo -n "   🐍 Python available: "
python3 --version >/dev/null 2>&1
test_result $?

echo
echo -e "${BLUE}4. Testing Environment${NC}"
echo "   🌍 PATH: $PATH"
echo "   🌍 NODE_PATH: ${NODE_PATH:-'(not set)'}"
echo "   🌍 FLATPAK_ID: ${FLATPAK_ID:-'(not set)'}"

echo
echo -e "${BLUE}5. Testing Network Access${NC}"
echo -n "   🌐 Internet connectivity: "
ping -c 1 8.8.8.8 >/dev/null 2>&1
test_result $?

echo -n "   🌐 GitHub connectivity: "
ping -c 1 github.com >/dev/null 2>&1
test_result $?

echo
echo -e "${BLUE}6. Testing MCP Requirements${NC}"
echo -n "   🤖 Can run npx commands: "
npx --help >/dev/null 2>&1
test_result $?

if command -v npx >/dev/null 2>&1; then
    echo "   💡 MCP server test command:"
    echo "      npx -y @upstash/context7-mcp@latest"
fi

echo
echo -e "${YELLOW}📋 Summary${NC}"
echo "=========="

if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Development environment is ready!${NC}"
    echo "   • Node.js and npm are accessible"
    echo "   • MCP servers should work"
    echo "   • Full development capabilities available"
else
    echo -e "${RED}❌ Development environment needs setup${NC}"
    echo "   • Run setup script from host system:"
    echo "     ./dev-02/setup-vscode-dev-permissions.sh"
    echo "   • Or use system command: setup-vscode-dev"
fi

echo
echo -e "${BLUE}🔧 If tests fail, run from host system:${NC}"
echo "   ./dev-02/setup-vscode-dev-permissions.sh"
echo
echo -e "${BLUE}🔄 Then restart VS Code:${NC}"
echo "   flatpak kill com.visualstudio.code"
echo "   flatpak run com.visualstudio.code"
