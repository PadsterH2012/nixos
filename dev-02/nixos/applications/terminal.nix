# Terminal configuration module
# Shell settings, aliases, and terminal preferences

{ config, pkgs, ... }:

{
  # Terminal packages
  environment.systemPackages = with pkgs; [
    # Terminal emulators
    gnome-terminal

    # Shell utilities
    bash-completion

    # Terminal tools
    tmux
    screen
    htop
    btop
    tree
    fzf
    ripgrep
    fd
    bat
    eza

    # Network tools
    curl
    wget
    netcat
    nmap

    # File tools
    unzip
    zip
    p7zip
    file
    which

    # System monitoring
    iotop
    nethogs
    ncdu
  ];

  # Global shell aliases using environment.shellAliases
  environment.shellAliases = {
    # Basic commands
    ll = "ls -la";
    la = "ls -A";
    l = "ls -CF";

    # Enhanced tools (fallback to standard tools if enhanced not available)
    grep = "grep --color=auto";

    # Git shortcuts
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gd = "git diff";
    gb = "git branch";
    gco = "git checkout";

    # NixOS shortcuts
    rebuild = "sudo nixos-rebuild switch";
    test-rebuild = "sudo nixos-rebuild test";
    update = "sudo nixos-rebuild switch --upgrade";
    rollback = "sudo nixos-rebuild switch --rollback";
    generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

    # Docker shortcuts
    d = "docker";
    dc = "docker-compose";
    dps = "docker ps";
    di = "docker images";

    # System shortcuts
    ports = "netstat -tuln";
    processes = "ps aux";
    disk = "df -h";
    memory = "free -h";

    # Development shortcuts
    serve = "python3 -m http.server";
    myip = "curl -s https://ipinfo.io/ip";

    # Browser shortcuts
    chrome = "google-chrome";
    firefox = "firefox";

    # Database tools
    compass = "mongodb-compass";

    # Safety aliases
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";
  };



  # Environment variables for all users
  environment.variables = {
    EDITOR = "code";
    BROWSER = "firefox";
    PAGER = "less";
  };

  # Create a setup script for user terminal configuration
  environment.etc."terminal/setup-user-terminal.sh" = {
    text = ''
      #!/bin/bash
      # Terminal setup script for users

      echo "🔧 Setting up terminal configuration..."

      # Create user bashrc additions
      cat >> ~/.bashrc << 'EOF'

# Custom prompt with Git branch
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Colorful prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Development environment
export NODE_ENV=development

# Custom functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# NixOS helper functions
nix-search() {
  nix-env -qaP | grep -i "$1"
}

# Development helpers
port-kill() {
  if [ $# -eq 0 ]; then
    echo "Usage: port-kill <port>"
    return 1
  fi
  lsof -ti:$1 | xargs kill -9
}

# Git helpers
git-clean-branches() {
  git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

# Docker helpers
docker-clean() {
  docker system prune -af
  docker volume prune -f
}

# Welcome message
echo "🚀 NixOS Development Environment Ready!"
echo "💡 Type 'rebuild' to apply configuration changes"

EOF

      echo "✅ Terminal configuration completed!"
      echo "🔄 Please restart your terminal or run 'source ~/.bashrc'"
    '';
    mode = "0755";
  };

  # Enable tmux
  programs.tmux.enable = true;

  # Create tmux configuration file
  environment.etc."tmux.conf" = {
    text = ''
      # Set prefix to Ctrl-a
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Enable mouse mode
      set -g mouse on

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Status bar
      set -g status-bg black
      set -g status-fg white
      set -g status-left '#[fg=green]#H'
      set -g status-right '#[fg=yellow]#(uptime | cut -d "," -f 1)'
    '';
    mode = "0644";
  };
}
