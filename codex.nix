{config, pkgs, ...}: let
  codexConfigPath = "${config.home.homeDirectory}/dotfiles/codex/config.toml";
in {
  home.packages = [
    pkgs.codex
    pkgs.mcp-proxy
  ];

  home.file.".codex/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink codexConfigPath;
    force = true;
  };
}
