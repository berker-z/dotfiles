{ config, lib, pkgs, ... }:

{
    programs.fuzzel = {
    enable = true;
    settings = {
main = {

terminal = "kitty";
font = "Iosevka Nerd Font-16";
prompt = "❯ ";
width = "30";
height = "0";
horizontal-pad = "10";
vertical-pad = "5";
inner-pad = "5";
line-height = "20";
letter-spacing = "0.5";
#icons-enabled = "no";
#icon-theme = "${config.gtk.iconTheme.name}";
};

colors = {
background = "2e3440f8";
text = "e5e9f0f8";
match = "88c0d0f8";
border = "88c0d0f8";
selection = "88c0d0f8";
selection-text = "2e3440f8";
selection-match = "2e3440f8";
};

border = {
width = "1";
radius = "3";
};

    };
    };
}