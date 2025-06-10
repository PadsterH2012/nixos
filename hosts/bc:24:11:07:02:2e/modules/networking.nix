# Networking configuration module
# Network settings, hostname, and firewall configuration

{ config, pkgs, ... }:

{
  networking.hostName = "nixos-dev-cinnamon"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking = {
    hostName = "hl-dev-nixos-builder";
    
    # For static IP (uncomment and modify if needed):
     interfaces.ens18 = {
       ipv4.addresses = [{
         address = "10.202.28.188";
         prefixLength = 24;  # Adjust as needed
       }];
     };
     defaultGateway = "10.202.28.1";
     nameservers = [ "10.202.28.51" "10.202.28.50" "" ];
  };

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
