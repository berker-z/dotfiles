{
  pkgs,
  lib,
  ...
}: {
  environment.sessionVariables = {
    # session basics
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # portals & gtk
    GTK_USE_PORTAL = "1";

    # qt / wayland
    #QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct"; # switched from kvantum
    #QT_STYLE_OVERRIDE = "kvantum";
    #QT_STYLE_OVERRIDE = "adwaita-dark";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    #QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}:${pkgs.hyprqt6engine}/lib/qt6/plugins";
    #QT_STYLE_OVERRIDE_QT5 = "kvantum";
    #experimental
    #QT_QUICK_CONTROLS_STYLE = "org.hyprland.style";
    # cursors
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Ice"; # new

    # misc frameworks
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11,*";

    # electron/chromium flags
    NIXOS_OZONE_WL = "1";

    # wlroots tweak
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
