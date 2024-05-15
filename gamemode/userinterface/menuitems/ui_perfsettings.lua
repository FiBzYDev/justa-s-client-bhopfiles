-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_perfsettings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

-- {name, desc, type, data: {}}
local settings = {
    {"Show players", "Toggles whether you can see players.", UISETTING_CVAR, {"bhop_showplayers", "bool"}},
    {"3D Sky", "Toggles whether you render the 3D Sky.", UISETTING_CVAR, {"r_3dsky", "bool"}},
    {"Water reflections", "Enables water reflections.", UISETTING_CVAR, {"r_WaterDrawReflection", "bool"}},
    {"Water refractions", "Enables water refractions.", UISETTING_CVAR, {"r_WaterDrawRefraction", "bool"}},
}

function PANEL:Start()
    self:SetSettings(settings)
end 

vgui.Register("vgui.perfsettings", PANEL, "vgui.settingbase")