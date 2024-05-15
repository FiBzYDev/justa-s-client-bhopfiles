-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_mapsettings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Init()
    local width, height = self:GetParent():GetSize()

    UI:NumberInput(self, 0, 0, width, 30, 0, 0, 2147483647, "units/s", false, function(var)
        print(var)
    end) 
end

vgui.Register("vgui.mapsettings", PANEL, "EditablePanel")