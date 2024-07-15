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
hyprshot
hyprpicker #needed for hyprshot
#nautilus
wlogout
playerctl
spotify 
spotify-tray #idk this doesnt work
bluez #bluetooth 
blueman #bluetooth
pinta #paint kind of
foliate #ebook reader
swaylock-effects
floorp
tangram

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




services.hypridle = {
  enable = true;
  settings = 
  {
  general = {
    after_sleep_cmd = "hyprctl dispatch dpms on";
    ignore_dbus_inhibit = false;
    lock_cmd = "swaylock -f";
  };

  listener = [
    {
      timeout = 900;
      on-timeout = "swaylock -f";
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
   cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
#    gtk2 = {
 #     configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
  #  };
  };
  home.pointerCursor =
  {
  name = "Bibata-Modern-Ice";
  package = pkgs.bibata-cursors;
  size = 24;  
  gtk.enable = true;
  };
qt = {
  enable = true;
};
programs.kitty = {
  enable = true;
  theme = "Nord";

  settings = {
  confirm_os_window_close = 0;
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

services.gammastep = { #redshift
  enable = true;
  provider = "manual";
  temperature.day = 5500;
  temperature.night = 3000;
  tray = true;
  latitude = 41.0;
  longitude = 28.9;
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



xdg.configFile."swaylock/config"= {
source = ./modules/swaylock/config;
};



home.stateVersion = "24.05";

programs.home-manager.enable = true;






}
