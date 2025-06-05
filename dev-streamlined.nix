# Streamlined NixOS configuration for development environment
# Based on new1.01.nix with additional features for auto-logon, NFS, and XRDP
# Features: lightweight desktop, terminal, SSH, Docker host, auto logon, mapped NFS drives, XRDP access

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader - GRUB for BIOS boot
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  
  # Proxmox VM optimizations
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ]; # Use "kvm-amd" for AMD hosts
  
  # Enable QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;
  
  # Enable SPICE agent for better display/clipboard integration
  services.spice-vdagentd.enable = true;

  networking.hostName = "nixos-dev-streamlined"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable MATE Desktop Environment (lightweight alternative to GNOME)
  services.xserver.desktopManager.mate.enable = true;
  
  # Configure LightDM with auto-login for user paddy
  services.xserver.displayManager.lightdm = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "paddy";
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      # Removed thunderbird to keep it more streamlined for dev work
    ];
  };

  # Allow unfree packages (needed for VS Code)
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile - streamlined for development
  environment.systemPackages = with pkgs; [
    # Essential editors and development tools
    vscode
    vim
    neovim
    git
    curl
    wget
    
    # Core development tools
    gcc
    gnumake
    nodejs
    python3
    python3Packages.pip
    docker
    docker-compose
    
    # Essential system utilities
    htop
    tree
    unzip
    zip
    file
    which
    
    # MATE desktop essentials (streamlined)
    mate.mate-terminal
    mate.caja
    
    # Network tools
    networkmanagerapplet
    
    # NFS utilities for mapped drives
    nfs-utils
    
    # Proxmox/VM utilities
    qemu-utils
    spice-vdagent
  ];

  # Enable NFS client support for mapped drives
  services.rpcbind.enable = true;
  services.nfs.server.enable = false;  # We only want client, not server
  boot.supportedFilesystems = [ "nfs" ];
  
  # Example NFS mount configuration (commented out - user can customize)
  # fileSystems."/mnt/nfs-share" = {
  #   device = "nfs-server:/path/to/share";
  #   fsType = "nfs";
  #   options = [ "rw" "hard" "intr" "rsize=8192" "wsize=8192" "timeo=14" ];
  # };

  # Enable Docker with additional configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
  
  # Enable nested virtualization for better Docker performance
  boot.extraModprobeConfig = "options kvm_intel nested=1"; # Use kvm_amd for AMD hosts

  # Enable the OpenSSH daemon for remote access
  services.openssh.enable = true;

  # Enable XRDP for remote desktop access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "mate-session";
    openFirewall = true;
  };
  
  # Fix XRDP session issues - ensure proper environment
  environment.etc."xrdp/startwm.sh" = {
    text = ''
      #!/bin/sh
      if [ -r /etc/default/locale ]; then
        . /etc/default/locale
        export LANG LANGUAGE LC_ALL LC_CTYPE
      fi
      
      # Start MATE session properly
      exec ${pkgs.mate.mate-session-manager}/bin/mate-session
    '';
    mode = "0755";
  };

  # Configure firewall for development needs
  networking.firewall = {
    enable = true;
    # XRDP port is automatically opened by openFirewall = true above
    # Add any additional ports needed for development
    allowedTCPPorts = [ 
      22    # SSH
      # 3389 # XRDP (opened automatically)
      # Add custom development ports here as needed
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.11"; # Did you read the comment?

}
