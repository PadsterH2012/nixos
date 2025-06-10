# Identity configuration for nixos-test-vm
# Test machine identity settings

{ config, pkgs, ... }:

{
  # Network configuration
  networking = {
    hostName = "nixos-test-vm";
    
    # Use NetworkManager for DHCP (recommended)
    networkmanager.enable = true;
  };

  # Machine identification
  environment.etc."machine-id".text = "nixos-test-vm";

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to show identity
    extraSessionCommands = ''
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "Test VM" "Machine: nixos-test-vm\nIP: $(hostname -I | awk '{print $1}')" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "nixos-test-vm";
    VM_ROLE = "testing";
  };
}
