# Remote access configuration module
# SSH and XRDP configuration for remote connectivity

{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon for remote access
  services.openssh.enable = true;

  # Enable XRDP for remote desktop access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "xfce4-session";
    openFirewall = true;
  };

  # Fix XRDP session issues - ensure proper environment
  environment.etc."xrdp/startwm.sh" = {
    text = ''
      #!/bin/sh
      if [ -r /etc/default/locale ]; then
        . /etc/default/locale
        export LANG LANGUAGE LC_ALL LC_CTYPE
      fi

      # Start XFCE session properly
      exec ${pkgs.xfce.xfce4-session}/bin/xfce4-session
    '';
    mode = "0755";
  };
}
