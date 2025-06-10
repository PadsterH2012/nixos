# Identity configuration for hl-dev-adhd-calendar
# ADHD calendar tools server - Static IP 10.202.28.184

{ config, pkgs, ... }:

{
  networking = {
    hostName = "hl-dev-adhd-calendar";
    networkmanager.enable = false;
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.184";
      prefixLength = 24;
    }];
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    useDHCP = false;
  };

  environment.etc."machine-id".text = "hl-dev-adhd-calendar";

  services.xserver.desktopManager.cinnamon = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.libnotify}/bin/notify-send "ADHD Calendar Server" "Machine: hl-dev-adhd-calendar\nIP: 10.202.28.184\nRole: Productivity & Calendar Tools" --icon=computer
    '';
  };

  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-adhd-calendar";
    VM_ROLE = "adhd-calendar";
    VM_IP = "10.202.28.184";
    CALENDAR_SERVER = "true";
  };

  environment.shellAliases = {
    task = "taskwarrior";
    time = "timewarrior";
    focus = "redshift -O 3000";
    unfocus = "redshift -x";
    calendar = "evolution";
  };
}
