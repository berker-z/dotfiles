{pkgs, ...}: {
  imports = [
    ../../profiles/home/common.nix
    ../../profiles/home/workstation.nix
    ../../profiles/home/agents.nix
  ];

  home.packages = with pkgs; [];

  xdg.desktopEntries.battlenet = {
    name = "Battle.net";
    comment = "Launch Battle.net through Lutris";
    exec = "env LUTRIS_SKIP_INIT=1 lutris lutris:rungame/battlenet";
    terminal = false;
    icon = "lutris_battlenet";
    categories = ["Game"];
  };

  programs.kitty.settings.font_size = 14;
}
