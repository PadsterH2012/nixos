# Git Configuration
# Global Git settings for development

{ config, pkgs, ... }:

{
  # Install Git and related tools
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    gitui          # Terminal UI for Git
    lazygit        # Another terminal UI for Git
  ];

  # Global Git configuration
  environment.etc."gitconfig".text = ''
    [init]
        defaultBranch = main
    
    [pull]
        rebase = false
    
    [core]
        editor = code --wait
        autocrlf = input
    
    [merge]
        tool = vscode
    
    [mergetool "vscode"]
        cmd = code --wait $MERGED
    
    [diff]
        tool = vscode
    
    [difftool "vscode"]
        cmd = code --wait --diff $LOCAL $REMOTE
    
    [alias]
        st = status
        co = checkout
        br = branch
        ci = commit
        ca = commit -a
        ps = push
        pl = pull
        lg = log --oneline --graph --decorate --all
        unstage = reset HEAD --
        last = log -1 HEAD
        visual = !gitk
  '';

  # Git shell aliases
  environment.shellAliases = {
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gd = "git diff";
    gb = "git branch";
    gco = "git checkout";
    glog = "git log --oneline --graph --decorate";
  };
}
