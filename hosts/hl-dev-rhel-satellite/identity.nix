# Identity configuration for hl-dev-rhel-satellite
# RHEL satellite management server - Static IP 10.202.28.187

{ config, pkgs, ... }:

{
  networking = {
    hostName = "hl-dev-rhel-satellite";
    networkmanager.enable = false;
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.187";
      prefixLength = 24;
    }];
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    useDHCP = false;
  };

  environment.etc."machine-id".text = "hl-dev-rhel-satellite";

  services.xserver.desktopManager.cinnamon = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.libnotify}/bin/notify-send "RHEL Satellite Server" "Machine: hl-dev-rhel-satellite\nIP: 10.202.28.187\nRole: Enterprise Management" --icon=computer
    '';
  };

  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-rhel-satellite";
    VM_ROLE = "rhel-satellite";
    VM_IP = "10.202.28.187";
    SATELLITE_SERVER = "true";
  };

  environment.shellAliases = {
    satellite = "systemctl status prometheus grafana";
    monitor = "grafana-cli";
    containers = "podman ps -a";
    virt = "virsh list --all";
    enterprise = "cockpit-ws";
  };
}
