-- "gamemodes\\bhop\\gamemode\\modules\\settings\\sh_settings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- MySQL stored player settings module

SETTING = SETTING or {}
SETTING.types = SETTING.types or {}

SETTINGTYPE_STR = 1
SETTINGTYPE_INT = 2 
SETTINGTYPE_BOOL = 3

function SETTING:Register(setting, ty, default)
    self.types[setting] = {ty = ty, default = default}
end 

function SETTING:Get(client, setting)
    if not client.settings then return self.types[setting].default end 
    if (client.settings[setting] != nil) then
        return client.settings[setting]
    else
        return self.types[setting].default 
    end
end 

function SETTING:ConvertTo(setting, value)
    if (not self.types[setting]) then return end 
    local ty = self.types[setting].ty 

    if (ty == SETTINGTYPE_STR) then 
        return value 
    elseif (ty == SETTINGTYPE_INT) then 
        return tostring(value)
    elseif (ty == SETTINGTYPE_BOOL) then 
        return value and "1" or "0"
    end 
end 

function SETTING:ConvertFrom(setting, value)
    if (not self.types[setting]) then return end 
    local ty = self.types[setting].ty 

    if (ty == SETTINGTYPE_STR) then 
        return value 
    elseif (ty == SETTINGTYPE_INT) then 
        return tonumber(value)
    elseif (ty == SETTINGTYPE_BOOL) then 
        return tonumber(value) == 1 and true or false 
    end 
end 

if CLIENT then 
    function SETTING:SetClient(setting, value)
        LocalPlayer().settings[setting] = value 
        NETWORK:StartNetworkMessage(false, 'SettingSet', setting, value)
    end 

    NETWORK:GetNetworkMessage('SettingCallback', function(_, data)
        local setting = data[1]
        local value = data[2]

        LocalPlayer().settings[setting] = value 
    end)
end 

-- SSJ settings
SETTING:Register("ssj_enabled", SETTINGTYPE_BOOL, false)
SETTING:Register("ssj_prestrafe", SETTINGTYPE_BOOL, true)
SETTING:Register("ssj_firstjump", SETTINGTYPE_BOOL, false)
SETTING:Register("ssj_jumpfrequency", SETTINGTYPE_INT, 1)
SETTING:Register("ssj_height", SETTINGTYPE_BOOL, false)
SETTING:Register("ssj_speed", SETTINGTYPE_BOOL, false)
SETTING:Register("ssj_gain", SETTINGTYPE_BOOL, true)
SETTING:Register("ssj_strafes", SETTINGTYPE_BOOL, false)
SETTING:Register("ssj_chat", SETTINGTYPE_BOOL, true)
SETTING:Register("ssj_hud", SETTINGTYPE_BOOL, false)
SETTING:Register("ssj_console", SETTINGTYPE_BOOL, true)
SETTING:Register("ssj_observer", SETTINGTYPE_BOOL, true)
SETTING:Register("ssj_time", SETTINGTYPE_BOOL, true)
SETTING:Register("ssj_shorten", SETTINGTYPE_BOOL, false)

-- Trainer
SETTING:Register("trainer_enabled", SETTINGTYPE_BOOL, false)

-- misc
SETTING:Register("nogun", SETTINGTYPE_BOOL, false)