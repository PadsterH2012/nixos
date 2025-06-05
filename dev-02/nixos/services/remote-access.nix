# Remote access configuration module
# SSH and XRDP configuration for remote connectivity with Cinnamon

{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon for remote access
  services.openssh.enable = true;

  # Enable XRDP for remote desktop access with Cinnamon
  services.xrdp = {
    enable = true;
    defaultWindowManager = "cinnamon-session";
    openFirewall = true;
  };

  # Configure XRDP session for Cinnamon desktop
  environment.etc."xrdp/startwm.sh" = {
    text = ''
      #!/bin/sh

      # Source system environment
      if [ -r /etc/default/locale ]; then
        . /etc/default/locale
        export LANG LANGUAGE LC_ALL LC_CTYPE
      fi

      # Set up complete environment for Cinnamon
      export XDG_CURRENT_DESKTOP=X-Cinnamon
      export XDG_SESSION_DESKTOP=cinnamon
      export DESKTOP_SESSION=cinnamon
      export XDG_SESSION_TYPE=x11
      export XDG_SESSION_CLASS=user
      export XDG_RUNTIME_DIR="/tmp/runtime-$USER"

      # Create runtime directory if it doesn't exist
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 700 "$XDG_RUNTIME_DIR"

      # Start D-Bus session
      if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        eval $(${pkgs.dbus}/bin/dbus-launch --sh-syntax --exit-with-session)
      fi

      # Start Cinnamon session with all components
      exec ${pkgs.cinnamon.cinnamon-session}/bin/cinnamon-session
    '';
    mode = "0755";
  };

  # Additional XRDP configuration for better Cinnamon support
  environment.etc."xrdp/sesman.ini" = {
    text = ''
      [Globals]
      ListenAddress=127.0.0.1
      ListenPort=3350
      EnableUserWindowManager=true
      UserWindowManager=cinnamon-session
      DefaultWindowManager=cinnamon-session

      [Security]
      AllowRootLogin=false
      MaxLoginRetry=4
      TerminalServerUsers=tsusers
      TerminalServerAdmins=tsadmins

      [Sessions]
      X11DisplayOffset=10
      MaxSessions=50
      KillDisconnected=false
      IdleTimeLimit=0
      DisconnectedTimeLimit=0

      [Logging]
      LogFile=xrdp-sesman.log
      LogLevel=INFO
      EnableSyslog=true
      SyslogLevel=INFO

      [Xorg]
      param1=-bs
      param2=-nolisten
      param3=tcp
      param4=-dpi
      param5=96
    '';
    mode = "0644";
  };
}
