# Development environment configuration module
# Development tools, packages, and Docker configuration

{ config, pkgs, ... }:

{
  # List packages installed in system profile - streamlined for development
  environment.systemPackages = with pkgs; [
    # Essential editors and development tools
    vscode
    vim
    neovim
    git
    curl
    wget
    
    # Core development tools
    gcc
    gnumake
    nodejs
    python3
    python3Packages.pip
    docker
    docker-compose

    # Database tools
    mongodb-compass
    
    # Essential system utilities
    htop
    tree
    unzip
    zip
    file
    which
    
    # NFS utilities for mapped drives
    nfs-utils
    
    # Proxmox/VM utilities
    qemu-utils
    spice-vdagent
  ];

  # Enable Docker with additional configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
