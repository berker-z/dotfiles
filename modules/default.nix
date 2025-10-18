{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./wlogout
    ./fuzzel
    ./nixvim.nix
    ./avante.nix
  ];
}
