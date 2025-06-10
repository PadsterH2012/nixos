# nixos-dev-cinnamon - NixOS Configuration

## Machine Information
- **Hostname**: nixos-dev-cinnamon
- **Primary MAC**: bc:24:11:07:02:2e
- **All MACs**: 02:42:a5:c4:77:56 bc:24:11:07:02:2e 
- **Primary IP**: 10.202.28.188
- **NixOS Version**: 24.11.718657.ed29f002b6d6 (Vicuna)
- **Configuration Type**: Traditional
- **Last Export**: Tue 10 Jun 16:11:34 BST 2025

## Network Configuration
- **Interface**: ens18
- **Gateway**: 10.202.28.1
- **DNS**: 10.202.28.51 10.202.28.50 
- **Type**: NetworkManager (likely DHCP)

## Deployment

### Quick Deploy
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/hosts/bc:24:11:07:02:2e/deploy.sh | bash
```

### Manual Deploy
```bash
git clone https://github.com/PadsterH2012/nixos.git
cd nixos/hosts/bc:24:11:07:02:2e
./deploy.sh
```

## Files Structure

- `configuration.nix` - Main NixOS configuration
- `hardware-configuration.nix` - Hardware-specific settings
- `modules/` - Configuration modules
- `services/` - Service configurations
- `applications/` - Application configurations
- `machine-info.yaml` - Machine and network information
- `deploy.sh` - Deployment script
- `README.md` - This file

## Configuration Type
This machine uses **traditional NixOS** configuration management.

## Network Settings
Current configuration uses NetworkManager (likely DHCP). See `machine-info.yaml` for detailed network settings and NixOS configuration examples.

## MAC Address Identification
This configuration is identified by MAC address `bc:24:11:07:02:2e` for reliable machine targeting across hostname changes.
