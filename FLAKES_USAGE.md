# 🚀 NixOS Development Environment Flakes Guide

This repository uses Nix Flakes to manage multiple identical development VMs with reproducible builds and shared configurations.

## 📁 Repository Structure

```
nixos/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Locked dependency versions
├── shared/                      # Shared configurations
│   ├── profiles/
│   │   └── development.nix      # Master development profile
│   ├── modules/
│   │   ├── desktop.nix          # Cinnamon desktop setup
│   │   ├── development-tools.nix # Dev tools and terminal
│   │   ├── localization.nix     # Time zone and locale
│   │   └── hardware-common.nix  # Common VM hardware
│   ├── services/
│   │   ├── audio.nix            # PipeWire audio
│   │   ├── nfs.nix              # Network file systems
│   │   ├── remote-access.nix    # SSH and XRDP
│   │   ├── auto-update.nix      # Automatic updates
│   │   └── vscode-flatpak.nix   # VS Code Flatpak setup
│   ├── applications/
│   │   ├── vscode.nix           # VS Code configuration
│   │   ├── git.nix              # Git setup
│   │   ├── terminal.nix         # Terminal enhancements
│   │   └── augment.nix          # Augment Code optimization
│   └── home/
│       └── paddy.nix            # User-specific settings
└── hosts/                       # Host-specific configurations
    ├── nixos-dev-cinnamon/      # Current working machine
    │   ├── configuration.nix    # Host config (imports shared)
    │   ├── hardware-configuration.nix
    │   └── identity.nix         # Hostname, IP, wallpaper
    ├── dev-vm-01/               # Template for new VMs
    │   ├── configuration.nix
    │   ├── hardware-configuration.nix
    │   └── identity.nix
    └── dev-vm-02/ ... dev-vm-08/ # Ready for deployment
```

## 🎯 Core Concepts

### **Shared Development Profile**
All VMs inherit from `shared/profiles/development.nix` which includes:
- ✅ **Identical development tools** (Node.js, Python, Docker, VS Code)
- ✅ **Enhanced terminal** (exa, bat, fd, ripgrep, jq)
- ✅ **Cinnamon desktop** with development optimizations
- ✅ **VS Code Flatpak** with OAuth support and Node.js integration
- ✅ **Git configuration** and aliases
- ✅ **Augment Code compatibility** settings

### **Host-Specific Identity**
Each VM has unique `identity.nix` with:
- 🏷️ **Hostname** (nixos-dev-cinnamon, dev-vm-01, etc.)
- 🌐 **Network settings** (IP address, interface configuration)
- 🖼️ **Visual identity** (custom wallpaper, notifications)
- 🔧 **Host-specific overrides** (if needed)

## 🚀 Deployment Commands

### **Deploy to Specific Host**
```bash
# Deploy to current machine
sudo nixos-rebuild switch --flake .#nixos-dev-cinnamon

# Deploy to specialized development VMs
sudo nixos-rebuild switch --flake .#hl-dev-nixos-builder
sudo nixos-rebuild switch --flake .#hl-dev-ansible
sudo nixos-rebuild switch --flake .#hl-dev-mcp-proxy
sudo nixos-rebuild switch --flake .#hl-dev-rpger
sudo nixos-rebuild switch --flake .#hl-dev-adhd-calendar
sudo nixos-rebuild switch --flake .#hl-dev-rpger-extractor
sudo nixos-rebuild switch --flake .#hl-dev-instructor
sudo nixos-rebuild switch --flake .#hl-dev-rhel-satellite
sudo nixos-rebuild switch --flake .#hl-pad-nixos-main

# Test configuration without switching
sudo nixos-rebuild test --flake .#nixos-dev-cinnamon
```

### **Remote Deployment**
```bash
# Deploy to remote VM
ssh paddy@hl-dev-nixos-builder "cd /mnt/network_repo/nixos && sudo nixos-rebuild switch --flake .#hl-dev-nixos-builder"

# Deploy to all VMs (using included script)
nix run .#deploy-all
```

