{pkgs, ...}: {
  home.packages = [
    pkgs.mcp-proxy
  ];

  programs.codex = {
    enable = true;

    settings = {
      # keep this if you want; it’s not what fixes Asana though
      features.rmcp_client = true;

      mcp_servers.asana = {
        url = "https://mcp.asana.com/sse";
      };
    };
  };
}
