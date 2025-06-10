# Identity configuration for hl-pad-nixos-main
# Main development workstation - Static IP 10.202.28.188

{ config, pkgs, ... }:

{
  networking = {
    hostName = "hl-pad-nixos-main";
    networkmanager.enable = false;
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.188";
      prefixLength = 24;
    }];
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    useDHCP = false;
  };

  environment.etc."machine-id".text = "hl-pad-nixos-main";

  services.xserver.desktopManager.cinnamon = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.libnotify}/bin/notify-send "Main Development Workstation" "Machine: hl-pad-nixos-main\nIP: 10.202.28.188\nRole: Primary Development Environment" --icon=computer
    '';
  };

  environment.variables = {
    HOSTNAME_DISPLAY = "hl-pad-nixos-main";
    VM_ROLE = "main-workstation";
    VM_IP = "10.202.28.188";
    MAIN_DEV_SERVER = "true";
  };

  environment.shellAliases = {
    idea = "idea-ultimate";
    pycharm = "pycharm-professional";
    webstorm = "webstorm";
    design = "figma-linux";
    stream = "obs";
    main-status = "systemctl --user status";
  };
}
