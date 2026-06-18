{
  config,
  lib,
  pkgs,
  ...
}: let
  gtkThemeName = "Nordic-darker";
  kvantumThemeName = "Nordic-Darker";
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
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile = {
    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      style=kvantum
      icon_theme=Nordzy
      standard_dialogs=xdgdesktopportal
    '';

    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      style=kvantum
      icon_theme=Nordzy
      standard_dialogs=xdgdesktopportal
    '';

    # Tell Kvantum which theme to use
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=${kvantumThemeName}
    '';

    # Kvantum does not reliably discover the Nordic theme inside the store on
    # its own, so expose the selected variant under ~/.config/Kvantum.
    "Kvantum/${kvantumThemeName}".source = "${pkgs.nordic}/share/Kvantum/${kvantumThemeName}";

    # KDE apps like Dolphin also use KDE color schemes. Without a matching dark
    # scheme, text can stay black while widgets are drawn with a dark Kvantum
    # theme.
    "kdeglobals".text = ''
      [General]
      ColorScheme=${kdeColorScheme}
      Name=${kdeColorScheme}

      [Icons]
      Theme=Nordzy
    '';
  };

  xdg.dataFile = {
    "color-schemes/${kdeColorScheme}.colors".source = "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
    "color-schemes/NordicDarker.colors".source = "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
  };
}
