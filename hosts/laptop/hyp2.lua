-- Native Lua equivalent of hyp2.conf.

local waybar = "waybar --config ~/.config/waybar/config.jsonc --style ~/.config/waybar/style.css"

hl.on("hyprland.start", function()
	hl.exec_cmd(waybar)
end)

hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("pkill waybar 2>/dev/null; " .. waybar))

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("AQ_DRM_DEVICES", "/dev/dri/amd-igpu")
hl.env("WLR_DRM_DEVICES", "/dev/dri/amd-igpu")
-- hl.env("GBM_BACKEND", "nvidia-drm")

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))

local keyboardBacklight = "/run/current-system/sw/bin/bash /home/berkerz/dotfiles/scripts/asus-kbd-backlight.sh"
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(keyboardBacklight .. " next"))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(keyboardBacklight .. " prev"))
hl.bind("code:238", hl.dsp.exec_cmd(keyboardBacklight .. " next"))
hl.bind("code:237", hl.dsp.exec_cmd(keyboardBacklight .. " prev"))

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "auto",
	scale = 1,
	mirror = "eDP-1",
})

hl.device({
	name = "elan1201:00-04f3:3098-touchpad",
	sensitivity = 0.9,
	natural_scroll = true,
})
