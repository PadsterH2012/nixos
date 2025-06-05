# 🐧 NixOS Configuration Repository

Modern, modular NixOS configurations for development environments with remote access capabilities.

## 🏗️ Configuration Structure Overview

This repository contains organized NixOS configurations for different machine types:

```
├── dev-01/                    # Legacy configuration (MATE desktop)
├── dev-02/                    # Modern configuration (Cinnamon desktop)
│   └── nixos/
│       ├── configuration.nix          # Main configuration file
│       ├── modules/                   # Core system modules
│       │   ├── desktop.nix           # Cinnamon desktop environment
│       │   ├── development.nix       # Development tools & Docker
│       │   ├── hardware.nix          # Hardware-specific settings
│       │   ├── localization.nix      # Language & timezone settings
│       │   └── networking.nix        # Network configuration
│       ├── services/                 # System services
│       │   ├── audio.nix            # Audio/sound configuration
│       │   ├── nfs.nix              # Network file system
│       │   └── remote-access.nix    # SSH & XRDP remote access
│       └── applications/            # Application-specific configs
│           ├── git.nix              # Git configuration
│           ├── terminal.nix         # Terminal tools & aliases
│           └── vscode.nix           # VS Code settings & extensions
└── legacy configs/            # Single-file configurations
```

## 🚀 Quick Deployment

### **Recommended: Modern Modular Configuration (dev-02)**

```bash
# One-liner deployment command:
cd /tmp && \
curl -L https://github.com/PadsterH2012/nixos/archive/refs/heads/main.tar.gz | tar -xz && \
sudo cp -r nixos-main/dev-02/nixos/* /etc/nixos/ && \
sudo nixos-rebuild switch
```

### **Legacy Single-File Configurations**

```bash
# Standard Development Configuration (MATE + VSCode)
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/new1.01.nix && sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix

# Streamlined Development Configuration (Auto-login + NFS + XRDP)
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-streamlined.nix && sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix
```

## 📝 Detailed Configuration Definitions (dev-02)

### 🖥️ **Main Configuration** (`configuration.nix`)
- **Purpose**: Entry point that imports all modules and defines the user account
- **Key Features**:
  - Creates user "paddy" with admin privileges
  - Enables unfree packages (for VS Code, Chrome, etc.)
  - Installs user applications (Firefox, Google Chrome)
  - Sets up printing services
  - Defines system state version (24.11)

### 🎨 **Desktop Module** (`modules/desktop.nix`)
- **Purpose**: Complete Cinnamon desktop environment setup
- **Key Features**:
  - Cinnamon desktop with LightDM display manager
  - Optimized fonts for ultrawide monitors
  - Essential desktop applications (file manager, image viewer, PDF viewer)
  - XRDP-compatible desktop session scripts
  - Desktop shortcuts for VS Code and Terminal
  - Multi-monitor support tools (arandr, autorandr)

### 🛠️ **Development Module** (`modules/development.nix`)
- **Purpose**: Development environment with essential tools
- **Key Features**:
  - Core development tools: VS Code, Git, Node.js, Python3, GCC
  - Docker with auto-pruning enabled
  - System utilities: htop, tree, zip/unzip
  - NFS utilities for network drives
  - Proxmox/VM utilities (qemu-utils, spice-vdagent)

### 🌐 **Remote Access Service** (`services/remote-access.nix`)
- **Purpose**: SSH and XRDP remote desktop access
- **Key Features**:
  - SSH daemon for command-line access
  - XRDP with Cinnamon session support
  - Optimized XRDP configuration for desktop environment
  - Firewall rules automatically configured

### 📁 **NFS Service** (`services/nfs.nix`)
- **Purpose**: Network File System client for accessing shared repositories
- **Key Features**:
  - Automatic mounting of network development repository
  - Mount point: `/mnt/network_repo` → `10.202.28.4:/Project_Repositories`
  - NFS v3 with read/write access
  - Automatic directory creation and permissions

