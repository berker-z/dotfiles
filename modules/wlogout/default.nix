{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.wlogout = {
    enable = true;

    # style.css sitting in the same directory as this file
    style = builtins.readFile ./style.css;

    layout = [
      {
        label = "lock";
        action = "loginctl lock-session";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "loginctl kill-session $XDG_SESSION_ID";
        text = "Pogout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
  };
}
