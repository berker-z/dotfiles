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
    ${builtins.readFile ./hyp2.conf}
  '';

  xdg.configFile."waybar/config.jsonc".source = lib.mkForce ../../modules/waybar/config-laptop.jsonc;

  home.sessionVariables.GSK_RENDERER = "ngl";

  programs.kitty.settings.font_size = 14;
}
