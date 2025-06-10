# Development Tools Module
# All development packages and tools shared across VMs

{ config, pkgs, pkgs-unstable, ... }:

{
  # Development packages
  environment.systemPackages = with pkgs; [
    # Core development tools
    gcc
    gnumake
    nodejs
    nodePackages.npm
    python3
    python3Packages.pip
    docker
    docker-compose
    
    # Enhanced terminal tools for AI agents
    jq          # JSON processing
    eza         # Better ls
    bat         # Better cat with syntax highlighting
    fd          # Better find
    ripgrep     # Better grep
    
    # Database tools
    mongodb-compass
    
    # VS Code variants
    vscode      # Native VS Code for full system access
    vscode-fhs  # VS Code with FHS environment for better compatibility
    
    # Node.js environment wrapper for script compatibility
    (writeShellScriptBin "ensure-node-path" ''
      export PATH="${nodejs}/bin:${nodePackages.npm}/bin:$PATH"
      exec "$@"
    '')
  ];

  # Enable Docker with configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Node.js environment setup
  environment.variables = {
    NODE_PATH = "${pkgs.nodejs}/lib/node_modules";
    NPM_CONFIG_PREFIX = "/home/paddy/.var/app/com.visualstudio.code/data/node_modules";
  };

  # Enhanced bash configuration for AI agent compatibility
  programs.bash = {
    enableCompletion = true;
    shellInit = ''
      # Ensure Node.js is in PATH for all bash sessions
      export PATH="${pkgs.nodejs}/bin:${pkgs.nodePackages.npm}/bin:$PATH"
      
      # Enhanced terminal tools in PATH
      export PATH="${pkgs.eza}/bin:${pkgs.bat}/bin:${pkgs.fd}/bin:${pkgs.ripgrep}/bin:${pkgs.jq}/bin:$PATH"
      
      # Colorized bash prompt: green user@host, blue path
      export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      
      # Enhanced history settings
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      export HISTCONTROL=ignoredups:erasedups
      
      # Append to history file
      shopt -s histappend
      
      # Show user info on login
      echo "Logged in as: $(whoami) on $(hostname)"
    '';
  };

  # Profile setup for Node.js
  environment.etc."profile.d/nodejs.sh" = {
    text = ''
      # Node.js environment setup for all shells
      export PATH="${pkgs.nodejs}/bin:${pkgs.nodePackages.npm}/bin:$PATH"
      export NODE_PATH="${pkgs.nodejs}/lib/node_modules"
    '';
    mode = "0644";
  };

  # Shell aliases optimized for AI agents and development
  environment.shellAliases = {
    # Node.js shortcuts with full paths for reliability
    node-version = "${pkgs.nodejs}/bin/node --version";
    npm-version = "${pkgs.nodePackages.npm}/bin/npm --version";
    npx-version = "${pkgs.nodePackages.npm}/bin/npx --version";
    
    # Enhanced terminal tools (AI agent compatible)
    ll = "${pkgs.eza}/bin/eza -la --git";
    la = "${pkgs.eza}/bin/eza -a";
    ls = "${pkgs.eza}/bin/eza";
    tree = "${pkgs.eza}/bin/eza --tree";
    cat = "${pkgs.bat}/bin/bat --style=plain --paging=never";
    find = "${pkgs.fd}/bin/fd";
    grep = "${pkgs.ripgrep}/bin/rg";
    
    # VS Code options for development
    code-native = "${pkgs.vscode}/bin/code";
    code-fhs = "${pkgs.vscode-fhs}/bin/code";
    code-flatpak = "flatpak run com.visualstudio.code";
  };
}
