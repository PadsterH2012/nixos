#!/bin/bash

# Enhanced NixOS Deployment Script with Application Configuration
# Deploys system configuration and sets up application configurations

set -e  # Exit on any error

# Configuration
ENVIRONMENT=${1:-dev-02}
BACKUP_DIR="/tmp/nixos-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/nixos-deploy-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Use sudo when needed."
    fi
}

# Validate environment
validate_environment() {
    if [[ ! -d "$ENVIRONMENT" ]]; then
        error "Environment directory '$ENVIRONMENT' not found!"
    fi
    
    if [[ ! -f "$ENVIRONMENT/nixos/configuration.nix" ]]; then
        error "Configuration file not found in '$ENVIRONMENT/nixos/configuration.nix'"
    fi
    
    log "✅ Environment '$ENVIRONMENT' validated"
}

# Create backup
create_backup() {
    log "📦 Creating backup of current configuration..."
    
    sudo mkdir -p "$BACKUP_DIR"
    sudo cp -r /etc/nixos/* "$BACKUP_DIR/" 2>/dev/null || true
    
    # Backup user configurations
    if [[ -d "$HOME/.config" ]]; then
        cp -r "$HOME/.config" "$BACKUP_DIR/user-config/" 2>/dev/null || true
    fi
    
    log "✅ Backup created at: $BACKUP_DIR"
}

# Deploy system configuration
deploy_system() {
    log "🚀 Deploying system configuration..."
    
    # Copy configuration files
    sudo cp -r "$ENVIRONMENT/nixos/"* /etc/nixos/
    
    # Test configuration first
    info "Testing configuration..."
    if sudo nixos-rebuild test; then
        log "✅ Configuration test successful"
    else
        error "❌ Configuration test failed! Check the logs."
    fi
    
    # Apply configuration
    info "Applying configuration..."
    if sudo nixos-rebuild switch; then
        log "✅ System configuration applied successfully"
    else
        error "❌ Failed to apply system configuration!"
    fi
}

# Setup application configurations
setup_applications() {
    log "🔧 Setting up application configurations..."
    
    # VS Code setup
    if [[ -f "/etc/vscode/install-extensions.sh" ]]; then
        info "Installing VS Code extensions..."
        bash /etc/vscode/install-extensions.sh || warning "Some VS Code extensions failed to install"
    fi
    
    # Git setup
    if [[ -f "/etc/git/setup-user-git.sh" ]]; then
        info "Setting up Git configuration..."
        bash /etc/git/setup-user-git.sh || warning "Git setup encountered issues"
    fi

    # Terminal setup
    if [[ -f "/etc/terminal/setup-user-terminal.sh" ]]; then
        info "Setting up terminal configuration..."
        bash /etc/terminal/setup-user-terminal.sh || warning "Terminal setup encountered issues"
    fi
    
    # Create desktop shortcuts
    if [[ -d "/etc/skel/Desktop" ]]; then
        info "Creating desktop shortcuts..."
        cp /etc/skel/Desktop/* "$HOME/Desktop/" 2>/dev/null || true
        chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true
    fi
    
    # Setup development directories
    info "Creating development directories..."
    mkdir -p "$HOME/Projects"
    mkdir -p "$HOME/Scripts"
    mkdir -p "$HOME/.local/bin"
    
    log "✅ Application configurations completed"
}

# Post-deployment tasks
post_deployment() {
    log "🔄 Running post-deployment tasks..."
    
    # Update system packages
    info "Updating system packages..."
    sudo nix-channel --update || warning "Failed to update channels"
    
    # Collect garbage
    info "Cleaning up old generations..."
    sudo nix-collect-garbage -d || warning "Garbage collection failed"
    
    # Verify services
    info "Verifying critical services..."
    systemctl is-active --quiet sshd && log "✅ SSH service is running" || warning "SSH service not running"
    systemctl is-active --quiet xrdp && log "✅ XRDP service is running" || warning "XRDP service not running"
    systemctl is-active --quiet docker && log "✅ Docker service is running" || warning "Docker service not running"
    
    log "✅ Post-deployment tasks completed"
}

# Generate deployment report
generate_report() {
    local report_file="/tmp/deployment-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
# NixOS Deployment Report
Date: $(date)
Environment: $ENVIRONMENT
Backup Location: $BACKUP_DIR
Log File: $LOG_FILE

## System Information
$(uname -a)

## NixOS Generation
$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1)

## Installed Packages
$(nix-env -q | wc -l) packages installed

## Services Status
SSH: $(systemctl is-active sshd)
XRDP: $(systemctl is-active xrdp)
Docker: $(systemctl is-active docker)
NetworkManager: $(systemctl is-active NetworkManager)

## Disk Usage
$(df -h /)

## Memory Usage
$(free -h)

## Network Configuration
$(ip addr show | grep -E "inet.*scope global")

EOF

    log "📊 Deployment report generated: $report_file"
    cat "$report_file"
}

# Rollback function
rollback() {
    if [[ -d "$BACKUP_DIR" ]]; then
        warning "Rolling back to previous configuration..."
        sudo cp -r "$BACKUP_DIR/"* /etc/nixos/
        sudo nixos-rebuild switch
        log "✅ Rollback completed"
    else
        error "No backup found for rollback!"
    fi
}

# Main deployment function
main() {
    log "🚀 Starting NixOS deployment with application configuration"
    log "Environment: $ENVIRONMENT"
    log "Timestamp: $(date)"
    
    # Trap for cleanup on error
    trap 'error "Deployment failed! Check log: $LOG_FILE"' ERR
    
    check_root
    validate_environment
    create_backup
    deploy_system
    setup_applications
    post_deployment
    generate_report
    
    log "🎉 Deployment completed successfully!"
    log "📁 Backup: $BACKUP_DIR"
    log "📋 Log: $LOG_FILE"
    
    echo ""
    echo -e "${GREEN}🎯 Next Steps:${NC}"
    echo "1. Test your applications (VS Code, Git, Terminal)"
    echo "2. Verify XRDP connection works"
    echo "3. Check that all services are running"
    echo "4. Review the deployment report above"
    echo ""
    echo -e "${BLUE}💡 Useful Commands:${NC}"
    echo "- Check system status: systemctl status"
    echo "- View logs: journalctl -xe"
    echo "- Rollback if needed: sudo nixos-rebuild switch --rollback"
    echo "- Or restore backup: sudo cp -r $BACKUP_DIR/* /etc/nixos/ && sudo nixos-rebuild switch"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --rollback     Rollback to previous configuration"
        echo ""
        echo "Examples:"
        echo "  $0 dev-02      Deploy dev-02 environment"
        echo "  $0 --rollback  Rollback to previous configuration"
        exit 0
        ;;
    --rollback)
        rollback
        exit 0
        ;;
    *)
        main
        ;;
esac
