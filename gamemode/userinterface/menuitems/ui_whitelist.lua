-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_whitelist.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Start()
    self:SetTitle("Showing current whitelisted players")
    self:InitScrollPanel({"Name", "SteamID"}, 2, {0, 1})
    self:RequestData("whitelist", 
    {}, function(index, data)
        return {{'name', data}, data}
    end)
    self:SetNoSort(true)
end 

vgui.Register("vgui.whitelist", PANEL, "vgui.scrollbase")