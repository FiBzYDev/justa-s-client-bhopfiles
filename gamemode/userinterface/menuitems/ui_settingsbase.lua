-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_settingsbase.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
UISETTING_MODULE = 1
UISETTING_CVAR = 2

local PANEL = {}

function PANEL:Init()
    self.settings = {}
    self.titles = {}
    self.nextY = 0
    self.todraw = {}
    self.gap = 12
end 

function PANEL:SetSettings(setts)
    local width, height = self:GetSize()

    if (#setts * 50 > self:GetParent():GetParent():GetTall()) then 
        width = width - 25
    end 

    for k, v in pairs(setts) do 
        if type(v) == 'string' then 
            table.insert(self.titles, {v, self.nextY})
            self.nextY = self.nextY + 20
            continue 
        end 

        local s = {self.nextY, v[1], v[2]}

        -- It uses the 'SETTING' module
        if (v[3] == UISETTING_MODULE) then 
            local name = v[4][1]
            local value = SETTING:Get(LocalPlayer(), name)
            local ty = SETTING.types[name].ty 

            if (ty == SETTINGTYPE_BOOL) then 
                local box = UI:CheckBox(self, width - 38, self.nextY, 38, value, function(newValue)
                    SETTING:SetClient(name, newValue)
                end)
            elseif (ty == SETTINGTYPE_INT) then 
                local input = UI:NumberInput(self, width - 38, self.nextY, 38, 38, value, 0, 999, "", false, function(newValue)
                    SETTING:SetClient(name, newValue)
                end, true) 
            end
        -- It uses a CreateClientConVar
        elseif (v[3] == UISETTING_CVAR) then 
            local name = v[4][1]
            local cvar = GetConVar(name)
            local ty = v[4][2]

            if (ty == 'bool') then 
                local value = cvar:GetBool()
                local box = UI:CheckBox(self, width - 38, self.nextY, 38, value, function(newValue)
                    --cvar:SetBool(newValue)
                    local val = newValue and "1" or "0"
                    RunConsoleCommand(name, val)
                end)
            elseif (ty == 'int') then 
                local value = cvar:GetInt()
                local input = UI:NumberInput(self, width - 38, self.nextY, 38, 38, value, cvar:GetMin(), cvar:GetMax(), "", false, function(newValue)
                    cvar:SetInt(newValue)
                end, true) 
            elseif (ty == 'float') then 
                local value = cvar:GetFloat()
                local input = UI:NumberInput(self, width - 38, self.nextY, 38, 38, value, cvar:GetMin(), cvar:GetMax(), "", true, function(newValue)
                    cvar:SetFloat(newValue)
                end, true) 
            end 
        end 

        table.insert(self.todraw, s)
        self.nextY = self.nextY + 38 + self.gap 
    end 

    self:SetTall(self.nextY)
end 

function PANEL:Paint(width, height)
    for k, v in pairs(self.todraw) do 
        local y = v[1]
        local title = v[2]
        local desc = v[3]

        draw.SimpleText(title, 'ui.mainmenu.button', 0, y, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(desc, 'ui.mainmenu.desc', 0, y + 38, UI_TEXT2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end 
end 

vgui.Register("vgui.settingbase", PANEL, "EditablePanel")