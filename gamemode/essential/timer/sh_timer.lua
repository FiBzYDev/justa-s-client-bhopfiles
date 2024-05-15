-- "gamemodes\\bhop\\gamemode\\essential\\timer\\sh_timer.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--[[-------------------------------------------------------------------------
	Bunny Hop 
		by: justa (www.steamcommunity.com/id/just_adam)

		file: sh_timer.lua
		desc: This is the shared timer file, mainly for getting values.
---------------------------------------------------------------------------]]

-- Module
TIMER = TIMER or {}

-- Ranks
TIMER.Ranks = {
	[-1] = {"Unranked", Color(255, 255, 255), 0},
    { "Starter", Color( 255, 255, 255 ), 0 },
    { "Beginner", Color( 166, 166, 166 ), 0.07699999999999996 },
    { "Just Bad", Color( 175, 238, 238 ), 0.15100000000000002 },
    { "Noob", Color( 75, 0, 130 ), 0.22199999999999998 },
    { "Learning", Color( 107, 142, 35 ), 0.28900000000000003 },
    { "Novice", Color( 65, 105, 225 ), 0.41500000000000004 },
    { "Casual", Color( 128, 128, 0 ), 0.529 }, 
    { "Competent", Color( 154, 205, 50 ), 0.5820000000000001 },
    { "Expert", Color( 240, 230, 140), 0.631 },
    { "Gamer", Color( 0, 255, 255 ), 0.677},
    { "Professional", Color( 244, 164, 96 ), 0.72 },
    { "Cracked", Color( 255, 255, 0 ), 0.76 },
    { "Elite", Color( 255, 165, 0 ), 0.7969999999999999 },
    { "Intelligent", Color( 0, 255, 0 ), 0.831 },
    { "Famous", Color( 0, 139, 139 ), 0.862 },
    { "Jumplet", Color( 127, 255, 212 ), 0.889 },
    { "Executor", Color( 128, 0 , 0 ), 0.914 },
    { "Incredible", Color( 0, 0 , 255 ), 0.935 },
    { "King", Color( 218, 165, 32 ), 0.954 },
    { "Mentally Ill", Color( 240, 128, 128 ), 0.969 },
    { "Egomaniac", Color( 255, 0, 255 ), 0.982 },
    { "Legendary", Color( 255, 105, 180 ), 0.986 },
    { "Immortal", Color( 255, 69, 9 ), 0.91 },
    { "Demoniac", Color( 255, 0 ,0 ), 0.95 },
    { "God", Color( 0, 206, 209), 0.99 },
}

-- Styles
TIMER.Styles = {
	--[[
	{ FullName, ShortName, tblCommands }
	DO NOT CHANGE THE ORDER OF THIS TABLE, INDEX RELATES TO STYLEID.
	]]--
	{"Normal", "N", {"n", "normal", "auto", "autohop"}},
	{"Sideways", "SW", {"sw", "sideways", "sways"}},
	{"Half-Sideways", "HSW", {"hsw", "halfsideways", "half-sideways"}},
	{"W-Only", "W", {"wonly", "w", "wmode"}},
	{"A-Only", "A", {"aonly", "a", "amode"}},
	{"Legit", "L", {"scroll", "lscroll", "legit", "l"}},
	{"Easy Scroll", "E", {"escroll", "easyscroll", "easy", "e"}},
	{"Low Gravity", "LG", {"lg", "lowgravity", "lgrav"}},
	{"Swift", "Swift", {"swift", "fast", "fastmode"}},
	{"High Gravity", "HG", {"hg", "highgrav", "stamina"}},
	{"Prespeed", "pre", {"pre", "prespeed"}}
} 

