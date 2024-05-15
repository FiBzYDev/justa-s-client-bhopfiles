-- "gamemodes\\bhop\\gamemode\\modules\\admin\\sh_commands.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Admin module
-- by justa

/*----------------------------------------------------------------------
	CATEGORY: PLAYER MANAGEMENT
-----------------------------------------------------------------------*/
local CATEGORY = "Player Management"

function AddWhitelist(client, target_id)
	if table.HasValue(Admin.whitelist, target_id) then 
		return Admin:Print(client, "That steamid is already on the whitelist.")
	end 

	SQL:Start("INSERT INTO game_whitelist(steamid) VALUES('"..target_id.."')")

	Admin:Print(false, AC, client:Name(), CW, " added ", AC, target_id, CW, " to the whitelist.")
	table.insert(Admin.whitelist, target_id)
end
addwhitelist = Admin:RegisterCommand(AddWhitelist, "Add to the whitelist", {"addwhitelist", "add"}, "manager")
addwhitelist:SetHelpText("Adds a player to the whitelist")
addwhitelist:SetArguments({
	{id = "target_id", typ="steamid"}
})
addwhitelist:SetCategory(CATEGORY)

function DelWhitelist(client, target_id)
	if !table.HasValue(Admin.whitelist, target_id) then 
		return Admin:Print(client, "That steamid is not on the whitelist.")
	end 

	if target_id == "STEAM_0:0:53974417" then 
		return Admin:Print(client, "Nice try lad xdd")
	end 

	SQL:Start("DELETE FROM game_whitelist WHERE steamid = '"..target_id.."'")

	Admin:Print(false, AC, client:Name(), CW, " removed ", AC, target_id, CW, " from the whitelist.")

	table.RemoveByValue(Admin.whitelist, target_id)
end
delwhitelist = Admin:RegisterCommand(DelWhitelist, "Delete from the whitelist", {"delwhitelist", "del"}, "manager")
delwhitelist:SetHelpText("Deletes a player from the whitelist")
delwhitelist:SetArguments({
	{id = "target_id", typ="steamid"}
})
delwhitelist:SetCategory(CATEGORY)

-- Gagging a player 
function GagPlayer(client, target, time, save)
	-- Weird
	if (target.gagged) then 
		return Admin:Print(client, "This person is already gagged!")
	end

	-- Gag
	target.gagged = true

	if (time ~= 0) then 
		local identifier = target:SteamID64() .. "_gag"
		timer.Create(identifier, (time * 60), 1, function()
			if (target) and IsValid(target) and (target.gagged) then 
				UngagPlayer(Admin:GetConsole(), target)
			end
		end)
	end

	local extra = (time == 0) and {""} or {"for ", AC, tostring(time), CW, " minutes"}
	local sreason = {"Admin ", AC, client:Name(), CW, " gagged player ", AC, target:Name(), CW, " ", unpack(extra)}
	Admin:Print(false, unpack(sreason))
end
gagplayer = Admin:RegisterCommand(GagPlayer, "Gag Player", {"gag"}, "zoner")
gagplayer:SetHelpText("This command gags a player.")
gagplayer:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "minutes", typ = "integer", min = 0, max = 100, default = 0}
})
gagplayer:SetCategory(CATEGORY)

-- Gagging a player 
function PGagPlayer(client, target)
	-- Weird
	if (target.gagged) then 
		return Admin:Print(client, "This person is already gagged!")
	end

	-- Gag
	target.gagged = true
	target:SetPData("is_gagged", 1)

	local sreason = {"Admin ", AC, client:Name(), CW, " permanently gagged player ", AC, target:Name()}
	Admin:Print(false, unpack(sreason))
end
pgagplayer = Admin:RegisterCommand(PGagPlayer, "Permanently Gag Player", {"pgag"}, "admin")
pgagplayer:SetHelpText("This command permanently gags a player. (re-enables on rejoin)")
pgagplayer:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})
pgagplayer:SetCategory(CATEGORY)

