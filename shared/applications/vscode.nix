# VS Code Application Configuration
# VS Code setup with extensions and settings

{ config, pkgs, ... }:

{
  # Install VS Code variants
  environment.systemPackages = with pkgs; [
    vscode          # Native VS Code
    vscode-fhs      # FHS-compatible VS Code
  ];

  # VS Code extensions (installed system-wide)
  environment.systemPackages = with pkgs.vscode-extensions; [
    # Essential extensions
    ms-vscode.cpptools
    ms-python.python
    bradlc.vscode-tailwindcss
    esbenp.prettier-vscode
    
    # Git integration
    eamodio.gitlens
    
    # Language support
    ms-vscode.vscode-typescript-next
    ms-vscode.vscode-json
    
    # Themes and UI
    pkief.material-icon-theme
    
    # Development tools
    ms-vscode.vscode-eslint
    formulahendry.auto-rename-tag
  ];

  # Shell aliases for VS Code variants
  environment.shellAliases = {
    code = "flatpak run com.visualstudio.code";  # Default to Flatpak for OAuth
    code-native = "${pkgs.vscode}/bin/code";
    code-fhs = "${pkgs.vscode-fhs}/bin/code";
    code-flatpak = "flatpak run com.visualstudio.code";
  };

  # Ensure Flatpak is available for VS Code OAuth
  services.flatpak.enable = true;

  # Add Flathub repository
  systemd.services.flatpak-repo = {
    description = "Add Flathub repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
