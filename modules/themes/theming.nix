{
  config,
  pkgs,
  ...
}: {
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
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=kvantum
    icon_theme=Nordzy
  '';

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=kvantum
    icon_theme=Nordzy
  '';

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]

    theme=Nordic
  '';

  xdg.configFile."Kvantum/Nordic".source = "${pkgs.nordic}/share/Kvantum/Nordic";
}
