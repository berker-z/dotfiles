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

  # Herdr's installer cannot overwrite settings.json because Home Manager
  # correctly exposes it as an immutable store symlink. Manage both halves of
  # the integration here instead.
  home.file.".claude/hooks/herdr-agent-state.sh" = {
    text =
      builtins.replaceStrings
      ["@python3@"]
      ["${pkgs.python3}/bin/python3"]
      (builtins.readFile ./herdr/claude-agent-state.sh);
    executable = true;
    force = true;
  };

  # Claude Code settings
  home.file.".claude/settings.json".text = builtins.toJSON {
    hooks.SessionStart = [
      {
        matcher = "*";
        hooks = [
          {
            type = "command";
            command = "bash '${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh' session";
            timeout = 10;
          }
        ];
      }
    ];

    statusLine = {
      type = "command";
      command = "${config.home.homeDirectory}/.claude/statusline.sh";
      padding = 0;
    };

    # OS-enforced sandbox (bubblewrap + seccomp on Linux).
    # This is what actually removes the permission prompts: commands that run
    # inside the sandbox are auto-approved, because the kernel — not a prompt —
    # is enforcing what they can touch.
    sandbox = {
      enabled = true;

      # Sandboxed commands run without prompting. Commands that cannot be
      # sandboxed fall back to the normal permission flow below.
      autoAllowBashIfSandboxed = true;

      # Degrade loudly rather than silently running unsandboxed.
      failIfUnavailable = false;

      filesystem = {
        # Writes are limited to the working directory + session tmpdir by
        # default. These are the caches build tools legitimately write to.
        allowWrite = [
          "${config.home.homeDirectory}/.cargo"
          "${config.home.homeDirectory}/.npm"
          "${config.home.homeDirectory}/.cache"
        ];

        # Secrets stay unreadable to sandboxed commands regardless of allowlists.
        denyRead = [
          "${config.home.homeDirectory}/.ssh"
          "${config.home.homeDirectory}/.gnupg"
          "${config.home.homeDirectory}/.aws"
          "${config.home.homeDirectory}/.claude/.credentials.json"
        ];
      };

      network = {
        # Unrestricted egress: no domain prompts, ever. Verified that a bare
        # "*" matches all hosts (undocumented, but tested against this version).
        # Note this is the layer that would otherwise stop a compromised
        # process from exfiltrating whatever it can read.
        allowedDomains = ["*"];

        # The nix daemon is reached over a Unix socket, which the sandbox
        # blocks by default — so every nix command that isn't a pure eval
        # (build, develop, store, flake fetch) dies with
        #   error: cannot create Unix domain socket: Operation not permitted
        #
        # allowUnixSockets = [...] does NOT fix this on Linux. Per the CLI's
        # own schema it is "macOS only ... Ignored on Linux (seccomp cannot
        # filter by path)" — seccomp screens syscalls, not sockaddrs, so
        # socket(AF_UNIX) is either allowed or denied wholesale. The
        # path-scoped form silently did nothing here.
        #
        # Tradeoff: this is all-or-nothing on Linux, so it also exposes every
        # other Unix socket on the box to sandboxed commands — notably the
        # docker socket (a full sandbox escape) and ssh-agent (usable for
        # signing even though ~/.ssh stays unreadable below). Accepted because
        # the alternative is agents routinely reaching for
        # dangerouslyDisableSandbox, which drops *all* confinement rather
        # than just this.
        allowAllUnixSockets = true;

        # Let dev servers bind localhost ports.
        allowLocalBinding = true;
      };

      # Strip secrets from the environment of sandboxed commands.
      credentials = {
        envVars = [
          {
            name = "ANTHROPIC_API_KEY";
            mode = "deny";
          }
          {
            name = "GITHUB_TOKEN";
            mode = "deny";
          }
          {
            name = "NPM_TOKEN";
            mode = "deny";
          }
        ];
      };

      # These cannot work inside the sandbox; they go through normal prompts.
      excludedCommands = [
        "nixos-rebuild"
        "sudo"
        "docker"
        "systemctl"
      ];
    };

    permissions = {
      # The sandbox above is the real boundary for Bash. These rules cover
      # Claude's own tools, plus the cases that escape the sandbox.

      allow = [
        # Read anything, anywhere. //** is an absolute filesystem-root glob,
        # so this covers reads outside the working directory too.
        "Read(//**)"
        "Grep"
        "Glob"

        # Write/edit freely inside the working directory. ./** is cwd-relative,
        # so it follows you from project to project. Edits OUTSIDE the working
        # directory are deliberately not allowed here: they fall through to the
        # built-in default, which prompts. Note Edit(...) also governs Write,
        # NotebookEdit and MultiEdit — path rules on Write are never consulted.
        "Edit(./**)"

        # Bash is unrestricted; the sandbox decides what it can actually touch.
        "Bash"

        # Internet: no approval for any of this.
        "WebFetch"
        "WebSearch"
        "mcp__claude-in-chrome__*"
      ];

      ask = [
        # Leaving the sandbox is the one Bash case worth a prompt — without
        # this, a failed sandboxed command can silently retry unsandboxed and
        # the blanket Bash allow above would auto-approve it.
        "Bash(dangerouslyDisableSandbox:true)"

        # Privilege escalation and system rebuilds run outside the sandbox.
        "Bash(sudo:*)"
        "Bash(nixos-rebuild:*)"

        # Outward-facing and hard to walk back.
        "Bash(git push:*)"
      ];

      deny = [];

      defaultMode = "default";
    };
  };

  # Kitty terminal: enable shift+enter for multiline input
  programs.kitty.settings = {
    "map shift+enter" = "send_text all \\x1b[13;2u";
  };
}