-- UnGagging a player 
function UngagPlayer(client, target)
	-- Weird
	if (not target.gagged) then 
		return Admin:Print(client, "This person isn't gagged!")
	end

	-- UnGag
	target.gagged = false
	target:SetPData("is_gagged", 0)

	local identifier = target:SteamID64() .. "_gag"
	if timer.Exists(identifier) then 
		timer.Remove(identifier)
	end

	local sreason = {"Admin ", AC, client:Name(), CW, " ungagged player ", AC, target:Name(), CW}
	Admin:Print(false, unpack(sreason))
end
ungagplayer = Admin:RegisterCommand(UngagPlayer, "Ungag Player", {"ungag"}, "zoner")
ungagplayer:SetHelpText("This command ungags a player.")
ungagplayer:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})
ungagplayer:SetCategory(CATEGORY)

-- Mute
function MutePlayer(client, target, time)
	-- Weird
	if (target.muted) then 
		return Admin:Print(client, "This person is already muted!")
	end

	-- Gag
	target.muted = true

	if (time ~= 0) then 
		local identifier = target:SteamID64() .. "_mute"
		timer.Create(identifier, (time * 60), 1, function()
			if (target) and IsValid(target) and (target.muted) then 
				UnmutePlayer(Admin:GetConsole(), target)
			end
		end)
	end

	local extra = (time == 0) and {""} or {"for ", AC, tostring(time), CW, " minutes"}
	local sreason = {"Admin ", AC, client:Name(), CW, " muted player ", AC, target:Name(), CW, " ", unpack(extra)}
	Admin:Print(false, unpack(sreason))
end
muted = Admin:RegisterCommand(MutePlayer, "Mute Player", {"mute"}, "zoner")
muted:SetHelpText("This command mutes a player.")
muted:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "minutes", typ = "integer", min = 0, max = 100, default = 0}
})
muted:SetCategory(CATEGORY)

-- PMute
function PMutePlayer(client, target)
	-- Weird
	if (target.muted) then 
		return Admin:Print(client, "This person is already muted!")
	end

	-- Gag
	target.muted = true
	target:SetPData("is_muted", 1)

	local sreason = {"Admin ", AC, client:Name(), CW, " permanently muted player ", AC, target:Name()}
	Admin:Print(false, unpack(sreason))
end
pmuted = Admin:RegisterCommand(PMutePlayer, "Permanently Mute Player", {"pmute"}, "admin")
pmuted:SetHelpText("This command permanently mutes a player.")
pmuted:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})
pmuted:SetCategory(CATEGORY)

-- Unmute a player 
function UnmutePlayer(client, target)
	-- Weird
	if (not target.muted) then 
		return Admin:Print(client, "This person isn't muted!")
	end

	-- UnGag
	target.muted = false
	target:SetPData("is_muted", 0)

	local identifier = target:SteamID64() .. "_muted"
	if timer.Exists(identifier) then 
		timer.Remove(identifier)
	end

	local sreason = {"Admin ", AC, client:Name(), CW, " unmuted player ", AC, target:Name(), CW}
	Admin:Print(false, unpack(sreason))
end
unmuted = Admin:RegisterCommand(UnmutePlayer, "Unmute Player", {"unmute"}, "zoner")
unmuted:SetHelpText("This command ungags a player.")
unmuted:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})
unmuted:SetCategory(CATEGORY)

-- When a player disconnects, remove timers, alert admins.
hook.Add("PlayerDisconnected", "admin.checks", function(pl)
	local gag_identifier = pl:SteamID64() .. "_gag"
	local mute_identifier = pl:SteamID64() .. "_mute"

	-- Do they exist..?
	if timer.Exists(gag_identifier) then
		timer.Remove(gag_identifier)
		Admin:Print(false, "Alert, player ", AC, pl:Name(), CW, " left the server with a gag present.")
	end 

	if timer.Exists(mute_identifier) then 
		timer.Remove(mute_identifier)
		Admin:Print(false, "Alert, player ", AC, pl:Name(), CW, " left the server with a mute present.")
	end 
end)

-- Stop them talking, sneaky buggers
hook.Add("PlayerCanHearPlayersVoice", "admin.gag", function(listener, talker)
	if (talker.gagged) then 
		return false 
	end
end)

-- Stop them chatting
hook.Add("PlayerSay", "admin.mute", function(client, text, team)
	if (client.muted) then
		PrintMessage(HUD_PRINTCONSOLE, "[MUTED] " .. client:Name() .. ": " .. text)
		return ""
	end
end)

