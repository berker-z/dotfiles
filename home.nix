{config, pkgs, osConfig, ...}:





{

  imports = [

    ./modules
    ./hosts/${osConfig.networking.hostName}/home.nix

  ];

home.username = "berkerz";
home.homeDirectory = "/home/berkerz";

home.packages = with pkgs; [
firefox

waybar
kitty
hyprlock
hypridle
hyprpaper
#nautilus
wlogout
playerctl
spotify
spotify-tray
bluez
blueman
];



wayland.windowManager.hyprland = {

  enable = true;
    extraConfig = ''
      ${builtins.readFile ./modules/hypr/hyprland.conf}
    '';
   };

xdg.configFile."hypr/hyprlock.conf"= {
source = ./modules/hypr/hyprlock.conf;
};

xdg.configFile."kitty/kitty.conf"={
  source = ./modules/kitty/kitty.conf;
};



services.hypridle = {
  enable = true;
  settings = 
  {
  general = {
    after_sleep_cmd = "hyprctl dispatch dpms on";
    ignore_dbus_inhibit = false;
    lock_cmd = "hyprlock";
  };

  listener = [
    {
      timeout = 900;
      on-timeout = "hyprlock";
    }
    {
      timeout = 1200;
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on";
    }
  ];
};

};

services.hyprpaper = {
  enable = true;
  settings = 
  {
  ipc = "off";
  splash = true;
  splash_offset = 2.0;

  preload = "~/.dotfiles/assets/lain.jpg";

  wallpaper = ",~/.dotfiles/assets/lain.jpg";
};


};


  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    iconTheme = {
      name = "Nordzy";
      package = pkgs.nordzy-icon-theme;
    };
  # cursorTheme = {
  #    name = "Nordzy-cursors";
  #    package = pkgs.nordzy-cursor-theme;
  #    size = 24;
  #  };
#    gtk2 = {
 #     configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
  #  };
  };

qt = {
  enable = true;
};
programs.kitty = {
  enable = true;
  settings = {

  };

};

programs.yazi = 
{
  enable = true;
  enableFishIntegration = true;
  settings = 
  {
    manager = 
    {
      show_hidden = true;
    };
  };
};

programs.fastfetch = 

{
enable = true;
settings = 
{
 logo = {
       source =  "~/.dotfiles/assets/ascii.txt";
};
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
    "colors"
  ];

};

};

home.stateVersion = "24.05";

programs.home-manager.enable = true;






}
