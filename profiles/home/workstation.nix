{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}: {
  imports = [
    ../../modules/workstation
  ];

  home.packages = [
    # agent-browser@0.34.0 (fixed) — Hermes's pinned ^0.26.0 and nixpkgs's
    # 0.27.0 both break CDP attach to a live browser (Page.enable timeout).
    # Hermes discovery checks PATH first, so this wins over its npx fallback.
    (pkgs.callPackage ../../packages/agent-browser.nix { })
  ];

  # Job Watch — serve the jobs.json list as an HTML page on 127.0.0.1:8791.
  # A systemd user service (not a stray background process) so it survives
  # reboots and restarts on crash. Loopback-only.
  systemd.user.services.job-watch = {
    Unit = {
      Description = "Job Watch HTML server (serves ~/job-watch/jobs.json)";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 ${config.home.homeDirectory}/job-watch/server.py 8791";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "${config.home.homeDirectory}/job-watch";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Hermes rejects symlinked cron scripts whose resolved target is outside
  # ~/.hermes/scripts. Copy this declarative source as a regular executable.
  home.activation.ensureHeliumCdpScript = lib.hm.dag.entryAfter ["writeBoundary"] ''
    target="$HOME/.hermes/scripts/ensure-helium-cdp"
    rm -f "$target"
    install -Dm755 ${../../scripts/ensure-helium-cdp.sh} "$target"
  '';

  programs.ssh.settings.wired = {
    HostName = "wired";
    User = primaryUser;
    IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_wired";
    IdentitiesOnly = true;
    ServerAliveInterval = 30;
    ServerAliveCountMax = 3;
  };

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
    config."background_color" = "0.18 0.20 0.25";
  };

  programs.obsidian = {
    enable = true;
    package = null; # Installed system-wide in packages/graphical.nix.
    vaults.local.target = "Documents/Local";
    defaultSettings.communityPlugins = with pkgs.obsidianPlugins; [
      powereditor
    ];
  };

  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform-hint=auto"
      # Remote debugging so Hermes can attach to Helium's real profile (cookies/sessions) via CDP.
      # Loopback-only binding: not reachable from the network.
      "--remote-debugging-port=9222"
      "--remote-debugging-address=127.0.0.1"
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enableXdgAutostart = true;
    systemd.enable = true;
    systemd.variables = ["--all"];
    configType = "lua";
    extraConfig = ''
      ${builtins.readFile ../../modules/hypr/hyprland.lua}
    '';
  };

  xdg.configFile = {
    "hypr/hyprlock.conf".source = ../../modules/hypr/hyprlock.conf;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 1800;
          on-timeout = "hyprlock";
        }
        {
          timeout = 3600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
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

  home.file.".local/bin/ccbz" = {
    source = ../../scripts/ccbz.sh;
    executable = true;
  };

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
      "inode/directory" = ["io.github.berker_z.Marcel.desktop"];
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
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "text/html" = "helium.desktop";
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

  services.gammastep = {
    enable = true;
    provider = "manual";
    temperature.day = 5500;
    temperature.night = 3000;
    tray = true;
    latitude = 41.0;
    longitude = 28.9;
  };
}
