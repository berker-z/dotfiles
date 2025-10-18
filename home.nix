{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./modules
    ./hosts/${osConfig.networking.hostName}/home.nix
  ];

  home.username = "berkerz";
  home.homeDirectory = "/home/berkerz";

  home.packages = with pkgs; [
    # core ui
    waybar
    kitty

    # hypr ecosystem
    hyprlock
    hypridle
    hyprpaper
    hyprshot
    hyprpicker
    hyprqt6engine
    hyprland-qtutils # new qt-6 platform theme
    hyprland-qt-support
    syspower

    # everyday tools
    wlogout
    playerctl
    spotify
    bluez
    blueman
    pinta
    foliate
    sioyek
    swaylock-effects
    vivaldi
    vivaldi-ffmpeg-codecs
    brave
    vlc
    deluge
    steam
    appflowy
    telegram-desktop
    feh
    drawing
    libreoffice
    gnome-clocks
  ];

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

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enableXdgAutostart = true;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = ''
      ${builtins.readFile ./modules/hypr/hyprland.conf}
    '';
  };

  xdg.configFile."hypr/hyprlock.conf".source = ./modules/hypr/hyprlock.conf;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "swaylock -f";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "swaylock -f";
        }
        {timeout = 1200;}
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
      splash = false;
      splash_offset = 2.0;
      preload = "~/.dotfiles/assets/aur.jpg";
      wallpaper = ",~/.dotfiles/assets/aur.jpg";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };

    iconTheme = {
      name = "Nordzy";
      package = pkgs.nordzy-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    gtk2.configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # symlink Nordic assets for libadwaita
  home.file.".config/assets".source = "${pkgs.nordic}/share/themes/Nordic/assets";
  home.file.".local/share/themes/Nordic/assets".source = "${pkgs.nordic}/share/themes/Nordic/assets";

  qt = {
    enable = true;
    platformTheme.name = "hyprqt6engine";
    #style.name = "adwaita-dark";
    style.name = "kvantum"; # keep kvantum style
  };

  ######## custom entries for launcher etc. ########
  xdg.desktopEntries.mirror = {
    name = "Mirror";
    comment = "Webcam preview with no UI";
    exec = "guvcview --gui=none";
    terminal = false;
    icon = "guvcview";
    categories = ["Utility" "Video"];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
      "image/png" = ["feh.desktop"];
      "image/jpeg" = ["feh.desktop"];
      "image/jpg" = ["feh.desktop"];
      "image/gif" = ["feh.desktop"];
      "image/bmp" = ["feh.desktop"];
      "image/tiff" = ["feh.desktop"];
      "image/webp" = ["feh.desktop"];
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
      logo.source = "~/.dotfiles/assets/ascii.txt";
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
        "colors"
      ];
    };
  };

  xdg.configFile."swaylock/config".source = ./modules/swaylock/config;

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  #theme=KvArcDark
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]

    theme=Nordic-Dark
  '';
}
