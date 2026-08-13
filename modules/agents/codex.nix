{
  config,
  pkgs,
  ...
}: let
  codexConfigPath = "${config.home.homeDirectory}/dotfiles/codex/config.toml";
  codexForHerdr = pkgs.symlinkJoin {
    name = "codex-with-herdr-detection";
    paths = [pkgs.codex];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram "$out/bin/codex" --set HERDR_AGENT codex
    '';
  };
in {
  home.packages = [
    codexForHerdr
    pkgs.mcp-proxy
  ];

  home.file.".codex/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink codexConfigPath;
    force = true;
  };

  # Herdr cannot infer Codex from the Nix package's `codex-raw` process name.
  # The wrapper above supplies its supported process hint, while these hooks
  # report the Codex session ID so Herdr can restore sessions it owns.
  home.file.".codex/hooks.json" = {
    text = builtins.toJSON {
      hooks.SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "bash '${config.home.homeDirectory}/.codex/herdr-agent-state.sh' session";
              timeout = 10;
            }
          ];
        }
      ];
    };
    force = true;
  };

  home.file.".codex/herdr-agent-state.sh" = {
    text =
      builtins.replaceStrings
      ["@python3@"]
      ["${pkgs.python3}/bin/python3"]
      (builtins.readFile ./herdr/codex-agent-state.sh);
    executable = true;
    force = true;
  };
}
