-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_personalrecords.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Start()
    self:SetTitle("Showing personal records")
    self:InitScrollPanel({"Map", "Time"}, 1, {0, 1})
    self:AddStyleMode(1,1,true)
    self:RequestData("personalrecords", {self:GetMode(), self:GetStyle()}, function(index, data)
        return {data.map, TIMER:GetFormatted(tonumber(data.time))}
    end)

    function self:OnUpdate()
        self:RequestData("personalrecords", {self:GetMode(), self:GetStyle()}, function(index, data)
            return {data.map, TIMER:GetFormatted(tonumber(data.time))}
        end)
    end
end 

vgui.Register("vgui.personalrecords", PANEL, "vgui.scrollbase")