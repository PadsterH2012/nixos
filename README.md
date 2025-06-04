# Download the config
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/main/test.nix

# Apply it
sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix

mate, vscode
curl -o /tmp/config.nix https://raw.githubusercontent.com/PadsterH2012/nixos/refs/heads/main/new1.01.nix && sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix
