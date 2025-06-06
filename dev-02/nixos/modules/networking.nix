# Networking configuration module
# Network settings, hostname, and firewall configuration

{ config, pkgs, ... }:

{
  networking.hostName = "nixos-dev-cinnamon"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure firewall for development needs
  networking.firewall = {
    enable = true;
    # XRDP port is automatically opened by openFirewall = true in remote-access.nix
    # Add any additional ports needed for development
    allowedTCPPorts = [ 
      22    # SSH
      # 3389 # XRDP (opened automatically)
      # Add custom development ports here as needed
    ];
  };
}
