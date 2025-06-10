# Host-specific configuration for hl-dev-rhel-satellite
# RHEL satellite management and enterprise tools

{ config, pkgs, ... }:

{
  imports = [
    ../../shared/profiles/development.nix
    ./hardware-configuration.nix
    ./identity.nix
  ];

  # Enterprise and RHEL management tools
  environment.systemPackages = with pkgs; [
    # Red Hat tools (where available)
    ansible
    ansible-core
    
    # Enterprise monitoring
    prometheus
    grafana
    
    # Container management
    podman
    buildah
    skopeo
    
    # System management
    cockpit
    
    # Network tools
    nmap
    wireshark
    tcpdump
    
    # Security tools
    nessus
    openscap
    
    # Virtualization
    libvirt
    virt-manager
    qemu
    
    # Backup tools
    rsync
    borgbackup
  ];

  # Enable enterprise services
  services.prometheus.enable = true;
  services.grafana.enable = true;
  
  # Enable virtualization
  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
  
  # Enterprise environment
  environment.variables = {
    ENTERPRISE_MODE = "true";
    RHEL_SATELLITE = "true";
  };
}
