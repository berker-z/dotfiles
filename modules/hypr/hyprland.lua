-- Native Lua equivalent of hyprland.conf.

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "marcel"
local menu = "fuzzel"
local browser = "helium"

hl.on("hyprland.start", function()
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("spotify", { workspace = "5 silent" })
	hl.exec_cmd("kitty", { workspace = "special:magic silent" })
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user import-environment --all")
	hl.exec_cmd("systemctl --user restart hyprpaper")
end)

-- hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")

hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 1,
		border_size = 2,
		col = {
			active_border = {
				colors = { "rgba(8fbcbbee)", "rgba(5e81acee)" },
				angle = 45,
			},
			inactive_border = "rgba(2e3440aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},
	decoration = {
		rounding = 10,
		active_opacity = 0.9,
		inactive_opacity = 0.8,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			ignore_opacity = true,
			popups = true,
			popups_ignorealpha = 0.6,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		middle_click_paste = false,
	},
	input = {
		kb_layout = "tr",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		mouse_refocus = true,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
	cursor = {
		warp_on_change_workspace = 1,
		no_hardware_cursors = true,
	},
})

hl.curve("myBezier", {
	type = "bezier",
	points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadePopups", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd(
		"wlogout -b 5 -c 0 -r 0 -m 0 -C /home/berkerz/dotfiles/modules/wlogout/style2.css --protocol layer-shell"
	)
)
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

local workspaceKeys = {
	["1"] = "1",
	["2"] = "2",
	["3"] = "3",
	["4"] = "4",
	["5"] = "5",
	["6"] = "6",
	["7"] = "7",
	["8"] = "8",
	["9"] = "9",
	["0"] = "10",
}

for key, workspace in pairs(workspaceKeys) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace, follow = true }))
end

hl.bind(mainMod .. " + D", hl.dsp.layout("swapwithmaster"))
hl.bind(
	"Print",
	hl.dsp.exec_cmd([[
grim -g "$(slurp)" -t ppm - | satty --filename - --config /home/berkerz/dotfiles/modules/satty.toml
]])
)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -s -m output -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = true }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^(vivaldi-stable)$" }, opacity = "1.0 override 1.0 override 1.0 override" })
hl.window_rule({ match = { class = "^(.vivaldi-wrapped)$" }, float = true })
hl.window_rule({ match = { title = "^(Phantom Wallet - Vivaldi)$" }, float = true })
hl.window_rule({ match = { title = "^(Rabby Wallet Notification - Vivaldi)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.clocks)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.clocks)$" }, size = { 150, 400 } })
hl.window_rule({
	match = { class = "^(org.gnome.clocks)$" },
	move = { "cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)" },
})
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" }, float = true })
-- hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(thunderbird)$", initial_title = "^()$" }, float = true })
hl.window_rule({ match = { class = "^(helium)$" }, opacity = "1.0 override 1.0 override 1.0 override" })
hl.window_rule({ match = { class = "^(com\\.gabm\\.satty)$" }, float = true })
hl.window_rule({ match = { initial_title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { initial_title = "^(Picture-in-Picture)$" }, size = { 910, 550 } })

hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "wlogout" }, blur = true })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
