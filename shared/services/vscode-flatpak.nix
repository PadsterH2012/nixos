# VS Code Flatpak Configuration Service
# Automatically configures VS Code Flatpak for development with OAuth support

{ config, pkgs, ... }:

{
  # Enable Flatpak
  services.flatpak.enable = true;

  # Service to configure VS Code Flatpak permissions for development
  systemd.services.configure-vscode-flatpak = {
    description = "Configure VS Code Flatpak for development access";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-system-helper.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
    
    script = ''
      # Wait for flatpak to be ready
      sleep 5
      
      # Create VS Code Flatpak data directories for Node.js (only if writable)
      if [ -w /home/paddy/.var/app/com.visualstudio.code ] || mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin 2>/dev/null; then
        mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin || true
        chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/data 2>/dev/null || true
        
        # Create Node.js symlinks in Flatpak-accessible location
        ln -sf ${pkgs.nodejs}/bin/node /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/node 2>/dev/null || true
        ln -sf ${pkgs.nodejs}/bin/npm /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npm 2>/dev/null || true
        ln -sf ${pkgs.nodejs}/bin/npx /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npx 2>/dev/null || true
        
        echo "Node.js symlinks created for VS Code Flatpak"
      else
        echo "VS Code Flatpak directory not writable, skipping symlink creation"
      fi
      
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
        
        # Set up environment for Node.js access and terminal tools
        ${pkgs.flatpak}/bin/flatpak override --user --env=PATH="${pkgs.nodejs}/bin:${pkgs.eza}/bin:${pkgs.bat}/bin:${pkgs.fd}/bin:${pkgs.ripgrep}/bin:${pkgs.jq}/bin:/app/bin:/usr/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin" com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --env=NODE_PATH="${pkgs.nodejs}/lib/node_modules" com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --env=NPM_CONFIG_PREFIX="/home/paddy/.var/app/com.visualstudio.code/data/node_modules" com.visualstudio.code || true
        
        # Terminal and editor environment for Augment Code
        ${pkgs.flatpak}/bin/flatpak override --user --env=EDITOR="code --wait" com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --env=PAGER="less" com.visualstudio.code || true
        ${pkgs.flatpak}/bin/flatpak override --user --env=TERM="xterm-256color" com.visualstudio.code || true
        
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
        
        echo "VS Code Flatpak configured for development access with Node.js symlinks!"
      else
        echo "VS Code Flatpak not found - Node.js symlinks created, will configure Flatpak when installed"
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

      # Create Node.js symlinks (only if not already present)
      if [ ! -L ~/.var/app/com.visualstudio.code/data/node_modules/bin/node ]; then
        ln -sf ${pkgs.nodejs}/bin/node ~/.var/app/com.visualstudio.code/data/node_modules/bin/node
      fi
      if [ ! -L ~/.var/app/com.visualstudio.code/data/node_modules/bin/npm ]; then
        ln -sf ${pkgs.nodejs}/bin/npm ~/.var/app/com.visualstudio.code/data/node_modules/bin/npm
      fi
      if [ ! -L ~/.var/app/com.visualstudio.code/data/node_modules/bin/npx ]; then
        ln -sf ${pkgs.nodejs}/bin/npx ~/.var/app/com.visualstudio.code/data/node_modules/bin/npx
      fi

      echo "Node.js symlinks ensured for user session"
    '';
  };

  # Shell alias for easy access
  environment.shellAliases = {
    configure-vscode-dev = "systemctl --user restart vscode-nodejs-symlinks";
  };

  # Activation script to ensure Node.js symlinks are created immediately
  system.activationScripts.vscode-nodejs-setup = ''
    # Create VS Code Flatpak Node.js symlinks during system activation (if possible)
    if [ -d /home/paddy ] && [ ! -f /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/node ]; then
      mkdir -p /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin 2>/dev/null || true
      
      # Create symlinks only if directory is writable
      if [ -w /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin ] 2>/dev/null; then
        ln -sf ${pkgs.nodejs}/bin/node /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/node 2>/dev/null || true
        ln -sf ${pkgs.nodejs}/bin/npm /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npm 2>/dev/null || true
        ln -sf ${pkgs.nodejs}/bin/npx /home/paddy/.var/app/com.visualstudio.code/data/node_modules/bin/npx 2>/dev/null || true
        
        # Set proper ownership
        chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/data 2>/dev/null || true
        
        echo "VS Code Flatpak Node.js environment configured"
      else
        echo "VS Code Flatpak directory not yet writable, will be configured by user service"
      fi
    fi
  '';

  # Create VS Code settings for optimal terminal experience
  system.activationScripts.vscode-terminal-settings = ''
    # Create VS Code settings directories
    mkdir -p /home/paddy/.var/app/com.visualstudio.code/config/Code/User
    mkdir -p /home/paddy/.config/Code/User

    # VS Code settings optimized for Augment Code with MCP integration
    cat > /home/paddy/.var/app/com.visualstudio.code/config/Code/User/settings.json << 'EOF'
{
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.confirmOnExit": "never",
  "terminal.integrated.confirmOnKill": "never",
  "terminal.integrated.enableBell": false,
  "editor.fontSize": 14,
  "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.wordWrap": "on",
  "editor.minimap.enabled": true,
  "editor.rulers": [80, 120],
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "vs-seti",
  "workbench.startupEditor": "newUntitledFile",
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "git.autofetch": true,
  "telemetry.telemetryLevel": "off",
  "update.showReleaseNotes": false,
  "augment.enableTelemetry": false,
  "augment.enableAnalytics": false,
  "augment.autoIndex": true,
  "augment.mcpServers": {
    "central-obsidian": {
      "url": "http://10.202.28.111:9090/obsidian-mcp-tools/sse"
    },
    "central-rpg": {
      "url": "http://10.202.28.111:9090/rpg-tools/sse"
    },
    "central-search": {
      "url": "http://10.202.28.111:9090/brave-search/sse"
    },
    "central-memory": {
      "url": "http://10.202.28.111:9090/memory/sse"
    },
    "central-mongodb": {
      "url": "http://10.202.28.111:9090/mongodb/sse"
    },
    "central-context7": {
      "url": "http://10.202.28.111:9090/Context7/sse"
    },
    "central-jenkins": {
      "url": "http://10.202.28.111:9090/jenkins-mcp/sse"
    }
  }
}
EOF

    # Set proper ownership
    chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/config 2>/dev/null || true
    chown -R paddy:users /home/paddy/.config/Code 2>/dev/null || true
  '';
}
