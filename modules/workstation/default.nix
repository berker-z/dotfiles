{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../themes
    ../wlogout
    ../fuzzel
    ../quickshell
  ];
}
