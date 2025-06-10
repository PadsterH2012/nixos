# Shared Development Profile
# This is the master template for all development VMs
# Based on the working configuration from bc:24:11:b3:15:31

{ config, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    # Core system modules
    ../modules/desktop.nix
    ../modules/development-tools.nix
    ../modules/localization.nix
    ../modules/hardware-common.nix
    
    # Services
    ../services/audio.nix
    ../services/nfs.nix
    ../services/remote-access.nix
    ../services/auto-update.nix
    ../services/vscode-flatpak.nix
    
    # Applications
    ../applications/vscode.nix
    ../applications/git.nix
    ../applications/terminal.nix
    ../applications/augment.nix
    ../applications/mcp-servers.nix
  ];

  # User configuration - identical across all VMs
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      google-chrome
    ];
  };

  # Security configuration for development convenience
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages (needed for VS Code, Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable nix-ld for compatibility with unpatched dynamic binaries
  programs.nix-ld.enable = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable Flatpak for VS Code OAuth functionality
  services.flatpak.enable = true;

  # Nix configuration for flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System packages that should be identical across all VMs
  environment.systemPackages = with pkgs; [
    # Flake management tools
    git
    nixos-rebuild
    
    # Essential development tools (from working config)
    curl
    wget
    nano
    vim
    neovim
    
    # System utilities
    htop
    tree
    unzip
    zip
    file
    which
    
    # NFS utilities for mapped drives
    nfs-utils
    
    # Proxmox/VM utilities
    qemu-utils
    spice-vdagent
  ];

  # Environment variables for development (can be overridden by specific applications)
  environment.variables = {
    EDITOR = lib.mkDefault "code";
    BROWSER = lib.mkDefault "firefox";
  };

  # Shell aliases for consistency (terminal aliases handled by terminal.nix)
  environment.shellAliases = {
    # Flake management
    rebuild = "sudo nixos-rebuild switch --flake /mnt/network_repo/nixos";
    update-flake = "cd /mnt/network_repo/nixos && nix flake update";

    # Development shortcuts
    nixos-test = "sudo nixos-rebuild test --flake /mnt/network_repo/nixos";
    nixos-switch = "sudo nixos-rebuild switch --flake /mnt/network_repo/nixos";
    nixos-rollback = "sudo nixos-rebuild switch --rollback";
  };

  # Fonts for development
  fonts.packages = with pkgs; [
    jetbrains-mono
    fira-code
    fira-code-symbols
  ];

  # Enable font configuration
  fonts.fontconfig.enable = true;
}
