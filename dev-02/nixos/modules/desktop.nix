# Desktop environment configuration module
# Cinnamon desktop environment - perfect for XRDP and ultrawide monitors
# Modern, polished interface with excellent multi-monitor support

{ config, pkgs, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable Cinnamon Desktop Environment
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure LightDM display manager (no auto-login for security)
  services.xserver.displayManager.lightdm.enable = true;

  # Fonts for better display on ultrawide monitors
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-emoji
    dejavu_fonts
    liberation_ttf
    source-code-pro
  ];

  # Desktop-specific packages optimized for development and ultrawide use
  environment.systemPackages = with pkgs; [
    # Essential desktop components
    file-roller
    eog  # Image viewer
    evince  # PDF viewer

    # Terminal options
    gnome-terminal

    # Network tools
    networkmanagerapplet

    # Display and monitor tools
    arandr
    autorandr

    # XDG utilities for proper desktop integration and protocol handling
    xdg-utils

    # System utilities
    pavucontrol

    # Development-friendly tools
    dconf-editor
  ];

  # Enable Cinnamon-specific services
  services.cinnamon.apps.enable = true;

  # Enable additional services for proper desktop functionality
  services.gvfs.enable = true;  # Virtual filesystem support
  services.udisks2.enable = true;  # Disk management
  services.upower.enable = true;  # Power management
  services.accounts-daemon.enable = true;  # User account management
  services.gnome.gnome-keyring.enable = true;  # Keyring for passwords

  # Enable D-Bus and other essential services
  services.dbus.enable = true;

  # XDG portal for better application integration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Ensure proper session management
  security.polkit.enable = true;

  # Configure PAM to automatically unlock GNOME keyring on login
  # This prevents the "Unlock Login Keyring" dialog in VS Code and other apps
  security.pam.services.lightdm.enableGnomeKeyring = true;
  security.pam.services.lightdm-greeter.enableGnomeKeyring = true;

  # Also enable for other common login services
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.su.enableGnomeKeyring = true;

  # Enable Flatpak for better application compatibility (especially OAuth)
  services.flatpak.enable = true;

  # Create a desktop startup script for troubleshooting
  environment.etc."xrdp/start-cinnamon-desktop.sh" = {
    text = ''
      #!/bin/bash
      # Manual desktop startup script for XRDP troubleshooting

      echo "Starting Cinnamon desktop components..."

      # Start the panel if it's not running
      if ! pgrep -f "cinnamon" > /dev/null; then
        echo "Starting Cinnamon desktop..."
        cinnamon --replace &
      fi

      # Start the settings daemon if it's not running
      if ! pgrep -f "cinnamon-settings-daemon" > /dev/null; then
        echo "Starting Cinnamon settings daemon..."
        cinnamon-settings-daemon &
      fi

      echo "Desktop components started. You should now see the taskbar and menu."
      echo "To open applications:"
      echo "- Right-click on desktop for context menu"
      echo "- Click on menu button in taskbar"
      echo "- Press Alt+F2 for run dialog"
      echo "- Open terminal: gnome-terminal"
      echo "- Open VS Code: code"
    '';
    mode = "0755";
  };

  # Create desktop shortcuts for easy access
  environment.etc."skel/Desktop/VS Code.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Visual Studio Code
      Comment=Code Editing. Redefined.
      Exec=code
      Icon=vscode
      Terminal=false
      Categories=Development;IDE;
      StartupNotify=true
      MimeType=x-scheme-handler/vscode;
    '';
    mode = "0644";
  };

  environment.etc."skel/Desktop/Terminal.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Terminal
      Comment=Use the command line
      Exec=gnome-terminal
      Icon=utilities-terminal
      Terminal=false
      Categories=System;TerminalEmulator;
      StartupNotify=true
    '';
    mode = "0644";
  };

  environment.etc."skel/Desktop/Google Chrome.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Google Chrome
      Comment=Access the Internet
      Exec=google-chrome
      Icon=google-chrome
      Terminal=false
      Categories=Network;WebBrowser;
      StartupNotify=true
      MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
    '';
    mode = "0644";
  };

  environment.etc."skel/Desktop/MongoDB Compass.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=MongoDB Compass
      Comment=GUI for MongoDB
      Exec=mongodb-compass
      Icon=mongodb-compass
      Terminal=false
      Categories=Development;Database;
      StartupNotify=true
    '';
    mode = "0644";
  };
}
