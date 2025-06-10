# Home Manager Configuration for paddy user
# User-specific settings and applications

{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "paddy";
  home.homeDirectory = "/home/paddy";

  # This value determines the Home Manager release which your
  # configuration is compatible with.
  home.stateVersion = "24.11";

  # User-specific packages
  home.packages = with pkgs; [
    # Development tools
    postman
    
    # Browsers
    firefox
    google-chrome
    
    # Media
    vlc
    
    # Utilities
    gnome.file-roller
    gnome.gnome-calculator
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Paddy";
    userEmail = "paddy@bastiondata.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "code --wait";
    };
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    
    bashrcExtra = ''
      # Custom bash configuration for development
      export EDITOR="code --wait"
      export BROWSER="firefox"
      
      # Development aliases
      alias ll='eza -la --git'
      alias la='eza -a'
      alias tree='eza --tree'
      
      # Quick navigation
      alias ..='cd ..'
      alias ...='cd ../..'
      
      # Git shortcuts
      alias gs='git status'
      alias ga='git add'
      alias gc='git commit'
      alias gp='git push'
      alias gl='git pull'
    '';
  };

  # VS Code configuration
  programs.vscode = {
    enable = false;  # We use Flatpak VS Code for OAuth
    
    # Extensions would go here if using native VS Code
    # extensions = with pkgs.vscode-extensions; [
    #   ms-python.python
    #   ms-vscode.cpptools
    # ];
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