## 🌐 **Network Configuration**

All specialized development VMs use static IP addresses:

| Hostname | IP Address | Role | Purpose |
|----------|------------|------|---------|
| `hl-dev-nixos-builder` | 10.202.28.180 | NixOS Build Server | CI/CD, package building |
| `hl-dev-ansible` | 10.202.28.181 | Ansible Automation | Infrastructure management |
| `hl-dev-mcp-proxy` | 10.202.28.182 | MCP Proxy Services | Model Context Protocol |
| `hl-dev-rpger` | 10.202.28.183 | RPG Development | Game development tools |
| `hl-dev-adhd-calendar` | 10.202.28.184 | ADHD Calendar Tools | Productivity & scheduling |
| `hl-dev-rpger-extractor` | 10.202.28.185 | RPG Data Extraction | Data processing & scraping |
| `hl-dev-instructor` | 10.202.28.186 | AI Instruction Tools | AI training & development |
| `hl-dev-rhel-satellite` | 10.202.28.187 | RHEL Satellite Mgmt | Enterprise management |
| `hl-pad-nixos-main` | 10.202.28.188 | Main Workstation | Primary development |

**Network Settings:**
- Gateway: `10.202.28.1`
- DNS Servers: `10.202.28.50`, `10.202.28.51`
- Subnet: `10.202.28.0/24`

### **Update and Maintenance**
```bash
# Update flake inputs (get latest packages)
nix flake update

# Check flake for errors
nix flake check

# Show flake info
nix flake show

# Enter development shell
nix develop
```

## 🆕 Adding New Development VMs

### **Method 1: Copy Existing Host**
```bash
# Copy existing host configuration for new VM
cp -r hosts/hl-dev-nixos-builder hosts/hl-new-machine

# Edit identity configuration
nano hosts/hl-new-machine/identity.nix
# Change hostname to "hl-new-machine"
# Update IP address (next available: 10.202.28.189+)
# Update VM_ROLE and purpose variables

# Update hardware configuration with actual UUIDs
nano hosts/hl-new-machine/hardware-configuration.nix
# Replace REPLACE-WITH-ACTUAL-UUID with real values from new VM

# Add to flake.nix
nano flake.nix
# Add "hl-new-machine" = mkNixosConfiguration "hl-new-machine"; to nixosConfigurations

# Deploy
sudo nixos-rebuild switch --flake .#hl-new-machine
```

### **Method 2: Generate Hardware Config**
```bash
# On new VM, generate hardware configuration
sudo nixos-generate-config --root /mnt

# Copy generated hardware-configuration.nix to hosts/new-vm/
# Edit identity.nix with correct hostname and network settings
# Deploy as above
```

## 🔧 Customizing Configurations

### **Shared Changes (All VMs)**
Edit files in `shared/` directory:
- `shared/profiles/development.nix` - Add/remove packages for all VMs
- `shared/modules/development-tools.nix` - Modify development tools
- `shared/applications/vscode.nix` - Change VS Code settings

### **Host-Specific Changes**
Edit files in `hosts/hostname/`:
- `identity.nix` - Change hostname, IP, visual identity
- `configuration.nix` - Add host-specific overrides
- `hardware-configuration.nix` - Hardware-specific settings

### **Example: Add Package to All VMs**
```nix
# In shared/profiles/development.nix
environment.systemPackages = with pkgs; [
  # Existing packages...
  
  # Add new package for all VMs
  your-new-package
];
```

### **Example: Host-Specific Override**
```nix
# In hosts/special-vm/configuration.nix
{
  imports = [
    ../../shared/profiles/development.nix
    ./hardware-configuration.nix
    ./identity.nix
  ];

  # Override for this host only
  services.special-service.enable = true;
  environment.systemPackages = with pkgs; [ special-tool ];
}
```

