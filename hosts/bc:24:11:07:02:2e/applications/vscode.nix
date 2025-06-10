# VS Code configuration module
# VS Code installation with FHS environment for OAuth compatibility
# Extensions can be installed normally through the VS Code marketplace
# Includes GNOME Keyring for authentication token storage (required for extension logins)
# Note: Using vscode-fhs for proper libsecret access and OAuth callback support

{ config, pkgs, ... }:

{
  # VS Code with FHS environment for proper library access and OAuth compatibility
  # This provides libsecret access for authentication support in extensions like Augment Code
  # Extensions are installed to ~/.vscode/extensions (user-writable location)
  environment.systemPackages = with pkgs; [
    # NOTE: Using Flatpak VS Code instead of native for OAuth compatibility
    # Native NixOS VS Code has OAuth authentication issues due to libsecret access
    # Flatpak VS Code provides proper keyring integration and OAuth support

    # Keep these for keyring support
    libsecret  # Required for keyring functionality
    seahorse  # GUI for GNOME Keyring management
    pkg-config  # Required for development
    glib  # Required for keyring integration
    dbus  # Required for desktop integration
  ];

  # Enable GNOME Keyring for VS Code authentication token storage
  # This is required for extensions like Augment Code, GitHub Copilot, etc.
  services.gnome.gnome-keyring.enable = true;

  # Additional services for OAuth authentication
  services.dbus.enable = true;
  programs.dconf.enable = true;

  # Environment variables for OAuth compatibility
  environment.sessionVariables = {
    # Force VS Code to use system keyring
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    # Enable OAuth debugging (optional)
    # VSCODE_LOGS = "debug";
  };

  # Automatic Flatpak VS Code installation service
  # This ensures VS Code is available via Flatpak for OAuth compatibility
  systemd.services.install-vscode-flatpak = {
    description = "Install VS Code via Flatpak for OAuth compatibility";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "install-vscode-flatpak" ''
        # Add Flathub repository if not exists
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

        # Install VS Code if not already installed
        if ! ${pkgs.flatpak}/bin/flatpak list --system | grep -q com.visualstudio.code; then
          echo "Installing VS Code via Flatpak for OAuth compatibility..."
          ${pkgs.flatpak}/bin/flatpak install -y --system flathub com.visualstudio.code
          echo "VS Code Flatpak installation complete"
        else
          echo "VS Code Flatpak already installed"
        fi
      '';
    };
  };

  # System-wide VS Code configuration with Augment MCP integration
  environment.etc."vscode/settings.json" = {
    text = builtins.toJSON {
      # Editor settings
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'Source Code Pro', 'Droid Sans Mono', monospace";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.wordWrap" = "on";
      "editor.minimap.enabled" = true;
      "editor.rulers" = [ 80 120 ];

      # Workbench settings
      "workbench.colorTheme" = "Dark+ (default dark)";
      "workbench.iconTheme" = "vs-seti";
      "workbench.startupEditor" = "newUntitledFile";

      # Terminal settings
      "terminal.integrated.shell.linux" = "${pkgs.bash}/bin/bash";
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.cursorBlinking" = true;

      # File settings
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # Git settings
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;

      # Language-specific settings
      "python.defaultInterpreterPath" = "${pkgs.python3}/bin/python";
      "python.linting.enabled" = true;
      "python.linting.pylintEnabled" = true;

      # NixOS specific
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";

      # Docker settings
      "docker.showStartPage" = false;

      # Remote development
      "remote.SSH.remotePlatform" = {
        "*" = "linux";
      };

      # Augment Code settings
      "augment.enableTelemetry" = false;
      "augment.enableAnalytics" = false;
      "augment.autoIndex" = true;

      # Augment MCP Servers (correct format based on research)
      "augment.mcpServers" = {
        "central-obsidian" = {
          "url" = "http://10.202.28.111:9090/obsidian-mcp-tools/sse";
        };
        "central-rpg" = {
          "url" = "http://10.202.28.111:9090/rpg-tools/sse";
        };
        "central-search" = {
          "url" = "http://10.202.28.111:9090/brave-search/sse";
        };
        "central-memory" = {
          "url" = "http://10.202.28.111:9090/memory/sse";
        };
        "central-mongodb" = {
          "url" = "http://10.202.28.111:9090/mongodb/sse";
        };
        "central-context7" = {
          "url" = "http://10.202.28.111:9090/Context7/sse";
        };
        "central-jenkins" = {
          "url" = "http://10.202.28.111:9090/jenkins-mcp/sse";
        };
      };
    };
    mode = "0644";
  };

  # Create a script to help with extension installation
  environment.etc."vscode/install-recommended-extensions.sh" = {
    text = ''
      #!/bin/bash
      # VS Code recommended extensions installation script

      echo "� Installing recommended VS Code extensions..."
      echo "Extensions will be installed to ~/.vscode/extensions"
      echo ""

      # Essential extensions
      echo "📦 Installing essential development extensions..."
      code --install-extension ms-python.python
      code --install-extension ms-vscode.cpptools
      code --install-extension ms-vscode-remote.remote-ssh
      code --install-extension bbenoist.nix
      code --install-extension redhat.vscode-yaml
      code --install-extension ms-vscode.vscode-json
      code --install-extension ms-vscode.vscode-typescript-next

      # Git and version control
      echo "🔀 Installing Git extensions..."
      code --install-extension eamodio.gitlens
      code --install-extension mhutchie.git-graph

      # Docker and containers
      echo "🐳 Installing Docker extensions..."
      code --install-extension ms-azuretools.vscode-docker

      # Productivity
      echo "⚡ Installing productivity extensions..."
      code --install-extension streetsidesoftware.code-spell-checker
      code --install-extension ms-vscode.vscode-todo-highlight

      # Themes and appearance
      echo "🎨 Installing themes and icons..."
      code --install-extension pkief.material-icon-theme
      code --install-extension zhuangtongfa.material-theme

      echo ""
      echo "✅ Recommended extensions installed!"
      echo "� You can now install additional extensions through VS Code's Extensions panel"
      echo "🔄 Extensions are stored in ~/.vscode/extensions and persist across updates"
      echo "🔐 GNOME Keyring is enabled for extension authentication (login tokens)"
      echo "🚀 Extensions like Augment Code, GitHub Copilot, etc. should now work with login"
      echo "🔗 OAuth authentication (browser callbacks) should work properly"
    '';
    mode = "0755";
  };

  # Create desktop shortcut for Flatpak VS Code (OAuth compatible)
  environment.etc."skel/Desktop/Visual Studio Code.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Visual Studio Code (OAuth Compatible)
      Comment=Code Editing. Redefined. (Flatpak - OAuth Working)
      Exec=flatpak run com.visualstudio.code %U
      Icon=com.visualstudio.code
      Terminal=false
      Categories=Development;IDE;
      StartupNotify=true
      MimeType=text/plain;inode/directory;x-scheme-handler/vscode;
      Actions=new-empty-window;

      [Desktop Action new-empty-window]
      Name=New Empty Window
      Exec=flatpak run com.visualstudio.code --new-window %U
      Icon=com.visualstudio.code
    '';
    mode = "0644";
  };

  # Create a workspace template for new projects
  environment.etc."vscode/workspace-template.code-workspace" = {
    text = builtins.toJSON {
      folders = [
        {
          path = ".";
        }
      ];
      settings = {
        "files.exclude" = {
          "**/.git" = true;
          "**/.DS_Store" = true;
          "**/node_modules" = true;
          "**/__pycache__" = true;
          "**/.pytest_cache" = true;
        };
        "search.exclude" = {
          "**/node_modules" = true;
          "**/bower_components" = true;
          "**/.git" = true;
        };
      };
      extensions = {
        recommendations = [
          # OAuth-compatible extensions (confirmed working)
          "augment.vscode-augment"
          "github.copilot"
          "github.copilot-chat"

          # Essential development
          "ms-python.python"
          "bbenoist.nix"
          "ms-vscode-remote.remote-ssh"
          "eamodio.gitlens"
          "ms-azuretools.vscode-docker"

          # Additional captured extensions
          "redhat.vscode-yaml"
          "ms-vscode.vscode-json"
          "mhutchie.git-graph"
          "streetsidesoftware.code-spell-checker"
          "pkief.material-icon-theme"
        ];
      };
    };
    mode = "0644";
  };

  # Note: VS Code protocol handler registration is handled automatically by the desktop file

  # Shell aliases for Flatpak VS Code
  environment.shellAliases = {
    code = "flatpak run com.visualstudio.code";
    vscode = "flatpak run com.visualstudio.code";
  };

  # SOLUTION SUMMARY:
  # ================
  # OAuth authentication works with Flatpak VS Code because:
  # 1. Proper keyring permissions (org.freedesktop.secrets)
  # 2. Correct desktop integration and protocol handling
  # 3. Sandboxed environment with proper library access
  # 4. Native NixOS VS Code cannot access libsecret properly
  #
  # This configuration automatically installs and configures Flatpak VS Code
  # which provides reliable OAuth authentication for extensions like Augment Code
}
