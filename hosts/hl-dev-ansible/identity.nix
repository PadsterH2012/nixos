# Identity configuration for hl-dev-ansible
# Ansible automation server - Static IP 10.202.28.181

{ config, pkgs, ... }:

{
  # Network configuration with static IP
  networking = {
    hostName = "hl-dev-ansible";
    
    # Disable NetworkManager for static IP configuration
    networkmanager.enable = false;
    
    # Static IP configuration
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.181";
      prefixLength = 24;
    }];
    
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    
    # Enable networking
    useDHCP = false;
  };

  # Machine identification
  environment.etc."machine-id".text = "hl-dev-ansible";

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to show identity
    extraSessionCommands = ''
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "Ansible Automation Server" "Machine: hl-dev-ansible\nIP: 10.202.28.181\nRole: Infrastructure Automation" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-ansible";
    VM_ROLE = "ansible-automation";
    VM_IP = "10.202.28.181";
    AUTOMATION_SERVER = "true";
  };

  # Custom shell aliases for Ansible
  environment.shellAliases = {
    ap = "ansible-playbook";
    ai = "ansible-inventory";
    av = "ansible-vault";
    al = "ansible-lint";
    tf = "terraform";
    infra-status = "ansible all -m ping";
  };
}
