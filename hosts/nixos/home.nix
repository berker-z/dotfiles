{pkgs, ...}: {
  imports = [
    ../../profiles/home/common.nix
    ../../profiles/home/workstation.nix
    ../../profiles/home/agents.nix
  ];

  home.packages = with pkgs; [];

  programs.kitty.settings.font_size = 14;
}
