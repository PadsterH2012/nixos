#!/bin/bash

# Migration script to clean up old structure and finalize flakes setup

echo "🚀 Migrating to Flakes-based NixOS Configuration"
echo

# Remove old export scripts and one-off tools
echo "📦 Cleaning up old scripts..."
rm -f export-nixos-config.sh
rm -f export-nixos-hands-off.sh
rm -f bulk-export-nixos.sh
rm -f setup-nixos-export-auth.sh
rm -f setup-github-auth.sh
rm -f simple-export.sh
rm -f quick-setup.sh
rm -f smart-deploy.sh
rm -f force-deploy.sh
rm -f fix-networking-conflict.sh
rm -f simple_export.md
rm -f NIXOS_CONFIG_EXPORT.md

echo "✅ Removed old export scripts"

# Remove old dev-02 directory (replaced by shared structure)
if [ -d "dev-02" ]; then
    echo "📦 Removing old dev-02 directory..."
    rm -rf dev-02
    echo "✅ Removed dev-02 directory"
fi

# Create template configurations for remaining VMs
echo "📦 Creating template configurations for dev-vm-02 through dev-vm-08..."

for i in {02..08}; do
    VM_NAME="dev-vm-$i"
    
    if [ ! -d "hosts/$VM_NAME" ]; then
        mkdir -p "hosts/$VM_NAME"
        
        # Copy template configuration
        cp "hosts/dev-vm-01/configuration.nix" "hosts/$VM_NAME/"
        cp "hosts/dev-vm-01/hardware-configuration.nix" "hosts/$VM_NAME/"
        
        # Create customized identity.nix
        sed "s/dev-vm-01/$VM_NAME/g; s/VM_NUMBER = \"01\"/VM_NUMBER = \"$i\"/g" \
            "hosts/dev-vm-01/identity.nix" > "hosts/$VM_NAME/identity.nix"
        
        echo "✅ Created $VM_NAME configuration"
    fi
done

# Create nixos-test-vm configuration (based on the other working machine)
if [ ! -d "hosts/nixos-test-vm" ]; then
    echo "📦 Creating nixos-test-vm configuration..."
    mkdir -p "hosts/nixos-test-vm"
    
    # Copy from the test machine if it exists
    if [ -d "hosts/bc:24:11:07:02:2e" ]; then
        cp "hosts/bc:24:11:07:02:2e/hardware-configuration.nix" "hosts/nixos-test-vm/" 2>/dev/null || \
        cp "hosts/dev-vm-01/hardware-configuration.nix" "hosts/nixos-test-vm/"
    else
        cp "hosts/dev-vm-01/hardware-configuration.nix" "hosts/nixos-test-vm/"
    fi
    
    # Create configuration.nix
    cat > "hosts/nixos-test-vm/configuration.nix" << 'EOF'
# Host-specific configuration for nixos-test-vm
# Test machine configuration

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

  # Host-specific overrides can go here
  # Most configuration comes from the shared profile
}
EOF

    # Create identity.nix
    cat > "hosts/nixos-test-vm/identity.nix" << 'EOF'
# Identity configuration for nixos-test-vm
# Test machine identity settings

{ config, pkgs, ... }:

{
  # Network configuration
  networking = {
    hostName = "nixos-test-vm";
    
    # Use NetworkManager for DHCP (recommended)
    networkmanager.enable = true;
  };

  # Machine identification
  environment.etc."machine-id".text = "nixos-test-vm";

  # Desktop environment customization
  services.xserver.desktopManager.cinnamon = {
    enable = true;
    
    # Custom session script to show identity
    extraSessionCommands = ''
      # Show machine identity in notification
      ${pkgs.libnotify}/bin/notify-send "Test VM" "Machine: nixos-test-vm\nIP: $(hostname -I | awk '{print $1}')" --icon=computer
    '';
  };

  # Host-specific environment variables
  environment.variables = {
    HOSTNAME_DISPLAY = "nixos-test-vm";
    VM_ROLE = "testing";
  };
}
EOF

    echo "✅ Created nixos-test-vm configuration"
fi

echo
echo "🎉 Migration to flakes structure complete!"
echo
echo "📋 Next steps:"
echo "1. Review the new structure in shared/ and hosts/ directories"
echo "2. Test deployment: sudo nixos-rebuild switch --flake .#nixos-dev-cinnamon"
echo "3. Read FLAKES_USAGE.md for detailed usage instructions"
echo "4. Commit changes to Git repository"
echo
echo "🚀 Your development environment is now flakes-based with:"
echo "   • Reproducible builds with locked dependencies"
echo "   • Shared configuration eliminating code duplication"
echo "   • Easy deployment to multiple VMs"
echo "   • Comprehensive documentation"