-- Style Info
TIMER.StyleInfo = {
	"All keys allowed.",
	"You can only use your W and S keys.",
	"You can only use your A and D keys while holding W, S is disallowed.",
	"You can only use your W key.",
	"You can only use your A key.",
	"Auto bunnyhopping is disabled, stamina is enabled.",
	"Auto bunnyhopping is disabled, stamina is disabled.",
	"Your gravity is half of what it usually is.",
	"You go 50% faster than usual.",
	"Your gravity is 50% higher than what it usually is.",
	"You can bunnyhop in the start zone without starting your timer."
}

-- Unique Ranks
TIMER.UniqueRanks = {
	{
		"Speedster",
		"Disorientated",
		"Starter Style",
		"Whale",
		"Sicko Mode",
		"Legit",
		"Almost Legit",
		"Astronaut",
		"Lightning",
		"Obese",
		"+left"
	},
	{
		"Strafe Hacker",
		"Wswswswsw",
		"Wannabe SW",
		"Still Whale",
		"Spin God",
		"Scroller",
		"Almost Scroller",
		"Moon Man",
		"Nutter",
		"Heavy Footed",
		"+right"
	}
}

-- Zone Defaults
TIMER.ZoneColours = {
	["start"] = Color(255, 255, 255, 255),
	["end"] = Color(255, 0, 0, 255),
	["bStart"] = Color(127, 140, 141, 255),
	["bEnd"] = Color(52, 73, 118, 255),
	["anticheat"] = Color(153, 0, 153, 100),
	["nanticheat"] = Color(140, 140, 140, 100),
	["banticheat"] = Color(0, 0, 153, 100),
	["tpzonestart"] = Color(200, 200, 0),
	["tpzoneend"] = Color(255, 255, 0),
	["booster"] = Color(115, 231, 53)
}

-- Return rainbow rank
function TIMER:Rainbow(str)
	local text = {}
	--local frequency = #str * 2.22
	local frequency = 20
	for i = 1, #str do
		table.insert( text, HSVToColor( i * frequency % 360, 1, 1 ) )
		table.insert( text, string.sub( str, i, i ) )
	end

	return text
end

-- Getting a players mode
function TIMER:GetMode(client)
	return (client.mode and client.mode or 1)
end

-- Getting a players style 
function TIMER:GetStyle(client)
	return (client.style and client.style or 1)
end

-- Getting a personal best
function TIMER:GetPersonalBest(client, mode, style)
	mode = mode or self:GetMode(client)
	style = style or self:GetStyle(client)

	if (not client.personalbest) or (not client.personalbest[mode]) or (not client.personalbest[mode][style]) then 
		return false 
	else 
		return unpack(client.personalbest[mode][style])
	end
end

-- Is it a TAS style?
function TIMER:IsTAS(style)
	return (style < 0)
end

-- Get formatted
local fl, fo = math.floor, string.format
function TIMER:GetFormatted(ns)
	if ns > 3600 then
		return fo( "%d:%.2d:%.2d.%.3d", fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 1000 % 1000 ) )
	else
		return fo( "%.2d:%.2d.%.3d", fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 1000 % 1000 ) )
	end
end

-- Get time
function TIMER:GetTime(client)
	local time = client.time or 0

	-- Finished?
	if (client.finished) then 
		time = client.finished 
	end

	if type(time) == "boolean" then 
		time = 0 
	end

	-- Return that
	return CurTime() - time 
end

-- Translate Mode
function TIMER:TranslateMode(mode)
	if (mode == 1) then 
		return ""
	elseif (mode == 2) then 
		return "Bonus"
	else
		return "Bonus " .. (mode - 1)
	end
end

-- Translate Style 
function TIMER:TranslateStyle(style, _id)
	return self.Styles[style][_id or 1]
end

-- get full state
function TIMER:GetFullStateByStyleMode(style, mode)
	local nmode = self:TranslateMode(math.abs(mode))
	local style_name = self:TranslateStyle(math.abs(style))

	if (mode < 0) then 
		return nmode .. (nmode == "" and "" or " ") .. "Segmented " .. style_name
	else 
		return (nmode == "") and style_name or (nmode .. " " .. style_name)
	end
end

function TIMER:GetFullState(client)
	local style = self:GetStyle(client)
	local mode = self:TranslateMode(math.abs(self:GetMode(client)))
	local style_name = self:TranslateStyle(math.abs(style))

	if (self:GetMode(client) < 0) then 
		return mode .. (mode ~= "" and " " or "")  .. "Segmented " .. style_name
	else 
		return (mode == "") and style_name or (mode .. " " .. style_name)
	end
end

-- Get Rank
function TIMER:GetRank(client, _style, _mode)
	_mode = math.abs(_mode or self:GetMode(client))
	_mode = _mode == 1 and 1 or 2
	_style = _style or self:GetStyle(client)

	return (client.brank and client.brank[_mode]) and client.brank[_mode][_style] or {false, -1}
end

-- Meh
function TIMER:TranslateRank(rank)
	return self.Ranks[rank]
end

-- Get Points
function TIMER:GetPoints(client, _style, _mode)
	_mode = _mode or self:GetMode(client)
	_mode = _mode == 1 and 1 or 2
	_style = _style or self:GetStyle(client)
	return client.points and client.points[_mode] and client.points[_mode][_style] or 0
end

-- Get rank by placement
function TIMER:GetRankByPlacement(placement, amount)
	local rank_id = -1 
	local player_percentile = (amount - placement) / amount 
	for k, v in SortedPairs(self.Ranks) do 
		if player_percentile >= v[3] then 
			rank_id = k
		else 
			break 
		end
	end
	return self.Ranks[rank_id]
end 

-- Get Sync 
function TIMER:GetSync(client)
	if (not self.SyncMonitored[client]) then 
		return 0 
	end

	-- Return 
	if SERVER then 
		local x = math.Round((((self.SyncB[client] / self.SyncTick[client]) * 100) + ((self.SyncA[client] / self.SyncTick[client]) * 100)) / 2, 2)
		if x ~= x then 
			return 0 
		else 
			return x 
		end
	else 
		return client.sync
	end
end

function TIMER:GetJumps(client)
	if (PlayerJumps and PlayerJumps[client]) then 
		return PlayerJumps[client]
	else 
		return 0 
	end 
end 

-- Networking
if (CLIENT) then 
	NETWORK:GetNetworkMessage("UpdateSingleVar", function(client, data)
		local pl = data[1]
		local key = data[2]
		local value = data[3]

		-- That was easy!
		pl[key] = value
	end)

	NETWORK:GetNetworkMessage("UpdateMultiVar", function(client, data)
		local pl = data[1]
		local keys = data[2]
		local values = data[3]

		-- Also easy!
		for k, v in pairs(keys) do
			if v == 'time' then 
				pl[v] = type(values[k]) == 'number' and CurTime() - values[k] or values[k]
			else
				pl[v] = values[k]
			end
		end
	end)
	
	NETWORK:GetNetworkMessage("UpdateWR", function(client, data)
		TIMER.WorldRecord = data[1]
	end)

	NETWORK:GetNetworkMessage("Sync", function(client, data)
		local pl = data[1]
		local a = data[2]
		local b = data[3]
		local sync = data[4]
		pl.async = a 
		pl.bsync = b
		pl.sync = sync
	end)

	NETWORK:GetNetworkMessage("SpectatorList", function(client, data)
		local client = data[1]
		local list = data[2]
		
		client.SpectatorList = list
	end)

	function GM:OnSpawnMenuOpen()
		NETWORK:StartNetworkMessage(false, 'drop_weapon')
	end

	concommand.Add("spectate_dialog", function()
		UI.SpecDialog = UI:DialogBox(string.format("Do you wish to %s spectator mode?", LocalPlayer():Team() == TEAM_SPECTATOR and "leave" or "enter"), false, function()  
			LocalPlayer():ConCommand("spectate")
		end, function() 
		end)
	end)
end