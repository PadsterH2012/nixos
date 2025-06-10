# Auto-Update Service
# Automatic system updates for development VMs

{ config, pkgs, ... }:

{
  # Enable automatic upgrades
  system.autoUpgrade = {
    enable = true;
    flake = "/mnt/network_repo/nixos";
    flags = [
      "--update-input" "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "weekly";
    randomizedDelaySec = "45min";
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic store optimization
  nix.settings.auto-optimise-store = true;

  # Systemd service to pull latest flake updates
  systemd.services.flake-update = {
    description = "Update flake inputs";
    serviceConfig = {
      Type = "oneshot";
      User = "paddy";
      WorkingDirectory = "/mnt/network_repo/nixos";
    };
    script = ''
      ${pkgs.git}/bin/git pull origin main
      ${pkgs.nix}/bin/nix flake update
    '';
  };

  # Timer for flake updates
  systemd.timers.flake-update = {
    description = "Update flake inputs weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
