-- "gamemodes\\bhop\\gamemode\\modules\\vip\\sh_vip.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- VIP Module 

VIP = VIP or {}
VIP.Features = VIP.Features or {}
VIP.Ranks = {
    [1] = "VIP",
    [2] = "VIP+"
}

function VIP:HasAccess(client, feature)
    local level = self:GetVIPLevel(client)
    local feature = self:GetFeature(feature)

    return feature.access <= level, feature.access
end 

function VIP:RegisterFeature(feature, access, commands)
    self.Features[feature] = {
        access = access
    }

    if SERVER then 
        for k, v in pairs(commands) do 
        end 
    end 
end 

function VIP:GetFeature(feature)
    return self.Features[feature] or false 
end 

function VIP:GetVIPLevel(client)
    return client:GetNWInt("vipLevel", 0)
end 

VIP:RegisterFeature("paint", 2, {})