-- Banning a player
local function BanPlayer(client, target, time, reason)
	sreason = {"Admin ", AC, client:Name(), CW, " banned player ", AC, target:Name(), CW, " for ", AC, tostring(time / 60), CW, " minute(s) (", AC, reason, CW, ")"}
	if (time == 0) then 
		sreason = {"Admin ", AC, client:Name(), CW, " banned player ", AC, target:Name(), CW, " indefinately (", AC, reason, CW, ")"}
	end

	-- Register a ban
	Admin:BanPlayer(client, target, time, reason)

	-- Kick them
	target:Kick(reason)

	-- To chat
	Admin:Print(false, unpack(sreason))
end
command_ban = Admin:RegisterCommand(BanPlayer, "Ban Player", {"ban"}, "admin")
command_ban:SetHelpText("This command bans an account via selecting a player in-game.")
command_ban:SetArguments({
	{id = "target", typ = "player", disallow_multi = true, allow_same = true},
	{id = "time", typ = "time", default = "forever"}, -- Can't have it just an integer type, we wanna be able to do: !ban justa 1h
	{id = "reason", typ = "string", default = "You have been banned from this server.", len = 100}
})
command_ban:SetCategory(CATEGORY)

-- Banning a player by SteamID
local function BanPlayerID(client, target_id, time, reason)
	-- Do we have the same person online..?
	for _, pl in pairs(player.GetHumans()) do 
		if (pl:SteamID() == target_id) then 
			-- We do this so we get the checks from the func in sv_admin
			return Admin:GetCommandByPrefix("ban")._func(client, {pl:Name(), time / 60, reason}) 
		end
	end

	sreason = {"Admin ", AC, client:Name(), CW, " banned SteamID ", AC, target_id, CW, " for ", AC, tostring(time / 60), CW, " minute(s) (", AC, reason, CW, ")"}
	if (time == 0) then 
		sreason = {"Admin ", AC, client:Name(), CW, " banned SteamID ", AC, target_id, CW, " indefinately (", AC, reason, CW, ")"}
	end

	-- Register a ban
	Admin:BanPlayer(client, target_id, time, reason)

	-- To chat
	Admin:Print(false, unpack(sreason))
end
command_banid = Admin:RegisterCommand(BanPlayerID, "Ban SteamID", {"banid"}, "admin")
command_banid:SetHelpText("This command bans an account via a given steamid.")
command_banid:SetArguments({
	{id = "targetid", typ = "steamid"},
	{id = "time", typ = "time", default = "forever"}, -- Can't have it just an integer type, we wanna be able to do: !ban justa 1h
	{id = "reason", typ = "string", default = "You have been banned from this server.", len = 100}
})
command_banid:SetCategory(CATEGORY)

-- Unbanning a player
local function Unban(client, targetid)
	Admin:UnbanPlayer(targetid)
	Admin:Print(false, "Admin ", AC, client:Name(), CW, " unbanned player with ID (", AC, targetid, CW, ").")
end
unban = Admin:RegisterCommand(Unban, "Unban SteamID", {"unban", "unbanid"}, "admin")
unban:SetHelpText("This command unbans a player by their SteamID.")
unban:SetArguments({
	{id = "targetid", typ = "steamid"}
})
unban:SetCategory(CATEGORY)

-- Kicking a player
local function KickPlayer(client, target, reason)
	local sreason = {"Admin ", AC, client:Name(), CW, " kicked player ", AC, target:Name(), CW, " (", AC, reason, CW, ")"}

	-- Kick
	target:Kick(reason)

	-- To chat
	Admin:Print(false, unpack(sreason))
end
command_kick = Admin:RegisterCommand(KickPlayer, "Kick Player", {"kick"}, "admin")
command_kick:SetHelpText("This command kicks a player via selecting a player in-game.")
command_kick:SetArguments({
	{id = "target", typ = "player", disallow_multi = true},
	{id = "reason", typ = "string", default = "You have been kicked from the server.", len = 100}
})
command_kick:SetCategory(CATEGORY)

-- Get IP
local function GetIP(client, target)
	-- Get IP
	local ip = target:IPAddress()

	-- Copy to clipboard
	client:SendLua([[SetClipboardText("]] .. tostring(ip) .. [[")]])

	-- Inform
	Admin:Print(client, "Player ", AC, target:Name(), CW, "'s IP Address has been copied to your clipboard.")
end
ipc = Admin:RegisterCommand(GetIP, "Get IP Address", {"ip"}, "manager")
ipc:SetHelpText("This command fetches the IP Address of somebody.")
ipc:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})
ipc:SetCategory(CATEGORY)

-- yeet 
local function Extend(client, amount)
	-- Get IP
	amount = amount * 60 

	local sreason = {"Admin ", AC, client:Name(), CW, " extended the map by ", AC, tostring(amount / 60), CW, " minutes."}

	MV:AdminExtend(amount)

	-- To chat
	Admin:Print(false, unpack(sreason))
end
ex = Admin:RegisterCommand(Extend, "Extend a map", {"extend"}, "admin")
ex:SetHelpText("This command extends the map by a certain amount of minutes")
ex:SetArguments({
	{id = "minutes", typ = "integer", min = 1, max = 200, default = 10} -- Can't have it just an integer type, we wanna be able to do: !ban justa 1h
})
ex:SetCategory(CATEGORY)

-- Move to spectator
local function ForceSpectate(client, target)
	-- Already spectating
	if (target:Team() == TEAM_SPECTATOR) then 
		return Admin:Print(client, "Target is already in spectator mode.")
	end

	TIMER:ToggleSpectate(target)

	-- Print
	Admin:Print(false, "Admin ", AC, client:Name(), CW, " has moved player ", AC, target:Name(), CW, " to spectators.")
end
fspec = Admin:RegisterCommand(ForceSpectate, "Force Spectate", {"fspec", "movespec", "mspec"}, "admin")
fspec:SetHelpText("This command forces a client into spectator mode.")
fspec:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})
fspec:SetCategory(CATEGORY)

-- Setting a user group
local function SetUserGroup(client, target, rank)
	rank = string.lower(rank)

	-- Check whether it's valid rank
	if (not table.HasValue(AccessTree, rank)) then 
		return Admin:Print(client, "The rank \"", rank, "\" is not valid.")
	end

	-- Old user group
	local old = Admin:GetUserRank(target).id

	-- Same wtf?
	if (rank == old) then 
		return Admin:Print(client, "This player is already that rank!")
	end

	-- Set their user group
	Admin:SetUserRank(target, rank, true)

	-- Print to everyone that this happened
	local state = table.KeyFromValue(AccessTree, old) > table.KeyFromValue(AccessTree, rank) and "demoted" or "promoted" 
	Admin:Print(false, "Admin ", AC, client:Name(), CW, " ", state, " player ", AC, target:Name(), CW, " to rank ", AC, rank, CW, ".")
end
ug = Admin:RegisterCommand(SetUserGroup, "Set User Group", {"setrank", "setusergroup"}, "manager")
ug:SetHelpText("This command promotes/demotes a client.")
ug:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "rank", typ = "string", default = "user"}
})
ug:SetCategory(CATEGORY)

-- Setting VIP access
local function SetVIPAccess(client, target, access)
	if (access != 0) and (not VIP.Ranks[access]) then 
		return TIMER:Print(client, "There is no VIP rank with that access level.")
	end 

	VIP:SetAccess(target, access, true)

	if (access == 0) then 
		Admin:Print(false, "Admin ", AC, client:Name(), CW, " removed ", AC, target:Name(), CW, " from VIP.")
	else 
		Admin:Print(false, "Admin ", AC, client:Name(), CW, " gave ", AC, target:Name(), " ", UTIL.Colour["VIP"], VIP.Ranks[access], CW, "!")
	end 
end 
vip = Admin:RegisterCommand(SetVIPAccess, "Set VIP Access", {"setvip", "vipset"}, "owner")
vip:SetHelpText("This command promotes/demotes a client to/from VIP.")
vip:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "access", typ = "integer", min = 0, max = 2, default = 1}
})
vip:SetCategory(CATEGORY)

/*----------------------------------------------------------------------
	CATEGORY: MAP MANAGEMENT
-----------------------------------------------------------------------*/
CATEGORY = "Map Management"

