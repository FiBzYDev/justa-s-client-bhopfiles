-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_styles.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Start()
    self:SetTitle("Click on a style to play it!")
    self:InitScrollPanel({"Name", "Description"}, 2, {0, 1})
    self:ForceData(TIMER.Styles, function(index, data)
        return {data[1], TIMER.StyleInfo[index] and TIMER.StyleInfo[index] or "No descrption added."}
    end)
    self:SetOptionFunction(function(self, index, data)
        local command = TIMER.Styles[index][3][1]
        LocalPlayer():ConCommand("say !"..command)
        UI:ToggleMainmenu()
    end)
end 

vgui.Register("vgui.styles", PANEL, "vgui.scrollbase")