{config, pkgs, osConfig, ...}:



{

  imports = [

    ./modules
    ./hosts/${osConfig.networking.hostName}/home.nix

  ];

home.username = "berkerz";
home.homeDirectory = "/home/berkerz";

home.packages = with pkgs; [
waybar
kitty
hyprlock
hypridle
hyprpaper
hyprshot
hyprpicker #needed for hyprshot
wlogout
playerctl
spotify 
spotify-tray #idk this doesnt work
bluez #bluetooth 
blueman #bluetooth
pinta #paint kind of
foliate #ebook reader
swaylock-effects # i hated hyprlock
floorp #browser
#ferdium #i've grown to dislike this a lot
vivaldi #like this these days
vivaldi-ffmpeg-codecs
vlc #media player
deluge #torrent client
appflowy #you kinda need to fuck with mime apps for this appflowy.flutter > appflowy.desktop iirc
libsForQt5.qtstyleplugins #qt theming
libsForQt5.qt5ct
libsForQt5.qtstyleplugin-kvantum
telegram-desktop #web client sucks
feh #picture viewer
];


programs.sioyek =

{
enable = true;
config = {
  "background_color" = "0.18 0.20 0.25";
};
  };


wayland.windowManager.hyprland = {

  enable = true;
  systemd.enableXdgAutostart = true;
  systemd.enable = true;
  systemd.variables = ["--all"];
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
      #on-timeout = "hyprctl dispatch dpms off";
      #on-resume = "hyprctl dispatch dpms on";
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

  #preload = "~/.dotfiles/assets/lain.jpg";
    preload = "~/.dotfiles/assets/squi.jpg";

  wallpaper = ",~/.dotfiles/assets/squi.jpg";
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
    gtk2 = {
      configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
   };
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
  platformTheme.name = "qt5ct";
  style = {
    name = "qt5ct";
  };
};


  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
      "image/*" = ["feh.desktop"];
      "application/pdf" = ["sioyek.desktop"];
      "application/epub+zip" = ["com.github.johnfactotum.Foliate.desktop"];
      "video/*" = ["vlc.desktop"];
      "audio/*" = ["vlc.desktop"];
      "x-scheme-handler/http" = ["vivaldi-stable.desktop"];
      "x-scheme-handler/https" = ["vivaldi-stable.desktop"];
      "text/html" = ["vivaldi-stable.desktop"];
    };
  };



programs.kitty = {
  enable = true;
  themeFile = "Nord";

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

#opener = {
#text = {
#  exec = "$EDITOR $@"; desc = "Open with editor";
 # exec = "xdg-open $@"; desc = "Open with default application";
#};
#fallback = {
#exec = "xdg-open $@"; desc = "Open with default application";
#};

 # };
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

home.sessionVariables = {

  QT_STYLE_OVERRIDE = "qt5ct";
};

xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
[General]
theme=Nordic-Darker
'';



}
