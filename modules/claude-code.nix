{
  config,
  lib,
  pkgs,
  ...
}: {
  # Claude Code configuration for NixOS
  # Includes chrome integration, terminal setup, and status line

  # Fix chrome native host for NixOS
  # The default script uses hardcoded store paths that break on updates
  home.file.".claude/chrome/chrome-native-host" = {
    text = ''
      #!/usr/bin/env bash
      # Chrome native host wrapper script
      # NixOS-friendly version using PATH
      exec claude --chrome-native-host
    '';
    executable = true;
  };

  # Status line script
  home.file.".claude/statusline.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Claude Code status line script
      # Displays model, directory, and context usage

      input=$(cat)

      MODEL=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name // "unknown"')
      DIR=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir // "~"' | xargs basename)
      CONTEXT=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.used_percentage // 0')

      echo "[$MODEL] 📁 $DIR | 🧠 $CONTEXT%"
    '';
    executable = true;
  };

  # Claude Code settings
  home.file.".claude/settings.json".text = builtins.toJSON {
    statusLine = {
      type = "command";
      command = "${config.home.homeDirectory}/.claude/statusline.sh";
      padding = 0;
    };

    permissions = {
      # Pre-approved tools and commands (no asking)
      allow = [
        # Reading and exploration - always allowed
        "Read"
        "Grep"
        "Glob"

        # File operations in working directory only
        "Edit"
        "Write"

        # Exploration commands
        "Bash(ls:*)"
        "Bash(cat:*)"
        "Bash(grep:*)"
        "Bash(rg:*)"
        "Bash(find:*)"
        "Bash(fzf:*)"
        "Bash(tree:*)"
        "Bash(head:*)"
        "Bash(tail:*)"
        "Bash(less:*)"

        # Git - reading only
        "Bash(git status:*)"
        "Bash(git diff:*)"
        "Bash(git log:*)"
        "Bash(git branch:*)"
        "Bash(git show:*)"
        "Bash(git blame:*)"

        # Nix tools (except rebuild)
        "Bash(nix build:*)"
        "Bash(nix flake:*)"
        "Bash(nix develop:*)"
        "Bash(nix run:*)"
        "Bash(nix-shell:*)"
        "Bash(nix search:*)"

        # Node.js/Bun development
        "Bash(npm:*)"
        "Bash(bun:*)"
        "Bash(node:*)"
        "Bash(npx:*)"

        # Rust development
        "Bash(cargo:*)"
        "Bash(rustc:*)"
        "Bash(rustup:*)"

        # File management
        "Bash(mkdir:*)"
        "Bash(mv:*)"
        "Bash(cp:*)"
        "Bash(touch:*)"

        # System inspection
        "Bash(systemctl:*)"
        "Bash(journalctl:*)"
        "Bash(ps:*)"
        "Bash(top:*)"
        "Bash(htop:*)"

        # Other utilities
        "Bash(which:*)"
        "Bash(whereis:*)"
        "Bash(xdg-settings:*)"

        # Browser automation - always allowed
        "mcp__claude-in-chrome__*"

        # Web fetching
        "WebFetch"
      ];

      # Ask before executing these
      ask = [
        # File operations outside working directory
        "Edit(~/**)"
        "Edit(//**)"
        "Write(~/**)"
        "Write(//**)"

        # Git - writing operations
        "Bash(git commit:*)"
        "Bash(git push:*)"
        "Bash(git merge:*)"
        "Bash(git rebase:*)"
        "Bash(git pull:*)"
        "Bash(git add:*)"
        "Bash(git reset:*)"
        "Bash(git checkout:*)"

        # System rebuild
        "Bash(nixos-rebuild:*)"

        # Dangerous operations
        "Bash(rm:*)"
        "Bash(sudo:*)"
      ];

      # No hard denials - everything is either allowed or asked
      deny = [];

      defaultMode = "default";
    };
  };

  # Kitty terminal: enable shift+enter for multiline input
  programs.kitty.settings = {
    "map shift+enter" = "send_text all \\x1b[13;2u";
  };
}
