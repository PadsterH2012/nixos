# NixOS Development Configuration - dev-02 (Cinnamon Desktop)

This directory contains a modular NixOS configuration for development environments using Cinnamon desktop environment, optimized for Proxmox VMs with XRDP access and ultrawide monitor support.

## 🎯 Perfect for Your Use Case

This configuration is specifically designed for:
- **Proxmox VM deployment** with excellent performance
- **XRDP remote desktop access** for seamless connectivity
- **Ultrawide monitor support** with proper scaling and multi-monitor handling
- **Development workflow** with VS Code, Git, Docker, and terminal access
- **Professional appearance** with modern, polished Cinnamon interface

## 🚀 Quick Deployment (Recommended)

**One-command deployment** using the automated script:

```bash
curl -s https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/deploy.sh | bash
```

This script will:
- ✅ Backup your existing configuration
- ✅ Download all required files
- ✅ Verify the installation
- ✅ Apply the configuration
- ✅ Provide next steps

### Alternative: Archive Download Method

```bash
# Download the entire dev-02 configuration
cd /tmp && \
curl -L https://github.com/PadsterH2012/nixos/archive/refs/heads/main.tar.gz | tar -xz && \
sudo cp -r nixos-main/dev-02/nixos/* /etc/nixos/ && \
sudo nixos-rebuild switch
```

### Alternative: Manual Download Method

```bash
# Create directories
sudo mkdir -p /etc/nixos/modules /etc/nixos/services

# Download all configuration files
sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/configuration.nix
sudo curl -o /etc/nixos/modules/hardware.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/modules/hardware.nix
sudo curl -o /etc/nixos/modules/networking.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/modules/networking.nix
sudo curl -o /etc/nixos/modules/localization.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/modules/localization.nix
sudo curl -o /etc/nixos/modules/desktop.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/modules/desktop.nix
sudo curl -o /etc/nixos/modules/development.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/modules/development.nix
sudo curl -o /etc/nixos/services/audio.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/services/audio.nix
sudo curl -o /etc/nixos/services/nfs.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/services/nfs.nix
sudo curl -o /etc/nixos/services/remote-access.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-02/nixos/services/remote-access.nix

# Apply the configuration
sudo nixos-rebuild switch
```

## Structure

```
nixos/
├── configuration.nix          # Main configuration file with imports
├── modules/                   # Custom modules directory
│   ├── desktop.nix           # Cinnamon desktop environment
│   ├── development.nix       # Development tools, Docker, packages
│   ├── hardware.nix          # Boot loader, kernel modules, Proxmox optimizations
│   ├── localization.nix      # Time zone, locale, keyboard settings
│   └── networking.nix        # Network settings, hostname, firewall
└── services/                  # Service-specific configurations
    ├── audio.nix             # PipeWire audio configuration
    ├── nfs.nix               # NFS client support for mapped drives
    └── remote-access.nix     # SSH and XRDP configuration for Cinnamon
```

## Features

- **Modern Cinnamon Desktop** with professional appearance
- **Full XRDP Support** for seamless remote desktop access
- **Ultrawide Monitor Optimized** with proper scaling and multi-monitor support
- **No auto-login** for security
- **Development Tools**: VS Code, Git, Docker, Node.js, Python
- **NFS Client Support** for mapped network drives
- **Proxmox VM Optimizations** with QEMU guest agent
- **Audio Support** via PipeWire
- **UK Localization** (timezone, keyboard, locale)

## Cinnamon Desktop Features

- **Modern Interface** - Clean, professional appearance perfect for ultrawide monitors
- **Multi-Monitor Support** - Excellent handling of multiple displays and scaling
- **Customizable Panels** - Taskbar, system tray, and workspace management
- **File Manager** - Nemo file manager with advanced features
- **System Settings** - Comprehensive configuration options
- **Theme Support** - Beautiful themes that scale well on high-resolution displays

## Manual Installation

1. Clone or download the configuration files
2. Copy the entire `nixos/` directory to `/etc/nixos/`
3. Run `sudo nixos-rebuild switch`

## XRDP Remote Desktop Access

**Perfect for your use case**: Full XRDP support with Cinnamon desktop:
- **Seamless RDP connection** from Windows, Mac, or Linux clients
- **Full desktop experience** with all applications and features
- **Excellent performance** over network connections
- **Multi-monitor support** when connecting from ultrawide setups
- **Automatic session management** and reconnection support

## Ultrawide Monitor Optimization

Cinnamon provides excellent ultrawide monitor support:
- **Proper scaling** for high-DPI displays
- **Multi-monitor configuration** tools (arandr, autorandr)
- **Workspace management** across multiple displays
- **Panel positioning** optimized for ultrawide layouts
- **Window snapping** and management for productivity

## User Account

The configuration creates a user account named "paddy" with:
- Manual login required (no auto-login for security)
- Docker group membership
- NetworkManager and wheel group access
- Firefox browser included

Remember to set a password with `passwd paddy` after installation.

## Customization

Each module can be independently modified or disabled by commenting out the import in `configuration.nix`. This modular approach makes it easy to:

- Add new development tools in `modules/development.nix`
- Configure additional services in the `services/` directory
- Modify Sway settings in `modules/desktop.nix`
- Adjust network or firewall settings in `modules/networking.nix`
