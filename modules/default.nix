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
    ./avante.nix
    ./claude-code.nix
  ];
}
