# Host-specific configuration for hl-dev-mcp-proxy
# MCP (Model Context Protocol) proxy services

{ config, pkgs, ... }:

{
  imports = [
    # Import the shared development profile
    ../../shared/profiles/development.nix
    
    # Host-specific hardware configuration
    ./hardware-configuration.nix
    
    # Host-specific identity and network settings
    ./identity.nix
  ];

  # Host-specific overrides for MCP proxy services
  environment.systemPackages = with pkgs; [
    # Node.js ecosystem for MCP servers
    nodejs_20
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    
    # MCP development tools
    nodePackages.typescript
    nodePackages.ts-node
    nodePackages.nodemon
    
    # Proxy and networking tools
    nginx
    haproxy
    socat
    netcat
    
    # Process management
    pm2
    supervisor
    
    # Monitoring tools
    htop
    iotop
    nethogs
  ];

  # Enable Nginx for MCP proxy services
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  # Open firewall ports for MCP services
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      80    # HTTP
      443   # HTTPS
      3000  # MCP proxy default
      8080  # Alternative HTTP
      9000  # MCP services
    ];
  };

  # MCP-specific environment
  environment.variables = {
    MCP_PROXY_PORT = "3000";
    MCP_LOG_LEVEL = "info";
  };
}
