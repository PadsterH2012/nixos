# Host-specific configuration for nixos-test-vm
# Test machine configuration

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
