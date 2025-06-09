#!/bin/bash

# Universal NixOS Development Environment Test Script
# Can be run via: curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash
# Or with options: curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node --docker --all

VERSION="1.0.0"
SCRIPT_NAME="NixOS Dev Environment Tester"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"

# Test flags
TEST_BASIC=false
TEST_NODE=false
TEST_DOCKER=false
TEST_PYTHON=false
TEST_GIT=false
TEST_VSCODE=false
TEST_NETWORK=false
TEST_ALL=false
CHANGE_HOSTNAME=false

# Show interactive menu if no arguments provided
show_menu() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║           ${BLUE}$SCRIPT_NAME v$VERSION${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Select tests to run:${NC}"
    echo
    echo -e "  ${GREEN}1)${NC} ${GEAR} Basic System Information"
    echo -e "  ${GREEN}2)${NC} ${PACKAGE} Node.js Environment (npm, npx)"
    echo -e "  ${GREEN}3)${NC} ${PACKAGE} Docker Environment"
    echo -e "  ${GREEN}4)${NC} ${PACKAGE} Python Environment"
    echo -e "  ${GREEN}5)${NC} ${PACKAGE} Git Environment"
    echo -e "  ${GREEN}6)${NC} ${PACKAGE} VS Code Environment"
    echo -e "  ${GREEN}7)${NC} ${PACKAGE} Network Connectivity"
    echo
    echo -e "  ${CYAN}8)${NC} ${GEAR} Change System Hostname"
    echo
    echo -e "  ${YELLOW}9)${NC} ${ROCKET} Run All Tests"
    echo -e "  ${YELLOW}h)${NC} ${INFO} Show Help"
    echo -e "  ${RED}0)${NC} Exit"
    echo
    echo -ne "${BLUE}Enter your choice [0-9,h]: ${NC}"
}

# Parse command line arguments or show menu
if [[ $# -eq 0 ]]; then
    # Check if we have a TTY for interactive mode
    if [[ ! -t 0 ]]; then
        echo -e "${YELLOW}No interactive terminal detected (running via curl/pipe)${NC}"
        echo -e "${INFO} Running basic system test by default..."
        echo -e "${INFO} For interactive menu, download and run locally:"
        echo -e "   ${CYAN}wget https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh${NC}"
        echo -e "   ${CYAN}chmod +x nixos-dev-test.sh${NC}"
        echo -e "   ${CYAN}./nixos-dev-test.sh${NC}"
        echo
        echo -e "${INFO} Or use command line options:"
        echo -e "   ${CYAN}curl -sSL .../nixos-dev-test.sh | bash -s -- --node${NC}"
        echo -e "   ${CYAN}curl -sSL .../nixos-dev-test.sh | bash -s -- --all${NC}"
        echo
        TEST_BASIC=true
    else
        # Interactive mode
        while true; do
            show_menu
            read -r choice
        case $choice in
            1)
                TEST_BASIC=true
                break
                ;;
            2)
                TEST_NODE=true
                break
                ;;
            3)
                TEST_DOCKER=true
                break
                ;;
            4)
                TEST_PYTHON=true
                break
                ;;
            5)
                TEST_GIT=true
                break
                ;;
            6)
                TEST_VSCODE=true
                break
                ;;
            7)
                TEST_NETWORK=true
                break
                ;;
            8)
                CHANGE_HOSTNAME=true
                break
                ;;
            9)
                TEST_ALL=true
                break
                ;;
            h|H)
                echo
                echo -e "${BLUE}$SCRIPT_NAME v$VERSION${NC}"
                echo
                echo "Usage: $0 [OPTIONS]"
                echo
                echo "Options:"
                echo "  --basic     Test basic system info and NixOS setup"
                echo "  --node      Test Node.js, npm, npx availability"
                echo "  --docker    Test Docker installation and service"
                echo "  --python    Test Python installation"
                echo "  --git       Test Git installation and configuration"
                echo "  --vscode    Test VS Code installation"
                echo "  --network   Test network connectivity"
                echo "  --hostname  Change system hostname"
                echo "  --all       Run all tests"
                echo "  --help      Show this help message"
                echo
                echo "Examples:"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all"
                echo
                echo -ne "${BLUE}Press Enter to continue...${NC}"
                read
                continue
                ;;
            0)
                echo -e "${YELLOW}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select 0-9 or h.${NC}"
                sleep 2
                continue
                ;;
        esac
        done
    fi
