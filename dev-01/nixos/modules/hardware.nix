# Hardware configuration module
# Boot loader, kernel modules, and Proxmox VM optimizations

{ config, pkgs, ... }:

{
  # Bootloader - GRUB for BIOS boot
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  
  # Proxmox VM optimizations
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ]; # Use "kvm-amd" for AMD hosts
  
  # Enable QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;
  
  # Enable SPICE agent for better display/clipboard integration
  services.spice-vdagentd.enable = true;
  
  # Enable nested virtualization for better Docker performance
  boot.extraModprobeConfig = "options kvm_intel nested=1"; # Use kvm_amd for AMD hosts
  
  # Support for NFS filesystems
  boot.supportedFilesystems = [ "nfs" ];
}
