# Identity configuration for dev-vm-05
# Host-specific network and visual identity settings

{ config, pkgs, ... }:

{
  # Network configuration
  networking = {
    hostName = "dev-vm-05";
    
    # Use NetworkManager for DHCP (recommended)
    networkmanager.enable = true;
    
    # Static IP configuration (customize as needed)
    # interfaces.ens18.ipv4.addresses = [{
    #   address = "10.202.28.101";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "10.202.28.1";
    # nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  # Machine identification
  environment.etc."machine-id".text = "dev-vm-05";

  # Custom wallpaper showing machine identity
  # environment.etc."wallpaper.png".source = ../../wallpapers/dev-vm-05.png;

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to set wallpaper and show identity
    extraSessionCommands = ''
      # Set custom wallpaper if available
      # gsettings set org.cinnamon.desktop.background picture-uri file:///etc/wallpaper.png
      
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "Development VM" "Machine: dev-vm-05\nIP: $(hostname -I | awk '{print $1}')" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "dev-vm-05";
    VM_ROLE = "development";
    VM_NUMBER = "05";
  };
}
