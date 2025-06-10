#!/bin/bash

# Setup NixOS Export Authentication
# Creates .nixos-export-config file for hands-off operation

VERSION="1.0.0"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║           ${BLUE}NixOS Export Auth Setup v$VERSION${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

main() {
    print_header
    
    echo -e "${CYAN}Setting up hands-off authentication for NixOS config export...${NC}"
    echo
    
    # Check if config already exists
    if [ -f "$HOME/.nixos-export-config" ]; then
        echo -e "${YELLOW}⚠️  Config file already exists: $HOME/.nixos-export-config${NC}"
        echo -e "${INFO} Would you like to update it? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Keeping existing configuration"
            exit 0
        fi
    fi
    
    echo -e "${BLUE}📋 You need a GitHub Personal Access Token (PAT)${NC}"
    echo
    echo -e "${BLUE}🔑 To create one:${NC}"
    echo -e "   1. Go to: ${CYAN}https://github.com/settings/tokens${NC}"
    echo -e "   2. Click 'Generate new token (classic)'"
    echo -e "   3. Select scopes: ${GREEN}repo${NC} (full control of private repositories)"
    echo -e "   4. Copy the token (starts with ghp_)"
    echo
    
    echo -e "${BLUE}Enter your GitHub Personal Access Token:${NC}"
    read -s token
    echo
    
    if [ -z "$token" ]; then
        echo -e "${RED}❌ No token provided${NC}"
        exit 1
    fi
    
    # Validate token format
    if [[ ! "$token" =~ ^ghp_[a-zA-Z0-9]{36}$ ]]; then
        echo -e "${YELLOW}⚠️  Token format looks unusual (expected ghp_...)${NC}"
        echo -e "${INFO} Continue anyway? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Setup cancelled"
            exit 1
        fi
    fi
    
    # Create config file
    cat > "$HOME/.nixos-export-config" << EOF
# NixOS Export Configuration
# Auto-generated on $(date)
# Keep this file secure - it contains your GitHub token

export GITHUB_USERNAME="PadsterH2012"
export GITHUB_TOKEN="$token"
EOF
    
    # Set secure permissions
    chmod 600 "$HOME/.nixos-export-config"
    
    echo -e "${GREEN}✅ Configuration saved to: $HOME/.nixos-export-config${NC}"
    echo -e "${GREEN}✅ File permissions set to 600 (owner read/write only)${NC}"
    echo
    
    # Test the token
    echo -e "${BLUE}🧪 Testing token...${NC}"
    if curl -s -H "Authorization: token $token" https://api.github.com/user | grep -q '"login"'; then
        local username=$(curl -s -H "Authorization: token $token" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
        echo -e "${GREEN}✅ Token is valid for user: $username${NC}"
    else
        echo -e "${RED}❌ Token appears to be invalid${NC}"
        echo -e "${INFO} You may need to check the token or try again"
    fi
    echo
    
    echo -e "${BLUE}🚀 Ready for hands-off export!${NC}"
    echo -e "${INFO} Now you can run the export script without any prompts:"
    echo -e "${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash${NC}"
    echo
    
    echo -e "${BLUE}📋 To deploy this config to other machines:${NC}"
    echo -e "${CYAN}# Copy the config file to other machines${NC}"
    echo -e "${CYAN}scp ~/.nixos-export-config user@other-machine:~/${NC}"
    echo
    echo -e "${CYAN}# Or create it directly on each machine${NC}"
    echo -e "${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/setup-nixos-export-auth.sh | bash${NC}"
    echo
    
    echo -e "${BLUE}🔒 Security reminder:${NC}"
    echo -e "   • Keep this token secure"
    echo -e "   • Don't share the .nixos-export-config file"
    echo -e "   • Regenerate the token if compromised"
    echo
    
    # Offer to test export now
    echo -e "${YELLOW}Would you like to test the export now? (y/N)${NC}"
    read -r test_response
    if [[ "$test_response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Running export test...${NC}"
        echo
        source "$HOME/.nixos-export-config"
        curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
    fi
}

main "$@"
