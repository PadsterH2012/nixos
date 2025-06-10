# Host-specific configuration for hl-pad-nixos-main
# Main development workstation with full capabilities

{ config, pkgs, ... }:

{
  imports = [
    ../../shared/profiles/development.nix
    ./hardware-configuration.nix
    ./identity.nix
  ];

  # Enhanced development environment for main workstation
  environment.systemPackages = with pkgs; [
    # All development tools
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.webstorm
    
    # Design tools
    figma-linux
    inkscape
    gimp
    
    # Communication
    discord
    slack
    teams
    zoom-us
    
    # Media production
    obs-studio
    audacity
    vlc
    
    # System tools
    gparted
    wireshark
    
    # Cloud tools
    awscli2
    azure-cli
    google-cloud-sdk
    
    # Virtualization
    virtualbox
    vagrant
  ];

  # Enable additional services for main workstation
  services.printing.enable = true;
  services.avahi.enable = true;
  
  # Enhanced graphics support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Main workstation environment
  environment.variables = {
    MAIN_WORKSTATION = "true";
    FULL_DEVELOPMENT = "true";
  };
}
