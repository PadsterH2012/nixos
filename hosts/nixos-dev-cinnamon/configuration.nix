# Host-specific configuration for nixos-dev-cinnamon
# Based on bc:24:11:b3:15:31 working configuration

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

  # Host-specific overrides can go here
  # Most configuration comes from the shared profile
}
