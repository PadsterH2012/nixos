# VS Code Terminal Settings for Augment Code Compatibility
# Optimized for AI agent interaction and development workflow

{ config, pkgs, ... }:

{
  # Create VS Code settings directory and configuration
  system.activationScripts.vscode-terminal-settings = ''
    # Create VS Code settings directories
    mkdir -p /home/paddy/.var/app/com.visualstudio.code/config/Code/User
    mkdir -p /home/paddy/.config/Code/User
    
    # VS Code settings optimized for Augment Code
    cat > /home/paddy/.var/app/com.visualstudio.code/config/Code/User/settings.json << 'EOF'
{
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.scrollback": 10000,
  "terminal.integrated.defaultProfile.linux": "bash",
  
  "terminal.integrated.profiles.linux": {
    "bash": {
      "path": "/bin/bash",
      "args": ["-l"],
      "icon": "terminal-bash"
    }
  },
  
  "terminal.integrated.confirmOnExit": "never",
  "terminal.integrated.confirmOnKill": "never",
  "terminal.integrated.enableBell": false,
  "terminal.integrated.fastScrollSensitivity": 5,
  "terminal.integrated.mouseWheelScrollSensitivity": 1,
  "terminal.integrated.smoothScrolling": true,
  
  "terminal.integrated.env.linux": {
    "EDITOR": "code --wait",
    "PAGER": "less",
    "TERM": "xterm-256color"
  },
  
  "editor.fontSize": 14,
  "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "editor.fontLigatures": true,
  "editor.lineNumbers": "on",
  "editor.minimap.enabled": true,
  "editor.wordWrap": "on",
  
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "vs-seti",
  
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  
  "extensions.autoUpdate": true,
  "update.mode": "start",
  
  "telemetry.telemetryLevel": "off"
}
EOF
    
    # Copy to native VS Code location as well
    cp /home/paddy/.var/app/com.visualstudio.code/config/Code/User/settings.json /home/paddy/.config/Code/User/settings.json 2>/dev/null || true
    
    # Set proper ownership
    chown -R paddy:users /home/paddy/.var/app/com.visualstudio.code/config 2>/dev/null || true
    chown -R paddy:users /home/paddy/.config/Code 2>/dev/null || true
    
    echo "VS Code terminal settings configured for Augment Code compatibility"
  '';
  
  # Install JetBrains Mono font system-wide
  fonts.packages = with pkgs; [
    jetbrains-mono
    fira-code
    fira-code-symbols
  ];
  
  # Enable font configuration
  fonts.fontconfig.enable = true;
}
