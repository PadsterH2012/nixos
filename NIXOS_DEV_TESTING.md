# 🧪 NixOS Development Environment Testing

Universal test script for diagnosing NixOS development environments. Features an **interactive menu** for easy use, plus command-line options for automation.

## 🎯 Interactive Menu Mode (Recommended)

### For Local Use (Full Interactive Menu)

```bash
# Download and run locally for full interactive menu
wget https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh
chmod +x nixos-dev-test.sh
./nixos-dev-test.sh
```

### For Remote Use (Auto-runs Basic Test)

```bash
# When run via curl, automatically runs basic system test
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash
```

**Note**: The interactive menu requires a TTY (terminal). When run via curl/pipe, it automatically runs the basic system test and shows you how to access the full menu.

**Menu Options:**
```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           NixOS Dev Environment Tester v1.0.0               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Select tests to run:

  1) ⚙️  Basic System Information
  2) 📦 Node.js Environment (npm, npx)
  3) 📦 Docker Environment
  4) 📦 Python Environment
  5) 📦 Git Environment
  6) 📦 VS Code Environment
  7) 📦 Network Connectivity

  8) ⚙️  Change System Hostname

  9) 🚀 Run All Tests
  h) ℹ️  Show Help
  0) Exit

Enter your choice [0-9]:
```

## 🚀 Command Line Mode (For Automation)

### Run via curl with specific tests

```bash
# Test specific components
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node --docker

# Run all tests
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all
```

### Run locally

```bash
# Download and run interactively
wget https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh
chmod +x nixos-dev-test.sh
./nixos-dev-test.sh

# Or run with specific options
./nixos-dev-test.sh --all
```

## 📋 Available Test Options

| Option | Description |
|--------|-------------|
| `--basic` | Basic system info and NixOS setup |
| `--node` | Node.js, npm, npx availability |
| `--docker` | Docker installation and service |
| `--python` | Python installation |
| `--git` | Git installation and configuration |
| `--vscode` | VS Code installation |
| `--network` | Network connectivity tests |
| `--hostname` | Change system hostname (interactive) |
| `--all` | Run all available tests |

## 🎯 Common Use Cases

### 🎮 Interactive Diagnosis (Easiest)
```bash
# Download for full interactive menu
wget https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh
chmod +x nixos-dev-test.sh
./nixos-dev-test.sh
# Then choose: 2) Node.js Environment

# Or quick basic test via curl
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash
```

### 🤖 Automated Testing (For Scripts/CI)

#### Diagnose Node.js Issues
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node
```

#### Check Development Environment
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node --docker --git --vscode
```

#### Full System Check
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all
```

#### Network Connectivity Test
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --network
```

#### Change System Hostname
```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --hostname
```

## 🔍 What It Tests

### Basic Tests (`--basic`)
- ✅ System information (hostname, user, shell)
- ✅ NixOS detection and version
- ✅ Nix store availability
- ✅ Current PATH analysis

### Node.js Tests (`--node`)
- ✅ Node.js, npm, npx command availability
- ✅ Version information
- ✅ Execution testing
- ✅ NODE_PATH environment variable
- ✅ Nix store Node.js installations

### Docker Tests (`--docker`)
- ✅ Docker and Docker Compose availability
- ✅ Docker daemon status
- ✅ Running container count
- ✅ Service accessibility

### Python Tests (`--python`)
- ✅ Python 3 and pip availability
- ✅ Version information
- ✅ Execution testing

### Git Tests (`--git`)
- ✅ Git availability and version
- ✅ Global configuration (user.name, user.email)

### VS Code Tests (`--vscode`)
- ✅ VS Code command availability
- ✅ Flatpak VS Code detection

### Network Tests (`--network`)
- ✅ Internet connectivity (8.8.8.8)
- ✅ GitHub connectivity
- ✅ Development server connectivity (10.202.28.111)

### Hostname Management (`--hostname`)
- ✅ Display current hostname
- ✅ Interactive hostname change wizard
- ✅ Hostname format validation
- ✅ Temporary change (until reboot)
- ✅ Permanent change instructions for NixOS
- ✅ Specific guidance for dev-02 configuration

## 🛠️ Common Issues & Solutions

### Node.js Not Found in Scripts
**Problem**: `sh: node: command not found`

**Solutions**:
```bash
# Use full path
/run/current-system/sw/bin/node script.js

# Source profile in scripts
source /etc/profile
node script.js

# Update NixOS configuration
sudo nixos-rebuild switch
```

### Docker Permission Denied
**Problem**: `permission denied while trying to connect to Docker daemon`

**Solution**:
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

### VS Code Extensions Not Working
**Problem**: Extensions fail to load or install

**Solutions**:
```bash
# Enable nix-ld for compatibility
sudo nixos-rebuild switch

# Use Flatpak VS Code for better compatibility
flatpak install flathub com.visualstudio.code
```

### Change Hostname on NixOS
**Problem**: Need to change system hostname

**Solutions**:
```bash
# Temporary change (until reboot)
sudo hostnamectl set-hostname new-hostname

# Permanent change - edit NixOS configuration
sudo nano /etc/nixos/configuration.nix
# Change: networking.hostName = "new-hostname";
sudo nixos-rebuild switch

# For dev-02 configuration
# Edit: dev-02/nixos/modules/networking.nix
# Change: networking.hostName = "new-hostname";
# Deploy: cd dev-02 && ./deploy.sh
```

## 🎨 Features

### Interactive Menu Interface
- 🎮 **No need to remember command-line switches**
- 🎯 **Visual menu with clear options**
- 📋 **Easy selection by number**
- 🔄 **Help available within the menu**
- 🚪 **Clean exit option**

### Rich Output
- 🎨 **Color-coded output** for easy reading
- ✅ **Clear success/failure indicators**
- 📊 **Detailed version information**
- 💡 **Actionable suggestions** for fixes
- 🔍 **Comprehensive diagnostics**

## 🔧 Integration

### Use in CI/CD
```yaml
- name: Test NixOS Environment
  run: curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all
```

### Use in Scripts
```bash
#!/bin/bash
echo "Testing development environment..."
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --node --docker
```

### Remote Debugging
```bash
# Test remote system via SSH
ssh user@remote-host 'curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/nixos-dev-test.sh | bash -s -- --all'
```

## 📝 Example Output

```
================================
NixOS Dev Environment Tester v1.0.0
================================

⚙️ Basic System Information
----------------------------------------
   ℹ️ Hostname: nixos-dev-cinnamon
   ℹ️ User: paddy
   ℹ️ Shell: /run/current-system/sw/bin/bash
   ✅ NixOS detected
      Version: 24.11 (Vicuña)

📦 Node.js Environment
----------------------------------------
   ✅ Node.js: /run/current-system/sw/bin/node
      Version: v20.11.1
   ✅ npm: /run/current-system/sw/bin/npm
      Version: 10.2.4
   ✅ npx: /run/current-system/sw/bin/npx
      Version: 10.2.4
```

## 🤝 Contributing

Feel free to add more tests or improve the script! The script is designed to be:
- **Modular**: Easy to add new test categories
- **Portable**: Works on any NixOS system
- **Informative**: Provides actionable feedback
- **Reliable**: Handles errors gracefully

## 📚 Related Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Development Environment Setup](./dev-02/README.md)
- [MCP Configuration Guide](./MCP-UNIVERSAL-CONFIG.md)
