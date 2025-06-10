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
        
        # Future development VMs (ready to deploy)
        "dev-vm-01" = mkNixosConfiguration "dev-vm-01";
        "dev-vm-02" = mkNixosConfiguration "dev-vm-02";
        "dev-vm-03" = mkNixosConfiguration "dev-vm-03";
        "dev-vm-04" = mkNixosConfiguration "dev-vm-04";
        "dev-vm-05" = mkNixosConfiguration "dev-vm-05";
        "dev-vm-06" = mkNixosConfiguration "dev-vm-06";
        "dev-vm-07" = mkNixosConfiguration "dev-vm-07";
        "dev-vm-08" = mkNixosConfiguration "dev-vm-08";
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
          echo "  nixos-dev-cinnamon (current)"
          echo "  nixos-test-vm"
          echo "  dev-vm-01 through dev-vm-08"
        '';
      };
      
      # Packages for easy access to custom scripts
      packages.${system} = {
        deploy-all = pkgs.writeShellScriptBin "deploy-all" ''
          #!/bin/bash
          echo "🚀 Deploying to all development VMs..."
          
          HOSTS=("dev-vm-01" "dev-vm-02" "dev-vm-03" "dev-vm-04" "dev-vm-05" "dev-vm-06" "dev-vm-07" "dev-vm-08")
          
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
