# Host-specific configuration for hl-dev-rpger
# RPG development and gaming tools

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

  # Host-specific overrides for RPG development
  environment.systemPackages = with pkgs; [
    # Game development tools
    godot_4
    blender
    krita
    gimp
    
    # Audio tools for game development
    audacity
    lmms
    
    # 3D modeling and assets
    freecad
    meshlab
    
    # Text and story tools
    twine
    
    # Database tools for game data
    sqlite
    sqlitebrowser
    
    # Image and texture tools
    imagemagick
    optipng
    
    # Version control for game assets
    git-lfs
  ];

  # Enable additional graphics support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Gaming-specific environment
  environment.variables = {
    GAME_DEV_MODE = "true";
    GODOT_PATH = "${pkgs.godot_4}/bin/godot4";
  };
}
