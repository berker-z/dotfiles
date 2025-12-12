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

  xdg.configFile = {
    # Tell Kvantum which theme to use
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Utterly-Nord-Solid
    '';

    # Make sure the theme files are visible under ~/.config/Kvantum
    # Adjust the derivation path if your flake imports pkgs differently
    "Kvantum/Utterly-Nord-Solid/Utterly-Nord-Solid.kvconfig".source =
      "${pkgs.utterly-nord-plasma}/share/Kvantum/Utterly-Nord-Solid/Utterly-Nord-Solid.kvconfig";

    "Kvantum/Utterly-Nord-Solid/Utterly-Nord-Solid.svg".source =
      "${pkgs.utterly-nord-plasma}/share/Kvantum/Utterly-Nord-Solid/Utterly-Nord-Solid.svg";

    "Kvantum/Utterly-Nord-Solid/Nord.patchconfig".source =
      "${pkgs.utterly-nord-plasma}/share/Kvantum/Utterly-Nord-Solid/Nord.patchconfig";
  };
}
