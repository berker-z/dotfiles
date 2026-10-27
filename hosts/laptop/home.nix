{
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
    # Started by hand from the package's "Copland Daemon" launcher, never at
    # login (autostart and tray.autostart default to false).
    tray.enable = true;
  };
}
