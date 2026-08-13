{pkgs, ...}: {
  imports = [
    ../../profiles/home/common.nix
    ../../profiles/home/agents.nix
  ];

  home.packages = with pkgs; [];
}
