# NFS client configuration module
# Network File System client support for mapped drives
# Includes automatic mounting of network development repository

{ config, pkgs, ... }:

{
  # Enable NFS client support for mapped drives
  services.rpcbind.enable = true;
  services.nfs.server.enable = false;  # We only want client, not server
  
  # Network Dev Repository NFS mount
  fileSystems."/mnt/network_repo" = {
    device = "10.202.28.4:/Project_Repositories";
    fsType = "nfs";
    options = [ "rw" "hard" "vers=3" ];
  };

  # Ensure mount point directory exists
  system.activationScripts.createNfsMountPoints = ''
    mkdir -p /mnt/network_repo
    chown root:root /mnt/network_repo
    chmod 755 /mnt/network_repo
  '';
}
