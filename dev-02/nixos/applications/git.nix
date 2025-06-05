# Git configuration module
# Global Git settings and aliases for development workflow

{ config, pkgs, ... }:

{
  # Ensure Git is installed
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    gitui  # Terminal UI for Git
    gh     # GitHub CLI
  ];

  # Global Git configuration
  environment.etc."gitconfig" = {
    text = ''
      [user]
          name = Paddy
          email = paddy@bastiondata.com

      [core]
          editor = code --wait
          autocrlf = input
          filemode = false
          ignorecase = false

      [init]
          defaultBranch = main

      [push]
          default = simple
          autoSetupRemote = true

      [pull]
          rebase = true

      [merge]
          tool = vscode
          conflictstyle = diff3

      [mergetool "vscode"]
          cmd = code --wait $MERGED

      [diff]
          tool = vscode

      [difftool "vscode"]
          cmd = code --wait --diff $LOCAL $REMOTE

      [alias]
          # Status and info
          st = status
          s = status --short
          br = branch
          co = checkout
          
          # Commit shortcuts
          ci = commit
          cm = commit -m
          ca = commit -am
          amend = commit --amend
          
          # Log and history
          lg = log --oneline --graph --decorate
          ll = log --pretty=format:'%C(yellow)%h%Creset -%C(red)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
          last = log -1 HEAD
          
          # Diff shortcuts
          d = diff
          dc = diff --cached
          dt = difftool
          
          # Remote operations
          pu = push
          pl = pull
          f = fetch
          fa = fetch --all
          
          # Branch operations
          new = checkout -b
          del = branch -d
          
          # Stash operations
          ss = stash save
          sp = stash pop
          sl = stash list
          
          # Reset operations
          unstage = reset HEAD --
          undo = reset --soft HEAD~1
          
          # Useful shortcuts
          aliases = config --get-regexp alias
          remotes = remote -v
          
          # NixOS specific
          nixos-commit = !git add . && git commit -m "NixOS: $(date '+%Y-%m-%d %H:%M') - Configuration update"

      [color]
          ui = auto
          branch = auto
          diff = auto
          status = auto

      [color "branch"]
          current = yellow reverse
          local = yellow
          remote = green

      [color "diff"]
          meta = yellow bold
          frag = magenta bold
          old = red bold
          new = green bold

      [color "status"]
          added = yellow
          changed = green
          untracked = cyan

      [credential]
          helper = store

      [filter "lfs"]
          clean = git-lfs clean -- %f
          smudge = git-lfs smudge -- %f
          process = git-lfs filter-process
          required = true

      [safe]
          directory = /etc/nixos
    '';
    mode = "0644";
  };

  # Global gitignore
  environment.etc."gitignore_global" = {
    text = ''
      # OS generated files
      .DS_Store
      .DS_Store?
      ._*
      .Spotlight-V100
      .Trashes
      ehthumbs.db
      Thumbs.db

      # Editor files
      .vscode/
      .idea/
      *.swp
      *.swo
      *~

      # Logs
      *.log
      logs/

      # Runtime data
      pids/
      *.pid
      *.seed

      # Dependency directories
      node_modules/
      bower_components/

      # Python
      __pycache__/
      *.py[cod]
      *$py.class
      *.so
      .Python
      env/
      venv/
      .venv/
      .pytest_cache/

      # Rust
      target/
      Cargo.lock

      # Go
      vendor/

      # Build outputs
      dist/
      build/
      *.o
      *.a
      *.exe

      # Temporary files
      *.tmp
      *.temp
      .cache/

      # NixOS specific
      result
      result-*
      .direnv/

      # Docker
      .dockerignore
      docker-compose.override.yml

      # Environment files
      .env
      .env.local
      .env.*.local
    '';
    mode = "0644";
  };

  # Git configuration script for users
  environment.etc."git/setup-user-git.sh" = {
    text = ''
      #!/bin/bash
      # Git user setup script
      
      echo "🔧 Setting up Git configuration..."
      
      # Copy global gitconfig to user home
      cp /etc/gitconfig ~/.gitconfig
      
      # Set global gitignore
      git config --global core.excludesfile /etc/gitignore_global
      
      # Prompt for user details if not set
      if [ -z "$(git config --global user.name)" ]; then
          read -p "Enter your full name: " name
          git config --global user.name "$name"
      fi
      
      if [ -z "$(git config --global user.email)" ]; then
          read -p "Enter your email address: " email
          git config --global user.email "$email"
      fi
      
      echo "✅ Git configuration complete!"
      echo "📋 Current configuration:"
      git config --global --list | grep -E "(user\.|core\.editor)"
    '';
    mode = "0755";
  };
}
