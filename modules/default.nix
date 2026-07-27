{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./themes
    ./wlogout
    ./fuzzel
    ./quickshell
    ./nixvim.nix
    ./claude-code.nix
  ];
}
