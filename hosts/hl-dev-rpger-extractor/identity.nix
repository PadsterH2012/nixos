# Identity configuration for hl-dev-rpger-extractor
# RPG data extraction server - Static IP 10.202.28.185

{ config, pkgs, ... }:

{
  networking = {
    hostName = "hl-dev-rpger-extractor";
    networkmanager.enable = false;
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.185";
      prefixLength = 24;
    }];
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    useDHCP = false;
  };

  environment.etc."machine-id".text = "hl-dev-rpger-extractor";

  services.xserver.desktopManager.cinnamon = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.libnotify}/bin/notify-send "RPG Data Extractor" "Machine: hl-dev-rpger-extractor\nIP: 10.202.28.185\nRole: Data Extraction & Processing" --icon=computer
    '';
  };

  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-rpger-extractor";
    VM_ROLE = "rpger-extractor";
    VM_IP = "10.202.28.185";
    EXTRACTOR_SERVER = "true";
  };

  environment.shellAliases = {
    extract = "python3 -m scrapy";
    process-data = "python3 -c 'import pandas as pd'";
    db-connect = "psql -U postgres";
    scrape = "selenium-python";
  };
}
