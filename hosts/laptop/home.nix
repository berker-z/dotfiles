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

home.sessionVariables = {
  
  GSK_RENDERER = "ngl";
};

programs.kitty = {

settings = {
font_size = 12;
};
};




}
