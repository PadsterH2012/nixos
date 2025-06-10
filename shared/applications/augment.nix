# Augment Code Configuration
# Settings optimized for AI agent interaction

{ config, pkgs, ... }:

{
  # Packages needed for Augment Code functionality
  environment.systemPackages = with pkgs; [
    # Core tools that Augment Code expects
    curl
    wget
    jq
    git
    
    # Node.js for MCP servers
    nodejs
    nodePackages.npm
    
    # Python for AI tools
    python3
    python3Packages.pip
    
    # Development tools
    gcc
    gnumake
  ];

  # Environment variables for AI agent compatibility
  environment.variables = {
    # Editor preference for AI agents
    EDITOR = "code --wait";
    
    # Ensure consistent terminal behavior
    TERM = "xterm-256color";
    
    # Node.js environment
    NODE_PATH = "${pkgs.nodejs}/lib/node_modules";
  };

  # Shell configuration optimized for AI agents
  programs.bash.shellInit = ''
    # Ensure predictable command behavior for AI agents
    export LC_ALL=C
    
    # Disable interactive prompts that could hang AI operations
    export DEBIAN_FRONTEND=noninteractive
    
    # Set consistent PATH for AI agent operations
    export PATH="${pkgs.nodejs}/bin:${pkgs.python3}/bin:${pkgs.git}/bin:${pkgs.curl}/bin:$PATH"
    
    # Function to check if running in AI agent context
    is_ai_agent() {
        [[ -n "$AUGMENT_AGENT" ]] || [[ -n "$AI_AGENT" ]] || [[ "$TERM_PROGRAM" == "augment" ]]
    }
    
    # Simplified prompt for AI agents
    if is_ai_agent; then
        export PS1='$ '
    fi
  '';

  # Aliases that work well with AI agents
  environment.shellAliases = {
    # Simple, predictable commands
    status = "systemctl status";
    logs = "journalctl -f";
    
    # Development shortcuts
    build = "nix-build";
    rebuild = "sudo nixos-rebuild switch --flake /mnt/network_repo/nixos";
    
    # File operations with consistent output
    list = "${pkgs.exa}/bin/exa -la";
    search = "${pkgs.ripgrep}/bin/rg";
    
    # Network diagnostics
    ping-test = "ping -c 4 8.8.8.8";
    
    # System information
    sysinfo = "uname -a && uptime && df -h";
  };

  # Systemd service to ensure MCP server compatibility
  systemd.user.services.mcp-environment = {
    description = "Ensure MCP server environment is ready";
    wantedBy = [ "default.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      # Ensure Node.js is accessible for MCP servers
      mkdir -p ~/.local/bin
      ln -sf ${pkgs.nodejs}/bin/node ~/.local/bin/node 2>/dev/null || true
      ln -sf ${pkgs.nodejs}/bin/npm ~/.local/bin/npm 2>/dev/null || true
      ln -sf ${pkgs.nodejs}/bin/npx ~/.local/bin/npx 2>/dev/null || true
      
      # Test MCP server availability
      if command -v npx >/dev/null 2>&1; then
        echo "MCP environment ready"
      else
        echo "Warning: MCP environment may not be properly configured"
      fi
    '';
  };
}
