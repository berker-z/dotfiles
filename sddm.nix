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
    extraPackages = [
      sddm-astronaut
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtvirtualkeyboard
    ];
  };

  environment.systemPackages = [sddm-astronaut]; # And here, also adds a lot of bloat
}
