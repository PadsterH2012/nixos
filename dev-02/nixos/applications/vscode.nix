# VS Code configuration module
# Declarative VS Code installation with extensions, settings, and preferences
# Extensions are installed automatically via vscode-with-extensions - no manual installation needed!

{ config, pkgs, ... }:

{
  # VS Code with declaratively installed extensions
  # Extensions are automatically installed and managed by Nix
  # To add more extensions: search https://search.nixos.org/packages?query=vscode-extensions
  # Or use extensionsFromVscodeMarketplace for extensions not in nixpkgs
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        # Essential extensions
        ms-python.python
        ms-vscode.cpptools
        ms-vscode-remote.remote-ssh
        bbenoist.nix
        ms-vscode.vscode-json
        redhat.vscode-yaml
        ms-vscode.vscode-typescript-next

        # Git and version control
        eamodio.gitlens

        # Docker and containers
        ms-azuretools.vscode-docker

        # Productivity
        streetsidesoftware.code-spell-checker

        # Themes and appearance
        pkief.material-icon-theme
      ] ++ vscode-utils.extensionsFromVscodeMarketplace [
        # Extensions not available in nixpkgs
        {
          name = "augment";
          publisher = "augment";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        }
        {
          name = "git-graph";
          publisher = "mhutchie";
          version = "1.30.0";
          sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
        }
        {
          name = "todo-highlight";
          publisher = "wayou";
          version = "1.0.5";
          sha256 = "sha256-CQVtMdt/fZcNIbH/KybJixnLqCsz5iF1U0k+GfL65Ok=";
        }
        {
          name = "material-theme";
          publisher = "zhuangtongfa";
          version = "3.16.2";
          sha256 = "sha256-Gn7/2ziVyJkj0A8LjNqjkJz2cjNhLbZdnXlnMmVjvgY=";
        }
      ];
    })
  ];

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

  # Create a script to verify installed extensions
  environment.etc."vscode/verify-extensions.sh" = {
    text = ''
      #!/bin/bash
      # VS Code extension verification script

      echo "🔍 Verifying VS Code extensions are installed..."
      echo "Extensions installed declaratively via NixOS configuration:"
      echo ""

      # List currently installed extensions
      code --list-extensions --show-versions

      echo ""
      echo "✅ Extensions are installed declaratively via NixOS!"
      echo "💡 No manual installation needed - extensions are managed by Nix"
      echo "🔄 To add/remove extensions, edit /etc/nixos/applications/vscode.nix and run 'nixos-rebuild switch'"
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
