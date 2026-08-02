{
  config,
  lib,
  pkgs,
  ...
}: let
  gtkThemeName = "WhiteSur-Dark-nord";
  gtkThemePackage = pkgs.whitesur-gtk-theme.override {
    colorVariants = ["dark"];
    opacityVariants = ["normal"];
    themeVariants = ["default"];
    schemeVariants = ["nord"];
  };
  gtkIconTheme = "Nordzy";
  kdeColorScheme = "UtterlyNord";
  kdeIconTheme = "breeze-dark";
  uiFont = "Iosevka Nerd Font";
  gtkFont = "Liberation Sans";
  fixedFont = "Iosevka Nerd Font Mono";
  uiFontSize = 12;
  smallFontSize = 11;
  fontSpec = family: size: weight: "${family},${toString size},-1,5,${toString weight},0,0,0,0,0";
  kdeFontSpec = fontSpec uiFont uiFontSize 50;
  kdeTitleFontSpec = fontSpec uiFont uiFontSize 57;
  kdeSmallFontSpec = fontSpec uiFont smallFontSize 50;
  kdeFixedFontSpec = fontSpec fixedFont uiFontSize 50;
  nordKdeColors = builtins.readFile "${pkgs.utterly-nord-plasma}/share/color-schemes/UtterlyNord.colors";
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
    nordKdeColors;
in {
  gtk = {
    enable = true;
    theme = {
      name = gtkThemeName;
      package = gtkThemePackage;
    };
    gtk4.theme = config.gtk.theme;

    iconTheme = {
      name = gtkIconTheme;
      package = pkgs.nordzy-icon-theme;
    };

    font = {
      name = gtkFont;
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
    document-font-name = "${gtkFont} ${toString uiFontSize}";
    font-name = "${gtkFont} ${toString uiFontSize}";
    monospace-font-name = "${fixedFont} ${toString uiFontSize}";
  };

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      name = "breeze";
      package = pkgs.kdePackages.breeze;
    };
  };

  xdg.configFile = {
    # Qt apps use KDE's platform theme and Breeze widgets. The Nord KDE
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
    "color-schemes/${kdeColorScheme}.colors".source = "${pkgs.utterly-nord-plasma}/share/color-schemes/UtterlyNord.colors";
  };
}
