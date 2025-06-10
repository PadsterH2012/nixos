# Audio Configuration Service
# PipeWire audio setup for development VMs

{ config, pkgs, ... }:

{
  # Disable PulseAudio (we use PipeWire)
  hardware.pulseaudio.enable = false;
  
  # Enable real-time kit for audio
  security.rtkit.enable = true;
  
  # Enable PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    
    # Optional: Enable JACK support
    jack.enable = false;
  };

  # Audio packages
  environment.systemPackages = with pkgs; [
    pavucontrol  # PulseAudio volume control
    alsa-utils   # ALSA utilities
  ];
}
