# VS Code Application Configuration
# VS Code setup with extensions and settings

{ config, pkgs, ... }:

{
  # Install VS Code variants (extensions installed via Flatpak or manually)
  environment.systemPackages = with pkgs; [
    # VS Code variants
    vscode          # Native VS Code
    vscode-fhs      # FHS-compatible VS Code

    # Note: VS Code extensions are better installed via:
    # 1. Flatpak VS Code (for OAuth support)
    # 2. VS Code marketplace (for latest versions)
    # 3. Manual installation as needed
  ];

  # Shell aliases for VS Code variants
  environment.shellAliases = {
    code = "flatpak run com.visualstudio.code";  # Default to Flatpak for OAuth
    code-native = "${pkgs.vscode}/bin/code";
    code-fhs = "${pkgs.vscode-fhs}/bin/code";
    code-flatpak = "flatpak run com.visualstudio.code";
  };

  # Ensure Flatpak is available for VS Code OAuth
  services.flatpak.enable = true;

  # Add Flathub repository
  systemd.services.flatpak-repo = {
    description = "Add Flathub repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # System-wide VS Code configuration with Augment MCP integration
  environment.etc."vscode/settings.json" = {
    text = builtins.toJSON {
      # Editor settings
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'Source Code Pro', 'Droid Sans Mono', monospace";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.wordWrap" = "on";
      "editor.minimap.enabled" = true;
      "editor.rulers" = [ 80 120 ];

      # Workbench settings
      "workbench.colorTheme" = "Dark+ (default dark)";
      "workbench.iconTheme" = "vs-seti";
      "workbench.startupEditor" = "newUntitledFile";

      # Terminal settings
      "terminal.integrated.shell.linux" = "${pkgs.bash}/bin/bash";
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.cursorBlinking" = true;

      # Git settings
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;

      # File settings
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # Search settings
      "search.exclude" = {
        "**/node_modules" = true;
        "**/bower_components" = true;
        "**/.git" = true;
        "**/dist" = true;
        "**/build" = true;
      };

      # Privacy settings
      "telemetry.telemetryLevel" = "off";
      "update.showReleaseNotes" = false;

      # Augment Code settings
      "augment.enableTelemetry" = false;
      "augment.enableAnalytics" = false;
      "augment.autoIndex" = true;

      # Augment MCP Servers (correct format based on research)
      "augment.mcpServers" = {
        "central-obsidian" = {
          "url" = "http://10.202.28.111:9090/obsidian-mcp-tools/sse";
        };
        "central-rpg" = {
          "url" = "http://10.202.28.111:9090/rpg-tools/sse";
        };
        "central-search" = {
          "url" = "http://10.202.28.111:9090/brave-search/sse";
        };
        "central-memory" = {
          "url" = "http://10.202.28.111:9090/memory/sse";
        };
        "central-mongodb" = {
          "url" = "http://10.202.28.111:9090/mongodb/sse";
        };
        "central-context7" = {
          "url" = "http://10.202.28.111:9090/Context7/sse";
        };
        "central-jenkins" = {
          "url" = "http://10.202.28.111:9090/jenkins-mcp/sse";
        };
      };
    };
    mode = "0644";
  };
}
