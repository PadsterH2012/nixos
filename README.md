# Download the config
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/main/test.nix

# Apply it
sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix

## Standard Development Configuration (MATE + VSCode)
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/new1.01.nix && sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix

## Streamlined Development Configuration (Auto-login + NFS + XRDP)
# Features: lightweight MATE desktop, auto-login, SSH, Docker, NFS client, XRDP remote access
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/dev-streamlined.nix && sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix
