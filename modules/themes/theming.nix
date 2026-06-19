{
  config,
  lib,
  pkgs,
  ...
}: let
  gtkThemeName = "Nordic-darker";
  gtkIconTheme = "Nordzy";
  kdeColorScheme = "Nordic-Darker";
  kdeIconTheme = "breeze-dark";
  uiFont = "Iosevka Nerd Font";
  fixedFont = "Iosevka Nerd Font Mono";
  uiFontSize = 12;
  smallFontSize = 11;
  fontSpec = family: size: weight: "${family},${toString size},-1,5,${toString weight},0,0,0,0,0";
  kdeFontSpec = fontSpec uiFont uiFontSize 50;
  kdeTitleFontSpec = fontSpec uiFont uiFontSize 57;
  kdeSmallFontSpec = fontSpec uiFont smallFontSize 50;
  kdeFixedFontSpec = fontSpec fixedFont uiFontSize 50;
  nordicKdeColors = builtins.readFile "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
  kdeGlobals =
    lib.replaceStrings
    [
      "[General]\n"
      "[KDE]\n"
      "[WM]\n"
    ]
    [
      ''
        [General]
        fixed=${kdeFixedFontSpec}
        font=${kdeFontSpec}
        menuFont=${kdeFontSpec}
        smallestReadableFont=${kdeSmallFontSpec}
        toolBarFont=${kdeFontSpec}
        widgetStyle=Breeze
      ''
      ''
        [KDE]
        AnimationDurationFactor=0
        ShowIconsInMenuItems=true
        ShowIconsOnPushButtons=true
        SingleClick=false
        widgetStyle=Breeze
      ''
      ''
        [WM]
        activeFont=${kdeTitleFontSpec}
      ''
    ]
    nordicKdeColors;
in {
  gtk = {
    enable = true;
    theme = {
      name = gtkThemeName;
      package = pkgs.nordic;
    };
    gtk4.theme = config.gtk.theme;

    iconTheme = {
      name = gtkIconTheme;
      package = pkgs.nordzy-icon-theme;
    };

    font = {
      name = uiFont;
      size = uiFontSize;
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
    font-name = "${uiFont} ${toString uiFontSize}";
    monospace-font-name = "${fixedFont} ${toString uiFontSize}";
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
    # color groups are embedded so KDE apps do not fall back to dark text while
    # resolving the external color-scheme file.
    "kdeglobals".text =
      kdeGlobals
      + ''

        [Icons]
        Theme=${kdeIconTheme}

        [Toolbar style]
        ToolButtonStyle=TextBesideIcon
        ToolButtonStyleOtherToolbars=TextBesideIcon
      '';

    "breezerc".text = ''
      [Style]
      AnimationsDuration=0
      AnimationsEnabled=false
      MenuOpacity=100
    '';
  };

  xdg.dataFile = {
    "color-schemes/${kdeColorScheme}.colors".source = "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
    "color-schemes/NordicDarker.colors".source = "${pkgs.nordic}/share/color-schemes/NordicDarker.colors";
  };
}
