# Terminal Application Configuration
# Enhanced terminal tools and configuration

{ config, pkgs, ... }:

{
  # Terminal enhancement packages
  environment.systemPackages = with pkgs; [
    # Enhanced terminal tools
    exa           # Better ls
    bat           # Better cat
    fd            # Better find
    ripgrep       # Better grep
    jq            # JSON processor
    tree          # Directory tree
    htop          # Process monitor
    
    # Terminal utilities
    tmux          # Terminal multiplexer
    screen        # Alternative terminal multiplexer
    fzf           # Fuzzy finder
    
    # Network tools
    curl
    wget
    netcat
    
    # Archive tools
    unzip
    zip
    p7zip
    
    # Text editors
    nano
    vim
    neovim
  ];

  # Enhanced shell aliases for terminal tools
  environment.shellAliases = {
    # Enhanced ls commands
    ll = "${pkgs.exa}/bin/exa -la --git";
    la = "${pkgs.exa}/bin/exa -a";
    ls = "${pkgs.exa}/bin/exa";
    tree = "${pkgs.exa}/bin/exa --tree";
    
    # Enhanced cat
    cat = "${pkgs.bat}/bin/bat --style=plain --paging=never";
    
    # Enhanced find and grep
    find = "${pkgs.fd}/bin/fd";
    grep = "${pkgs.ripgrep}/bin/rg";
    
    # System shortcuts
    h = "history";
    c = "clear";
    e = "exit";
    
    # Process management
    psg = "ps aux | grep";
    
    # Network shortcuts
    myip = "curl -s https://ipinfo.io/ip";
    
    # Directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  # Configure bash for better terminal experience
  programs.bash = {
    completion.enable = true;
    
    # Additional bash configuration
    shellInit = ''
      # Enable history search with arrow keys
      bind '"\e[A": history-search-backward'
      bind '"\e[B": history-search-forward'
      
      # Enable case-insensitive tab completion
      bind 'set completion-ignore-case on'
      
      # Show all completions immediately
      bind 'set show-all-if-ambiguous on'
      
      # Enable colored output for ls
      alias ls='${pkgs.exa}/bin/exa --color=auto'
      
      # Enable colored output for grep
      alias grep='${pkgs.ripgrep}/bin/rg --color=auto'
    '';
  };
}