## 🤖 AI Agent Integration

### **Augment Code Compatibility**
The configuration is optimized for AI agents:
- ✅ **Predictable bash environment** with consistent PATH
- ✅ **Enhanced terminal tools** (exa, bat, fd, ripgrep, jq)
- ✅ **Node.js and npm** properly configured for MCP servers
- ✅ **VS Code Flatpak** with full development access
- ✅ **Non-interactive operations** for automated deployment

### **MCP Server Configuration**
All VMs are pre-configured with MCP servers for AI agents:

**Available MCP Servers:**
- **central-proxmox** - `http://10.202.28.111:9090/proxmox-mcp/sse`
- **neo-mcp-proxy-control** - `http://10.202.28.182:3000/mcp-proxy/sse`
- **memory-mcp** - Local memory management
- **filesystem-mcp** - File system access
- **brave-search** - Web search capabilities

**Configuration Files Created:**
- Augment Code: `~/.config/augment/mcp-servers.json`
- Claude Desktop: `~/.config/claude-desktop/claude_desktop_config.json`
- Cline: `~/.config/cline/mcp-servers.json`
- VS Code: `~/.var/app/com.visualstudio.code/config/Code/User/mcp-servers.json`

**MCP Management Commands:**
```bash
# Test MCP server connectivity
mcp-test

# View MCP configuration
mcp-config

# Check Proxmox MCP health
mcp-proxmox

# Check MCP proxy health
mcp-proxy
```

### **AI Agent Commands**
```bash
# Check system status
systemctl status

# Rebuild system
sudo nixos-rebuild switch --flake /mnt/network_repo/nixos

# Update flake
cd /mnt/network_repo/nixos && nix flake update

# Test MCP server
npx -y @upstash/context7-mcp@latest

# Check development environment
node --version && npm --version && code --version
```

## 🔄 Maintenance Workflows

### **Weekly Updates**
```bash
# Update flake inputs
nix flake update

# Test on one VM first
sudo nixos-rebuild test --flake .#dev-vm-01

# Deploy to all VMs if successful
nix run .#deploy-all
```

### **Rollback if Issues**
```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or specify specific generation
sudo nixos-rebuild switch --switch-generation 123
```

### **Cleanup**
```bash
# Clean old generations (automatic via auto-update.nix)
sudo nix-collect-garbage --delete-older-than 30d

# Optimize store
nix store optimise
```

## 🎨 Visual Identity Setup

### **Custom Wallpapers**
1. Create wallpapers showing VM identity:
   ```
   Machine: dev-vm-01
   IP: 10.202.28.101
   Role: Development
   ```

2. Place in `wallpapers/dev-vm-01.png`

3. Uncomment wallpaper lines in `identity.nix`

### **Desktop Notifications**
Each VM shows identity notification on login via `identity.nix` configuration.

## 🔒 Security Notes

- **Sudo without password** enabled for development convenience
- **SSH access** enabled with password authentication
- **Firewall** configured for SSH (22) and XRDP (3389)
- **Auto-updates** enabled for security patches

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [Home Manager](https://github.com/nix-community/home-manager)

## 🆘 Troubleshooting

### **Common Issues**
1. **Flake not found**: Ensure you're in `/mnt/network_repo/nixos`
2. **Permission denied**: Use `sudo` for nixos-rebuild commands
3. **Network issues**: Check `identity.nix` network configuration
4. **VS Code OAuth**: Ensure Flatpak VS Code is installed and configured

### **Debug Commands**
```bash
# Check flake syntax
nix flake check

# Show configuration
nixos-option system.stateVersion

# Check services
systemctl status configure-vscode-flatpak

# View logs
journalctl -u configure-vscode-flatpak
```

This flakes-based setup provides reproducible, maintainable development environments with minimal code duplication and maximum consistency across all VMs! 🎉
