# Desktop environment configuration module
# X11, XFCE desktop, display manager, and GUI-related settings

{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable XFCE Desktop Environment (lightweight and stable)
  services.xserver.desktopManager.xfce.enable = true;

  # Configure LightDM display manager (no auto-login for security)
  services.xserver.displayManager.lightdm.enable = true;

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # XFCE desktop essentials
    xfce.xfce4-terminal
    xfce.thunar
    xfce.xfce4-panel
    xfce.xfce4-settings

    # Network tools
    networkmanagerapplet
  ];
}
