# NFS client configuration module
# Network File System client support for mapped drives

{ config, pkgs, ... }:

{
  # Enable NFS client support for mapped drives
  services.rpcbind.enable = true;
  services.nfs.server.enable = false;  # We only want client, not server
  
  # Example NFS mount configuration (commented out - user can customize)
  # fileSystems."/mnt/nfs-share" = {
  #   device = "nfs-server:/path/to/share";
  #   fsType = "nfs";
  #   options = [ "rw" "hard" "intr" "rsize=8192" "wsize=8192" "timeo=14" ];
  # };
}
