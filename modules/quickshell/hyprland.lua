-- Native Lua equivalent of the Hyprland fragment in default.nix.

local mainMod = "SUPER"
local nordPill = "nord-pill"

hl.on("hyprland.start", function()
	hl.exec_cmd(nordPill .. " start")
end)

hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(nordPill .. " restart"))
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd(nordPill .. " toggle"))
hl.bind(mainMod .. " + ALT + SHIFT + P", hl.dsp.exec_cmd(nordPill .. " restart"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd(nordPill .. " calendar"))
hl.bind(mainMod .. " + ALT + M", hl.dsp.exec_cmd(nordPill .. " mixer"))
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd(nordPill .. " clipboard"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd(nordPill .. " sidebar"))
hl.bind(mainMod .. " + ALT + O", hl.dsp.exec_cmd(nordPill .. " power"))
