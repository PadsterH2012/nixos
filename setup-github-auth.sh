#!/bin/bash

# GitHub Authentication Setup for NixOS Export
# Helps set up Personal Access Token for private repository access

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
    echo -e "${PURPLE}║           ${BLUE}GitHub Auth Setup v$VERSION${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

main() {
    print_header
    
    echo -e "${CYAN}Setting up GitHub authentication for NixOS config export...${NC}"
    echo
    
    echo -e "${BLUE}📋 What you need:${NC}"
    echo -e "   1. GitHub Personal Access Token (PAT)"
    echo -e "   2. Repository access permissions"
    echo
    
    echo -e "${BLUE}🔑 Creating a Personal Access Token:${NC}"
    echo -e "   1. Go to: ${CYAN}https://github.com/settings/tokens${NC}"
    echo -e "   2. Click 'Generate new token' → 'Generate new token (classic)'"
    echo -e "   3. Set expiration (recommend 90 days or no expiration)"
    echo -e "   4. Select scopes:"
    echo -e "      ✅ ${GREEN}repo${NC} (Full control of private repositories)"
    echo -e "      ✅ ${GREEN}workflow${NC} (Update GitHub Action workflows)"
    echo -e "   5. Click 'Generate token'"
    echo -e "   6. ${YELLOW}Copy the token immediately${NC} (you won't see it again!)"
    echo
    
    echo -e "${BLUE}💾 Setting up the token:${NC}"
    echo
    echo -e "${YELLOW}Option 1: Environment Variable (Recommended)${NC}"
    echo -e "Add to your shell profile (~/.bashrc, ~/.zshrc):"
    echo -e "${CYAN}export GITHUB_TOKEN='ghp_your_token_here'${NC}"
    echo
    echo -e "${YELLOW}Option 2: One-time use${NC}"
    echo -e "Run export command with token:"
    echo -e "${CYAN}GITHUB_TOKEN='ghp_your_token_here' curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash${NC}"
    echo
    
    echo -e "${BLUE}🧪 Testing authentication:${NC}"
    if [ -n "$GITHUB_TOKEN" ]; then
        echo -e "   ${GREEN}✅ GITHUB_TOKEN is set${NC}"
        echo -e "   Token: ${GITHUB_TOKEN:0:8}...${GITHUB_TOKEN: -4}"
        
        # Test token validity
        echo -e "   ${BLUE}Testing token access...${NC}"
        if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q '"login"'; then
            local username=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
            echo -e "   ${GREEN}✅ Token is valid for user: $username${NC}"
        else
            echo -e "   ${RED}❌ Token appears to be invalid${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠️  GITHUB_TOKEN not set${NC}"
        echo -e "   Set it with: ${CYAN}export GITHUB_TOKEN='your_token'${NC}"
    fi
    echo
    
    echo -e "${BLUE}🚀 Ready to export:${NC}"
    echo -e "Once your token is set, run:"
    echo -e "${CYAN}curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash${NC}"
    echo
    
    echo -e "${BLUE}🔒 Security Notes:${NC}"
    echo -e "   • Keep your token secure (treat it like a password)"
    echo -e "   • Don't share it in scripts or logs"
    echo -e "   • Regenerate if compromised"
    echo -e "   • Use environment variables, not hardcoded values"
    echo
    
    # Interactive token setup
    echo -e "${YELLOW}Would you like to set the token now? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Enter your GitHub Personal Access Token:${NC}"
        read -s token
        echo
        
        if [ -n "$token" ]; then
            export GITHUB_TOKEN="$token"
            echo -e "${GREEN}✅ Token set for this session${NC}"
            echo
            echo -e "${BLUE}To make it permanent, add this to your shell profile:${NC}"
            echo -e "${CYAN}export GITHUB_TOKEN='$token'${NC}"
            echo
            echo -e "${BLUE}Test the export now? (y/N)${NC}"
            read -r test_response
            if [[ "$test_response" =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}Running export script...${NC}"
                curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
            fi
        else
            echo -e "${YELLOW}No token entered${NC}"
        fi
    fi
}

main "$@"
