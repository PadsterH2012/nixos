# Remote access configuration module
# SSH and XRDP configuration for remote connectivity

{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon for remote access
  services.openssh.enable = true;

  # Enable XRDP for remote desktop access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "mate-session";
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
      
      # Start MATE session properly
      exec ${pkgs.mate.mate-session-manager}/bin/mate-session
    '';
    mode = "0755";
  };
}
