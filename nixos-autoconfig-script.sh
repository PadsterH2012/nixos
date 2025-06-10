#!/usr/bin/env bash

# NixOS Auto-Configuration Script
# Automatically configures NixOS based on MAC address

set -euo pipefail

# Configuration
GITHUB_REPO="${NIXOS_CONFIG_REPO:-your-username/nixos-configs}"
GITHUB_BRANCH="${NIXOS_CONFIG_BRANCH:-main}"
CONFIG_BASE_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"
TEMP_DIR="/tmp/nixos-autoconfig"
NIXOS_CONFIG_DIR="/etc/nixos"

# Security: Ensure temp directory has proper permissions
umask 077

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to get primary network interface MAC address
get_mac_address() {
    local mac_addr
    
    # Try to get MAC from primary interface (usually eth0 or the first non-loopback interface)
    mac_addr=$(ip link show | grep -E "^[0-9]+: (eth|en|wl)" | head -1 | grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" | head -1)
    
    if [[ -z "$mac_addr" ]]; then
        # Fallback: get any non-loopback interface MAC
        mac_addr=$(ip link show | grep -v "lo:" | grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" | head -1)
    fi
    
    if [[ -z "$mac_addr" ]]; then
        error "Could not determine MAC address"
    fi
    
    echo "$mac_addr" | tr '[:upper:]' '[:lower:]'
}

# Function to check if URL exists
url_exists() {
    local url="$1"
    curl --silent --head --fail "$url" > /dev/null 2>&1
}

# Function to download file from GitHub
download_file() {
    local url="$1"
    local dest="$2"

    log "Downloading: $url"
    if ! curl --silent --fail "$url" -o "$dest"; then
        return 1
    fi

    # Check if file is encrypted (age format)
    if [[ "$dest" == *.age ]] || head -1 "$dest" 2>/dev/null | grep -q "^age-encryption.org"; then
        log "Detected encrypted file, attempting to decrypt..."

        local decrypted_dest="${dest%.age}"
        if command -v age >/dev/null 2>&1 && [[ -f ~/.age/key.txt ]]; then
            if age -d -i ~/.age/key.txt "$dest" > "$decrypted_dest" 2>/dev/null; then
                mv "$decrypted_dest" "$dest"
                success "File decrypted successfully"
            else
                warn "Failed to decrypt file - using as-is"
            fi
        else
            warn "age not available or no key found - cannot decrypt"
        fi
    fi

    return 0
}

# Function to backup existing configuration
backup_config() {
    local backup_dir="/etc/nixos/backup-$(date +%Y%m%d-%H%M%S)"
    
    if [[ -f "$NIXOS_CONFIG_DIR/configuration.nix" ]]; then
        log "Backing up existing configuration to $backup_dir"
        mkdir -p "$backup_dir"
        cp -r "$NIXOS_CONFIG_DIR"/* "$backup_dir/" 2>/dev/null || true
        success "Backup created at $backup_dir"
    fi
}

# Function to validate configuration syntax
validate_config() {
    local config_file="$1"

    log "Validating configuration syntax..."

    # Check for basic Nix syntax errors
    if ! nix-instantiate --parse "$config_file" >/dev/null 2>&1; then
        error "Configuration file has syntax errors: $config_file"
    fi

    # Check for common configuration issues
    if grep -q "boot.loader.grub.device.*sda" "$config_file" 2>/dev/null; then
        warn "Configuration contains hardcoded device paths (sda) - this may cause issues"
    fi

    success "Configuration syntax validation passed"
}

# Function to apply configuration
apply_config() {
    local config_type="$1"

    log "Applying $config_type configuration..."

    # Validate configuration before applying
    validate_config "$NIXOS_CONFIG_DIR/configuration.nix"

    # Make configuration owned by root
    chown -R root:root "$NIXOS_CONFIG_DIR"
    chmod -R 644 "$NIXOS_CONFIG_DIR"/*.nix 2>/dev/null || true

    # Test configuration
    log "Testing configuration..."
    if ! nixos-rebuild dry-build; then
        error "Configuration test failed. Check your NixOS configuration files."
    fi

    # Apply configuration
    log "Rebuilding NixOS..."
    if nixos-rebuild switch; then
        success "NixOS configuration applied successfully!"

        # Store successful configuration info for potential rollback
        echo "$(date): Successfully applied configuration from $GITHUB_REPO" >> /var/log/nixos-autoconfig.log

        # Run post-deployment tests if available
        if command -v nixos-dev-test.sh >/dev/null 2>&1; then
            log "Running post-deployment tests..."
            if nixos-dev-test.sh --all; then
                success "Post-deployment tests passed!"
            else
                warn "Post-deployment tests failed - configuration may have issues"
            fi
        fi
    else
        warn "Failed to apply NixOS configuration - attempting rollback..."

        # Attempt to rollback to previous generation
        if nixos-rebuild switch --rollback; then
            warn "Rolled back to previous configuration"
            error "New configuration failed but rollback succeeded"
        else
            error "Failed to apply NixOS configuration AND rollback failed"
        fi
    fi
}

# Main configuration function
configure_system() {
    local mac_addr="$1"
    local config_found=false
    
    # Clean up and create temp directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    log "Looking for configurations for MAC address: $mac_addr"
    
    # Try different configuration patterns
    local config_patterns=(
        "hosts/${mac_addr}/configuration.nix"
        "hosts/${mac_addr}/default.nix"
        "machines/${mac_addr}.nix"
        "configs/${mac_addr}/configuration.nix"
        "${mac_addr}.nix"
    )
    
    # Try to find and download configurations
    for pattern in "${config_patterns[@]}"; do
        local config_url="${CONFIG_BASE_URL}/${pattern}"
        local temp_file="${TEMP_DIR}/$(basename "$pattern")"
        
        if url_exists "$config_url"; then
            log "Found configuration: $pattern"
            
            if download_file "$config_url" "$temp_file"; then
                config_found=true
                
                # Backup existing config
                backup_config
                
                # Copy new configuration
                cp "$temp_file" "$NIXOS_CONFIG_DIR/configuration.nix"
                
                # Try to download additional files from the same directory
                local config_dir=$(dirname "$pattern")
                if [[ "$config_dir" != "." ]]; then
                    download_additional_files "$config_dir" "$mac_addr"
                fi
                
                break
            fi
        fi
    done
    
    if [[ "$config_found" == false ]]; then
        # Try to download a default configuration
        log "No specific configuration found, trying default..."
        
        local default_patterns=(
            "default/configuration.nix"
            "templates/default.nix"
            "base/configuration.nix"
        )
        
        for pattern in "${default_patterns[@]}"; do
            local config_url="${CONFIG_BASE_URL}/${pattern}"
            local temp_file="${TEMP_DIR}/configuration.nix"
            
            if url_exists "$config_url" && download_file "$config_url" "$temp_file"; then
                warn "Using default configuration: $pattern"
                backup_config
                cp "$temp_file" "$NIXOS_CONFIG_DIR/configuration.nix"
                config_found=true
                break
            fi
        done
    fi
    
    if [[ "$config_found" == false ]]; then
        error "No configuration found for MAC address $mac_addr or default configuration"
    fi
    
    # Apply the configuration
    apply_config "system"
}

# Function to download additional configuration files
download_additional_files() {
    local config_dir="$1"
    local mac_addr="$2"
    
    log "Checking for additional configuration files..."
    
    # Common additional files
    local additional_files=(
        "hardware-configuration.nix"
        "users.nix"
        "packages.nix"
        "services.nix"
        "networking.nix"
    )
    
    for file in "${additional_files[@]}"; do
        local file_url="${CONFIG_BASE_URL}/${config_dir}/${file}"
        local dest_file="${NIXOS_CONFIG_DIR}/${file}"
        
        if url_exists "$file_url"; then
            log "Found additional file: $file"
            download_file "$file_url" "$dest_file"
        fi
    done
}

# Function to check if git is available and configured
check_git_config() {
    if ! command -v git &> /dev/null; then
        error "Git is not installed. Please install git to use upload functionality."
    fi
    
    if [[ -z "$(git config --global user.name)" ]] || [[ -z "$(git config --global user.email)" ]]; then
        error "Git is not configured. Please run: git config --global user.name 'Your Name' && git config --global user.email 'your.email@example.com'"
    fi
}

# Function to upload configuration to GitHub
upload_config() {
    local mac_addr="$1"
    local github_token="$2"
    local commit_message="$3"
    
    log "Uploading configuration for MAC address: $mac_addr"
    
    # Check git configuration
    check_git_config
    
    # Create temporary directory for git operations
    local git_temp_dir="/tmp/nixos-config-upload-$(date +%s)"
    mkdir -p "$git_temp_dir"
    
    # Clone or update repository
    local repo_url
    if [[ -n "$github_token" ]]; then
        repo_url="https://${github_token}@github.com/${GITHUB_REPO}.git"
    else
        repo_url="https://github.com/${GITHUB_REPO}.git"
    fi
    
    log "Cloning repository: $GITHUB_REPO"
    if ! git clone --depth 1 -b "$GITHUB_BRANCH" "$repo_url" "$git_temp_dir" 2>/dev/null; then
        # Try to clone without specifying branch (might not exist)
        if ! git clone --depth 1 "$repo_url" "$git_temp_dir"; then
            error "Failed to clone repository. Check repository URL and access permissions."
        fi
        
        # Create and switch to the specified branch
        cd "$git_temp_dir"
        git checkout -b "$GITHUB_BRANCH" 2>/dev/null || git checkout "$GITHUB_BRANCH"
    fi
    
    cd "$git_temp_dir"
    
    # Create host directory structure
    local host_dir="hosts/${mac_addr}"
    mkdir -p "$host_dir"
    
    # Copy configuration files
    log "Copying configuration files..."
    
    local files_copied=0
    
    # Copy main configuration files
    if [[ -f "$NIXOS_CONFIG_DIR/configuration.nix" ]]; then
        cp "$NIXOS_CONFIG_DIR/configuration.nix" "$host_dir/"
        files_copied=$((files_copied + 1))
        log "Copied configuration.nix"
    fi
    
    if [[ -f "$NIXOS_CONFIG_DIR/hardware-configuration.nix" ]]; then
        cp "$NIXOS_CONFIG_DIR/hardware-configuration.nix" "$host_dir/"
        files_copied=$((files_copied + 1))
        log "Copied hardware-configuration.nix"
    fi
    
    # Copy additional common configuration files
    local additional_files=(
        "users.nix"
        "packages.nix"
        "services.nix"
        "networking.nix"
        "home.nix"
    )
    
    for file in "${additional_files[@]}"; do
        if [[ -f "$NIXOS_CONFIG_DIR/$file" ]]; then
            cp "$NIXOS_CONFIG_DIR/$file" "$host_dir/"
            files_copied=$((files_copied + 1))
            log "Copied $file"
        fi
    done
    
    # Copy any custom .nix files
    find "$NIXOS_CONFIG_DIR" -name "*.nix" -not -name "configuration.nix" -not -name "hardware-configuration.nix" | while read -r file; do
        local filename=$(basename "$file")
        if [[ ! " ${additional_files[@]} " =~ " ${filename} " ]]; then
            cp "$file" "$host_dir/"
            files_copied=$((files_copied + 1))
            log "Copied custom file: $filename"
        fi
    done
    
    if [[ $files_copied -eq 0 ]]; then
        error "No configuration files found to upload"
    fi
    
    # Generate a README for this host
    generate_host_readme "$host_dir" "$mac_addr"
    
    # Add files to git
    git add "$host_dir"
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        warn "No changes detected. Configuration may already be up to date."
        rm -rf "$git_temp_dir"
        return 0
    fi
    
    # Commit changes
    log "Committing changes..."
    git commit -m "$commit_message"
    
    # Push changes
    log "Pushing to GitHub..."
    if git push origin "$GITHUB_BRANCH"; then
        success "Configuration uploaded successfully!"
        success "Files uploaded: $files_copied"
        success "Location: $host_dir"
    else
        error "Failed to push to GitHub. Check your permissions and network connection."
    fi
    
    # Clean up
    rm -rf "$git_temp_dir"
}

# Function to generate README for host
generate_host_readme() {
    local host_dir="$1"
    local mac_addr="$2"
    
    cat > "$host_dir/README.md" << EOF
# NixOS Configuration for $mac_addr

**Last Updated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Hostname:** $(hostname)
**Architecture:** $(uname -m)
**Kernel:** $(uname -r)

## System Information

- **MAC Address:** $mac_addr
- **NixOS Version:** $(nixos-version 2>/dev/null || echo "Unknown")
- **Hardware Platform:** $(nix-instantiate --eval --expr 'builtins.currentSystem' 2>/dev/null | tr -d '"' || echo "Unknown")

## Configuration Files

$(find "$host_dir" -name "*.nix" -type f | while read -r file; do
    echo "- \`$(basename "$file")\` - $(wc -l < "$file") lines"
done)

## Hardware Summary

$(lscpu 2>/dev/null | grep "Model name:" | sed 's/Model name:[[:space:]]*/- **CPU:** /' || echo "- **CPU:** Unknown")
$(free -h 2>/dev/null | awk '/^Mem:/ {print "- **Memory:** " $2}' || echo "- **Memory:** Unknown")
$(df -h / 2>/dev/null | awk 'NR==2 {print "- **Root Filesystem:** " $2 " (" $5 " used)"}' || echo "- **Root Filesystem:** Unknown")

## Network Interfaces

$(ip link show 2>/dev/null | grep -E "^[0-9]+:" | grep -v "lo:" | sed 's/^[0-9]*: \([^:]*\):.*/- \1/' || echo "- Unable to detect interfaces")

---
*Generated automatically by nixos-auto-config on $(date)*
EOF
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

Commands:
    download (default)      Download and apply configuration from GitHub
    upload                  Upload current configuration to GitHub
    sync                    Download, then upload (bidirectional sync)

Options:
    -r, --repo REPO         GitHub repository (format: username/repo-name)
    -b, --branch BRANCH     Git branch to use (default: main)
    -m, --mac MAC          Manually specify MAC address
    -t, --token TOKEN      GitHub personal access token (for upload/sync)
    -c, --commit MSG       Custom commit message (for upload/sync)
    -d, --dry-run          Show what would be done without applying
    -f, --force            Force upload even if no changes detected
    -h, --help             Show this help message

Examples:
    # Download configuration
    $0 --repo myuser/nixos-configs
    $0 download --repo myuser/nixos-configs --branch development
    
    # Upload current configuration
    $0 upload --repo myuser/nixos-configs --token ghp_xxxxxxxxxxxx
    $0 upload --repo myuser/nixos-configs --commit "Updated packages"
    
    # Bidirectional sync
    $0 sync --repo myuser/nixos-configs --token ghp_xxxxxxxxxxxx
    
    # Specify MAC address manually
    $0 --mac 00:11:22:33:44:55 --repo myuser/nixos-configs

Environment Variables:
    GITHUB_TOKEN           GitHub personal access token
    NIXOS_CONFIG_REPO      Default repository (format: username/repo-name)
    NIXOS_CONFIG_BRANCH    Default branch

EOF
}

# Set defaults from environment variables
GITHUB_REPO="${NIXOS_CONFIG_REPO:-$GITHUB_REPO}"
GITHUB_BRANCH="${NIXOS_CONFIG_BRANCH:-$GITHUB_BRANCH}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
COMMAND="download"
COMMIT_MESSAGE=""
FORCE_UPLOAD=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        download|upload|sync)
            COMMAND="$1"
            shift
            ;;
        -r|--repo)
            GITHUB_REPO="$2"
            shift 2
            ;;
        -b|--branch)
            GITHUB_BRANCH="$2"
            shift 2
            ;;
        -m|--mac)
            MAC_ADDRESS="$2"
            shift 2
            ;;
        -t|--token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        -c|--commit)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE_UPLOAD=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1. Use --help for usage information."
            ;;
    esac
