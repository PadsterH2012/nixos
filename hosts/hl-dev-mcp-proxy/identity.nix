# Identity configuration for hl-dev-mcp-proxy
# MCP proxy services server - Static IP 10.202.28.182

{ config, pkgs, ... }:

{
  # Network configuration with static IP
  networking = {
    hostName = "hl-dev-mcp-proxy";
    
    # Disable NetworkManager for static IP configuration
    networkmanager.enable = false;
    
    # Static IP configuration
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.182";
      prefixLength = 24;
    }];
    
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    
    # Enable networking
    useDHCP = false;
  };

  # Machine identification
  environment.etc."machine-id".text = "hl-dev-mcp-proxy";

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to show identity
    extraSessionCommands = ''
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "MCP Proxy Server" "Machine: hl-dev-mcp-proxy\nIP: 10.202.28.182\nRole: Model Context Protocol Services" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-mcp-proxy";
    VM_ROLE = "mcp-proxy";
    VM_IP = "10.202.28.182";
    MCP_SERVER = "true";
  };

  # Custom shell aliases for MCP development
  environment.shellAliases = {
    mcp-start = "pm2 start mcp-proxy";
    mcp-stop = "pm2 stop mcp-proxy";
    mcp-logs = "pm2 logs mcp-proxy";
    mcp-status = "pm2 status";
    proxy-test = "curl -X GET http://localhost:3000/health";
    nginx-reload = "sudo systemctl reload nginx";
  };
}
