# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader - Keep GRUB for BIOS boot
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

  networking.hostName = "nixos-dev"; # Define your hostname.

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
  services.xserver.displayManager.lightdm.enable = true;

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
      thunderbird
    ];
  };

  # Allow unfree packages (needed for VS Code)
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Editor and Development
    vscode
    vim
    neovim
    git
    curl
    wget
    
    # Development tools
    gcc
    gnumake
    nodejs
    python3
    python3Packages.pip
    docker
    docker-compose
    lazydocker  # TUI for Docker management
    dive        # Tool for exploring Docker images
    
    # System utilities
    htop
    tree
    unzip
    zip
    file
    which
    
    # MATE desktop extras
    mate.mate-terminal
    mate.caja
    mate.pluma
    
    # Network tools
    networkmanagerapplet
    
    # Proxmox/VM utilities
    qemu-utils
    spice-vdagent
  ];

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.11"; # Did you read the comment?

}
