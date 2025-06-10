#!/bin/bash

# Bulk NixOS Configuration Export Script
# Exports configurations from multiple NixOS machines
# Usage: ./bulk-export-nixos.sh [machine1] [machine2] [machine3]...

VERSION="1.0.0"
SCRIPT_NAME="Bulk NixOS Config Exporter"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default machine list (edit as needed)
DEFAULT_MACHINES=(
    "nixos-dev-cinnamon"
    "nixos-server-01"
    "nixos-workstation-02"
    "nixos-lab-03"
)

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║           ${BLUE}$SCRIPT_NAME v$VERSION${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

export_from_machine() {
    local machine=$1
    local user=${2:-"paddy"}
    
    echo -e "${BLUE}🔄 Exporting from ${GREEN}$machine${NC}..."
    
    # Try to connect and run export script
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$user@$machine" 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash' 2>/dev/null; then
        echo -e "   ✅ Export successful from $machine"
        return 0
    else
        echo -e "   ❌ Failed to export from $machine"
        echo -e "      • Check if machine is reachable"
        echo -e "      • Verify SSH access"
        echo -e "      • Ensure internet connectivity on target"
        return 1
    fi
}

main() {
    print_header
    
    # Use provided machines or default list
    if [ $# -gt 0 ]; then
        MACHINES=("$@")
    else
        MACHINES=("${DEFAULT_MACHINES[@]}")
        echo -e "${YELLOW}ℹ️  No machines specified, using default list${NC}"
    fi
    
    echo -e "${CYAN}Exporting configurations from ${#MACHINES[@]} machines...${NC}"
    echo
    
    local success_count=0
    local total_count=${#MACHINES[@]}
    
    for machine in "${MACHINES[@]}"; do
        if export_from_machine "$machine"; then
            ((success_count++))
        fi
        echo
    done
    
    echo -e "${BLUE}📊 Export Summary:${NC}"
    echo -e "   • Total machines: $total_count"
    echo -e "   • Successful: ${GREEN}$success_count${NC}"
    echo -e "   • Failed: ${RED}$((total_count - success_count))${NC}"
    echo
    
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}✅ Bulk export completed!${NC}"
        echo -e "${CYAN}View all configurations: https://github.com/PadsterH2012/nixos${NC}"
    else
        echo -e "${RED}❌ No successful exports${NC}"
        echo -e "${YELLOW}Check network connectivity and SSH access${NC}"
    fi
}

# Show help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Bulk NixOS Configuration Export Script"
    echo
    echo "Usage:"
    echo "  $0                          # Export from default machines"
    echo "  $0 machine1 machine2        # Export from specified machines"
    echo "  $0 --help                   # Show this help"
    echo
    echo "Examples:"
    echo "  $0 nixos-dev-01 nixos-server-02"
    echo "  $0 192.168.1.100 192.168.1.101"
    echo
    echo "Requirements:"
    echo "  • SSH access to target machines"
    echo "  • Internet connectivity on target machines"
    echo "  • Git push access to repository (or manual push later)"
    exit 0
fi

main "$@"
