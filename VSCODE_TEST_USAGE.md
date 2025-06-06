# VS Code OAuth Authentication Test Scripts

## Overview

These scripts help diagnose and fix VS Code OAuth authentication issues on NixOS via SSH connection.

## Files Created

1. **`vscode_oauth_test_script.sh`** - Main diagnostic script (runs on NixOS machine)
2. **`run_remote_vscode_test.sh`** - Remote runner script (runs from your local machine)
3. **`VSCODE_TEST_USAGE.md`** - This usage guide

## Quick Start

### Option 1: Run Directly via SSH (Recommended)

```bash
# From your local machine, run this single command:
ssh paddy@<nixos-machine-ip> 'bash -s' < vscode_oauth_test_script.sh
```

Replace `<nixos-machine-ip>` with your NixOS machine's IP address.

### Option 2: Use the Remote Runner Script

```bash
# Make sure you're in the directory with the scripts
./run_remote_vscode_test.sh
```

The script will prompt you for:
- Hostname/IP of your NixOS machine
- Username (probably 'paddy')
- SSH key path (optional)

## What the Test Script Checks

### 🔍 **System Information**
- NixOS version
- Desktop environment
- Display settings

### 📦 **Package Installation**
- VS Code (`code` command)
- GNOME Keyring
- Seahorse (keyring GUI)

### 📚 **Library Availability**
- **libsecret** (CRITICAL for OAuth)
- libgnome-keyring

### 🔐 **Keyring Status**
- GNOME Keyring daemon running
- Keyring accessibility
- Secret storage functionality

### 🖥️ **Desktop Integration**
- VS Code desktop files
- **Protocol handler registration** (`x-scheme-handler/vscode`)
- MIME type associations

### 🌐 **OAuth Flow Testing**
- `vscode://` URL handling
- xdg-open functionality
- Browser callback simulation

## Interpreting Results

### ✅ **PASS** - Component working correctly
### ❌ **FAIL** - Critical issue that needs fixing
### ⚠️ **WARN** - Potential issue or missing optional component
### ℹ️ **INFO** - Informational output

## Common Issues and Fixes

### 1. **libsecret Missing**
```
❌ FAIL: Library libsecret is NOT available
```

**Fix**: Add to your NixOS configuration:
```nix
environment.systemPackages = with pkgs; [
  vscode
  libsecret  # Add this line
];
```

### 2. **Protocol Handler Not Registered**
```
❌ FAIL: vscode:// protocol handler NOT configured
```

**Fix**: Add to VS Code desktop file:
```
MimeType=text/plain;inode/directory;x-scheme-handler/vscode;
```

### 3. **Keyring Not Running**
```
❌ FAIL: GNOME Keyring daemon is NOT running
```

**Fix**: Check PAM configuration:
```nix
security.pam.services.lightdm.enableGnomeKeyring = true;
```

## Automated Fixes

The script includes automated fixes that can:
- Register the `vscode://` protocol handler
- Update MIME and desktop databases
- Test keyring functionality

When prompted, type `y` to attempt automated fixes.

## Advanced Testing

The remote runner script offers additional tests:
1. **URL handling test** - Tests `vscode://` URLs directly
2. **Extension directory check** - Verifies VS Code setup
3. **Keyring access test** - Tests secret storage/retrieval
4. **System report** - Detailed configuration dump

## Expected Output for Working System

```
✅ PASS: code is installed
✅ PASS: Library libsecret is available
✅ PASS: GNOME Keyring daemon is running
✅ PASS: Keyring is accessible
✅ PASS: Protocol handler registered in desktop file
✅ PASS: vscode:// protocol handler: code.desktop
```

## Troubleshooting

### SSH Connection Issues
- Verify SSH service is running: `sudo systemctl status sshd`
- Check firewall: `sudo ufw status` or `iptables -L`
- Test basic SSH: `ssh paddy@<ip> 'echo test'`

### Permission Issues
- Ensure user is in correct groups: `groups paddy`
- Check file permissions: `ls -la ~/.config/Code`

### Display Issues (for GUI tests)
- Set DISPLAY variable: `export DISPLAY=:0`
- Check X11 forwarding: `ssh -X user@host`

## Next Steps After Running Tests

1. **Review the diagnostic output**
2. **Apply recommended fixes** to your NixOS configuration
3. **Deploy changes**: `sudo nixos-rebuild switch`
4. **Reboot** to ensure all changes take effect
5. **Re-run the test script** to verify fixes
6. **Test actual OAuth flow** with Augment Code extension

## Support

If issues persist after applying fixes:
1. **Save the complete diagnostic output**
2. **Check the detailed analysis report**: `VS_Code_OAuth_Authentication_Analysis_Report.md`
3. **Consider alternative solutions** (vscode-fhs, Flatpak)
4. **Report specific error messages** for further troubleshooting
