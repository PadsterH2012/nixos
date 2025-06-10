# Bidirectional NixOS Configuration Management

## Overview

The enhanced script now supports three modes:
1. **Download** - Pull configuration from GitHub and apply it
2. **Upload** - Push current local configuration to GitHub
3. **Sync** - Download latest, then upload current state (bidirectional)

## Quick Start (One-Line Installation)

### Download and Run Directly from GitHub

```bash
# Download and apply configuration (most common use case)
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo PadsterH2012/nixos

# Upload current configuration to GitHub
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- upload --repo PadsterH2012/nixos --token YOUR_GITHUB_TOKEN

# Bidirectional sync (download then upload)
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- sync --repo PadsterH2012/nixos --token YOUR_GITHUB_TOKEN
```

### Quick Examples for Different Repositories

```bash
# For your own repository
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo yourusername/your-nixos-configs

# With specific branch
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo yourusername/nixos-configs --branch development

# With custom MAC address
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo yourusername/nixos-configs --mac 00:11:22:33:44:55
```

### Environment Variable Method

```bash
# Set your defaults
export NIXOS_CONFIG_REPO="yourusername/nixos-configs"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Then use simplified commands
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo -E bash -s -- download
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo -E bash -s -- upload
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo -E bash -s -- sync
```

### Download and Save for Repeated Use

```bash
# Download the script for local use
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh -o nixos-autoconfig.sh
chmod +x nixos-autoconfig.sh

# Then use normally
sudo ./nixos-autoconfig.sh download --repo yourusername/nixos-configs
```

## Setup Requirements

### 1. GitHub Personal Access Token

For uploading configurations, you'll need a GitHub Personal Access Token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with these permissions:
   - `repo` (Full control of private repositories)
   - `public_repo` (Access public repositories)
3. Save the token securely

### 2. Git Configuration

Ensure git is configured on your system:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Remote Execution via curl

### Security Considerations for curl Usage

When running scripts via curl, always:
1. **Inspect the script first**: `curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | less`
2. **Use HTTPS**: Ensures encrypted download
3. **Verify the repository**: Make sure you trust the source
4. **Use specific commits**: For production, pin to specific commit hashes

### curl Command Patterns

#### Basic Patterns
```bash
# Pattern: curl -sSL SCRIPT_URL | sudo bash -s -- COMMAND OPTIONS
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo USER/REPO

# With specific commit (recommended for production)
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/COMMIT_HASH/nixos-autoconfig-script.sh | sudo bash -s -- download --repo USER/REPO
```

#### Advanced curl Usage
```bash
# Dry run to see what would happen
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo USER/REPO --dry-run

# With timeout and retry
curl -sSL --max-time 30 --retry 3 https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo USER/REPO

# Save script and verify before running
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh -o /tmp/nixos-autoconfig.sh
sha256sum /tmp/nixos-autoconfig.sh  # Verify checksum if you have it
sudo bash /tmp/nixos-autoconfig.sh download --repo USER/REPO
```

### Remote Deployment Scenarios

#### New Machine Setup
```bash
# Step 1: Download and apply base configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo PadsterH2012/nixos

# Step 2: Verify the setup
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all
```

#### Emergency Recovery
```bash
# Rollback to known good configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo PadsterH2012/nixos --branch stable

# Or download specific machine configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo PadsterH2012/nixos --mac 00:11:22:33:44:55
```

#### Automated Deployment
```bash
#!/bin/bash
# deployment-script.sh - for automated deployments

set -euo pipefail

REPO="PadsterH2012/nixos"
SCRIPT_URL="https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh"

echo "🚀 Starting automated NixOS deployment..."

# Download and apply configuration
if curl -sSL "$SCRIPT_URL" | sudo bash -s -- download --repo "$REPO"; then
    echo "✅ Configuration applied successfully"

    # Run post-deployment tests
    if curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all; then
        echo "✅ All tests passed"
    else
        echo "⚠️ Some tests failed - manual review needed"
    fi
else
    echo "❌ Deployment failed"
    exit 1
fi
```

## Usage Examples

### Download Configuration (Default)

```bash
# Basic download
sudo ./install.sh --repo yourusername/nixos-configs

# Download from specific branch
sudo ./install.sh download --repo yourusername/nixos-configs --branch development

# Download with specific MAC address
sudo ./install.sh download --repo yourusername/nixos-configs --mac 00:11:22:33:44:55
```

### Upload Current Configuration

```bash
# Upload with token
sudo ./install.sh upload --repo yourusername/nixos-configs --token ghp_xxxxxxxxxxxx

# Upload with custom commit message
sudo ./install.sh upload --repo yourusername/nixos-configs --token ghp_xxxxxxxxxxxx --commit "Updated desktop environment"

# Upload using environment variable for token
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
sudo -E ./install.sh upload --repo yourusername/nixos-configs
```

### Bidirectional Sync

```bash
# Full sync (download latest, then upload current)
sudo ./install.sh sync --repo yourusername/nixos-configs --token ghp_xxxxxxxxxxxx

# Sync with custom commit message
sudo ./install.sh sync --repo yourusername/nixos-configs --token ghp_xxxxxxxxxxxx --commit "Sync after package updates"
```

