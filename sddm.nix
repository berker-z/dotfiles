{
  pkgs,
  config,
  lib,
  ...
}: let
  sddmTheme =
    if config.networking.hostName == "laptop"
    then "japanese_aesthetic"
    else "hyprland_kath";
  cursorTheme = "Bibata-Modern-Ice";
  cursorSize = 24;
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = sddmTheme;
    # themeConfig = { }  # put extra keys here if you want
  };
in {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    settings.General.GreeterEnvironment = "XCURSOR_THEME=${cursorTheme},XCURSOR_SIZE=${toString cursorSize}";
    settings.Theme = {
      CursorTheme = cursorTheme;
      CursorSize = cursorSize;
    };
    extraPackages = [
      sddm-astronaut
      pkgs.bibata-cursors
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtvirtualkeyboard
    ];
  };

  environment.systemPackages = [
    sddm-astronaut
    pkgs.bibata-cursors
  ]; # And here, also adds a lot of bloat

  xdg.icons.fallbackCursorThemes = [cursorTheme];
}
