# VS Code Extensions Configuration for NixOS
# Captured from working OAuth setup with Flatpak VS Code

{ config, pkgs, ... }:

{
  # Create extension installation script based on captured working setup
  environment.etc."vscode/install-captured-extensions.sh" = {
    text = ''
      #!/bin/bash
      # VS Code Flatpak Extensions Installation Script
      # Based on captured extensions from working OAuth setup on 10.202.28.189

      echo "Installing VS Code Extensions for Flatpak VS Code..."
      echo "Extensions will be installed to Flatpak VS Code sandbox"
      echo ""

      # Color codes
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      YELLOW='\033[1;33m'
      NC='\033[0m'

      install_extension() {
          local ext_id=$1
          local ext_name=$2
          echo -e "''${BLUE}Installing''${NC}: $ext_name ($ext_id)"
          flatpak run com.visualstudio.code --install-extension "$ext_id" --force
          if [ $? -eq 0 ]; then
              echo -e "''${GREEN}Success''${NC}: $ext_name installed"
          else
              echo -e "''${YELLOW}Warning''${NC}: Failed to install $ext_name"
          fi
          echo ""
      }

      # Check if Flatpak VS Code is available
      if ! flatpak list | grep -q com.visualstudio.code; then
          echo "Error: Flatpak VS Code not installed. Please install it first:"
          echo "flatpak install flathub com.visualstudio.code"
          exit 1
      fi

      echo "CAPTURED EXTENSIONS FROM WORKING OAUTH SETUP"
      echo "============================================="
      
      # OAuth-compatible extensions (confirmed working)
      echo "Installing OAuth-compatible extensions..."
      
      # Augment Code (OAuth working - version 0.472.3)
      install_extension "augment.vscode-augment" "Augment Code"
      
      # GitHub Copilot (OAuth working - versions 1.330.0 and 0.27.3)
      install_extension "github.copilot" "GitHub Copilot"
      install_extension "github.copilot-chat" "GitHub Copilot Chat"

      echo "Installing essential development extensions..."
      
      # Essential development extensions
      install_extension "ms-python.python" "Python"
      install_extension "ms-vscode.cpptools" "C/C++"
      install_extension "ms-vscode-remote.remote-ssh" "Remote SSH"
      install_extension "bbenoist.nix" "Nix Language Support"
      install_extension "redhat.vscode-yaml" "YAML"
      install_extension "ms-vscode.vscode-json" "JSON"

      echo "Installing Git and version control extensions..."
      
      # Git and version control
      install_extension "eamodio.gitlens" "GitLens"
      install_extension "mhutchie.git-graph" "Git Graph"

      echo "Installing Docker and container extensions..."
      
      # Docker and containers
      install_extension "ms-azuretools.vscode-docker" "Docker"

      echo "Installing productivity extensions..."
      
      # Productivity
      install_extension "streetsidesoftware.code-spell-checker" "Code Spell Checker"
      install_extension "ms-vscode.vscode-todo-highlight" "TODO Highlight"

      echo "Installing themes and appearance extensions..."
      
      # Themes and appearance
      install_extension "pkief.material-icon-theme" "Material Icon Theme"
      install_extension "zhuangtongfa.material-theme" "One Dark Pro"

      echo ""
      echo -e "''${GREEN}Extension installation complete!''${NC}"
      echo ""
      echo "OAUTH AUTHENTICATION STATUS:"
      echo "- Augment Code: OAuth working (confirmed)"
      echo "- GitHub Copilot: OAuth working (confirmed)"
      echo "- Extensions stored in Flatpak VS Code sandbox"
      echo "- Extensions persist across Flatpak updates"
      echo ""
      echo "Launch VS Code: flatpak run com.visualstudio.code"
      echo "Or use alias: code (after restarting terminal)"
    '';
    mode = "0755";
  };

  # Create extension list for reference
  environment.etc."vscode/captured-extensions.json" = {
    text = builtins.toJSON {
      capturedFrom = "10.202.28.189";
      captureDate = "2025-06-06";
      oauthStatus = "working";
      extensions = [
        {
          id = "augment.vscode-augment";
          version = "0.472.3";
          name = "Augment Code";
          oauthWorking = true;
          critical = true;
        }
        {
          id = "github.copilot";
          version = "1.330.0";
          name = "GitHub Copilot";
          oauthWorking = true;
          critical = true;
        }
        {
          id = "github.copilot-chat";
          version = "0.27.3";
          name = "GitHub Copilot Chat";
          oauthWorking = true;
          critical = true;
        }
        {
          id = "ms-python.python";
          name = "Python";
          category = "development";
        }
        {
          id = "ms-vscode.cpptools";
          name = "C/C++";
          category = "development";
        }
        {
          id = "ms-vscode-remote.remote-ssh";
          name = "Remote SSH";
          category = "development";
        }
        {
          id = "bbenoist.nix";
          name = "Nix Language Support";
          category = "development";
        }
        {
          id = "redhat.vscode-yaml";
          name = "YAML";
          category = "development";
        }
        {
          id = "ms-vscode.vscode-json";
          name = "JSON";
          category = "development";
        }
        {
          id = "eamodio.gitlens";
          name = "GitLens";
          category = "git";
        }
        {
          id = "mhutchie.git-graph";
          name = "Git Graph";
          category = "git";
        }
        {
          id = "ms-azuretools.vscode-docker";
          name = "Docker";
          category = "containers";
        }
        {
          id = "streetsidesoftware.code-spell-checker";
          name = "Code Spell Checker";
          category = "productivity";
        }
        {
          id = "ms-vscode.vscode-todo-highlight";
          name = "TODO Highlight";
          category = "productivity";
        }
        {
          id = "pkief.material-icon-theme";
          name = "Material Icon Theme";
          category = "themes";
        }
        {
          id = "zhuangtongfa.material-theme";
          name = "One Dark Pro";
          category = "themes";
        }
      ];
    };
    mode = "0644";
  };

  # Create user setup script for extensions
  environment.etc."vscode/setup-user-extensions.sh" = {
    text = ''
      #!/bin/bash
      # User setup script for VS Code extensions
      
      echo "Setting up VS Code extensions for user: $USER"
      echo ""
      
      # Run the extension installation script
      if [ -f /etc/vscode/install-captured-extensions.sh ]; then
          echo "Running extension installation script..."
          /etc/vscode/install-captured-extensions.sh
      else
          echo "Extension installation script not found"
          exit 1
      fi
      
      echo ""
      echo "Extension setup complete for user: $USER"
      echo "VS Code is ready with OAuth-compatible extensions"
    '';
    mode = "0755";
  };
}