else
    # Command line mode
    while [[ $# -gt 0 ]]; do
        case $1 in
            --basic)
                TEST_BASIC=true
                shift
                ;;
            --node|--nodejs)
                TEST_NODE=true
                shift
                ;;
            --docker)
                TEST_DOCKER=true
                shift
                ;;
            --python)
                TEST_PYTHON=true
                shift
                ;;
            --git)
                TEST_GIT=true
                shift
                ;;
            --vscode|--code)
                TEST_VSCODE=true
                shift
                ;;
            --network|--net)
                TEST_NETWORK=true
                shift
                ;;
            --hostname)
                CHANGE_HOSTNAME=true
                shift
                ;;
            --all)
                TEST_ALL=true
                shift
                ;;
            --help|-h)
                echo -e "${BLUE}$SCRIPT_NAME v$VERSION${NC}"
                echo
                echo "Usage: $0 [OPTIONS]"
                echo
                echo "Options:"
                echo "  --basic     Test basic system info and NixOS setup"
                echo "  --node      Test Node.js, npm, npx availability"
                echo "  --docker    Test Docker installation and service"
                echo "  --python    Test Python installation"
                echo "  --git       Test Git installation and configuration"
                echo "  --vscode    Test VS Code installation"
                echo "  --network   Test network connectivity"
                echo "  --hostname  Change system hostname"
                echo "  --all       Run all tests"
                echo "  --help      Show this help message"
                echo
                echo "Examples:"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --hostname"
                echo "  curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
fi

# If --all is specified, enable all tests
if [[ "$TEST_ALL" == "true" ]]; then
    TEST_BASIC=true
    TEST_NODE=true
    TEST_DOCKER=true
    TEST_PYTHON=true
    TEST_GIT=true
    TEST_VSCODE=true
    TEST_NETWORK=true
fi

# Helper functions
print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo
}

print_section() {
    echo -e "${CYAN}$1${NC}"
    echo "$(printf '%.0s-' {1..40})"
}

check_command() {
    local cmd=$1
    local name=${2:-$cmd}
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$(eval "$cmd --version 2>/dev/null | head -1" || echo "Unknown version")
        echo -e "   ${CHECK} $name: $(which $cmd)"
        echo -e "      Version: $version"
        return 0
    else
        echo -e "   ${CROSS} $name: Not found"
        return 1
    fi
}

# Test functions
test_basic() {
    print_section "${GEAR} Basic System Information"
    
    echo -e "   ${INFO} Hostname: $(hostname)"
    echo -e "   ${INFO} User: $(whoami)"
    echo -e "   ${INFO} Shell: $SHELL"
    echo -e "   ${INFO} PWD: $(pwd)"
    echo
    
    # Check if NixOS
    if [ -f /etc/NIXOS ]; then
        echo -e "   ${CHECK} NixOS detected"
        if command -v nixos-version >/dev/null 2>&1; then
            echo -e "      Version: $(nixos-version)"
        fi
    else
        echo -e "   ${WARNING} Not running on NixOS"
    fi
    
    # Check Nix store
    if [ -d /nix/store ]; then
        echo -e "   ${CHECK} Nix store available"
        # Quick size check with timeout to avoid hanging
        local store_size=$(timeout 5s du -sh /nix/store 2>/dev/null | cut -f1 || echo "Large (timeout)")
        echo -e "      Size: $store_size"
    else
        echo -e "   ${CROSS} Nix store not found"
    fi
    
    # Check current PATH
    echo -e "   ${INFO} PATH components:"
    echo "$PATH" | tr ':' '\n' | sed 's/^/      /'
    echo
}

test_node() {
    print_section "${PACKAGE} Node.js Environment"
    
    check_command "node" "Node.js"
    check_command "npm" "npm"
    check_command "npx" "npx"
    
    # Test Node.js execution
    if command -v node >/dev/null 2>&1; then
        echo -e "   ${INFO} Testing Node.js execution:"
        local test_result=$(node -e "console.log('Node.js is working!')" 2>&1)
        if [[ $? -eq 0 ]]; then
            echo -e "      ${CHECK} $test_result"
        else
            echo -e "      ${CROSS} Node.js execution failed: $test_result"
        fi
    fi
    
    # Check NODE_PATH
    echo -e "   ${INFO} NODE_PATH: ${NODE_PATH:-'(not set)'}"
    
    # Find Node.js in Nix store
    if [ -d /nix/store ]; then
        local node_paths=$(find /nix/store -name "node" -type f -executable 2>/dev/null | head -3)
        if [ -n "$node_paths" ]; then
            echo -e "   ${INFO} Node.js installations in Nix store:"
            echo "$node_paths" | sed 's/^/      /'
        fi
    fi
    echo
}

