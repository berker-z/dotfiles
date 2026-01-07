{
  config,
  lib,
  pkgs,
  ...
}: {
  services.displayManager.sddm.enable = lib.mkForce false;
  services.displayManager.ly = {
    enable = true;
    settings = {
      full_color = true;
      animation = "none";

      blank_box = true;
      hide_key_hints = true;
      hide_keyboard_locks = true;
      hide_version_string = true;

      bg = "0x002E3440";
      fg = "0x00D8DEE9";
      border_fg = "0x005E81AC";
      error_fg = "0x01BF616A";

      box_title = null;
    };
  };
}
