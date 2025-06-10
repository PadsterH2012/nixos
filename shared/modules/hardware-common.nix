# Common Hardware Configuration
# Shared hardware settings for all VMs

{ config, pkgs, ... }:

{
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable sound with pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # VM-specific optimizations
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Enable OpenGL for desktop environment
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Power management for VMs
  powerManagement.enable = true;
}
