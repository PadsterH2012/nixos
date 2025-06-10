# Host-specific configuration for hl-dev-nixos-builder
# NixOS build server and development environment

{ config, pkgs, ... }:

{
  imports = [
    # Import the shared development profile
    ../../shared/profiles/development.nix
    
    # Host-specific hardware configuration
    ./hardware-configuration.nix
    
    # Host-specific identity and network settings
    ./identity.nix
  ];

  # Host-specific overrides for build server
  # Additional packages for NixOS building and CI/CD
  environment.systemPackages = with pkgs; [
    # Build tools
    cachix          # Binary cache management
    nix-build-uncached
    nix-output-monitor
    
    # CI/CD tools
    act             # GitHub Actions locally
    
    # Additional development tools
    direnv          # Environment management
    lorri           # Nix shell for direnv
  ];

  # Enable additional services for build server
  services.openssh.settings.X11Forwarding = true;
  
  # Optimize for building
  nix.settings = {
    max-jobs = "auto";
    cores = 0;  # Use all available cores
    
    # Build optimization
    keep-outputs = true;
    keep-derivations = true;
  };
}
