-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_timersettings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

-- {name, desc, type, data: {}}
local settings = {
    {"Override weapons pickup", "Stops all triggers from giving or removing guns.", UISETTING_MODULE, {"nogun"}},
    {"Hide spectator HUD", "Stops displaying people currently spectating you.", UISETTING_CVAR, {"bhop_hidespec", "bool"}},
    {"Anticheats", "Displays anticheat zones.", UISETTING_CVAR, {"bhop_anticheats", "bool"}},
    {"Gun sounds", "Toggles gunsounds.", UISETTING_CVAR, {"bhop_gunsounds", "bool"}},
    {"Flip weapons", "Flips all your weapons.", UISETTING_CVAR, {"bhop_flipweapons", "bool"}},
    {"Weapon sway", "Toggles whether your weapon's viewmodel should move when moving.", UISETTING_CVAR, {"bhop_weaponsway", "bool"}}
}

function PANEL:Start()
    self:SetSettings(settings)
end 

vgui.Register("vgui.timersettings", PANEL, "vgui.settingbase")