done

# Main execution
main() {
    log "Starting NixOS Auto-Configuration - Command: $COMMAND"
    
    # Check if running as root for system operations
    if [[ "$COMMAND" == "download" ]] && [[ $EUID -ne 0 ]]; then
        error "Download command must be run as root (use sudo)"
    fi
    
    # Check if we're on NixOS for system operations
    if [[ "$COMMAND" == "download" ]] && [[ ! -f /etc/NIXOS ]]; then
        error "Download command can only be run on NixOS"
    fi
    
    # Validate repository is specified
    if [[ -z "$GITHUB_REPO" ]]; then
        error "GitHub repository must be specified with --repo or NIXOS_CONFIG_REPO environment variable"
    fi
    
    # Get MAC address
    local mac_addr="${MAC_ADDRESS:-$(get_mac_address)}"
    log "System MAC address: $mac_addr"
    
    # Update CONFIG_BASE_URL with provided repo
    CONFIG_BASE_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"
    
    # Set default commit message if not provided
    if [[ -z "$COMMIT_MESSAGE" ]]; then
        COMMIT_MESSAGE="Update configuration for $(hostname) (${mac_addr}) - $(date)"
    fi
    
    case "$COMMAND" in
        "download")
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                log "DRY RUN: Would download configuration for MAC: $mac_addr"
                log "DRY RUN: Would use repository: $GITHUB_REPO"
                log "DRY RUN: Would use branch: $GITHUB_BRANCH"
                exit 0
            fi
            configure_system "$mac_addr"
            success "Configuration download completed!"
            ;;
            
        "upload")
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                log "DRY RUN: Would upload configuration for MAC: $mac_addr"
                log "DRY RUN: Would use repository: $GITHUB_REPO"
                log "DRY RUN: Would use branch: $GITHUB_BRANCH"
                log "DRY RUN: Would use commit message: $COMMIT_MESSAGE"
                exit 0
            fi
            
            # Check for required upload dependencies
            if [[ "$COMMAND" == "upload" ]] && [[ -z "$GITHUB_TOKEN" ]]; then
                warn "No GitHub token provided. Attempting to upload using existing git credentials..."
                warn "If this fails, provide a token with --token or set GITHUB_TOKEN environment variable"
            fi
            
            upload_config "$mac_addr" "$GITHUB_TOKEN" "$COMMIT_MESSAGE"
            success "Configuration upload completed!"
            ;;
            
        "sync")
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                log "DRY RUN: Would sync (download then upload) configuration for MAC: $mac_addr"
                log "DRY RUN: Would use repository: $GITHUB_REPO"
                log "DRY RUN: Would use branch: $GITHUB_BRANCH"
                exit 0
            fi
            
            # Check if running as root for download part
            if [[ $EUID -ne 0 ]]; then
                error "Sync command must be run as root (use sudo) for the download portion"
            fi
            
            log "Starting bidirectional sync..."
            
            # First download the latest configuration
            log "Step 1: Downloading latest configuration..."
            configure_system "$mac_addr"
            
            # Then upload the current state
            log "Step 2: Uploading current configuration..."
            upload_config "$mac_addr" "$GITHUB_TOKEN" "$COMMIT_MESSAGE"
            
            success "Bidirectional sync completed!"
            ;;
            
        *)
            error "Unknown command: $COMMAND"
            ;;
    esac
    
    log "You may need to reboot for all changes to take effect."
}

# Run main function
main "$@"