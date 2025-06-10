# Identity configuration for hl-dev-rpger
# RPG development server - Static IP 10.202.28.183

{ config, pkgs, ... }:

{
  # Network configuration with static IP
  networking = {
    hostName = "hl-dev-rpger";
    
    # Disable NetworkManager for static IP configuration
    networkmanager.enable = false;
    
    # Static IP configuration
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.183";
      prefixLength = 24;
    }];
    
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    
    # Enable networking
    useDHCP = false;
  };

  # Machine identification
  environment.etc."machine-id".text = "hl-dev-rpger";

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to show identity
    extraSessionCommands = ''
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "RPG Development Server" "Machine: hl-dev-rpger\nIP: 10.202.28.183\nRole: RPG Game Development" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-rpger";
    VM_ROLE = "rpg-development";
    VM_IP = "10.202.28.183";
    GAME_DEV_SERVER = "true";
  };

  # Custom shell aliases for RPG development
  environment.shellAliases = {
    godot = "godot4";
    game-build = "godot4 --headless --export";
    asset-optimize = "optipng *.png";
    story-edit = "twine";
    blend = "blender";
  };
}
