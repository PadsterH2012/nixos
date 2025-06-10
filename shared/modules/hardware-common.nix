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

  # Enable graphics for desktop environment
  hardware.graphics = {
    enable = true;
    # driSupport and driSupport32Bit are deprecated and enabled by default
  };

  # Power management for VMs
  powerManagement.enable = true;
}
