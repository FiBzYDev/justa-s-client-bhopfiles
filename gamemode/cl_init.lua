-- "gamemodes\\bhop\\gamemode\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
Client = {}

include( "shared.lua" )
include("essential/sh_movement.lua")
include("essential/sh_network.lua")

include( "modules/settings/sh_settings.lua" )
include("essential/sh_utilities.lua")
include("essential/zones/cl_zoneeditor.lua")

include("essential/timer/sh_timer.lua")

-- Userinterface Core
include( "userinterface/cl_settings.lua" )
include( "userinterface/cl_themes.lua" )
include( "userinterface/cl_theme.lua" )
include( "userinterface/cl_ui.lua" )
include( "userinterface/cl_hud.lua" )
include( "userinterface/cl_menu.lua" )

-- Numbered UI modules
include("userinterface/numbered/ui_mapvote.lua")
include("userinterface/numbered/ui_replay.lua")
include("modules/admin/sh_admin.lua")
include("modules/admin/sh_commands.lua")
include( "modules/cl_strafe.lua" )
include("userinterface/scoreboards/cl_default.lua")

include( "modules/movementfixes/sh_prediction.lua" )
include("modules/vip/sh_vip.lua")
include("modules/vip/paint/cl_paint.lua")

include("userinterface/chatbox/cl_chatbox.lua")
include("essential/timer/cl_replaycontrols.lua")

-- show hidden
include("modules/showhidden/sh_init.lua")

ShowHidden.luabsp = include("modules/showhidden/luabsp.lua")
include("modules/showhidden/cl_init.lua")
include("modules/showhidden/cl_lang.lua")

include("modules/strafe/cl_trainer.lua")

local setting_anticheats = CreateClientConVar("bhop_anticheats", "0", true, false)
local setting_gunsounds = CreateClientConVar("bhop_gunsounds", "1", true, false)

local function ClientTick()
	if not IsValid( LocalPlayer() ) then timer.Simple( 1, ClientTick ) return end
	timer.Simple( 5, ClientTick )

	local ent = LocalPlayer()
	ent:SetHull( _C["Player"].HullMin, _C["Player"].HullStand )
	ent:SetHullDuck( _C["Player"].HullMin, _C["Player"].HullDuck )

	if not Client.ViewSet then
		ent:SetViewOffset( _C["Player"].ViewStand )
		ent:SetViewOffsetDucked( _C["Player"].ViewDuck )
		Client.ViewSet = true
	end
end

local function ChatEdit( nIndex, szName, szText, szID )
	if szID == "joinleave" then
		return true
	end
end
hook.Add( "ChatText", "SuppressMessages", ChatEdit )

local function ChatTag( ply, szText, bTeam, bDead )
	if ply.ChatMuted then
		print( "[CHAT MUTE] " .. ply:Name() .. ": " .. szText )
		return true
	end

	local tab = {}
	if bTeam then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end

	if ply:Team() == TEAM_SPECTATOR then
		table.insert( tab, Color( 189, 195, 199 ) )
		table.insert( tab, "*SPEC* " )
	end

	local nAccess = 0
	if IsValid( ply ) and ply:IsPlayer() then
		nAccess = ply:GetNWInt( "AccessIcon", 0 )
		local RANK = TIMER:GetRank(ply)
		local STYLE = TIMER:GetStyle(ply)
		local MODE = math.abs(TIMER:GetMode(ply)) > 1 and 2 or 1
		table.insert( tab, color_white )

		local VIPTag, VIPTagColor = ply:GetNWString( "VIPTag", "" ), ply:GetNWVector( "VIPTagColor", Vector( -1, 0, 0 ) )
		if nAccess > 0 and VIPTag != "" and VIPTagColor.x >= 0 then
			table.insert( tab, Core.Util:VectorToColor( VIPTagColor ) )
			table.insert( tab, "[" )
			table.insert( tab, VIPTag )
			table.insert( tab, "] " )
			table.insert( tab, color_white )
		else
			
			if RANK[1] == 1 then 
				local r = TIMER:Rainbow(TIMER.UniqueRanks[MODE][STYLE])
				for k, v in pairs(r) do 
					table.insert(tab, v)
				end 
			elseif ply:SteamID()=="STEAM_0:0:713873548" then 
				local r = TIMER:Rainbow("Franchise")
				for k, v in pairs(r) do 
					table.insert(tab, v)
				end 
			else
				table.insert( tab, TIMER:TranslateRank(RANK[2])[2] )
				table.insert( tab, TIMER:TranslateRank(RANK[2])[1] )
				
			end
			table.insert( tab, Color(200, 200, 200) )
			table.insert( tab, " | " )
			table.insert( tab, color_white )
		end

		if (ply:SteamID() == "STEAM_0:0:53974417") or (ply:SteamID() == "STEAM_0:0:53053491") then
			local r = TIMER:Rainbow(ply:SteamID() == "STEAM_0:0:53053491" and "alex" or "justa")
			for k, v in pairs(r) do 
				table.insert(tab, v)
			end 
		elseif (ply:SteamID()=='STEAM_0:0:713873548') then 
			local r = TIMER:Rainbow("Perfect")
			for k, v in pairs(r) do 
				table.insert(tab, v)
			end 
		else
			table.insert( tab, Color( 98, 176, 255 ) )
			table.insert( tab, ply:Name() )
		end
	else
		table.insert( tab, "Console" )
	end

	table.insert( tab, color_white )
	table.insert( tab, ": " )

	if nAccess > 0 then
		local VIPChat = ply:GetNWVector( "VIPChat", Vector( -1, 0, 0 ) )
		if VIPChat.x >= 0 then
			table.insert( tab, Core.Util:VectorToColor( VIPChat ) )
		end
	end

	table.insert( tab, szText )

	chat.AddText( unpack( tab ) )
	return true
