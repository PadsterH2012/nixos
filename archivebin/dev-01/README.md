# NixOS Development Configuration - dev-01

This directory contains a modular NixOS configuration for development environments, organized into logical components for better maintainability and reusability.

## Quick Deployment

To deploy this configuration directly from GitHub:

```bash
curl -o /tmp/configuration.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-01/nixos/configuration.nix && sudo nixos-rebuild switch -I nixos-config=/tmp/configuration.nix
```

## Structure

```
nixos/
├── configuration.nix          # Main configuration file with imports
├── modules/                   # Custom modules directory
│   ├── desktop.nix           # X11, XFCE desktop, display manager
│   ├── development.nix       # Development tools, Docker, packages
│   ├── hardware.nix          # Boot loader, kernel modules, Proxmox optimizations
│   ├── localization.nix      # Time zone, locale, keyboard settings
│   └── networking.nix        # Network settings, hostname, firewall
└── services/                  # Service-specific configurations
    ├── audio.nix             # PipeWire audio configuration
    ├── nfs.nix               # NFS client support for mapped drives
    └── remote-access.nix     # SSH and XRDP configuration
```

## Features

- **Lightweight XFCE Desktop Environment** (no auto-login for security)
- **Development Tools**: VS Code, Git, Docker, Node.js, Python
- **Remote Access**: SSH and XRDP support
- **NFS Client Support** for mapped network drives
- **Proxmox VM Optimizations** with QEMU guest agent
- **Audio Support** via PipeWire
- **UK Localization** (timezone, keyboard, locale)

## Manual Installation

1. Clone or download the configuration files
2. Copy the entire `nixos/` directory to `/etc/nixos/`
3. Run `sudo nixos-rebuild switch`

## Customization

Each module can be independently modified or disabled by commenting out the import in `configuration.nix`. This modular approach makes it easy to:

- Add new development tools in `modules/development.nix`
- Configure additional services in the `services/` directory
- Modify desktop settings in `modules/desktop.nix`
- Adjust network or firewall settings in `modules/networking.nix`

## User Account

The configuration creates a user account named "paddy" with:
- Manual login required (no auto-login for security)
- Docker group membership
- NetworkManager and wheel group access
- Firefox browser included

Remember to set a password with `passwd paddy` after installation.
