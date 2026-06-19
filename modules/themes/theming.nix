{
  config,
  lib,
  pkgs,
  ...
}: let
  gtkThemeName = "Nordic-darker";
  kdeColorScheme = "Nordic-Darker";
in {
  gtk = {
    enable = true;
    theme = {
      name = gtkThemeName;
      package = pkgs.nordic;
    };
    gtk4.theme = config.gtk.theme;

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

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # symlink Nordic assets for libadwaita
  home.file.".config/assets".source = "${pkgs.nordic}/share/themes/${gtkThemeName}/assets";
  home.file.".local/share/themes/${gtkThemeName}/assets".source = "${pkgs.nordic}/share/themes/${gtkThemeName}/assets";

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      name = "breeze";
      package = pkgs.kdePackages.breeze;
    };
  };

  xdg.configFile = {
    # Qt apps now use KDE's platform theme and Breeze widgets. The Nordic KDE
    # color scheme keeps the palette aligned with the GTK/Quickshell Nord stack.
    "kdeglobals".text = ''
      [General]
      ColorScheme=${kdeColorScheme}
      Name=${kdeColorScheme}
      widgetStyle=Breeze

      [Icons]
      Theme=Nordzy
    '';
  };

  xdg.dataFile = {
    "color-schemes/${kdeColorScheme}.colors".source = "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
    "color-schemes/NordicDarker.colors".source = "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
  };
}
