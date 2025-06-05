# Automatic system updates and maintenance module
# Configures automatic NixOS updates with optional reboots and maintenance tasks

{ config, pkgs, ... }:

{
  # Enable automatic system upgrades
  system.autoUpgrade = {
    enable = true;
    
    # Update schedule - run at 2:00 AM daily
    dates = "02:00";
    
    # Add randomized delay to prevent all systems updating simultaneously
    randomizedDelaySec = "45min";
    
    # Automatically reboot if kernel/initrd changes
    allowReboot = true;
    
    # Reboot window - only reboot between 2:00-6:00 AM
    rebootWindow = {
      lower = "02:00";
      upper = "06:00";
    };
    
    # Additional flags for the upgrade process
    flags = [
      "--upgrade"           # Upgrade to latest channel
      "--no-build-output"   # Reduce log verbosity
      "--show-trace"        # Show detailed error traces if build fails
    ];
    
    # Operation to perform (switch is default, but being explicit)
    operation = "switch";
  };

  # Enable automatic garbage collection to free up disk space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize nix store weekly
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];  # Run after auto-upgrade completes
  };

  # Create a maintenance script for additional cleanup tasks
  environment.etc."maintenance/auto-maintenance.sh" = {
    text = ''
      #!/bin/bash
      # Automatic maintenance script
      # Runs additional cleanup tasks after system updates
      
      echo "🔧 Starting automatic maintenance tasks..."
      
      # Clean up old Docker images and containers (if Docker is running)
      if systemctl is-active --quiet docker; then
        echo "🐳 Cleaning up Docker resources..."
        docker system prune -f --volumes
        docker image prune -a -f
      fi
      
      # Clean up old logs
      echo "📝 Cleaning up old logs..."
      journalctl --vacuum-time=30d
      
      # Clean up temporary files
      echo "🗑️ Cleaning up temporary files..."
      find /tmp -type f -atime +7 -delete 2>/dev/null || true
      find /var/tmp -type f -atime +30 -delete 2>/dev/null || true
      
      # Update locate database
      if command -v updatedb >/dev/null 2>&1; then
        echo "🔍 Updating locate database..."
        updatedb
      fi
      
      echo "✅ Maintenance tasks completed!"
    '';
    mode = "0755";
  };

  # Create a systemd service for the maintenance script
  systemd.services.auto-maintenance = {
    description = "Automatic system maintenance";
    after = [ "nixos-upgrade.service" ];
    wants = [ "nixos-upgrade.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/maintenance/auto-maintenance.sh";
      User = "root";
    };
  };

  # Create a timer for the maintenance service (runs after auto-upgrade)
  systemd.timers.auto-maintenance = {
    description = "Timer for automatic system maintenance";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnCalendar = "04:00";  # Run at 4:00 AM (after auto-upgrade)
      RandomizedDelaySec = "30min";
      Persistent = true;
    };
  };

  # Create a status script to check auto-upgrade status
  environment.etc."maintenance/check-auto-upgrade.sh" = {
    text = ''
      #!/bin/bash
      # Check auto-upgrade status and last run information
      
      echo "🔄 NixOS Auto-Upgrade Status"
      echo "=========================="
      echo ""
      
      echo "📅 Timer Status:"
      systemctl status nixos-upgrade.timer --no-pager -l
      echo ""
      
      echo "🔧 Last Upgrade Service Status:"
      systemctl status nixos-upgrade.service --no-pager -l
      echo ""
      
      echo "📊 System Generations:"
      nixos-rebuild list-generations | tail -5
      echo ""
      
      echo "🗑️ Garbage Collection Status:"
      systemctl status nix-gc.timer --no-pager -l
      echo ""
      
      echo "⚡ Store Optimization Status:"
      systemctl status nix-optimise.timer --no-pager -l
      echo ""
      
      echo "🔧 Maintenance Status:"
      systemctl status auto-maintenance.timer --no-pager -l
    '';
    mode = "0755";
  };

  # Add helpful aliases for managing auto-updates
  environment.shellAliases = {
    # Auto-upgrade management
    "upgrade-status" = "/etc/maintenance/check-auto-upgrade.sh";
    "upgrade-now" = "sudo nixos-rebuild switch --upgrade";
    "upgrade-logs" = "sudo journalctl -u nixos-upgrade.service -f";
    
    # Maintenance commands
    "maintenance-now" = "sudo /etc/maintenance/auto-maintenance.sh";
    "maintenance-status" = "sudo systemctl status auto-maintenance.timer";
    
    # System cleanup
    "cleanup-now" = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
    "generations" = "nixos-rebuild list-generations";
  };
}
