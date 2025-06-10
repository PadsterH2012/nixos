{
  description = "NixOS Development Environment Flake - Multi-VM Development Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager for user-specific configurations
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Create pkgs with unfree packages allowed
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
      # Unstable packages for cutting-edge development tools
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      
      # Common arguments passed to all configurations
      commonArgs = {
        inherit system;
        specialArgs = { 
          inherit inputs pkgs-unstable;
        };
      };
      
      # Helper function to create NixOS configuration
      mkNixosConfiguration = hostname: nixpkgs.lib.nixosSystem (commonArgs // {
        modules = [
          # Shared development profile
          ./shared/profiles/development.nix
          
          # Host-specific configuration
          ./hosts/${hostname}/configuration.nix
          ./hosts/${hostname}/hardware-configuration.nix
          
          # Home Manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.paddy = import ./shared/home/paddy.nix;
          }
          
          # System-wide configuration
          {
            networking.hostName = hostname;
            system.stateVersion = "24.11";
          }
        ];
      });
      
    in {
      # NixOS Configurations for all development VMs
      nixosConfigurations = {
        # Current working machines
        "nixos-dev-cinnamon" = mkNixosConfiguration "nixos-dev-cinnamon";
        "nixos-test-vm" = mkNixosConfiguration "nixos-test-vm";

        # Specialized development VMs with static IPs (10.202.28.180+)
        "hl-dev-nixos-builder" = mkNixosConfiguration "hl-dev-nixos-builder";      # 10.202.28.180
        "hl-dev-ansible" = mkNixosConfiguration "hl-dev-ansible";                  # 10.202.28.181
        "hl-dev-mcp-proxy" = mkNixosConfiguration "hl-dev-mcp-proxy";              # 10.202.28.182
        "hl-dev-rpger" = mkNixosConfiguration "hl-dev-rpger";                      # 10.202.28.183
        "hl-dev-adhd-calendar" = mkNixosConfiguration "hl-dev-adhd-calendar";      # 10.202.28.184
        "hl-dev-rpger-extractor" = mkNixosConfiguration "hl-dev-rpger-extractor";  # 10.202.28.185
        "hl-dev-instructor" = mkNixosConfiguration "hl-dev-instructor";            # 10.202.28.186
        "hl-dev-rhel-satellite" = mkNixosConfiguration "hl-dev-rhel-satellite";    # 10.202.28.187
        "hl-pad-nixos-main" = mkNixosConfiguration "hl-pad-nixos-main";            # 10.202.28.188
      };
      
      # Development shell for working with this flake
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          nixos-rebuild
          home-manager
        ];
        
        shellHook = ''
          echo "🚀 NixOS Development Environment Flake"
          echo "Available commands:"
          echo "  nixos-rebuild switch --flake .#hostname"
          echo "  nix flake update"
          echo "  nix flake check"
          echo ""
          echo "Available hosts:"
          echo "  nixos-dev-cinnamon (current working machine)"
          echo "  nixos-test-vm (test machine)"
          echo ""
          echo "Specialized Development VMs (Static IPs 10.202.28.180+):"
          echo "  hl-dev-nixos-builder    (10.202.28.180) - NixOS build server"
          echo "  hl-dev-ansible          (10.202.28.181) - Ansible automation"
          echo "  hl-dev-mcp-proxy        (10.202.28.182) - MCP proxy services"
          echo "  hl-dev-rpger            (10.202.28.183) - RPG development"
          echo "  hl-dev-adhd-calendar    (10.202.28.184) - ADHD calendar tools"
          echo "  hl-dev-rpger-extractor  (10.202.28.185) - RPG data extraction"
          echo "  hl-dev-instructor       (10.202.28.186) - AI instruction tools"
          echo "  hl-dev-rhel-satellite   (10.202.28.187) - RHEL satellite mgmt"
          echo "  hl-pad-nixos-main       (10.202.28.188) - Main development"
        '';
      };
      
      # Packages for easy access to custom scripts
      packages.${system} = {
        deploy-all = pkgs.writeShellScriptBin "deploy-all" ''
          #!/bin/bash
          echo "🚀 Deploying to all development VMs..."

          HOSTS=(
            "hl-dev-nixos-builder"
            "hl-dev-ansible"
            "hl-dev-mcp-proxy"
            "hl-dev-rpger"
            "hl-dev-adhd-calendar"
            "hl-dev-rpger-extractor"
            "hl-dev-instructor"
            "hl-dev-rhel-satellite"
            "hl-pad-nixos-main"
          )

          for host in "''${HOSTS[@]}"; do
            echo "📡 Deploying to $host..."
            if ping -c 1 "$host" >/dev/null 2>&1; then
              ssh "paddy@$host" "cd /mnt/network_repo/nixos && sudo nixos-rebuild switch --flake .#$host"
            else
              echo "⚠️  $host is not reachable, skipping..."
            fi
          done

          echo "✅ Deployment complete!"
        '';
      };
    };
}
