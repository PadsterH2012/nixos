# VS Code Flatpak Development Permissions Service
# Automatically configures Flatpak VS Code with full development access
# This runs as a system service to grant necessary permissions

{ config, pkgs, ... }:

{
  # Service to configure VS Code Flatpak permissions for development
  systemd.services.configure-vscode-flatpak = {
    description = "Configure VS Code Flatpak for development access";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-system-helper.service" ];
    wants = [ "flatpak-system-helper.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Run as the user who needs VS Code access
      User = "paddy";
      Group = "users";
    };
    
    script = ''
      # Wait for flatpak to be ready
      sleep 5

      # Create VS Code Flatpak data directories for Node.js
      mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin
      mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/lib
      chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/data/node_modules || true

      # Create Node.js symlinks in Flatpak-accessible location
      ln -sf ${pkgs.nodejs}/bin/node /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/node
      ln -sf ${pkgs.nodejs}/bin/npm /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npm
      ln -sf ${pkgs.nodejs}/bin/npx /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npx
      ln -sf ${pkgs.nodejs}/lib/node_modules /home/paddy/.var/app/com.visualstudio.code/data/node_modules/lib/node_modules

      echo "Node.js symlinks created for VS Code Flatpak"

      # Check if VS Code Flatpak is installed
      if ${pkgs.flatpak}/bin/flatpak list --user | grep -q com.visualstudio.code; then
        echo "Configuring VS Code Flatpak permissions for development..."
        
        # Grant comprehensive filesystem access
        ${pkgs.flatpak}/bin/flatpak override --user --filesystem=host com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --filesystem=/nix com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --filesystem=/tmp com.visualstudio.code || true
        
        # Grant network access
        ${pkgs.flatpak}/bin/flatpak override --user --share=network com.visualstudio.code || true
        
        # Grant device access
        ${pkgs.flatpak}/bin/flatpak override --user --device=all com.visualstudio.code || true
        
        # Set up environment for Node.js access
        ${pkgs.flatpak}/bin/flatpak override --user --env=PATH="${pkgs.nodejs}/bin:/app/bin:/usr/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin" com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --env=NODE_PATH="${pkgs.nodejs}/lib/node_modules" com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --env=NPM_CONFIG_PREFIX="/home/paddy/.var/app/com.visualstudio.code/data/node_modules" com.visualstudio.code || true
        
        # Grant system bus access for development tools
        ${pkgs.flatpak}/bin/flatpak override --user --system-talk-name=org.freedesktop.systemd1 com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --system-talk-name=org.freedesktop.login1 com.visualstudio.code || true
        
        # Grant session bus access for keyring (OAuth)
        ${pkgs.flatpak}/bin/flatpak override --user --talk-name=org.freedesktop.secrets com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --talk-name=org.gnome.keyring com.visualstudio.code || true
        
        # Grant socket access
        ${pkgs.flatpak}/bin/flatpak override --user --socket=x11 com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --socket=wayland com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --socket=pulseaudio com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --socket=session-bus com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --socket=system-bus com.visualstudio.code || true
        
        echo "VS Code Flatpak configured for development access!"
      else
        echo "VS Code Flatpak not found - will configure when installed"
      fi
    '';
  };

  # User service to ensure Node.js symlinks are always available
  systemd.user.services.vscode-nodejs-symlinks = {
    description = "Create Node.js symlinks for VS Code Flatpak";
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Create directories
      mkdir -p ~/.var/app/com.visualstudio.code/data/node_modules/bin
      mkdir -p ~/.var/app/com.visualstudio.code/data/node_modules/lib

      # Create Node.js symlinks
      ln -sf ${pkgs.nodejs}/bin/node ~/.var/app/com.visualstudio.code/data/node_modules/bin/node
      ln -sf ${pkgs.nodejs}/bin/npm ~/.var/app/com.visualstudio.code/data/node_modules/bin/npm
      ln -sf ${pkgs.nodejs}/bin/npx ~/.var/app/com.visualstudio.code/data/node_modules/bin/npx
      ln -sf ${pkgs.nodejs}/lib/node_modules ~/.var/app/com.visualstudio.code/data/node_modules/lib/node_modules

      echo "Node.js symlinks created for user session"
    '';
  };

  # Create a user script to manually trigger permission setup
  environment.etc."vscode/configure-flatpak-dev.sh" = {
    text = ''
      #!/bin/bash
      # Manual VS Code Flatpak permission configuration
      
      echo "🔧 Configuring VS Code Flatpak for development..."
      
      if ! command -v flatpak >/dev/null 2>&1; then
        echo "❌ Flatpak not found in PATH"
        echo "💡 Try running: sudo systemctl restart configure-vscode-flatpak"
        exit 1
      fi
      
      if ! flatpak list --user | grep -q com.visualstudio.code; then
        echo "❌ VS Code Flatpak not installed"
        echo "💡 Install with: flatpak install flathub com.visualstudio.code"
        exit 1
      fi
      
      echo "📁 Granting filesystem access..."
      flatpak override --user --filesystem=host com.visualstudio.code
      flatpak override --user --filesystem=/nix com.visualstudio.code
      
      echo "🌐 Granting network and device access..."
      flatpak override --user --share=network com.visualstudio.code
      flatpak override --user --device=all com.visualstudio.code
      
      echo "🔧 Setting up Node.js environment..."
      flatpak override --user --env=PATH="/app/bin:/usr/bin:${pkgs.nodejs}/bin:${pkgs.nodePackages.npm}/bin:/run/current-system/sw/bin" com.visualstudio.code
      flatpak override --user --env=NODE_PATH="${pkgs.nodejs}/lib/node_modules" com.visualstudio.code
      
      echo "✅ Configuration complete!"
      echo "🔄 Please restart VS Code: flatpak kill com.visualstudio.code"
    '';
    mode = "0755";
  };
  
  # Shell alias for easy access
  environment.shellAliases = {
    configure-vscode-dev = "/etc/vscode/configure-flatpak-dev.sh";
  };

  # Activation script to ensure Node.js symlinks are created immediately
  system.activationScripts.vscode-nodejs-setup = ''
    # Create VS Code Flatpak Node.js symlinks during system activation
    mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin
    mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/lib

    # Create symlinks
    ln -sf ${pkgs.nodejs}/bin/node /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/node
    ln -sf ${pkgs.nodejs}/bin/npm /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npm
    ln -sf ${pkgs.nodejs}/bin/npx /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npx
    ln -sf ${pkgs.nodejs}/lib/node_modules /home/paddy/.var/app/com.visualstudio.code/data/node_modules/lib/node_modules

    # Set proper ownership
    chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/data/node_modules 2>/dev/null || true

    echo "VS Code Flatpak Node.js environment configured"
  '';
}
