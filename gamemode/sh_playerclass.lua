-- "gamemodes\\bhop\\gamemode\\sh_playerclass.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
DEFINE_BASECLASS("player_default")

local PLAYER = {}
PLAYER.DisplayName				= "Player"
PLAYER.WalkSpeed 				= 250
PLAYER.RunSpeed				= 250
PLAYER.CrouchedWalkSpeed 	= 0.6
PLAYER.DuckSpeed				= 0.4
PLAYER.UnDuckSpeed			= 0.2
PLAYER.JumpPower				= 290
PLAYER.AvoidPlayers				= false
PLAYER.Model = "models/player/group01/male_01.mdl"
PLAYER.BotModel = "models/player/kleiner.mdl"

function PLAYER:Loadout()
	self.Player:StripWeapons()

	self.Player.enablepickup = true 
	for k, v in pairs(self.Player.Inventory or {}) do 
		self.Player:Give(v)
	end

	if self.Player.ActiveWeapon and self.Player:HasWeapon(self.Player.ActiveWeapon) then 
		self.Player:SelectWeapon(self.Player.ActiveWeapon)
	end 
	self.Player.enablepickup = false 

	self.Player:SetAmmo( 999, "pistol" ) 
	self.Player:SetAmmo( 999, "smg1" )
	self.Player:SetAmmo( 999, "buckshot" )
end

function PLAYER:SetModel()
	self.Player:SetModel(self.Player:IsBot() and PLAYER.BotModel or PLAYER.Model)
end

player_manager.RegisterClass( "player_bhop", PLAYER, "player_default" )