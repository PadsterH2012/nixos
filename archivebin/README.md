# 📦 Archive Bin

This folder contains historical files and scripts that were used during the development and testing phases of the NixOS configuration setup. These files are preserved for reference but are no longer part of the active NixOS configuration.

## 📁 Contents

### **Configuration Development Files**
- `APPLICATION_CONFIG_GUIDE.md` - Early application configuration guide
- `current.nix` - Previous configuration iterations
- `new1.01.nix` - Development configuration versions
- `dev-streamlined.nix` - Streamlined development attempts

### **VS Code Setup Scripts**
- `install_vscode_flatpak.sh` - VS Code Flatpak installation script
- `setup_complete_vscode_environment.sh` - Complete VS Code environment setup
- `setup_vscode_oauth_user.sh` - OAuth setup for VS Code
- `vscode_oauth_test_script.sh` - OAuth testing scripts
- `run_remote_vscode_test.sh` - Remote VS Code testing

### **MCP (Model Context Protocol) Configuration**
- `augment-mcp-config.json` - Augment MCP configuration
- `augment-mcpServers-updated.json` - Updated MCP servers config
- `claude-desktop-config.json` - Claude desktop configuration
- `cline-mcp-config.json` - Cline MCP configuration
- `apply_augment_mcp_settings.sh` - MCP settings application script
- `mcp-proxy-scripts/` - MCP proxy scripts directory
- `MCP-UNIVERSAL-CONFIG.md` - Universal MCP configuration guide

### **Development and Testing Scripts**
- `nixos-autoconfig-script.sh` - Automated NixOS configuration script
- `nixos-dev-test.sh` - Development testing script
- `capture-config.sh` - Configuration capture utility
- `deploy-with-apps.sh` - Deployment with applications
- `test-config.sh` - Configuration testing
- `migrate-to-flakes.sh` - Migration script to flakes (completed)

### **Export and Management Tools**
- `export-nixos-config-authenticated.sh` - Authenticated export script
- Various export and setup utilities (replaced by flakes)

### **Documentation**
- `README.md` - Previous repository README (this file, now updated)
- `nixos_git_guide.md` - Git guide for NixOS
- `NIXOS_DEV_TESTING.md` - Development testing documentation
- `VSCODE_TEST_USAGE.md` - VS Code testing usage guide
- `VS_Code_OAuth_Authentication_Analysis_Report.md` - OAuth analysis
- `Bidirectional NixOS Configuration Management.md` - Configuration management guide

### **Development Directories**
- `dev-01/` - Development configuration directory

## 🎯 Current Status

All functionality from these archived files has been:
- ✅ **Integrated into the flakes-based configuration** in the `shared/` directory
- ✅ **Replaced by declarative NixOS modules** for better maintainability
- ✅ **Documented in FLAKES_USAGE.md** for ongoing reference

## 🗂️ Repository Structure Now

The main repository now contains only:
```
nixos/
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependencies
├── FLAKES_USAGE.md        # Comprehensive usage guide
├── shared/                # Shared NixOS configurations
├── hosts/                 # Host-specific configurations
└── archivebin/            # This archive (historical files)
```

## 🔄 Migration Complete

The migration from individual scripts and configurations to a clean, flakes-based NixOS system is complete. These archived files represent the development journey and are kept for historical reference and potential future insights.

**Note**: These files are no longer maintained and should not be used for active configuration management. Use the flakes-based system in the main repository instead.

