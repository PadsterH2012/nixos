# Remote Access Configuration
# SSH and XRDP for development VM access

{ config, pkgs, ... }:

{
  # Enable OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      # Allow password authentication for development convenience
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Enable XRDP for remote desktop access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "cinnamon-session";
    openFirewall = true;
  };

  # Open firewall ports for remote access
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      22    # SSH
      3389  # XRDP
    ];
  };

  # Install remote access tools
  environment.systemPackages = with pkgs; [
    openssh
    remmina  # Remote desktop client
  ];
}