end
hook.Add( "OnPlayerChat", "TaggedChat", ChatTag )


local function VisibilityCallback( CVar, Previous, New )
	if tonumber( New ) == 1 then
		for _,ent in pairs( ents.FindByClass("env_spritetrail") ) do
			ent:SetNoDraw( false )
		end
		for _,ent in pairs( ents.FindByClass("beam") ) do
			ent:SetNoDraw( false )
		end
	else
		for _,ent in pairs( ents.FindByClass("env_spritetrail") ) do
			ent:SetNoDraw( true )
		end
		for _,ent in pairs( ents.FindByClass("beam") ) do
			ent:SetNoDraw( true )
		end
	end
end
cvars.AddChangeCallback( "bhop_showplayers", VisibilityCallback )

CreateClientConVar("bhop_showplayers", 1, true, false, "Shows bhop players", 0, 1)
concommand.Add("bhop_showplayers_toggle", function(client)
	LocalPlayer():ConCommand("bhop_showplayers "..(GetConVar("bhop_showplayers"):GetInt() == 0 and 1 or 0))
end)

local function PlayerVisiblityCheck( ply )
	if (GetConVar("bhop_showplayers"):GetInt() == 0) then 
		return true
	end 
end
hook.Add( "PrePlayerDraw", "PlayerVisiblityCheck", PlayerVisiblityCheck )

local function Initialize()
	timer.Simple( 5, ClientTick )
	timer.Simple( 5, function() Core:Optimize() end )
end
hook.Add( "Initialize", "ClientBoot", Initialize )

concommand.Add("_toggleanticheats", function(client, command, args)
	local acs = GetConVar("bhop_anticheats")
	acs:SetInt(acs:GetInt() == 1 and 0 or 1)
end)

concommand.Add("_togglegunsounds", function()
	local gunshots = GetConVar("bhop_gunsounds")
	gunshots:SetInt(gunshots:GetInt() == 1 and 0 or 1)
end)

hook.Add("Think", "Validation", function()
	if IsValid(LocalPlayer()) then 
		RunConsoleCommand("_imvalid")
		hook.Remove("Think", "Validation")
	end
end)

local fp = CreateClientConVar("bhop_flipweapons", 0, true, false, "Flips weapon view models.", 0, 1)
cvars.AddChangeCallback("bhop_flipweapons", function(cvar, prev, new)
	local bool = (new == "1")

	if IsValid(LocalPlayer()) then 
		for k, v in pairs(LocalPlayer():GetWeapons()) do 
			v.ViewModelFlip = !bool 
		end 
	end 
end)

hook.Add("HUDWeaponPickedUp", "flipweps", function(wep)
	wep.ViewModelFlip = (not fp:GetBool())
end)

local swayvar = CreateClientConVar("bhop_weaponsway", 1, true, false, "Controls how weapon view models move.", 0, 1)
local sway = swayvar:GetBool()
cvars.AddChangeCallback("bhop_weaponsway", function(cvar, prev, new)
	sway = (new == "1") 
end)

function GM:CalcViewModelView( we, vm, op, oa, p, a )
	if (not sway) then 
		return op, oa
	end 
end 	