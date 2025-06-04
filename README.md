# Download the config
curl -o /tmp/config.nix https://raw.githubusercontent.com/username/repo/main/configuration.nix

# Apply it
sudo nixos-rebuild switch -I nixos-config=/tmp/config.nix