test_docker() {
    print_section "${PACKAGE} Docker Environment"
    
    check_command "docker" "Docker"
    check_command "docker-compose" "Docker Compose"
    
    # Test Docker service
    if command -v docker >/dev/null 2>&1; then
        echo -e "   ${INFO} Testing Docker service:"
        if docker info >/dev/null 2>&1; then
            echo -e "      ${CHECK} Docker daemon is running"
            local containers=$(docker ps -q | wc -l)
            echo -e "      ${INFO} Running containers: $containers"
        else
            echo -e "      ${CROSS} Docker daemon not accessible"
            echo -e "      ${INFO} Try: sudo systemctl start docker"
        fi
    fi
    echo
}

test_python() {
    print_section "${PACKAGE} Python Environment"
    
    check_command "python3" "Python 3"
    check_command "pip" "pip"
    check_command "pip3" "pip3"
    
    # Test Python execution
    if command -v python3 >/dev/null 2>&1; then
        echo -e "   ${INFO} Testing Python execution:"
        local test_result=$(python3 -c "print('Python is working!')" 2>&1)
        if [[ $? -eq 0 ]]; then
            echo -e "      ${CHECK} $test_result"
        else
            echo -e "      ${CROSS} Python execution failed: $test_result"
        fi
    fi
    echo
}

test_git() {
    print_section "${PACKAGE} Git Environment"
    
    check_command "git" "Git"
    
    if command -v git >/dev/null 2>&1; then
        echo -e "   ${INFO} Git configuration:"
        local git_user=$(git config --global user.name 2>/dev/null || echo "(not set)")
        local git_email=$(git config --global user.email 2>/dev/null || echo "(not set)")
        echo -e "      User: $git_user"
        echo -e "      Email: $git_email"
    fi
    echo
}

test_vscode() {
    print_section "${PACKAGE} VS Code Environment"
    
    check_command "code" "VS Code"
    
    # Check for Flatpak VS Code
    if command -v flatpak >/dev/null 2>&1; then
        if flatpak list 2>/dev/null | grep -q "com.visualstudio.code"; then
            echo -e "   ${CHECK} VS Code (Flatpak) installed"
        else
            echo -e "   ${INFO} VS Code (Flatpak) not found"
        fi
    fi
    echo
}

test_network() {
    print_section "${PACKAGE} Network Connectivity"

    # Test basic connectivity
    echo -e "   ${INFO} Testing network connectivity:"

    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "      ${CHECK} Internet connectivity (8.8.8.8)"
    else
        echo -e "      ${CROSS} No internet connectivity"
    fi

    if ping -c 1 github.com >/dev/null 2>&1; then
        echo -e "      ${CHECK} GitHub connectivity"
    else
        echo -e "      ${CROSS} Cannot reach GitHub"
    fi

    # Test specific development server
    if ping -c 1 10.202.28.111 >/dev/null 2>&1; then
        echo -e "      ${CHECK} Development server (10.202.28.111) reachable"
    else
        echo -e "      ${WARNING} Development server (10.202.28.111) not reachable"
    fi
    echo
}

change_hostname() {
    print_section "${GEAR} Change System Hostname"

    local current_hostname=$(hostname)
    echo -e "   ${INFO} Current hostname: ${YELLOW}$current_hostname${NC}"
    echo

    # Check if running on NixOS
    if [ ! -f /etc/NIXOS ]; then
        echo -e "   ${WARNING} This feature is designed for NixOS systems"
        echo -e "   ${INFO} For other systems, use: sudo hostnamectl set-hostname <new-name>"
        echo
        return
    fi

    echo -e "   ${BLUE}Enter new hostname (or press Enter to cancel):${NC}"
    echo -ne "   ${CYAN}New hostname: ${NC}"
    read -r new_hostname

    # Validate input
    if [[ -z "$new_hostname" ]]; then
        echo -e "   ${YELLOW}Hostname change cancelled${NC}"
        echo
        return
    fi

    # Validate hostname format
    if [[ ! "$new_hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
        echo -e "   ${CROSS} Invalid hostname format"
        echo -e "   ${INFO} Hostname must:"
        echo -e "      - Start and end with alphanumeric characters"
        echo -e "      - Contain only letters, numbers, and hyphens"
        echo -e "      - Be 1-63 characters long"
        echo
        return
    fi

    echo
    echo -e "   ${WARNING} This will change your hostname from ${YELLOW}$current_hostname${NC} to ${YELLOW}$new_hostname${NC}"
    echo -e "   ${INFO} Methods available:"
    echo -e "      ${GREEN}1)${NC} Temporary change (until reboot)"
    echo -e "      ${GREEN}2)${NC} Permanent change (requires NixOS rebuild)"
    echo -e "      ${GREEN}3)${NC} Cancel"
    echo
    echo -ne "   ${BLUE}Choose method [1-3]: ${NC}"
    read -r method_choice

    case $method_choice in
        1)
            echo -e "   ${INFO} Applying temporary hostname change..."
            if sudo hostnamectl set-hostname "$new_hostname" 2>/dev/null; then
                echo -e "   ${CHECK} Hostname temporarily changed to: ${GREEN}$new_hostname${NC}"
                echo -e "   ${WARNING} This change will be lost on reboot"
                echo -e "   ${INFO} New hostname will be active in new shell sessions"
            else
                echo -e "   ${CROSS} Failed to change hostname temporarily"
                echo -e "   ${INFO} You may need sudo privileges"
            fi
            ;;
        2)
            echo -e "   ${INFO} For permanent hostname change on NixOS:"
            echo -e "   ${YELLOW}1.${NC} Edit your NixOS configuration:"
            echo -e "      ${CYAN}sudo nano /etc/nixos/configuration.nix${NC}"
            echo -e "   ${YELLOW}2.${NC} Find the line: ${CYAN}networking.hostName = \"...\";${NC}"
            echo -e "   ${YELLOW}3.${NC} Change it to: ${CYAN}networking.hostName = \"$new_hostname\";${NC}"
            echo -e "   ${YELLOW}4.${NC} Rebuild NixOS: ${CYAN}sudo nixos-rebuild switch${NC}"
            echo
            echo -e "   ${INFO} Or if using the dev-02 configuration:"
            echo -e "   ${YELLOW}1.${NC} Edit: ${CYAN}dev-02/nixos/modules/networking.nix${NC}"
            echo -e "   ${YELLOW}2.${NC} Change: ${CYAN}networking.hostName = \"$new_hostname\";${NC}"
            echo -e "   ${YELLOW}3.${NC} Deploy: ${CYAN}cd dev-02 && ./deploy.sh${NC}"
            ;;
        3|*)
            echo -e "   ${YELLOW}Hostname change cancelled${NC}"
            ;;
    esac
    echo
}

# Main execution
print_header "$SCRIPT_NAME v$VERSION"

echo -e "${BLUE}Running tests...${NC}"
echo

# Run selected tests
if [[ "$TEST_BASIC" == "true" ]]; then
    test_basic
fi

if [[ "$TEST_NODE" == "true" ]]; then
    test_node
fi

if [[ "$TEST_DOCKER" == "true" ]]; then
    test_docker
fi

if [[ "$TEST_PYTHON" == "true" ]]; then
    test_python
fi

if [[ "$TEST_GIT" == "true" ]]; then
    test_git
fi

if [[ "$TEST_VSCODE" == "true" ]]; then
    test_vscode
fi

if [[ "$TEST_NETWORK" == "true" ]]; then
    test_network
fi

if [[ "$CHANGE_HOSTNAME" == "true" ]]; then
    change_hostname
fi

# Final summary (only show for tests, not hostname change)
if [[ "$CHANGE_HOSTNAME" == "false" ]]; then
    print_header "${ROCKET} Test Complete!"
else
    print_header "${ROCKET} Hostname Management Complete!"
fi

echo -e "${YELLOW}Quick fixes for common issues:${NC}"
echo
echo -e "${INFO} Node.js not found in scripts:"
echo "   Use full path: /run/current-system/sw/bin/node"
echo "   Or source profile: source /etc/profile"
echo
echo -e "${INFO} Docker permission denied:"
echo "   Add user to docker group: sudo usermod -aG docker \$USER"
echo "   Then logout and login again"
echo
echo -e "${INFO} Update NixOS configuration:"
echo "   sudo nixos-rebuild switch"
echo
echo -e "${BLUE}For more help, visit: https://github.com/PadsterH2012/nixos${NC}"
