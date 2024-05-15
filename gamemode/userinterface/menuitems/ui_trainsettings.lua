-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_trainsettings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

-- {name, desc, type, data: {}}
local settings = {
    {"Strafe Trainer", "Strafe Trainer master switch.", UISETTING_CVAR, {"bhop_strafetrainer", "bool"}},
    {"Update rate", "Update rate in ticks, 1 means it updates every tick, etc.", UISETTING_CVAR, {"bhop_strafetrainer_interval", "int"}},
    {"Ground", "Strafe Trainer should update on the ground.", UISETTING_CVAR, {"bhop_strafetrainer_ground", "bool"}}
}

function PANEL:Start()
    self:SetSettings(settings)
end 

vgui.Register("vgui.trainsettings", PANEL, "vgui.settingbase")