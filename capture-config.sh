#!/bin/bash

# Configuration Capture Script
# Extracts application configurations for NixOS deployment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

CAPTURE_DIR="./captured-configs-$(date +%Y%m%d-%H%M%S)"

log() {
    echo -e "${GREEN}[CAPTURE]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create capture directory
mkdir -p "$CAPTURE_DIR"
log "📁 Created capture directory: $CAPTURE_DIR"

# Capture VS Code settings
capture_vscode() {
    log "🔧 Capturing VS Code configuration..."
    
    local vscode_dir="$CAPTURE_DIR/vscode"
    mkdir -p "$vscode_dir"
    
    # User settings
    if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
        cp "$HOME/.config/Code/User/settings.json" "$vscode_dir/"
        info "✅ VS Code settings captured"
    else
        warning "VS Code settings not found"
    fi
    
    # Keybindings
    if [[ -f "$HOME/.config/Code/User/keybindings.json" ]]; then
        cp "$HOME/.config/Code/User/keybindings.json" "$vscode_dir/"
        info "✅ VS Code keybindings captured"
    fi
    
    # Extensions list
    if command -v code &> /dev/null; then
        code --list-extensions > "$vscode_dir/extensions.txt"
        info "✅ VS Code extensions list captured"
    fi
    
    # Snippets
    if [[ -d "$HOME/.config/Code/User/snippets" ]]; then
        cp -r "$HOME/.config/Code/User/snippets" "$vscode_dir/"
        info "✅ VS Code snippets captured"
    fi
}

# Capture Git configuration
capture_git() {
    log "📝 Capturing Git configuration..."
    
    local git_dir="$CAPTURE_DIR/git"
    mkdir -p "$git_dir"
    
    # Global config
    if [[ -f "$HOME/.gitconfig" ]]; then
        cp "$HOME/.gitconfig" "$git_dir/"
        info "✅ Git global config captured"
    fi
    
    # Global gitignore
    if [[ -f "$HOME/.gitignore_global" ]]; then
        cp "$HOME/.gitignore_global" "$git_dir/"
        info "✅ Git global ignore captured"
    fi
    
    # Git aliases and config dump
    git config --global --list > "$git_dir/git-config-dump.txt" 2>/dev/null || warning "Could not dump git config"
}

# Capture shell configuration
capture_shell() {
    log "🐚 Capturing shell configuration..."
    
    local shell_dir="$CAPTURE_DIR/shell"
    mkdir -p "$shell_dir"
    
    # Bash configuration
    if [[ -f "$HOME/.bashrc" ]]; then
        cp "$HOME/.bashrc" "$shell_dir/"
        info "✅ Bashrc captured"
    fi
    
    if [[ -f "$HOME/.bash_profile" ]]; then
        cp "$HOME/.bash_profile" "$shell_dir/"
        info "✅ Bash profile captured"
    fi
    
    if [[ -f "$HOME/.bash_aliases" ]]; then
        cp "$HOME/.bash_aliases" "$shell_dir/"
        info "✅ Bash aliases captured"
    fi
    
    # Environment variables
    env > "$shell_dir/environment.txt"
    info "✅ Environment variables captured"
    
    # Aliases
    alias > "$shell_dir/aliases.txt" 2>/dev/null || true
    info "✅ Current aliases captured"
}

# Capture desktop environment settings
capture_desktop() {
    log "🖥️ Capturing desktop environment settings..."
    
    local desktop_dir="$CAPTURE_DIR/desktop"
    mkdir -p "$desktop_dir"
    
    # Cinnamon settings (if available)
    if command -v dconf &> /dev/null; then
        dconf dump /org/cinnamon/ > "$desktop_dir/cinnamon-settings.dconf" 2>/dev/null || warning "Could not dump Cinnamon settings"
        info "✅ Cinnamon settings captured"
    fi
    
    # Desktop files
    if [[ -d "$HOME/.local/share/applications" ]]; then
        cp -r "$HOME/.local/share/applications" "$desktop_dir/"
        info "✅ Custom desktop files captured"
    fi
    
    # Autostart applications
    if [[ -d "$HOME/.config/autostart" ]]; then
        cp -r "$HOME/.config/autostart" "$desktop_dir/"
        info "✅ Autostart applications captured"
    fi
}

# Capture SSH configuration
capture_ssh() {
    log "🔐 Capturing SSH configuration..."
    
    local ssh_dir="$CAPTURE_DIR/ssh"
    mkdir -p "$ssh_dir"
    
    if [[ -f "$HOME/.ssh/config" ]]; then
        # Remove sensitive information
        grep -v -E "(IdentityFile|PrivateKey)" "$HOME/.ssh/config" > "$ssh_dir/config" || true
        info "✅ SSH config captured (sensitive data removed)"
    fi
    
    # Known hosts (public information)
    if [[ -f "$HOME/.ssh/known_hosts" ]]; then
        cp "$HOME/.ssh/known_hosts" "$ssh_dir/"
        info "✅ SSH known hosts captured"
    fi
}

# Capture application list
capture_applications() {
    log "📦 Capturing installed applications..."
    
    local apps_dir="$CAPTURE_DIR/applications"
    mkdir -p "$apps_dir"
    
    # System packages (if on NixOS)
    if command -v nix-env &> /dev/null; then
        nix-env -q > "$apps_dir/nix-packages.txt"
        info "✅ Nix packages captured"
    fi
    
    # Flatpak applications
    if command -v flatpak &> /dev/null; then
        flatpak list > "$apps_dir/flatpak-apps.txt" 2>/dev/null || true
        info "✅ Flatpak applications captured"
    fi
    
    # Snap packages
    if command -v snap &> /dev/null; then
        snap list > "$apps_dir/snap-packages.txt" 2>/dev/null || true
        info "✅ Snap packages captured"
    fi
}

# Generate conversion guide
generate_guide() {
    log "📚 Generating conversion guide..."
    
    cat > "$CAPTURE_DIR/CONVERSION_GUIDE.md" << 'EOF'
# Configuration Conversion Guide

This directory contains captured configurations from your current system.
Use this guide to convert them to NixOS configuration modules.

## Files Captured

### VS Code (`vscode/`)
- `settings.json` - User settings
- `keybindings.json` - Custom keybindings
- `extensions.txt` - Installed extensions
- `snippets/` - Code snippets

**Convert to:** `applications/vscode.nix`

### Git (`git/`)
- `.gitconfig` - Global Git configuration
- `.gitignore_global` - Global gitignore
- `git-config-dump.txt` - All Git settings

**Convert to:** `applications/git.nix`

### Shell (`shell/`)
- `.bashrc` - Bash configuration
- `.bash_profile` - Bash profile
- `aliases.txt` - Current aliases
- `environment.txt` - Environment variables

**Convert to:** `applications/terminal.nix`

### Desktop (`desktop/`)
- `cinnamon-settings.dconf` - Cinnamon settings
- `applications/` - Custom desktop files
- `autostart/` - Autostart applications

**Convert to:** `modules/desktop.nix`

### SSH (`ssh/`)
- `config` - SSH client configuration
- `known_hosts` - Known SSH hosts

**Convert to:** `modules/ssh.nix`

### Applications (`applications/`)
- `nix-packages.txt` - Currently installed Nix packages
- `flatpak-apps.txt` - Flatpak applications
- `snap-packages.txt` - Snap packages

**Convert to:** `modules/development.nix` or specific application modules

## Conversion Steps

1. **Review captured files** to understand current configuration
2. **Create NixOS modules** using the templates in the main repository
3. **Test configurations** in a development environment
4. **Deploy gradually** - start with essential applications
5. **Iterate and refine** based on testing results

## Security Notes

- SSH private keys and sensitive data have been excluded
- Review all captured configurations before committing to version control
- Consider using NixOS secrets management for sensitive configurations

## Next Steps

1. Compare captured settings with existing NixOS modules
2. Identify gaps and create new modules as needed
3. Test the converted configuration in a VM or test environment
4. Deploy to production systems once validated
EOF

    info "✅ Conversion guide generated"
}

# Main function
main() {
    log "🚀 Starting configuration capture..."
    
    capture_vscode
    capture_git
    capture_shell
    capture_desktop
    capture_ssh
    capture_applications
    generate_guide
    
    log "✅ Configuration capture completed!"
    log "📁 Results saved to: $CAPTURE_DIR"
    
    echo ""
    echo -e "${GREEN}🎯 Next Steps:${NC}"
    echo "1. Review captured configurations in: $CAPTURE_DIR"
    echo "2. Use the conversion guide to create NixOS modules"
    echo "3. Test configurations before deployment"
    echo "4. Update your NixOS configuration with new modules"
    echo ""
    echo -e "${BLUE}💡 Tip:${NC} Use the APPLICATION_CONFIG_GUIDE.md for detailed conversion instructions"
}

# Run main function
main
