{
  config,
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
    waybar
    kitty
    hyprlock
    hypridle
    hyprpaper
    hyprshot
    hyprpicker #needed for hyprshot
    wlogout
    playerctl
    spotify
    bluez #bluetooth
    blueman #bluetooth
    pinta #paint kind of
    foliate #ebook reader
    swaylock-effects # i hated hyprlock
    vivaldi #like this these days
    vivaldi-ffmpeg-codecs
    vlc #media player
    deluge #torrent client
    appflowy #you kinda need to fuck with mime apps for this appflowy.flutter > appflowy.desktop iirc
    libsForQt5.qtstyleplugins #qt theming
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    telegram-desktop #web client sucks
    feh #picture viewer
    steam
    brave
    libsForQt5.kolourpaint
    drawing
    libreoffice
    gnome-clocks
    libsForQt5.breeze-icons
  ];

  services.mako = {
    enable = true;
    defaultTimeout = 2500;
    font = "monospace 11";
    anchor = "bottom-right";
    margin = "10";
    borderRadius = 10;
    borderSize = 1;
    borderColor = "#88c0d0";
    backgroundColor = "#2e3440";
    extraConfig = ''
      [mode=dnd]
      invisible=1
    '';
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

  xdg.configFile."hypr/hyprlock.conf" = {
    source = ./modules/hypr/hyprlock.conf;
  };

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
        {
          timeout = 1200;
          #on-timeout = "hyprctl dispatch dpms off";
          #on-resume = "hyprctl dispatch dpms on";
        }
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
    # font.name = "Iosevka Nerd Font";
    # font.size = 12;
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
    gtk2 = {
      configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
    };
  };
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    #style = {
    #   name = "kvantum";
    #};
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

    settings = {
      confirm_os_window_close = 0;
    };
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
      };

      #opener = {
      #text = {
      #  exec = "$EDITOR $@"; desc = "Open with editor";
      # exec = "xdg-open $@"; desc = "Open with default application";
      #};
      #fallback = {
      #exec = "xdg-open $@"; desc = "Open with default application";
      #};

      # };
    };
  };

  services.gammastep = {
    #redshift
    enable = false;
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
      logo = {
        source = "~/.dotfiles/assets/ascii.txt";
      };
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

  xdg.configFile."swaylock/config" = {
    source = ./modules/swaylock/config;
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    #  GDK_SCALE = "1"; # Adjust this value (1, 1.25, 1.5, 2, etc.)
    # GDK_DPI_SCALE = "1";
    # QT_STYLE_OVERRIDE = "kvantum";
  };
}
