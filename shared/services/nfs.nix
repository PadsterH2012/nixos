# NFS Configuration Service
# Network file system support for shared storage

{ config, pkgs, ... }:

{
  # Enable NFS client support
  services.rpcbind.enable = true;
  
  # Install NFS utilities
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  # Example NFS mount (commented out - configure per host as needed)
  # fileSystems."/mnt/shared" = {
  #   device = "nfs-server:/path/to/share";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4.1" "rsize=1048576" "wsize=1048576" "hard" "intr" "timeo=600" ];
  # };

  # Open firewall for NFS if needed
  # networking.firewall.allowedTCPPorts = [ 2049 ];
  # networking.firewall.allowedUDPPorts = [ 2049 ];
}
