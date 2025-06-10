# 🚀 Application Configuration Capture & Deployment Guide

## Overview
NixOS excels at capturing and reproducing application configurations. This guide shows you how to capture, version, and deploy application settings across multiple systems.

## 🎯 **Methods for Capturing Application Config**

### 1. **Declarative Configuration (Recommended)**
Configure applications directly in NixOS modules - most reliable method.

### 2. **Home Manager Integration**
Manage user-specific application configurations.

### 3. **Configuration File Templates**
Template important config files for deployment.

### 4. **Dotfiles Management**
Version control application dotfiles and settings.

---

## 📁 **Current Configuration Structure**

```
nixos/
├── configuration.nix          # Main system configuration
├── modules/                   # System-level modules
│   ├── desktop.nix           # Desktop environment settings
│   ├── development.nix       # Development tools & packages
│   ├── hardware.nix          # Hardware-specific settings
│   ├── localization.nix      # Locale, timezone, keyboard
│   └── networking.nix        # Network configuration
├── services/                  # Service configurations
│   ├── audio.nix             # Audio system settings
│   ├── nfs.nix               # NFS client configuration
│   └── remote-access.nix     # SSH & XRDP settings
└── applications/             # Application-specific configs (NEW)
    ├── vscode.nix            # VS Code settings & extensions
    ├── git.nix               # Git global configuration
    ├── terminal.nix          # Terminal preferences
    └── browser.nix           # Browser settings
```

---

## 🛠️ **Implementation Examples**

### **VS Code Configuration**
```nix
# applications/vscode.nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode
  ];

  # VS Code settings via Home Manager (user-specific)
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.cpptools
      ms-vscode-remote.remote-ssh
      bbenoist.nix
    ];
    userSettings = {
      "editor.fontSize" = 14;
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "workbench.colorTheme" = "Dark+ (default dark)";
      "terminal.integrated.shell.linux" = "${pkgs.bash}/bin/bash";
    };
  };
}
```

### **Git Configuration**
```nix
# applications/git.nix
{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Paddy";
        email = "paddy@bastiondata.com";
      };
      core = {
        editor = "code --wait";
        autocrlf = "input";
      };
      push = {
        default = "simple";
      };
      pull = {
        rebase = true;
      };
    };
  };
}
```

### **Terminal Configuration**
```nix
# applications/terminal.nix
{ config, pkgs, ... }:

{
  # Configure default shell and terminal settings
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      grep = "grep --color=auto";
      rebuild = "sudo nixos-rebuild switch";
      update = "sudo nixos-rebuild switch --upgrade";
    };
    bashrcExtra = ''
      # Custom prompt
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      
      # Development shortcuts
      export EDITOR=code
      export BROWSER=firefox
    '';
  };
}
```

---

## 🏠 **Home Manager Integration**

### **Setup Home Manager**
```nix
# Add to configuration.nix imports
{
  imports = [
    <home-manager/nixos>
    # ... other imports
  ];

  # Enable Home Manager for user
  home-manager.users.paddy = { pkgs, ... }: {
    home.stateVersion = "23.11";
    
    # Import application configurations
    imports = [
      ./applications/vscode.nix
      ./applications/git.nix
      ./applications/terminal.nix
    ];
  };
}
```

---

## 📋 **Configuration Capture Workflow**

### **Step 1: Identify Applications to Configure**
- VS Code (settings, extensions, keybindings)
- Git (user info, aliases, preferences)
- Terminal (shell, aliases, prompt)
- Browser (bookmarks, extensions)
- Desktop environment (themes, panels, shortcuts)

### **Step 2: Create Application Modules**
```bash
# Create application configuration directory
mkdir -p nixos/applications

# Create individual application configs
touch nixos/applications/vscode.nix
touch nixos/applications/git.nix
touch nixos/applications/terminal.nix
touch nixos/applications/browser.nix
```

### **Step 3: Extract Current Settings**
```bash
# VS Code settings
cp ~/.config/Code/User/settings.json /tmp/vscode-settings.json

# Git configuration
git config --list --global > /tmp/git-config.txt

# Shell configuration
cp ~/.bashrc /tmp/bashrc-backup
```

### **Step 4: Convert to Nix Configuration**
Transform extracted settings into Nix modules using the examples above.

---

## 🚀 **Deployment Strategy**

### **Method 1: Direct Integration**
Add application modules to main configuration:

```nix
# configuration.nix
{
  imports = [
    # ... existing imports
    ./applications/vscode.nix
    ./applications/git.nix
    ./applications/terminal.nix
  ];
}
```

### **Method 2: Environment-Specific Configs**
```nix
# Create environment-specific application sets
./applications/
├── development.nix       # Dev-focused applications
├── desktop.nix          # Desktop applications
└── server.nix           # Server applications
```

### **Method 3: User Profiles**
```nix
# Different user configurations
./profiles/
├── developer.nix        # Developer user profile
├── admin.nix           # Admin user profile
└── standard.nix        # Standard user profile
```

---

## 🔄 **Automated Deployment**

### **Enhanced Deploy Script**
```bash
#!/bin/bash
# Enhanced deployment with application configs

ENVIRONMENT=${1:-dev-02}
CONFIG_BACKUP="/tmp/nixos-config-backup-$(date +%Y%m%d-%H%M%S)"

echo "🚀 Deploying NixOS configuration: $ENVIRONMENT"

# Backup current configuration
sudo cp -r /etc/nixos "$CONFIG_BACKUP"

# Deploy new configuration
sudo cp -r "$ENVIRONMENT/nixos/"* /etc/nixos/

# Apply configuration
sudo nixos-rebuild switch

echo "✅ Deployment complete!"
echo "📁 Backup saved to: $CONFIG_BACKUP"
```

---

## 📊 **Best Practices**

### **1. Version Control Everything**
- Keep all configurations in Git
- Use meaningful commit messages
- Tag stable configurations

### **2. Test Before Deployment**
- Use `nixos-rebuild test` first
- Keep rollback options available
- Test in development environment

### **3. Modular Design**
- Separate concerns into modules
- Make configurations reusable
- Use parameters for customization

### **4. Documentation**
- Document configuration choices
- Include setup instructions
- Maintain change logs

---

## 🎯 **Next Steps**

1. **Choose applications to configure**
2. **Create application modules**
3. **Test configurations**
4. **Update deployment scripts**
5. **Document the process**

This approach gives you reproducible, version-controlled application configurations that can be deployed consistently across multiple systems! 🚀
