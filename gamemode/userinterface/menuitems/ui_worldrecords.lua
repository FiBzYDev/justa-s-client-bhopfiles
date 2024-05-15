-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_worldrecords.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Start()
    self:SetTitle("Showing "..LocalPlayer():Name().."'s world records")
    self:InitScrollPanel({"Map", "Time"}, 1, {0, 1})
    self:AddStyleMode(1,1,true)
    self:RequestData("worldrecords", {self:GetMode(), self:GetStyle()}, function(index, data)
        return {data.map, TIMER:GetFormatted(tonumber(data.time))}
    end)

    function self:OnUpdate()
        self:RequestData("worldrecords", {self:GetMode(), self:GetStyle()}, function(index, data)
            return {data.map, TIMER:GetFormatted(tonumber(data.time))}
        end)
    end
end 

vgui.Register("vgui.worldrecords", PANEL, "vgui.scrollbase")