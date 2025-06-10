# Identity configuration for nixos-dev-cinnamon
# Host-specific network and visual identity settings

{ config, pkgs, ... }:

{
  # Network configuration
  networking = {
    hostName = "nixos-dev-cinnamon";
    
    # Use NetworkManager for DHCP (recommended for VMs)
    networkmanager.enable = true;
    
    # Static IP configuration (uncomment if needed)
    # interfaces.ens18.ipv4.addresses = [{
    #   address = "10.202.28.188";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "10.202.28.1";
    # nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  # Machine identification
  environment.etc."machine-id".text = "nixos-dev-cinnamon-main";

  # Custom wallpaper showing machine identity (optional)
  # environment.etc."wallpaper.png".source = ../../wallpapers/nixos-dev-cinnamon.png;

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to set wallpaper and show identity
    extraSessionCommands = ''
      # Set custom wallpaper if available
      # gsettings set org.cinnamon.desktop.background picture-uri file:///etc/wallpaper.png
      
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "Development VM" "Machine: nixos-dev-cinnamon\nIP: $(hostname -I | awk '{print $1}')" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "nixos-dev-cinnamon";
    VM_ROLE = "development";
  };
}
