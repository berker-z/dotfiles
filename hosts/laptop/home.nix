{config, pkgs, osConfig, ...}:


{

home.packages = with pkgs; [

  brightnessctl
];



#nvidia stuff for my laptop
wayland.windowManager.hyprland = {

    extraConfig = ''

      ${builtins.readFile ./hyp2.conf}
    '';
   };

programs.kitty = {

settings = {
font_size = 12;
};
};




}
