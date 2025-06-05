# Desktop environment configuration module
# X11, MATE desktop, display manager, and GUI-related settings

{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable MATE Desktop Environment (lightweight alternative to GNOME)
  services.xserver.desktopManager.mate.enable = true;
  
  # Configure LightDM with auto-login for user paddy
  services.xserver.displayManager.lightdm = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "paddy";
    };
  };

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # MATE desktop essentials (streamlined)
    mate.mate-terminal
    mate.caja
    
    # Network tools
    networkmanagerapplet
  ];
}
