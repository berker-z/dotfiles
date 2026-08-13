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

      otto = {
        HostName = "100.118.69.26";
        User = "hermes";
        IdentityFile = "${config.home.homeDirectory}/Projects/hermesbox/ssh-key-2026-05-01.key";
        IdentitiesOnly = true;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
        HostKeyAlias = "hermesbox";
        StrictHostKeyChecking = "accept-new";
        UserKnownHostsFile = "/tmp/hermesbox_known_hosts";
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