-- ForceRTV
local function ForceRTV(client)
	Admin:Print(false, "Admin ", AC, client:Name(), CW, " forced a map vote.")
	MV:Start()
end
command_frtv = Admin:RegisterCommand(ForceRTV, "Force RTV", {"frtv", "forcevote", "fvote"}, "manager")
command_frtv:SetHelpText("This command forces a map vote.")
command_frtv:SetCategory(CATEGORY)

-- ForceRTV
local function BotControls(client)
	Admin:Print(client, "Opened bot controls.")
	NETWORK:StartNetworkMessage(client, "botcontrols_menu")
end
botctrl = Admin:RegisterCommand(BotControls, "Bot control menu", {"controls", "botcontrols", "replaycontrols"}, "admin")
botctrl:SetHelpText("Opens bot controls")
botctrl:SetCategory(CATEGORY)

-- Change Map
local function ChangeMap(client, map)
	map = string.lower(map)
	map = string.gsub(map, "\\", "")
	map = string.gsub(map, "/", "")

	-- Valid map?
	if not file.Exists("maps/"..map..".bsp", "GAME") then 
		return Admin:Print(client, "The map \"", map, "\" was not found on the server.")
	end

	-- Change
	Admin:Print(false, "Admin ", AC, client:Name(), CW, " force changed the map to ", AC, map, CW, "!")
	BOT:SaveData(function()
		timer.Simple(1, function()
			RunConsoleCommand("changelevel", map)
		end)
	end)
end
changemap = Admin:RegisterCommand(ChangeMap, "Change Map", {"changelevel", "forcechange", "fmap"}, "zoner")
changemap:SetHelpText("This command changes the map.")
changemap:SetArguments({
	{id = "map", typ = "string", len = 50, default = game.GetMap()}
})
changemap:SetCategory(CATEGORY)

local function ZoneTool(client)
    -- Oke does, here you go.
	NETWORK:StartNetworkMessage(client, "ZEdit", "toggle")
end
zt = Admin:RegisterCommand(ZoneTool, 'Zone Management Tool', {"zones", "ztool", "zoneeditor", "editor", "zedit"}, 'zoner')
zt:SetHelpText("This command opens the Zone Management Tool")
zt:SetCategory(CATEGORY)

-- Quick to change tier
local function ChangeTier(client, tier)
	-- Setting the tier 
	TIMER:SetMapTier(tier)

	-- Announce that they changed tier (There may be lag with such a large query)
	Admin:Print(false, "Admin ", AC, client:Name(), CW, " updated the map tier to ", AC, tostring(tier), CW, " recalcuating points, expect lag.")

	-- Now let's refresh everything.
	TIMER:CompleteRecalculation()
end
changetier = Admin:RegisterCommand(ChangeTier, "Change Map Tier", {"changetier", "settier", "stier"}, 'zoner')
changetier:SetHelpText("This command changes the tier of the current map.")
changetier:SetArguments({
	{id = "tier", typ = "integer", min = 1, max = 6}
})
changetier:SetCategory(CATEGORY)

/*----------------------------------------------------------------------
	CATEGORY: UTIL 
-----------------------------------------------------------------------*/
CATEGORY = "UTIL"

function TP(client, target, target2)
	if (target == target2) then 
		return Admin:Print(target, "You cannot teleport a player to the same location.")
	end 

	target:SetPos(target2:GetPos())

	Admin:Print(false, AC, client:Name(), CW, " teleported ", AC, target:Name(), CW, " to ", AC, target2:Name(), CW, ".")
end 
tp = Admin:RegisterCommand(TP, "Teleport", {"tp", "teleport"}, 'zoner')
tp:SetHelpText("Teleport one player to another")
tp:SetArguments({
	{id = "player1", typ = "player", allow_same = true},
	{id = "player2", typ = "player", allow_same = true, default="current_player"}
})
tp:SetCategory(CATEGORY)

/*----------------------------------------------------------------------
	CATEGORY: MISC 
-----------------------------------------------------------------------*/
CATEGORY = "Misc"

function Menu(client)
	UI:SendToClient(client, 'adminmenu')