### Environment Variables

Set default values to avoid repeating parameters:

```bash
export NIXOS_CONFIG_REPO="yourusername/nixos-configs"
export NIXOS_CONFIG_BRANCH="main"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Now you can use simplified commands:
sudo -E ./install.sh download
sudo -E ./install.sh upload
sudo -E ./install.sh sync
```

## Workflow Examples

### Initial Setup Workflow

```bash
# 1. Set up your first machine
sudo ./install.sh upload --repo yourusername/nixos-configs --token ghp_xxxxxxxxxxxx

# 2. Configure additional machines
sudo ./install.sh download --repo yourusername/nixos-configs

# 3. Make changes and sync back
sudo ./install.sh sync --repo yourusername/nixos-configs --token ghp_xxxxxxxxxxxx
```

### Development Workflow

```bash
# 1. Download latest configuration
sudo ./install.sh download --repo yourusername/nixos-configs --branch development

# 2. Make local changes to /etc/nixos/configuration.nix

# 3. Test the changes
sudo nixos-rebuild test

# 4. Upload the working configuration
sudo ./install.sh upload --repo yourusername/nixos-configs --branch development --token ghp_xxxxxxxxxxxx --commit "Added new development tools"
```

### Multi-Machine Management

```bash
# Machine A - Upload initial config
sudo ./install.sh upload --repo company/nixos-configs --token ghp_xxx --commit "Workstation A baseline"

# Machine B - Download and customize
sudo ./install.sh download --repo company/nixos-configs
# Make machine-specific changes
sudo ./install.sh upload --repo company/nixos-configs --token ghp_xxx --commit "Workstation B customizations"

# Machine C - Get latest from both machines
sudo ./install.sh sync --repo company/nixos-configs --token ghp_xxx
```

### curl-based Multi-Machine Management

```bash
# Machine A - Upload initial config via curl
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- upload --repo company/nixos-configs --token ghp_xxx --commit "Workstation A baseline"

# Machine B - Download and customize via curl
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo company/nixos-configs
# Make machine-specific changes
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- upload --repo company/nixos-configs --token ghp_xxx --commit "Workstation B customizations"

# Machine C - Get latest from both machines via curl
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- sync --repo company/nixos-configs --token ghp_xxx
```

### Common curl Use Cases

#### Development Workflow
```bash
# Quick development machine setup
export NIXOS_CONFIG_REPO="mycompany/dev-configs"
export NIXOS_CONFIG_BRANCH="development"

# Download latest dev configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo -E bash -s -- download

# Test the environment
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all

# Upload changes back
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo -E bash -s -- upload --commit "Added new development tools"
```

#### Production Deployment
```bash
# Use specific commit for production stability
COMMIT_HASH="a1b2c3d4e5f6"
SCRIPT_URL="https://raw.githubusercontent.com/PadsterH2012/nixos/${COMMIT_HASH}/nixos-autoconfig-script.sh"

# Deploy production configuration
curl -sSL "$SCRIPT_URL" | sudo bash -s -- download --repo company/nixos-configs --branch production

# Verify deployment
curl -sSL "https://raw.githubusercontent.com/PadsterH2012/nixos/${COMMIT_HASH}/nixos-dev-test.sh" | bash -s -- --all
```

#### Emergency Recovery
```bash
# Quick rollback to last known good configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo backup/nixos-configs --branch last-known-good

# Or rollback using NixOS generations
sudo nixos-rebuild switch --rollback
```

## Automated Uploads

### Systemd Service for Auto-Upload

Create a systemd service to automatically upload configuration changes:

```ini
# /etc/systemd/system/nixos-config-sync.service
[Unit]
Description=NixOS Configuration Auto-Sync
After=network-online.target

[Service]
Type=oneshot
Environment=GITHUB_TOKEN=ghp_xxxxxxxxxxxx
Environment=NIXOS_CONFIG_REPO=yourusername/nixos-configs
ExecStart=/usr/local/bin/install.sh upload --commit "Automated sync from %H"
User=root

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/nixos-config-sync.timer
[Unit]
Description=Run NixOS config sync daily
Requires=nixos-config-sync.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable the timer:
```bash
sudo systemctl enable nixos-config-sync.timer
sudo systemctl start nixos-config-sync.timer
```

### Hook into nixos-rebuild

Add automatic upload after successful rebuilds by creating a wrapper script:

```bash
#!/bin/bash
# /usr/local/bin/nixos-rebuild-and-sync
set -e

# Run normal nixos-rebuild
nixos-rebuild "$@"

# If rebuild was successful and we're doing 'switch', upload config
if [[ "$1" == "switch" ]] && [[ -n "$NIXOS_AUTO_UPLOAD" ]]; then
    echo "Uploading configuration after successful rebuild..."
    /usr/local/bin/install.sh upload --commit "Auto-upload after nixos-rebuild switch"
