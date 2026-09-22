{
  config,
  primaryUser,
  ...
}: {
  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";
    stateVersion = "24.05";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      # The Oracle Cloud VM, by its public IP. Its Tailscale address
      # (100.118.69.26) is the private route when the tailnet is up.
      oracle = {
        HostName = "129.159.24.126";
        User = "hermes";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_oracle";
        IdentitiesOnly = true;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };
    };
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings.manager.show_hidden = true;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo.source = "~/dotfiles/assets/ascii.txt";
      modules = [
        "title"
        "separator"
        "os"
        "packages"
        "kernel"
        "uptime"
        "shell"
        "display"
        "wmtheme"
        "theme"
        "de"
        "wm"
        "terminal"
        "terminalfont"
        "cpu"
        "disk"
        "break"
      ];
    };
  };

  programs.home-manager.enable = true;
}
