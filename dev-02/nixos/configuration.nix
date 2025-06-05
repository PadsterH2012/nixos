# Main NixOS configuration for development environment
# Modular configuration with Cinnamon desktop environment
# Features: Modern Cinnamon desktop, XRDP access, development tools, ultrawide monitor support

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    /etc/nixos/hardware-configuration.nix

    # Custom modules
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/localization.nix
    ./modules/desktop.nix
    ./modules/development.nix

    # Services
    ./services/audio.nix
    ./services/nfs.nix
    ./services/remote-access.nix

    # Application configurations
    ./applications/vscode.nix
    ./applications/git.nix
    ./applications/terminal.nix
  ];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      # Removed thunderbird to keep it more streamlined for dev work
    ];
  };

  # Allow unfree packages (needed for VS Code)
  nixpkgs.config.allowUnfree = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.11"; # Did you read the comment?
}
