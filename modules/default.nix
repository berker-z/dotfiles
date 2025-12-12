{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./themes
    ./wlogout
    ./fuzzel
    ./nixvim.nix
    ./avante.nix
  ];
}
