# Host-specific configuration for hl-dev-adhd-calendar
# ADHD calendar and productivity tools

{ config, pkgs, ... }:

{
  imports = [
    ../../shared/profiles/development.nix
    ./hardware-configuration.nix
    ./identity.nix
  ];

  # ADHD and productivity tools
  environment.systemPackages = with pkgs; [
    # Calendar and scheduling
    thunderbird
    evolution
    
    # Task management
    taskwarrior
    timewarrior
    
    # Note-taking and organization
    obsidian
    logseq
    
    # Focus and productivity
    redshift
    
    # Time tracking
    gtimelog
    
    # Reminder tools
    dunst
    libnotify
  ];

  # Enable calendar services
  services.evolution-data-server.enable = true;
  
  # Productivity environment
  environment.variables = {
    PRODUCTIVITY_MODE = "true";
    FOCUS_TOOLS = "enabled";
  };
}
