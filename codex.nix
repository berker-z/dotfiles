{pkgs, ...}: {
  home.packages = [
    pkgs.mcp-proxy
  ];

  programs.codex = {
    enable = true;
  };
}
