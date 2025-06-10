# Identity configuration for hl-dev-nixos-builder
# NixOS build server - Static IP 10.202.28.170

{ config, pkgs, ... }:

{
  # Network configuration with static IP
  networking = {
    hostName = "hl-dev-nixos-builder";
    
    # Disable NetworkManager for static IP configuration
    networkmanager.enable = false;
    
    # Static IP configuration
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.170";
      prefixLength = 24;
    }];
    
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    
    # Enable networking
    useDHCP = false;
  };

  # Machine identification
  environment.etc."machine-id".text = "hl-dev-nixos-builder";

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to show identity
    extraSessionCommands = ''
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "NixOS Build Server" "Machine: hl-dev-nixos-builder\nIP: 10.202.28.170\nRole: NixOS Build & CI/CD" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-nixos-builder";
    VM_ROLE = "nixos-builder";
    VM_IP = "10.202.28.170";
    BUILD_SERVER = "true";
  };

  # Custom shell aliases for build server
  environment.shellAliases = {
    build-all = "nix-build '<nixpkgs>' -A hello";
    check-cache = "cachix use";
    build-status = "systemctl status nix-daemon";
  };
}
