# Desktop Environment Module
# Cinnamon desktop configuration shared across all VMs

{ config, pkgs, ... }:

{
  # Enable the X11 windowing system
  services.xserver = {
    enable = true;
    
    # Enable the Cinnamon Desktop Environment
    displayManager.lightdm.enable = true;
    desktopManager.cinnamon.enable = true;
    
    # Configure keymap in X11
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  # Enable automatic login for development convenience
  services.displayManager.autoLogin = {
    enable = true;
    user = "paddy";
  };

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Cinnamon-specific packages
    cinnamon.nemo-with-extensions
    cinnamon-settings-daemon

    # Desktop utilities
    file-roller  # Archive manager
    gnome-calculator
    gnome-screenshot

    # Media
    vlc

    # System monitoring
    gnome-system-monitor
  ];

  # Exclude some default Cinnamon packages to keep it streamlined
  environment.cinnamon.excludePackages = with pkgs; [
    # Remove some default applications we don't need for development
    gnome-terminal  # We'll use the integrated terminal in VS Code
    hexchat
  ];

  # Enable touchpad support (useful for laptops, harmless for VMs)
  services.libinput.enable = true;

  # Configure Plymouth for better boot experience
  boot.plymouth.enable = true;
}
