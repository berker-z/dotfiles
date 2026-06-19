{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./codex.nix
    ./modules
    ./hosts/${osConfig.networking.hostName}/home.nix
  ];

  home.username = "berkerz";
  home.homeDirectory = "/home/berkerz";

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 2500;
      font = "monospace 11";
      anchor = "bottom-right";
      margin = 10;
      border-radius = 10;
      border-size = 1;
      border-color = "#88c0d0";
      background-color = "#2e3440";

      "mode=dnd".invisible = 1;
      "urgency=critical".default-timeout = 0;
    };
  };

  programs.sioyek = {
    enable = true;
    config = {
      "background_color" = "0.18 0.20 0.25";
    };
  };

  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform-hint=auto"
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enableXdgAutostart = true;
    systemd.enable = true;
    systemd.variables = ["--all"];
    configType = "hyprlang";
    extraConfig = ''
      ${builtins.readFile ./modules/hypr/hyprland.conf}
    '';
  };

  xdg.configFile."hypr/hyprlock.conf".source = ./modules/hypr/hyprlock.conf;
  xdg.configFile."waybar/style.css".source = ./modules/waybar/style.css;
  xdg.configFile."waybar/config.jsonc".source = let
    host = osConfig.networking.hostName;
  in
    if host == "laptop"
    then ./modules/waybar/config-laptop.jsonc
    else ./modules/waybar/config.jsonc;

  services.hypridle = let
    host = osConfig.networking.hostName;
  in {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener =
        [
          {
            timeout = 1800;
            on-timeout = "hyprlock";
          }
        ]
        ++ lib.optionals (host != "nixos") [
          {
            timeout = 3600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      splash = false;
      splash_offset = 2;
      wallpaper = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/dotfiles/assets/fog.jpg";
          fit_mode = "cover";
        }
      ];
    };
  };

  #xdg.configFile."Kvantum/Nordic".source = "${pkgs.nordic}/share/Kvantum/Nordic";

  home.file.".local/bin/ccbz" = {
    source = ./scripts/ccbz.sh;
    executable = true;
  };

  home.file.".local/bin/hermes-desktop-remote" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      env_file="''${XDG_CONFIG_HOME:-$HOME/.config}/hermes-desktop/remote.env"

      if [[ -f "$env_file" ]]; then
        set -a
        # shellcheck disable=SC1090
        . "$env_file"
        set +a
      fi

      if [[ -z "''${HERMES_DESKTOP_REMOTE_URL:-}" || -z "''${HERMES_DESKTOP_REMOTE_TOKEN:-}" ]]; then
        printf 'Hermes Desktop remote access is not configured.\n' >&2
        printf 'Create %s with HERMES_DESKTOP_REMOTE_URL and HERMES_DESKTOP_REMOTE_TOKEN.\n' "$env_file" >&2
        exit 1
      fi

      if command -v curl >/dev/null 2>&1; then
        status="$(
          curl --silent --output /dev/null --write-out '%{http_code}' \
            --connect-timeout 2 --max-time 4 \
            --header "Authorization: Bearer $HERMES_DESKTOP_REMOTE_TOKEN" \
            "''${HERMES_DESKTOP_REMOTE_URL%/}/api/profiles/sessions" || true
        )"

        if [[ "$status" == "404" ]]; then
          printf 'Hermes Desktop remote API is incompatible; falling back to local backend.\n' >&2
          unset HERMES_DESKTOP_REMOTE_URL HERMES_DESKTOP_REMOTE_TOKEN
        fi
      fi

      export HERMES_HOME="''${HERMES_HOME:-$HOME/.hermes}"
      mkdir -p "$HERMES_HOME"

      exec /run/current-system/sw/bin/hermes-desktop "$@"
    '';
    executable = true;
  };

  xdg.configFile."hermes-desktop/remote.env.example".text = ''
    # Copy this to ~/.config/hermes-desktop/remote.env and chmod 600 it.
    # Keep the real token out of Git and out of the Nix store.
    HERMES_DESKTOP_REMOTE_URL=https://hermes.example.com
    HERMES_DESKTOP_REMOTE_TOKEN=replace-with-remote-gateway-token
  '';

  ######## custom entries for launcher etc. ########
  xdg.desktopEntries.mirror = {
    name = "Mirror";
    comment = "Webcam preview with no UI";
    exec = "guvcview --gui=none";
    terminal = false;
    icon = "guvcview";
    categories = [
      "Utility"
      "Video"
    ];
  };

  xdg.desktopEntries.ccbz = {
    name = "CCBZ";
    comment = "Open wiremix, bluetuith, and nmcli in Kitty windows";
    exec = "${config.home.homeDirectory}/.local/bin/ccbz";
    terminal = false;
    icon = "utilities-terminal";
    categories = [
      "System"
      "Settings"
      "Utility"
    ];
  };

  xdg.desktopEntries.hermes-desktop-remote = {
    name = "Hermes Desktop Remote";
    comment = "Connect Hermes Desktop to the remote Hermes gateway";
    exec = "${config.home.homeDirectory}/.local/bin/hermes-desktop-remote";
    terminal = false;
    icon = "hermes";
    categories = [
      "Utility"
      "Development"
    ];
  };

  #APPARENTLY THIS IS THE ONLY WAY TO OVERRIDE DESKTOP ENTRIES??
  xdg.dataFile."applications/com.github.johnfactotum.Foliate.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Foliate
    Exec=env GDK_BACKEND=x11 foliate %U
    Icon=com.github.johnfactotum.Foliate
    Categories=Office;Viewer;
    MimeType=application/epub+zip;
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
      "image/jpeg" = ["org.gnome.Loupe.desktop"];
      "image/jpg" = ["org.gnome.Loupe.desktop"];
      "image/gif" = ["org.gnome.Loupe.desktop"];
      "image/bmp" = ["org.gnome.Loupe.desktop"];
      "image/tiff" = ["org.gnome.Loupe.desktop"];
      "image/webp" = ["org.gnome.Loupe.desktop"];
      "application/pdf" = ["sioyek.desktop"];
      "application/epub+zip" = ["com.github.johnfactotum.Foliate.desktop"];
      "video/*" = ["vlc.desktop"];
      "audio/*" = ["vlc.desktop"];
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "text/html" = "zen.desktop";
      "text/plain" = "org.xfce.mousepad.desktop";
    };

    associations.added = {
      "x-scheme-handler/appflowy-flutter" = "appflowy.desktop";
      "x-scheme-handler/appflowy" = "appflowy.desktop";
      "x-scheme-handler/appflowy-desktop" = "appflowy.desktop";
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "Nord";
    settings.confirm_os_window_close = 0;
    keybindings = {
      "ctrl+t" = "new_tab";
      "ctrl+n" = "new_window";
      "alt+tab" = "next_window";
      "ctrl+tab" = "next_tab";
      "ctrl+w" = "close_window";
      "ctrl+q" = "close_tab";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      otto = {
        HostName = "100.118.69.26";
        User = "hermes";
        IdentityFile = "${config.home.homeDirectory}/Projects/hermesbox/ssh-key-2026-05-01.key";
        IdentitiesOnly = true;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
        HostKeyAlias = "hermesbox";
        StrictHostKeyChecking = "accept-new";
        UserKnownHostsFile = "/tmp/hermesbox_known_hosts";
      };
    };
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings.manager.show_hidden = true;
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    temperature.day = 5500;
    temperature.night = 3000;
    tray = true;
    latitude = 41.0;
    longitude = 28.9;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo.source = "~/dotfiles/assets/ascii.txt";
      modules = [
        "title"
        "separator"
        "os"
        "packages"
        "kernel"
        "uptime"
        "shell"
        "display"
        "wmtheme"
        "theme"
        "de"
        "wm"
        "terminal"
        "terminalfont"
        "cpu"
        "disk"
        "break"
      ];
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
