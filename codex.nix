{pkgs, ...}: {
  home.packages = [
    pkgs.mcp-proxy
  ];

  programs.codex = {
    enable = true;

    settings = {
      sandbox_mode = "workspace-write";
      approval_policy = "on-request";

      sandbox_workspace_write = {
        network_access = true;
      };

      features = {
        web_search_request = true;
      };
    };
  };
}
