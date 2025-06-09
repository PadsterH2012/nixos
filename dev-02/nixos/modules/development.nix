# Development environment configuration module
# Development tools, packages, and Docker configuration

{ config, pkgs, ... }:

{
  # List packages installed in system profile - streamlined for development
  environment.systemPackages = with pkgs; [
    # Essential editors and development tools
    vscode  # Native VS Code for full system access
    vscode-fhs  # VS Code with FHS environment for better compatibility
    vim
    neovim
    git
    curl
    wget
    
    # Core development tools
    gcc
    gnumake
    nodejs
    nodePackages.npm
    python3
    python3Packages.pip
    docker
    docker-compose

    # Database tools
    mongodb-compass
    
    # Essential system utilities
    htop
    tree
    unzip
    zip
    file
    which
    
    # NFS utilities for mapped drives
    nfs-utils
    
    # Proxmox/VM utilities
    qemu-utils
    spice-vdagent

    # Node.js environment wrapper for script compatibility
    (writeShellScriptBin "ensure-node-path" ''
      export PATH="${nodejs}/bin:${nodePackages.npm}/bin:$PATH"
      exec "$@"
    '')

    # VS Code Flatpak development permissions setup script
    (writeShellScriptBin "setup-vscode-dev" ''
      #!/bin/bash
      echo "🔧 Setting up VS Code Flatpak for development..."

      # Grant comprehensive permissions for development
      if command -v flatpak >/dev/null 2>&1; then
        echo "📁 Granting filesystem access..."
        flatpak override --user --filesystem=host com.visualstudio.code 2>/dev/null || true
        flatpak override --user --filesystem=/nix com.visualstudio.code 2>/dev/null || true

        echo "🌐 Granting network and device access..."
        flatpak override --user --share=network com.visualstudio.code 2>/dev/null || true
        flatpak override --user --device=all com.visualstudio.code 2>/dev/null || true

        echo "🔌 Setting up environment..."
        flatpak override --user --env=PATH="/app/bin:/usr/bin:${nodejs}/bin:${nodePackages.npm}/bin:/run/current-system/sw/bin" com.visualstudio.code 2>/dev/null || true
        flatpak override --user --env=NODE_PATH="${nodejs}/lib/node_modules" com.visualstudio.code 2>/dev/null || true

        echo "✅ VS Code Flatpak configured for development!"
        echo "🔄 Please restart VS Code: flatpak kill com.visualstudio.code"
      else
        echo "❌ Flatpak not found. Please run from host system."
      fi
    '')
  ];

  # Enable Docker with additional configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Ensure Node.js tools are available in all shell environments
  environment.variables = {
    # Add Node.js to PATH for all users and scripts
    NODE_PATH = "${pkgs.nodejs}/lib/node_modules";
  };

  # Set up shell initialization for all users
  programs.bash.shellInit = ''
    # Ensure Node.js is in PATH for all bash sessions
    export PATH="${pkgs.nodejs}/bin:${pkgs.nodePackages.npm}/bin:$PATH"
  '';

  # Ensure system-wide profile includes Node.js
  environment.profileRelativeEnvVars = {
    PATH = [ "/bin" ];
  };

  # Create symlinks in standard locations for script compatibility
  environment.etc."profile.d/nodejs.sh" = {
    text = ''
      # Node.js environment setup for all shells
      export PATH="${pkgs.nodejs}/bin:${pkgs.nodePackages.npm}/bin:$PATH"
      export NODE_PATH="${pkgs.nodejs}/lib/node_modules"
    '';
    mode = "0644";
  };

  # Additional development environment setup
  environment.shellAliases = {
    # Node.js shortcuts with full paths for reliability
    node-version = "${pkgs.nodejs}/bin/node --version";
    npm-version = "${pkgs.nodePackages.npm}/bin/npm --version";
    npx-version = "${pkgs.nodePackages.npm}/bin/npx --version";

    # VS Code options for development
    code-native = "${pkgs.vscode}/bin/code";  # Native VS Code (full system access)
    code-fhs = "${pkgs.vscode-fhs}/bin/code";  # FHS VS Code (better compatibility)
    code-flatpak = "flatpak run com.visualstudio.code";  # Flatpak VS Code (OAuth)

    # Default to native for development
    code = "${pkgs.vscode}/bin/code";
  };
}
