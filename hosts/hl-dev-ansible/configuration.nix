# Host-specific configuration for hl-dev-ansible
# Ansible automation and infrastructure management

{ config, pkgs, ... }:

{
  imports = [
    # Import the shared development profile
    ../../shared/profiles/development.nix
    
    # Host-specific hardware configuration
    ./hardware-configuration.nix
    
    # Host-specific identity and network settings
    ./identity.nix
  ];

  # Host-specific overrides for Ansible development
  environment.systemPackages = with pkgs; [
    # Ansible and automation tools
    ansible
    ansible-lint
    ansible-core
    
    # Infrastructure tools
    terraform
    packer
    vagrant
    
    # Cloud tools
    awscli2
    azure-cli
    google-cloud-sdk
    
    # Network tools
    nmap
    netcat
    tcpdump
    wireshark
    
    # YAML/JSON tools
    yq-go
    jq
    
    # SSH and connection tools
    sshpass
    openssh
  ];

  # Enable additional services for infrastructure management
  services.openssh.settings = {
    X11Forwarding = true;
    PermitRootLogin = "no";
    PasswordAuthentication = true;
  };

  # Ansible-specific environment
  environment.variables = {
    ANSIBLE_HOST_KEY_CHECKING = "False";
    ANSIBLE_INVENTORY = "/home/paddy/ansible/inventory";
  };
}