fi
```

## Security Considerations

### Token Storage

**Never store tokens in configuration files!** Use one of these secure methods:

1. **Environment variables** (preferred for servers):
   ```bash
   export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
   ```

2. **Systemd service with credentials**:
   ```ini
   [Service]
   LoadCredential=github-token:/etc/nixos/secrets/github-token
   ExecStart=/bin/sh -c 'GITHUB_TOKEN=$(cat $CREDENTIALS_DIRECTORY/github-token) /usr/local/bin/install.sh upload'
   ```

3. **Age encryption** for storing in repository:
   ```bash
   # Encrypt token
   echo "ghp_xxxxxxxxxxxx" | age -r age1... > .github-token.age
   
   # Decrypt and use
   GITHUB_TOKEN=$(age -d -i ~/.age/key.txt .github-token.age)
   ```

### Repository Access

- Use fine-grained personal access tokens when possible
- Limit token scope to specific repositories
- Consider using deploy keys for read-only access
- Regularly rotate tokens

## Generated Files

When uploading, the script automatically creates:

### Host README.md
Each `hosts/MAC_ADDRESS/README.md` contains:
- System information (hostname, kernel, architecture)
- Hardware summary (CPU, memory, disk)
- Network interfaces
- File listing with line counts
- Last update timestamp

### Repository Structure
```
nixos-configs/
├── hosts/
│   ├── 00:11:22:33:44:55/
│   │   ├── README.md              # Auto-generated
│   │   ├── configuration.nix      # Main config
│   │   ├── hardware-configuration.nix
│   │   ├── users.nix             # If exists
│   │   ├── packages.nix          # If exists
│   │   └── *.nix                 # Any other .nix files
│   └── aa:bb:cc:dd:ee:ff/
│       └── ...
```

## Troubleshooting

### Common Issues

1. **Permission denied on upload**:
   - Check GitHub token permissions
   - Ensure token hasn't expired
   - Verify repository exists and you have write access

2. **Git not configured**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

3. **Network connectivity**:
   - Test with: `curl -I https://github.com`
   - Check firewall settings
   - Verify proxy settings if behind corporate firewall

4. **No changes detected on upload**:
   - Use `--force` flag to upload anyway
   - Check if files have actually changed
   - Ensure correct MAC address detection

### Debug Mode

Add debug output by modifying the script:
```bash
# Add after the initial variables
set -x  # Enable debug output
```

Or use dry-run mode to see what would happen:
```bash
# Local script
sudo ./install.sh sync --repo yourusername/nixos-configs --dry-run

# Via curl
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- sync --repo yourusername/nixos-configs --dry-run
```

### curl-specific Troubleshooting

1. **Script download fails**:
   ```bash
   # Test script accessibility
   curl -I https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh

   # Download and inspect before running
   curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | head -20
   ```

2. **Script execution fails**:
   ```bash
   # Download to file first for debugging
   curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh -o /tmp/nixos-autoconfig.sh
   chmod +x /tmp/nixos-autoconfig.sh
   sudo /tmp/nixos-autoconfig.sh download --repo yourusername/nixos-configs --debug
   ```

3. **Environment variables not passed**:
   ```bash
   # Use -E flag with sudo to preserve environment
   export NIXOS_CONFIG_REPO="yourusername/nixos-configs"
   curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo -E bash -s -- download
   ```

## Quick Reference

### curl Command Templates

```bash
# Download and apply configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- download --repo USER/REPO

# Upload current configuration
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- upload --repo USER/REPO --token TOKEN

# Bidirectional sync
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-autoconfig-script.sh | sudo bash -s -- sync --repo USER/REPO --token TOKEN

# Test environment after deployment
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all
```

### Common Options

- `--repo USER/REPO` - GitHub repository
- `--branch BRANCH` - Git branch (default: main)
- `--token TOKEN` - GitHub personal access token
- `--mac MAC_ADDRESS` - Override MAC address detection
- `--commit MESSAGE` - Commit message for uploads
- `--dry-run` - Show what would be done without applying
- `--debug` - Enable verbose output

### Environment Variables

- `NIXOS_CONFIG_REPO` - Default repository
- `NIXOS_CONFIG_BRANCH` - Default branch
- `GITHUB_TOKEN` - GitHub token for authentication

### Security Best Practices for curl Usage

1. **Always use HTTPS**: Ensures encrypted download
2. **Inspect scripts first**: `curl -sSL SCRIPT_URL | less`
3. **Pin to specific commits**: Use commit hashes for production
4. **Verify checksums**: When available, verify script integrity
5. **Use environment variables**: Avoid tokens in command history

```bash
# Production-safe example
COMMIT_HASH="a1b2c3d4e5f6"
SCRIPT_URL="https://raw.githubusercontent.com/PadsterH2012/nixos/${COMMIT_HASH}/nixos-autoconfig-script.sh"
curl -sSL "$SCRIPT_URL" | sudo bash -s -- download --repo company/nixos-configs
```

This bidirectional approach gives you complete control over your NixOS configurations across multiple machines while maintaining a centralized, version-controlled repository. The curl-based execution makes it perfect for remote deployments, automation, and emergency recovery scenarios.