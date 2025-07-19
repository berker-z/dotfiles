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
    sioyek
    swaylock-effects # i hated hyprlock
    vivaldi #like this these days
    vivaldi-ffmpeg-codecs
    vlc #media player
    deluge #torrent client
    appflowy #you kinda need to fuck with mime apps for this appflowy.flutter > appflowy.desktop iirc
    libsForQt5.qtstyleplugins #qt theming
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

    settings = {
      # global defaults
      default-timeout = 2500;
      font = "monospace 11";
      anchor = "bottom-right";
      margin = 10;
      border-radius = 10;
      border-size = 1;
      border-color = "#88c0d0";
      background-color = "#2e3440";

      # sections (former ‘criteria’)
      "mode=dnd" = {
        invisible = 1; # hide everything in dnd
      };

      "urgency=critical" = {
        default-timeout = 0; # stick until dismissed
      };
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

  #this one line fixes libadwaita theming for Nordic. all the gtk.css files already import from the store but the assets weren't symlinking to .config/
  home.file.".config/assets".source = "${pkgs.nordic}/share/themes/Nordic/assets";

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
  ########custom entries for launcher etc#####################
  xdg.desktopEntries = {
    mirror = {
      name = "Mirror";
      comment = "Webcam preview with no UI";
      exec = "guvcview --gui=none";
      terminal = false;
      icon = "guvcview";
      categories = ["Utility" "Video"];
    };
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
      "x-scheme-handler/http" = "zen.desktop"; # Replace with the actual file name
      "x-scheme-handler/https" = "zen.desktop"; # Replace with the actual file name
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
    # Wayland and XDG session info
    XDG_SESSION_TYPE = "wayland"; # specify that this is a wayland session
    XDG_CURRENT_DESKTOP = "Hyprland"; # set the current desktop environment name
    XDG_SESSION_DESKTOP = "Hyprland"; # set the session desktop name (redundant but some apps check both)

    # GTK and portals
    GTK_USE_PORTAL = "1"; # enable portal interfaces for file pickers etc

    # QT settings
    QT_QPA_PLATFORM = "wayland"; # make qt apps use wayland backend
    QT_QPA_PLATFORMTHEME = "kvantum"; # platform theme for qt (currently kvantum)
    QT_STYLE_OVERRIDE = "kvantum"; # enforce kvantum styling
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # avoid double window borders in qt apps

    # Hyprland-specific cursor settings
    XCURSOR_SIZE = "24"; # cursor size for wayland + x11 apps
    HYPRCURSOR_SIZE = "24"; # hyprland-specific cursor size

    # Misc GUI frameworks
    CLUTTER_BACKEND = "wayland"; # ensure clutter apps (like some gnome stuff) use wayland
    GDK_BACKEND = "wayland,x11,*"; # gtk apps should prefer wayland backend

    # Electron / Chromium based apps
    NIXOS_OZONE_WL = "1"; # enable wayland backend for electron apps (vivaldi, brave, etc.)

    # WLR tweaks
    WLR_NO_HARDWARE_CURSORS = "1"; # software cursor fallback, mostly important for nvidia cards
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=KvArcDark
  '';
}
