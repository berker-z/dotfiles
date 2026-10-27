{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../profiles/home/common.nix
    ../../profiles/home/workstation.nix
    ../../profiles/home/agents.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
  ];

  wayland.windowManager.hyprland.extraConfig = ''
    ${builtins.readFile ./hyp2.lua}
  '';

  home.sessionVariables.GSK_RENDERER = "ngl";

  programs.kitty.settings.font_size = 14;

  # Copland's daemon runs this machine's agents; daemon.toml (and its tokens)
  # comes from `copland-daemon --setup`, never from the store. Never use
  # `--install-service` here: this is that unit, declared.
  services.copland = {
    enable = true;
    package = pkgs.copland;
    runtimes = with pkgs; [claude-code git gh];
    tray.enable = true;
  };

  # Started by hand on the laptop, never at login: the units stay declared
  # (current store path, declared PATH) but nothing wants them.
  systemd.user.services.copland-daemon.Install.WantedBy = lib.mkForce [];
  systemd.user.services.copland-tray.Install.WantedBy = lib.mkForce [];

  xdg.desktopEntries.copland-daemon = {
    name = "Copland Daemon";
    comment = "Start this machine's Copland agents and the tray";
    exec = "systemctl --user start copland-daemon.service copland-tray.service";
    terminal = false;
    icon = "copland-box";
    categories = ["Development"];
    actions.stop = {
      name = "Stop Copland Daemon";
      exec = "systemctl --user stop copland-tray.service copland-daemon.service";
    };
  };
}
