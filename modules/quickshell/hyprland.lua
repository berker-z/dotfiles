-- Native Lua equivalent of the Hyprland fragment in default.nix.

local mainMod = "SUPER"
local cornice = "cornice"

hl.on("hyprland.start", function()
	hl.exec_cmd(cornice .. " start")
end)

hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(cornice .. " restart"))
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd(cornice .. " toggle"))
hl.bind(mainMod .. " + ALT + SHIFT + P", hl.dsp.exec_cmd(cornice .. " restart"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd(cornice .. " calendar"))
hl.bind(mainMod .. " + ALT + M", hl.dsp.exec_cmd(cornice .. " mixer"))
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd(cornice .. " clipboard"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd(cornice .. " sidebar"))
hl.bind(mainMod .. " + ALT + O", hl.dsp.exec_cmd(cornice .. " power"))
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd(cornice .. " network"))
