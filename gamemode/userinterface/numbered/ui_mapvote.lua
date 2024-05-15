-- "gamemodes\\bhop\\gamemode\\userinterface\\numbered\\ui_mapvote.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = false 
local VoteInProgress = false 
local RTVStart = false
local CurrentSelected = false

local function Vote(mapId)
	return function()
		if CurrentSelected then 
			PANEL:UpdateOption(CurrentSelected, false, PANEL.themec["Text Colour"])
		end
		CurrentSelected = mapId 
		PANEL:UpdateOption(CurrentSelected, false, PANEL.themec["Accent Colour"])
		NETWORK:StartNetworkMessage(false, "VoteCallback", mapId)
	end
end

local function StartRTV(maps, isRevote, End)
	if isRevote and PANEL and PANEL.title then return end

	Maps = {}

	-- Convert options to readable by UI API
	local ui_options = {}
	for k, v in SortedPairs(maps) do
		local name = "[" .. v.votes .. "] " .. v.name
		if v.tier then 
			name = name .. " - Tier " .. v.tier .. " (" .. v.plays .. " plays)"
		end

		table.insert(ui_options, {["name"] = name, ["function"] = Vote(k)})
	end

	PANEL = UI:NumberedUIPanel("", unpack(ui_options))

	if (isRevote) then
		RTVStart = RTVStart and RTVStart or CurTime() + 30
		if CurrentSelected then 
			PANEL:UpdateOption(CurrentSelected, false, PANEL.themec["Accent Colour"])
		end
	else
		RTVStart = (End and End or (CurTime() + 30))
	end

	function PANEL:OnThink()
		if not RTVStart then return end
		local s = math.Round(RTVStart - CurTime())

		if (s <= 0) then
			self:Exit()
			RTVStart = false
			PANEL = nil
			return
		end

		self.title = "Map Vote (" .. s .. "s remaining)"
	end

	function PANEL:OnExit()
		UTIL:AddMessage("Server", "You can reopen this panel with !revote") 
	end

	PANEL:SetCustomDelay(2)
	VoteInProgress = true 
end

local function EndRTV()
	if PANEL and PANEL.Exit then PANEL:Exit() end
	RTVStart = false
	Maps = {}
	VoteInProgress = false
	CurrentSelected = false
end

local function UpdatePanel(mapId, mapInfo, old)
	if not PANEL or not PANEL.title then return end
	if old then 
		local mapIdOld = old[1]
		local mapInfoOld = old[2]
		local name = "[" .. mapInfoOld.votes .. "] " .. mapInfoOld.name
		if mapInfoOld.plays then 
			name = name .. " - Tier " .. mapInfoOld.tier .. " (" .. mapInfoOld.plays .. " plays)"
		end
		PANEL:UpdateOption(mapIdOld, name)
	end

	local nname = "[" .. mapInfo.votes .. "] " .. mapInfo.name
	if mapInfo.plays then 
		nname = nname .. " - Tier " .. mapInfo.tier .. " (" .. mapInfo.plays .. " plays)"
	end
	PANEL:UpdateOption(mapId, nname)
end

UI:AddListener("MapVote", function(_, data)
	local id = data[1]

	if id == "started" then
		Maps = data[2] 
		End = data[3] or false

		if TIMER:GetMode(LocalPlayer()) < 0 then 
			UTIL:AddMessage("Server", "A map vote has started, because you are in segment it did not open. Type !revote to open the menu.")
		else 
			StartRTV(Maps, false, End)
		end 
	elseif id == "ended" then 
		EndRTV()
	elseif id == "update" then 
		UpdatePanel(data[2], data[3], data[4])
	elseif id == "revote" then 
		local maps = data[2]
		StartRTV(maps, true)
	end
end)
