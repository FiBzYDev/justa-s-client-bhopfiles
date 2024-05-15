--[[
	Bunny Hop
	a gamemode by justa
]]--

GM.Name = "Bunny Hop"
GM.DisplayName = "Bunny Hop"
GM.Author = "justa"
GM.Email = ""
GM.Website = "www.steamcommunity.com/id/just_adam"
GM.TeamBased = false

DeriveGamemode( "base" )
DEFINE_BASECLASS( "gamemode_base" )

_C = _C or {}
_C["Version"] = 7.26
_C["PageSize" ] = 7
_C["GameType"] = "bhop"
_C["ServerName"] = "My Bunny Hop"
_C["Identifier"] = "yourservername-" .. _C.GameType -- If you want clientside caching to work (lower player join usage), set this
_C["SteamGroup"] = "" -- Set this to your group URL if you want people to see a pop-up when joining for the first time (cl_init.lua at the bottom)
_C["MaterialID"] = "flow" -- Change this to the name of the folder in content/materials/

_C["Team"] = { Players = 1, Spectator = TEAM_SPECTATOR }
_C["Style"] = { Normal = 1, SW = 2, HSW = 3, ["W-Only"] = 4, ["A-Only"] = 5, Legit = 6, ["Easy Scroll"] = 7, Bonus = 8, Segment = 9, ["Low Gravity"] = 10 }

_C["Player"] = {
	DefaultModel = "models/player/group01/male_01.mdl",
	DefaultWeapon = "weapon_glock",
	JumpPower = 290,
	ScrollPower = 268.4,
	HullMin = Vector( -16, -16, 0 ),
	HullDuck = Vector( 16, 16, 45 ),
	HullStand = Vector( 16, 16, 62 ),
	ViewDuck = Vector( 0, 0, 47 ),
	ViewStand = Vector( 0, 0, 64 )
}

_C["Prefixes"] = {
	["Timer"] = Color(0, 132, 255),
	["General"] = Color( 52, 152, 219 ),
	["Admin"] = Color(244, 66, 66),
	["Notification"] = Color( 231, 76, 60 ),
	[_C["ServerName"]] = Color( 46, 204, 113 ),
	["Radio"] = Color( 230, 126, 34 ),
	["VIP"] = Color( 174, 0, 255 )
}

if game.GetMap() == "bhop_aux_a9" then
	_C.Player.JumpPower = math.sqrt( 2 * 800 * 57.0 )
end

util.PrecacheModel( _C.Player.DefaultModel )

include( "sh_playerclass.lua" )

local mc, mp = math.Clamp, math.pow
local bn, ba, bo = bit.bnot, bit.band, bit.bor
local sl, ls = string.lower, {}
local lp, ft, ct, gf = LocalPlayer, FrameTime, CurTime, {}

function GM:PlayerNoClip(ply)
	local practice = ply:GetNWInt("inPractice", false)
	
	if (not practice) then 
		if (SERVER) then 
			ply:SetNWInt("inPractice", true)
			if (ply.time) then 
				TIMER:Print(ply, "Your timer has been disabled due to noclipping.")
				TIMER:Disable(ply)
			end
			return true
		end
	end

	return practice
end

function GM:PlayerUse( ply )
	if not ply:Alive() then return false end
	if ply:Team() == TEAM_SPECTATOR then return false end
	if ply:GetMoveType() != MOVETYPE_WALK then return false end
	
	return true
end

function GM:CreateTeams()
	team.SetUp( _C.Team.Players, "Players", Color( 255, 50, 50, 255 ), false )
	team.SetUp( _C.Team.Spectator, "Spectators", Color( 50, 255, 50, 255 ), true )
	team.SetSpawnPoint( _C.Team.Players, { "info_player_terrorist", "info_player_counterterrorist" } )
end

-- Core
Core = {}

function Core:Optimize()
	hook.Remove( "PlayerTick", "TickWidgets" )
	hook.Remove( "PreDrawHalos", "PropertiesHover" )
end

ShowHidden = ShowHidden or {}
ShowHidden.Refresh = (ShowHidden.Refresh ~= nil)