### 💻 **Terminal Application** (`applications/terminal.nix`)
- **Purpose**: Terminal tools, aliases, and shell configuration
- **Key Features**:
  - Modern terminal tools: **eza** (ls replacement), **bat** (cat replacement), **ripgrep**, **fzf**
  - Comprehensive shell aliases (Git shortcuts, NixOS shortcuts, Docker shortcuts)
  - Custom bash prompt with Git branch display
  - Tmux configuration with custom key bindings
  - Helper functions for development workflow

### 🔧 **VS Code Application** (`applications/vscode.nix`)
- **Purpose**: Declarative VS Code installation with extensions and configuration
- **Key Features**:
  - **Declarative extension installation** - extensions installed automatically via Nix
  - Pre-configured settings for development
  - Workspace templates
  - NixOS-specific language server configuration
  - Desktop shortcuts and file associations
  - Extension verification script

## 🚀 Complete Deployment Commands

### **For Development Machine** (storing configs in Git):

```bash
# 1. Navigate to your repository
cd /mnt/network_repo/nixos

# 2. Make any configuration changes
# (edit files in dev-02/nixos/ as needed)

# 3. Commit and push changes to GitHub
git add .
git commit -m "Update NixOS configuration"
git push origin main
```

### **For Target NixOS Machine** (applying the configuration):

```bash
# Complete one-liner deployment command:
cd /tmp && \
curl -L https://github.com/PadsterH2012/nixos/archive/refs/heads/main.tar.gz | tar -xz && \
sudo cp -r nixos-main/dev-02/nixos/* /etc/nixos/ && \
sudo nixos-rebuild switch

# Or step-by-step:

# 1. Download and extract configuration
cd /tmp
curl -L https://github.com/PadsterH2012/nixos/archive/refs/heads/main.tar.gz | tar -xz

# 2. Copy configuration to system location
sudo cp -r nixos-main/dev-02/nixos/* /etc/nixos/

# 3. Apply the configuration
sudo nixos-rebuild switch
```

### **Alternative Deployment Commands**:

```bash
# Test configuration without switching (safer)
sudo nixos-rebuild test

# Build configuration but don't activate
sudo nixos-rebuild build

# Switch with upgrade (updates packages)
sudo nixos-rebuild switch --upgrade

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```
## 🎯 What Each Configuration Provides

| Component | Provides |
|-----------|----------|
| **Desktop** | Cinnamon desktop, fonts, display tools, XRDP compatibility |
| **Development** | VS Code, Git, Docker, Node.js, Python, build tools |
| **Remote Access** | SSH + XRDP for remote desktop connections |
| **Terminal** | Modern CLI tools, aliases, tmux, development shortcuts |
| **VS Code** | Pre-configured IDE with extensions and settings |
| **Services** | Audio, NFS mounts (network repository), networking |

## 🔧 Post-Deployment Setup

After successful deployment, run these commands on the target machine:

```bash
# Verify VS Code extensions are installed (optional)
sudo /etc/vscode/verify-extensions.sh

# Set up user terminal configuration
sudo /etc/terminal/setup-user-terminal.sh

# Restart to ensure all services are running
sudo reboot
```

**Note**: VS Code extensions are now installed **declaratively** via NixOS configuration - no manual installation needed!

## 🌟 Features

### **Modern Development Environment**
- ✅ Cinnamon desktop optimized for remote access
- ✅ VS Code with pre-configured extensions
- ✅ Docker with auto-pruning
- ✅ Modern terminal tools (eza, bat, ripgrep, fzf)
- ✅ Git with helpful aliases and shortcuts
- ✅ Web browsers: Firefox and Google Chrome

### **Remote Access**
- ✅ SSH for command-line access
- ✅ XRDP for full desktop remote access
- ✅ Optimized for ultrawide monitors
- ✅ Multi-monitor support tools

### **Developer Productivity**
- ✅ Comprehensive shell aliases and shortcuts
- ✅ Custom bash prompt with Git branch display
- ✅ Tmux configuration with custom key bindings
- ✅ NFS client for network drives
- ✅ Automated setup scripts

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Search](https://search.nixos.org/packages)
- [NixOS Wiki](https://nixos.wiki/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

---

**Note**: This configuration creates a complete development environment with remote access capabilities, optimized for modern development workflows! 🚀