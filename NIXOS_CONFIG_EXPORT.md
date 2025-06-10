# 🚀 NixOS Configuration Export System

Universal system for exporting NixOS configurations from multiple machines to Git, with automatic network settings and hostname capture.

## 🎯 Quick Start

### Export from Current Machine
```bash
# Run on any NixOS machine to export its configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
```

### Export from Multiple Machines
```bash
# Download bulk export script
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/bulk-export-nixos.sh -o bulk-export.sh
chmod +x bulk-export.sh

# Export from specific machines
./bulk-export.sh nixos-dev-01 nixos-server-02 192.168.1.100

# Or use default machine list
./bulk-export.sh
```

## 📋 What Gets Exported

### 🖥️ **Machine Information**
- Hostname and NixOS version
- Export timestamp
- Primary network interface
- IP address and gateway
- DNS servers
- Network type (DHCP/Static/NetworkManager)

### 📁 **Configuration Files**
- Complete `/etc/nixos/` directory structure
- All modules, services, and applications
- Hardware configuration
- Custom configurations

### 🛠️ **Generated Files**
- `machine-info.yaml` - Complete machine and network details
- `deploy.sh` - Ready-to-use deployment script
- `README.md` - Machine-specific documentation
- NixOS network configuration examples

## 🌐 Repository Structure

After export, your repository will look like:
```
nixos/
├── nixos-dev-cinnamon/
│   ├── nixos/                    # Complete NixOS config
│   │   ├── configuration.nix
│   │   ├── modules/
│   │   ├── services/
│   │   └── applications/
│   ├── machine-info.yaml        # Machine details
│   ├── deploy.sh                # Deployment script
│   └── README.md                # Documentation
├── nixos-server-01/
│   ├── nixos/
│   ├── machine-info.yaml
│   ├── deploy.sh
│   └── README.md
└── export-nixos-config.sh       # Export script
```

## 🔧 Usage Examples

### Single Machine Export
```bash
# From the machine you want to export
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
```

### Remote Export via SSH
```bash
# Export from remote machine
ssh user@remote-machine 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash'
```

### Bulk Export from Management Machine
```bash
# Export from multiple machines at once
./bulk-export-nixos.sh \
  nixos-dev-01 \
  nixos-server-02 \
  192.168.1.100 \
  192.168.1.101
```

## 📊 Machine Info Example

Each export creates a detailed `machine-info.yaml`:

```yaml
machine:
  hostname: "nixos-dev-cinnamon"
  nixos_version: "24.11 (Vicuña)"
  export_date: "2025-06-09T21:30:00+00:00"
  
network:
  primary_ip: "192.168.1.100"
  primary_interface: "enp0s3"
  gateway: "192.168.1.1"
  dns_servers: "8.8.8.8 8.8.4.4"
  network_type: "NetworkManager (likely DHCP)"
  
nixos_network_config: |
  networking = {
    hostName = "nixos-dev-cinnamon";
    networkmanager.enable = true;
    # Static IP example included
  };
```

## 🚀 Deployment

### Quick Deploy to Same Machine
```bash
# Deploy exported config back to the same machine
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/HOSTNAME/deploy.sh | bash
```

### Deploy to Different Machine
```bash
# Clone and deploy manually
git clone https://github.com/PadsterH2012/nixos.git
cd nixos/HOSTNAME
./deploy.sh
```

### Cross-Machine Deployment
```bash
# Deploy config from machine A to machine B
ssh user@machine-b 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/machine-a/deploy.sh | bash'
```

## 🔄 Workflow Examples

### Development Workflow
```bash
# 1. Export current config
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash

# 2. Make changes via GitHub web interface or git clone

# 3. Deploy changes
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/HOSTNAME/deploy.sh | bash
```

### Multi-Machine Management
```bash
# 1. Export from all machines
./bulk-export-nixos.sh machine1 machine2 machine3

# 2. Make centralized changes in Git

# 3. Deploy to specific machines
ssh user@machine1 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/machine1/deploy.sh | bash'
ssh user@machine2 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/machine2/deploy.sh | bash'
```

## 🛡️ Security & Safety

### Safety Features
- ✅ **Hostname verification** in deployment scripts
- ✅ **Configuration backup** before deployment
- ✅ **Non-destructive export** (read-only operations)
- ✅ **Git history** for rollback capability

### Security Considerations
- 🔒 **SSH key authentication** recommended for remote operations
- 🔒 **Review configurations** before deployment
- 🔒 **Network settings** captured but not automatically applied
- 🔒 **Sensitive data** should be reviewed before committing

## 🔧 Customization

### Modify Default Machines
Edit `bulk-export-nixos.sh`:
```bash
DEFAULT_MACHINES=(
    "your-machine-1"
    "your-machine-2"
    "192.168.1.100"
)
```

### Custom Repository
Edit `export-nixos-config.sh`:
```bash
REPO_URL="https://github.com/yourusername/your-nixos-repo.git"
```

## 🐛 Troubleshooting

### Export Issues
```bash
# Check if machine is reachable
ping machine-hostname

# Test SSH access
ssh user@machine-hostname 'echo "SSH works"'

# Check internet connectivity on target
ssh user@machine-hostname 'curl -I https://github.com'
```

### Deployment Issues
```bash
# Check NixOS syntax
sudo nixos-rebuild dry-build

# Test configuration without switching
sudo nixos-rebuild test

# Rollback if needed
sudo nixos-rebuild switch --rollback
```

## 📚 Integration Examples

### CI/CD Pipeline
```yaml
# GitHub Actions example
- name: Export NixOS Config
  run: |
    ssh user@${{ matrix.machine }} 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash'
```

### Cron Job for Regular Exports
```bash
# Add to crontab for daily exports
0 2 * * * curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
```

### Monitoring Integration
```bash
# Export with notification
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash && \
  curl -X POST "https://hooks.slack.com/..." -d "Config exported from $(hostname)"
```

## 🎯 Benefits

- 🚀 **One-command export** from any NixOS machine
- 📊 **Complete machine documentation** with network details
- 🔄 **Git-based change management** with history
- 🌐 **Multi-machine coordination** from single repository
- 🛠️ **Ready-to-deploy scripts** for each machine
- 📋 **Network configuration capture** for easy migration
- 🔒 **Safe deployment** with hostname verification

Perfect for managing multiple NixOS machines, lab environments, or production deployments! 🎉
