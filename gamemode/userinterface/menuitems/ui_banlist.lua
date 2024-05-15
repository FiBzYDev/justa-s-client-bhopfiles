-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_banlist.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Start()
    self:SetTitle("Showing current bans")
    self:InitScrollPanel({"Name", "Date", "Reason", "Length"}, 6, {0, 1.5, 2.5, 5})
    self:RequestData("banlist", 
    {}, function(index, data)
        print(index, data)
        return {{'name', index}, os.date("%d/%m/%Y", data.start), data.reason, data.time}
    end)
end 

vgui.Register("vgui.banlist", PANEL, "vgui.scrollbase")