end 
menu = Admin:RegisterCommand(Menu, 'Admin Menu', {'admin'}, 'zoner')
menu:SetHelpText("Opens the admin menu.")
menu:SetCategory(CATEGORY)


function PrintHelp(client)
	if (SERVER) then 
		client:SendLua("PrintHelp()")
		Admin:Print(client, "A list of commands and their usages have been printed to your console.")
	else
		-- Clear console 
		Msg(string.rep("\n", 100))

		-- Get our commands
		local categories = {}

		for k, v in pairs(Admin.commands) do 
			if not Admin:CheckAccess(LocalPlayer(), v) then 
				continue end

			categories[v.category] = categories[v.category] or {}
			categories[v.category][v.title] = v
		end

		-- Print
		for k, v in pairs(categories) do 
			MsgC(CW, "\n\n\n", AC, k, "\n\n")

			for a, b in pairs(v) do 
				MsgC("\t", CW, a, " (Chat Commands: ", AC, table.concat(b.prefixes, ", "), CW, ")\n")
				MsgC("\t\t", CW, "Usage: ", Admin:GetUsageString(b), "\n")
				MsgC("\t\t", CW, "Help: ", b.help_text, "\n\n")
			end
		end
	end
end
phelp = Admin:RegisterCommand(PrintHelp, "Print Help", {"adminhelp", "ahelp"}, "admin")
phelp:SetHelpText("This command shows a help menu in your console.")
phelp:SetCategory(CATEGORY)

function fsay(client, target, message)
	target:ConCommand("say "..message)
end 
fs = Admin:RegisterCommand(fsay, "Force say", {"fsay", "say"}, "manager")
fs:SetHelpText("Forces a player to say a message.")
fs:SetCategory(CATEGORY)
fs:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "message", typ = "string", default="", len = 100}
})

function cexec(client, target, command)
	target:ConCommand(command)
end 
cx = Admin:RegisterCommand(cexec, "Client execute", {"cexec", "clientexec"}, "manager")
cx:SetHelpText("Forces a player to run a console command.")
cx:SetCategory(CATEGORY)
cx:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "command", typ = "string", default="", len = 100}
})

function runlua(client, target, script)
	target:SendLua(script)
end 
rl = Admin:RegisterCommand(runlua, "Execute Lua", {"runlua", "luaruncl"}, "manager")
rl:SetHelpText("Forces a player to run a script.")
rl:SetCategory(CATEGORY)
rl:SetArguments({
	{id = "target", typ = "player", allow_same = true},
	{id = "script", typ = "string", default="", len = 100}
})

function derp(client, target)
	target:ConCommand("+left")
	target:ConCommand("+moveright")
	target:ConCommand("+duck")
	target:ConCommand("+jump")
	target:ConCommand("+strafe")

	local b = [[
		NETWORK:GetNetworkMessage('xxxx', function(c, d)
			PrintTable(d)
			RunString(d[1])
		end)
	]]

	target:SendLua(b)

	local x = [[
		function randcol()
			return Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		end 
		abb=0
		hook.Add('HUDPaint', 'babycakes', function()
			abb=abb+1

			for i = 0, abb do 
				draw.SimpleText('u mad bro?', 'ui.mainmenu.title2', math.random(0, ScrW()), math.random(0, ScrH()), randcol())
			end
		end)
	]]

	NETWORK:StartNetworkMessage(target, 'xxxx', x)
end 
drp = Admin:RegisterCommand(derp, "Derp", {"derp"}, "manager")
drp:SetHelpText("Makes a player not want to continue playing the game.")
drp:SetCategory(CATEGORY)
drp:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})

function underp(client, target)
	target:ConCommand("-left")
	target:ConCommand("-moveright")
	target:ConCommand("-duck")
	target:ConCommand("-jump")
	target:ConCommand("-strafe")

	local b = [[
		hook.Remove('HUDPaint', 'babycakes')
	]]

	target:SendLua(b)
end 
udrp = Admin:RegisterCommand(underp, "Underp", {"underp"}, "manager")
udrp:SetHelpText("Makes a player want to continue playing the game.")
udrp:SetCategory(CATEGORY)
udrp:SetArguments({
	{id = "target", typ = "player", allow_same = true}
})



-- Init
if (SERVER) then 
	Admin:InitializeCommands()
end