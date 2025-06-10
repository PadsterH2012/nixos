# nixos-dev-cinnamon - NixOS Configuration

## Machine Information
- **Hostname**: nixos-dev-cinnamon
- **Primary MAC**: 02:42:a5:c4:77:56
- **All MACs**: 02:42:a5:c4:77:56 bc:24:11:07:02:2e 
- **Primary IP**: 
- **NixOS Version**: unknown
- **Configuration Type**: Traditional
- **Last Export**: Tue 10 Jun 15:33:36 BST 2025

## Network Configuration
- **Interface**: unknown
- **Gateway**: unknown
- **DNS**: 10.202.28.51 10.202.28.50 
- **Type**: Static/Unknown

## Deployment

### Quick Deploy
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/hosts/02:42:a5:c4:77:56/deploy.sh | bash
```

### Manual Deploy
```bash
git clone https://github.com/PadsterH2012/nixos.git
cd nixos/hosts/02:42:a5:c4:77:56
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
Current configuration uses Static/Unknown. See `machine-info.yaml` for detailed network settings and NixOS configuration examples.

## MAC Address Identification
This configuration is identified by MAC address `02:42:a5:c4:77:56` for reliable machine targeting across hostname changes.
