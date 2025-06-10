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
      8080  # Health check endpoint
      9000  # MCP services
    ];
  };

  # MCP-specific environment
  environment.variables = {
    MCP_PROXY_PORT = "3000";
    MCP_LOG_LEVEL = "info";
  };

  # MCP proxy server service
  systemd.services.mcp-proxy-server = {
    description = "MCP Proxy Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "paddy";
      WorkingDirectory = "/home/paddy/mcp-proxy";
      Restart = "always";
      RestartSec = "10";
    };

    script = ''
      # Ensure MCP proxy directory exists
      mkdir -p /home/paddy/mcp-proxy
      cd /home/paddy/mcp-proxy

      # Start MCP proxy server
      ${pkgs.nodejs}/bin/npx -y mcp-http-proxy --port 3000 --host 0.0.0.0
    '';
  };

  # Health check endpoint
  systemd.services.mcp-proxy-health = {
    description = "MCP Proxy Health Check";
    wantedBy = [ "multi-user.target" ];
    after = [ "mcp-proxy-server.service" ];

    serviceConfig = {
      Type = "simple";
      User = "paddy";
      Restart = "always";
      RestartSec = "30";
    };

    script = ''
      # Simple health check server
      ${pkgs.python3}/bin/python3 -c "
import http.server
import socketserver
import json

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health' or self.path == '/mcp-proxy/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {'status': 'healthy', 'service': 'mcp-proxy', 'port': 3000}
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

with socketserver.TCPServer(('', 8080), HealthHandler) as httpd:
    httpd.serve_forever()
"
    '';
  };
}
