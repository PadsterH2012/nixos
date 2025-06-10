# Simple NixOS Configuration Export

## Step 1: Create Config File

```bash
echo 'export GITHUB_USERNAME="PadsterH2012"' > ~/.nixos-export-config
echo 'export GITHUB_TOKEN="ghp_your_new_token_here"' >> ~/.nixos-export-config
chmod 600 ~/.nixos-export-config
```

## Step 2: Run Export

```bash
curl -sSL https://raw.githubusercontent.com/PadsterH2012/nixos/main/export-nixos-config.sh | bash
```

That's it! Your NixOS configuration will be exported to the repository.
