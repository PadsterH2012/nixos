# VS Code configuration module
# VS Code installation with FHS environment for extension compatibility
# Extensions can be installed normally through the VS Code marketplace
# Includes GNOME Keyring for authentication token storage (required for extension logins)

{ config, pkgs, ... }:

{
  # VS Code with FHS environment for extension compatibility
  # This allows VS Code to install and manage extensions normally through the marketplace
  # Extensions are installed to ~/.vscode/extensions (user-writable location)
  environment.systemPackages = with pkgs; [
    vscode.fhs
    gnome.seahorse  # GUI for GNOME Keyring (optional but helpful)
  ];

  # Enable GNOME Keyring for VS Code authentication token storage
  # This is required for extensions like Augment Code, GitHub Copilot, etc.
  services.gnome.gnome-keyring.enable = true;

  # System-wide VS Code configuration
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
    '';
    mode = "0755";
  };

  # Create desktop shortcut for VS Code
  environment.etc."skel/Desktop/Visual Studio Code.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Visual Studio Code
      Comment=Code Editing. Redefined.
      Exec=code
      Icon=vscode
      Terminal=false
      Categories=Development;IDE;
      StartupNotify=true
      MimeType=text/plain;inode/directory;
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
          "ms-python.python"
          "bbenoist.nix"
          "ms-vscode-remote.remote-ssh"
          "eamodio.gitlens"
          "ms-azuretools.vscode-docker"
        ];
      };
    };
    mode = "0644";
  };
}
