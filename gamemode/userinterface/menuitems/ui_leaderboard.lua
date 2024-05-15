-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_leaderboard.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

local function GetWide(size)
	surface.SetFont("ui.mainmenu.button2")
	return select(1, surface.GetTextSize(size))
end
local function GetWide2(size)
	surface.SetFont("ui.mainmenu.button")
	return select(1, surface.GetTextSize(size))
end

WRList = {
	[game.GetMap()] = {}
}
local currentmap = game.GetMap()
local cmode = 1
local cstyle = 1
local AMOUNT = {
	[game.GetMap()] = {}
}
local CURRENT = 0
local HASMORE = {
	[game.GetMap()] = {}
}

local CURRENT_TIER = 1

local function RequestTimes(mode, style, page)
	local map = currentmap == game.GetMap() and false or currentmap

	-- Request 
	UI:SendCallback("RequestWR", {mode, style, (page or 1), map})
end

local function translate(mode)
	return TIMER:TranslateMode(mode) == "" and "Normal" or TIMER:TranslateMode(mode)
end

WRLISTADDFUNC = nil

UI:AddListener("WRList", function(_, data)
	if not WRList then return end 
	local times = data[1]
	local amount = data[2]
	local page = data[3]
	local map = data[4]

	if map and map ~= currentmap then return end 

	WRList[currentmap] = WRList[currentmap] or {}
	WRList[currentmap][cmode] = WRList[currentmap][cmode] or {}
	WRList[currentmap][cmode][cstyle] = WRList[currentmap][cmode][cstyle] or {} 

	for k, v in SortedPairs(times) do 
		table.insert(WRList[currentmap][cmode][cstyle], v)
	end

	AMOUNT[currentmap] = AMOUNT[currentmap] or {}
	AMOUNT[currentmap][cmode] = AMOUNT[currentmap][cmode] or {}
	AMOUNT[currentmap][cmode][cstyle] = amount 
	CURRENT = #WRList[currentmap][cmode][cstyle]
	HASMORE[currentmap] = HASMORE[currentmap] or {}
	HASMORE[currentmap][cmode] = HASMORE[currentmap][cmode] or {}
	HASMORE[currentmap][cmode][cstyle] = math.ceil(amount / 50) > page
	UpdateList(page, math.ceil(amount / 50) > page)
end)

	
UI:AddListener("RetrieveTier", function(_, data)
	CURRENT_TIER = data[1]
end)

CurrentDisplayAverage = {0, 0, 0}
UI:AddListener("RetrieveAverages", function(_, data)
	CurrentDisplayAverage = {data[1], data[2], data[3]}
end)

CHANGE_MODES = nil
function BuildWorldRecords(pan, option)
	UI:SendCallback("GetTier", {currentmap})

	local width, height = pan:GetSize()
	local col = UI_PRIMARY
	local pl = LocalPlayer()
	col = Color(col.r + 10, col.g + 10, col.b + 10, 255)


	local MODES, STYLES, mz = {}, {}, {}
	for k, v in SortedPairs(TIMER.Styles) do 
		table.insert(STYLES, {v[1], k})
	end

	for k, v in SortedPairs(TIMER.modes) do 
		table.insert(MODES, {translate(v), v})
		mz[v] = #MODES
	end

	for k, v in SortedPairs(TIMER.modes) do 
		table.insert(MODES, {"Segmented "..translate(v), -v})
		mz[-v] = #MODES
	end

	pan.mode = BuildDropdown(pan, width - 380, 0 ,170, 30, MODES, mz[pl.mode])
	cmode = pl.mode
	pan.style = BuildDropdown(pan, width - 560 , 0 ,170, 30, STYLES, pl.style)
	cstyle = pl.style
	pan.themec = UI.mainmenu.themec

	function ChangeModes(tbl)
		cmode = 1
		pan.mode:Clear()

		for k, v in SortedPairs(tbl) do 
			pan.mode:AddChoice(translate(v), v)
		end
		for k, v in SortedPairs(tbl) do 
			pan.mode:AddChoice("Segmented "..translate(v), -v)
		end

		pan.mode:SetValue("Normal")
	end
	CHANGE_MODES = ChangeModes

	currentmap = game.GetMap()

	pan.map = BuildSleekButton(pan, width - 200, 0, 200, 30, currentmap, function()
		if pan.tmp then pan.tmp:Remove() end
		local w, h = UI.mainmenu.BASE:GetSize()
		pan.tmp = UI.mainmenu.BASE:Add('EditablePanel')
		pan.tmp:SetSize(w - 100, h - 100)
		pan.tmp:SetPos(50, 50)
		pan.tmp.themec = UI.mainmenu.themec
		pan.tmp.themet = UI.mainmenu.themet

		local w, h = pan.tmp:GetSize()
		pan.tmp.close = BuildSleekButton(pan.tmp, 10, h - 40, w-20, 30, "Cancel", function() 
			pan.tmp:Remove()
			pan.tmp = nil
		end)

		function pan.tmp:Paint(width, height)
			surface.SetDrawColor(UI_SECONDARY)
			surface.DrawRect(0, 0, width, height)

			if not TIMER.HasMapList then 
				draw.SimpleText('Gathering maps...', 'ui.mainmenu.title', width / 2, height / 2, UI_TEXT1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText('Select a map by clicking on it.', 'ui.mainmenu.button', 10, 56, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		UI:DrawBanner(pan.tmp, "Select a map")
		local w, h = pan.tmp:GetSize()
		pan.tmp.ScrollPan = UI:ScrollablePanel(pan.tmp, 10, 80, w - 20, h - 124, {
			{"Name", "Tier", "Plays"}, 4, {0, 2, 3}
		})

		function pan.tmp:domaps()
			for id, map in pairs(TIMER.MapList) do 
				UI:MapScrollable(pan.tmp.ScrollPan, {map.name, tonumber(map.tier), tonumber(map.plays)}, {4, {0, 2, 3}}, function()
					SetCurrMap(map.name)
					pan.tmp:Remove()
					pan.tmp = nil
				end)
			end
		end
		WRLISTADDFUNC = pan.tmp.domaps
		
		pan.tmp.Search = UI:SearchBox(pan.tmp, w - 210, 40, 200, 30, false, col, function(value)
			-- Clear current
			for k, v in pairs(pan.tmp.ScrollPan.contents) do 
				v:Remove()
				pan.tmp.ScrollPan.contents[k] = nil
			end

			-- Add 
			for k, v in pairs(TIMER.MapList) do 
				local mapname = v.name
				if (string.find(mapname, value)) then 
					UI:MapScrollable(pan.tmp.ScrollPan, {v.name, tonumber(v.tier), tonumber(v.plays)}, {
						4, {0, 2, 3}
					}, function()
						SetCurrMap(v.name)
						pan.tmp:Remove()
						pan.tmp = nils
					end)
				end
			end

			-- Just because it bugs me
			local base = pan.tmp.ScrollPan
			if (#base.contents * 40) > base:GetTall() then 
				base.scrollbar = true
			else
				base.scrollbar = false 
			end
		end) 

		if TIMER.HasMapList then 
			pan.tmp:domaps()
		else 
			TIMER.WRMapList = true
			NETWORK:StartNetworkMessage(false, "GetMapList")
		end
	end, false, false)


	pan.ScrollPan = UI:ScrollablePanel(pan, 0, 39, width, height - 44, {
		{"Place", "Name", "Time"}, 4, {0, 0.5, 3.3}
	})
	pan.ScrollPan.nosort = true
	WRList = {}

	function pan.ScrollPan:Think()
		local gripY = select(2, self.VBar.btnGrip:GetPos() )
		local gripH = self.VBar.btnGrip:GetTall()
		local btnY = select(2, self.VBar.btnDown:GetPos() )

		if gripY != 0 and (gripY + gripH + 20) >= btnY then 
			self:HitBottom()
		end
	end

	function pan.ScrollPan.HitBottom() end

	-- we'll try but we gotta be aware that some modes might not have a time lol
	if not WRList[currentmap] or not WRList[currentmap][cmode] or not WRList[currentmap][cmode][cstyle] then 
		RequestTimes(cmode, cstyle)
	end

	function UpdateList(page, hasmore)
		for i = ((page - 1) * 50) + 1, page * 50 do 
			if not WRList[currentmap][cmode][cstyle][i] then break end 
			local time = WRList[currentmap][cmode][cstyle][i]
			local wrtime = WRList[currentmap][cmode][cstyle][1]
			local scrollable = UI:MapScrollable(pan.ScrollPan, {i, {'name', time.steamid}, TIMER:GetFormatted(time.time)}, { 4, {0, 0.5, 3.3}}, function(self)
				CurrentDisplayAverage = false
				UI:SendCallback("RequestAverages", {cmode, cstyle, time.steamid})

				if pan.tmp then pan.tmp:Remove() end

				local w, h = UI.mainmenu.BASE:GetSize()
				pan.tmp = UI.mainmenu.BASE:Add('EditablePanel')
				pan.tmp:SetSize(w - 100, h - 100)
				pan.tmp:SetPos(50, 50)
				pan.tmp.themec = UI.mainmenu.themec
				pan.tmp.themet = UI.mainmenu.themet

				local w, h = pan.tmp:GetSize()
				pan.tmp.close = BuildSleekButton(pan.tmp, 10, h - 40, w - 20, 30, "Close", function() 
					pan.tmp:Remove()
					pan.tmp = nil
				end)


				local function coolFunc(var)
					if var > 0 then 
						return "+" .. var 
					else 
						return var 
					end
				end

				function pan.tmp:Paint(width, height)
					surface.SetDrawColor(UI_SECONDARY)
					surface.DrawRect(0, 0, width, height)

					-- First Row 
					local yOffset = 50
					local xOffset = 15
					local isWR = wrtime == time

					draw.SimpleText("General Statistics", "ui.mainmenu.title", xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					yOffset = yOffset + 24
					local timeStr = isWR and TIMER:GetFormatted(time.time) or TIMER:GetFormatted(time.time) .. " (+" .. TIMER:GetFormatted(time.time - wrtime.time) .. " WR)"
					draw.SimpleText(timeStr, 'ui.mainmenu.button', xOffset + GetWide("Time:") + 6, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Time: ", 'ui.mainmenu.button2', xOffset, yOffset, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					local jumpStr = isWR and time.jumps or time.jumps .. " (" .. coolFunc(time.jumps - wrtime.jumps) .. " WR)"
					draw.SimpleText("Jumps: ", 'ui.mainmenu.button2', xOffset + 1, yOffset + 20, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(jumpStr, 'ui.mainmenu.button', xOffset + GetWide("Jumps:") + 7, yOffset + 20, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					local strafeStr = isWR and time.strafes or time.strafes .. " (" .. coolFunc(time.strafes - wrtime.strafes) .. " WR)"
					draw.SimpleText("Strafes: ", 'ui.mainmenu.button2', xOffset, yOffset + 40, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(strafeStr, 'ui.mainmenu.button', xOffset + GetWide("Strafes:") + 6, yOffset + 40, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					local speedStr = isWR and math.Round(time.tspeed, 3) .. " u/s" or math.Round(time.tspeed, 3) .. " u/s" .. " (" .. coolFunc(math.Round(time.tspeed - wrtime.tspeed, 3)) .. " u/s WR)"
					draw.SimpleText("Top Speed: ", 'ui.mainmenu.button2', xOffset, yOffset + 60, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(speedStr, 'ui.mainmenu.button', xOffset + GetWide("Top Speed:") + 6, yOffset + 60, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					xOffset = width - 15 
					draw.SimpleText("Points: ", 'ui.mainmenu.button2', xOffset - GetWide2(time.points) - 2, yOffset, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(time.points, 'ui.mainmenu.button', xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					local sid = time.steamid
					draw.SimpleText("SteamID: ", 'ui.mainmenu.button2', xOffset - GetWide2(sid) - 2, yOffset + 20, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(sid, 'ui.mainmenu.button', xOffset, yOffset + 20, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					local prof = "www.steamcommunity.com/profiles/" .. util.SteamIDTo64(time.steamid)
					draw.SimpleText("Profile: ", 'ui.mainmenu.button2', xOffset - GetWide2(prof) - 2, yOffset + 40, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(prof, 'ui.mainmenu.button', xOffset, yOffset + 40, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					local date = os.date('%d %B %Y at %I:%M:%S %p', time.date)
					draw.SimpleText("Date: ", 'ui.mainmenu.button2', xOffset - GetWide2(date) - 2, yOffset + 60, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(date, 'ui.mainmenu.button', xOffset, yOffset + 60, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					-- Second Row 
					yOffset = yOffset + 100
					xOffset = 15 

					draw.SimpleText("Strafe Statistics and Completions", "ui.mainmenu.title", xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					yOffset = yOffset + 24

					local gainStr = math.Round(time.again, 3) .. "%" .. (CurrentDisplayAverage and " (" .. coolFunc(math.Round(time.again - CurrentDisplayAverage[1], 3)) .. "% on their personal average)" or " (Loading...)")
					draw.SimpleText(gainStr, 'ui.mainmenu.button', xOffset + GetWide("Average Gain:") + 6, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Average Gain: ", 'ui.mainmenu.button2', xOffset, yOffset, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					local syncStr = math.Round(time.sync, 3) .. "%" .. (CurrentDisplayAverage and " (" .. coolFunc(math.Round(time.sync - CurrentDisplayAverage[2], 3)) .. "% on their personal average)" or " (Loading...)")
					draw.SimpleText(syncStr, 'ui.mainmenu.button', xOffset + GetWide("Sync:") + 6, yOffset + 20, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Sync: ", 'ui.mainmenu.button2', xOffset, yOffset + 20, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					local completionsStr = time.completions .. (CurrentDisplayAverage and " (" .. coolFunc(time.completions - CurrentDisplayAverage[3]) .. " on their personal average)" or " (Loading...)")
					draw.SimpleText(completionsStr, 'ui.mainmenu.button', xOffset + GetWide("Completions:") + 8, yOffset + 40, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Completions: ", 'ui.mainmenu.button2', xOffset, yOffset + 40, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					yOffset = yOffset + 80
					draw.SimpleText("Group Statistics", "ui.mainmenu.title", xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					-- Group stuff
					yOffset = yOffset + 24 
					local groups = {
						{1.02, 1.1, 1.2, 1.4, 1.7, 2}, {1.05, 1.1, 1.2, 1.4, 1.7, 2},
						{1.1, 1.2, 1.4, 1.6, 1.8, 2}, {1.1, 1.2, 1.4, 1.6, 1.8, 2},
						{1.2, 1.4, 1.6, 1.8, 1.9, 2}, {1.1, 1.2, 1.4, 1.6, 1.8, 2}
					}
					local c = {
						Color(185, 242, 255),
						Color(218, 165, 32),
						Color(205, 127, 50),
						Color(227, 66, 245),
						Color(230, 139, 48),
						Color(222, 47, 70)
					}
					for i = 1, 6 do 
						local align = i > 3 and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT
						local timeDiff = ((wrtime.time * groups[CURRENT_TIER][i]) - time.time)
						local timeBool = timeDiff > 0 and true or false
						local tStr = TIMER:GetFormatted(wrtime.time * groups[CURRENT_TIER][i]) .. " (" .. (not timeBool and ("-" .. TIMER:GetFormatted(math.abs(timeDiff)) .. " required)") or "achieved)")

						if i == 6 then 
							draw.SimpleText("Group " .. i .. ": ", "ui.mainmenu.button2", width - (timeBool and 15 or 15) - GetWide("achieved") - 2, yOffset + ((20 * (i - 1)) - 60), UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
							draw.SimpleText("achieved", "ui.mainmenu.button", width - 15, yOffset + ((20 * (i - 1)) - 60), UI_ACCENT, align, TEXT_ALIGN_CENTER)
						elseif i > 3 then 
							draw.SimpleText("Group " .. i .. ": ", "ui.mainmenu.button2", width - (timeBool and 15 or 15) - GetWide2(tStr) - 2, yOffset + ((20 * (i - 1)) - 60), UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
							draw.SimpleText(tStr, "ui.mainmenu.button", width - 15, yOffset + ((20 * (i - 1)) - 60), timeBool and UI_ACCENT or UI_TEXT1, align, TEXT_ALIGN_CENTER)
						else 
							draw.SimpleText("Group " .. i .. ": ", "ui.mainmenu.button2", xOffset, yOffset + 20 * (i - 1), UI_ACCENT, align, TEXT_ALIGN_CENTER)
							draw.SimpleText(tStr, "ui.mainmenu.button", xOffset + GetWide("Group " .. i .. ":") + 6, yOffset + 20 * (i - 1), timeBool and UI_ACCENT or UI_TEXT1, align, TEXT_ALIGN_CENTER)
						end
					end

					yOffset = yOffset + 90
					local max = width - 10
					local col = UI_PRIMARY
					col = Color(col.r + 10, col.g + 10, col.b + 10)
					surface.SetDrawColor(col)
					surface.DrawRect(xOffset - 5, yOffset, width - 20, 40)

					local per = math.abs(time.time / wrtime.time) - 1
					per = 1 - per
					surface.SetDrawColor(UI_ACCENT)
					surface.DrawRect(xOffset, yOffset + 5, (width - 30) * per, 30)
					draw.SimpleText("PB", "ui.mainmenu.button", xOffset + ((width - 30) * per), yOffset + 50, UI_TEXT1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					surface.SetDrawColor(UI_TEXT1)
					surface.DrawLine(xOffset + ((width - 30) * per), yOffset, xOffset + ((width - 30) * per), yOffset + 40)

					draw.SimpleText("WR", "ui.mainmenu.button", xOffset + width - 20, yOffset - 10, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					surface.DrawLine(xOffset + width - 30, yOffset, xOffset + width - 30, yOffset + 40)

					for i = 1, 5 do
						local var = 2 - groups[CURRENT_TIER][i]
						local w = width - 20
						local p = (w * var)
						local x = p
						draw.SimpleText(tostring(i), "ui.mainmenu.button2", xOffset + x - 4, yOffset + 20, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					end
				end

				UI:DrawBanner(pan.tmp, "Statistics for " .. time.name .. "'s #" .. i .. " run on " .. currentmap .. " (" .. TIMER:TranslateStyle(cstyle) .. ", " .. translate(cmode) .. ")")
			end)
		end

		if hasmore then 
			timer.Simple(0.5, function()
			pan.ScrollPan.HitBottom = function()
				RequestTimes(cmode, cstyle, page + 1) 
				pan.ScrollPan.HitBottom = function() end
			end end)
		end
	end

	function ChangeList(hault)
		-- wipey wipe 
		for k, v in pairs(pan.ScrollPan.contents or {}) do 
			v:Remove()
			pan.ScrollPan.contents[k] = nil
		end

		if pan.ScrollPan.contents then 
			local base = pan.ScrollPan
			if (#base.contents * 40) > base:GetTall() then 
				base.scrollbar = true
			else
				base.scrollbar = false 
			end
		end

		-- Addy add 
		if not hault then 
			UpdateList(1, HASMORE[currentmap][cmode][cstyle])
		end
	end

	function SetCurrMap(m)
		currentmap = m 
		pan.map.title = m
		cmode = 1 

		UI:SendCallback("GetTier", {currentmap})

		if m == game.GetMap() or UI.ModesForMaps[m] then 
			ChangeModes(m == game.GetMap() and TIMER.modes or UI.ModesForMaps[m])
		end

		if not WRList[currentmap] or not WRList[currentmap][cmode] or not WRList[currentmap][cmode][cstyle] then 
			ChangeList(true)
			RequestTimes(cmode, cstyle, 1)
		else 
			ChangeList()
		end
	end

	function pan.mode:OnSelect(index, value, data)
		cmode = data
		if not WRList[currentmap] or not WRList[currentmap][cmode] or not WRList[currentmap][cmode][cstyle] then 
			ChangeList(true)
			RequestTimes(cmode, cstyle, 1)
		else 
			CURRENT = #WRList[currentmap][cmode][cstyle]
			ChangeList()
		end
	end

	function pan.style:OnSelect(index, value, data)
		cstyle = data
		if not WRList[currentmap] or not WRList[currentmap][cmode] or not WRList[currentmap][cmode][cstyle] then 
			ChangeList(true)
			RequestTimes(cmode, cstyle, 1)
		else 
			CURRENT = #WRList[currentmap][cmode][cstyle]
			ChangeList()
		end
	end

	function pan:Paint()
		if WRList and WRList[currentmap] and WRList[currentmap][cmode] and WRList[currentmap][cmode][cstyle] and #WRList[currentmap][cmode][cstyle] > 0 then 
			draw.SimpleText("Displaying "..CURRENT.."/"..AMOUNT[currentmap][cmode][cstyle].." times", "ui.mainmenu.button", 0, 15, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("No times avaliable", "ui.mainmenu.button", 0, 15, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	if (option) then
		SetCurrMap(option)
	end 
end


------- Top List 
TopList = {}
TopListAmount = {}
TopListMode = 1
TopListStyle = 1
TopListCurrent = 0
TopListHM = {}
UpdateTopList = function() end 

UI:AddListener("TopList", function(_, data)
	if not TopList then return end 
	local lst = data[1]
	local amount = data[2]
	local page = data[3]

	TopList = TopList or {}
	TopList[TopListMode] = TopList[TopListMode] or {}
	TopList[TopListMode][TopListStyle] = TopList[TopListMode][TopListStyle] or {} 

	for k, v in SortedPairs(lst) do 
		table.insert(TopList[TopListMode][TopListStyle], v)
	end

	TopListAmount[TopListMode] = TopListAmount[TopListMode] or {}
	TopListAmount[TopListMode][TopListStyle] = amount 
	TopListCurrent = #TopList[TopListMode][TopListStyle]

	TopListHM[TopListMode] = TopListHM[TopListMode] or {}
	TopListHM[TopListMode][TopListStyle] = math.ceil(amount / 50) > page
	UpdateTopList(page, math.ceil(amount / 50) > page)
end)

TopListPan = nil 
 
function RequestTopList(mode, style, page)
	UI:SendCallback("RequestTop", {mode, style, (page or 1)})
end

TopInfo = false
UI:AddListener("GetTopInfo", function(_, data)
	TopInfo = {
		total_completions = data[1],
		highest_completion = data[2][2] .. " (" .. data[2][1] .. ")",
		wrs_obtained = data[3],
		recent_wr = data[4],
		avgmapcomp = data[5],
		avgtier = data[6],
		avgpos = data[7],
		avgwrtier = data[8] == data[8] and data[8] or "-",
		mapsleft = data[9]
	}
end)

function CreateTopList(pan)
	TopList = {}
	TopListAmount = {}
	TopListMode = 1
	TopListStyle = 1
	TopListCurrent = 0
	TopInfo = false

	local width, height = pan:GetSize()
	local col = UI_PRIMARY
	local pl = LocalPlayer()
	col = Color(col.r + 10, col.g + 10, col.b + 10, 255)

	local MODES, STYLES = {}, {}
	for k, v in SortedPairs(TIMER.Styles) do 
		table.insert(STYLES, {v[1], k})
	end

	table.insert(MODES, {"Normal", 1})
	table.insert(MODES, {"Bonus", 2})

	local m = math.abs(pl.mode)
	if m > 2 then m = 2 end 
	pan.mode = BuildDropdown(pan, width - 170, 0 , 170, 30, MODES, m)
	TopListMode = m
	pan.style = BuildDropdown(pan, width - (170 + 170 + 10) , 0 , 170, 30, STYLES, pl.style)
	TopListStyle = pl.style 

	RequestTopList(TopListMode, TopListStyle)
	pan.themec = UI.mainmenu.themec
	pan.ScrollPan = UI:ScrollablePanel(pan, 0, 39, width, height - 44, {
		{"Place", "Rank", "Name", "Points"}, 5, {0, 0.7, 1.5, 4.5}
	})

	pan.ScrollPan.nosort = true

	function pan.ScrollPan:Think()
		local gripY = select(2, self.VBar.btnGrip:GetPos() )
		local gripH = self.VBar.btnGrip:GetTall()
		local btnY = select(2, self.VBar.btnDown:GetPos() )

		if gripY != 0 and (gripY + gripH + 5) >= btnY then 
			self:HitBottom()
		end
	end

	function pan.ScrollPan.HitBottom() end

	function UpdateTopList(page, hasmore)
		for i = ((page - 1) * 50) + 1, page * 50 do 
			if not TopList[TopListMode][TopListStyle][i] then break end 
			local ply = TopList[TopListMode][TopListStyle][i]
			local rank = TIMER:GetRankByPlacement(i, TopListAmount[TopListMode][TopListStyle])
			local scrollable = UI:MapScrollable(pan.ScrollPan, {i, rank, ply.name, ply.points}, { 5, {0, 0.7, 1.5, 4.5} }, function(self) 
				if pan.tmp then pan.tmp:Remove() end

				local w, h = UI.mainmenu.BASE:GetSize()
				pan.tmp = UI.mainmenu.BASE:Add('EditablePanel')
				pan.tmp:SetSize(w - 100, h - 310)
				pan.tmp:SetPos(50, 50)
				pan.tmp.themec = UI.mainmenu.themec
				pan.tmp.themet = UI.mainmenu.themet

				local w, h = pan.tmp:GetSize()
				pan.tmp.close = BuildSleekButton(pan.tmp, 10, h - 40, w - 20, 30, "Close", function() 
					pan.tmp:Remove()
					pan.tmp = nil
				end)

				pan.tmp.prof = BuildSleekButton(pan.tmp, 10, h - 74, w - 20, 30, "View more statistics...", function() 
					pan.tmp:Remove()
					pan.tmp = nil
				end)

				local function coolFunc(var)
					if var > 0 then 
						return "+" .. var 
					else 
						return var 
					end
				end

				TopInfo = false
				UI:SendCallback("RequestTopInformation", {TopListMode, TopListStyle, ply.steamid})
				
				local function getstat(stat)
					if not TopInfo then 
						return "Loading..."
					end 

					return TopInfo[stat]
				end 

				function pan.tmp:Paint(width, height)
					surface.SetDrawColor(UI_SECONDARY)
					surface.DrawRect(0, 0, width, height)

					-- First Row 
					local yOffset = 50
					local xOffset = 15

					draw.SimpleText("General Statistics", "ui.mainmenu.title", xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					yOffset = yOffset + 24
					draw.SimpleText(rank[1], 'ui.mainmenu.button', xOffset + GetWide("Rank: ") + 2, yOffset, rank[2], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Rank: ", 'ui.mainmenu.button2', xOffset, yOffset, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					draw.SimpleText("Map completions: ", 'ui.mainmenu.button2', xOffset + 1, yOffset + 20, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(getstat("total_completions"), 'ui.mainmenu.button', xOffset + GetWide("Map completions: ") + 5, yOffset + 20, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					draw.SimpleText("Maps played: ", 'ui.mainmenu.button2', xOffset + 1, yOffset + 40, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(ply.completions, 'ui.mainmenu.button', xOffset + GetWide("Maps played: ") + 5, yOffset + 40, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


					draw.SimpleText("Maps left: ", 'ui.mainmenu.button2', xOffset + 1, yOffset + 60, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(getstat("mapsleft"), 'ui.mainmenu.button', xOffset + GetWide("Maps left: ") + 5, yOffset + 60, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					xOffset = width - 15 
					draw.SimpleText("Points: ", 'ui.mainmenu.button2', xOffset - GetWide2(ply.points) - 2, yOffset, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(ply.points, 'ui.mainmenu.button', xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					draw.SimpleText("Most played map: ", 'ui.mainmenu.button2', xOffset - GetWide2(getstat("highest_completion")) - 2, yOffset + 20, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(getstat("highest_completion"), 'ui.mainmenu.button', xOffset, yOffset + 20, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					draw.SimpleText("World records obtained: ", 'ui.mainmenu.button2', xOffset - GetWide2(getstat("wrs_obtained")) - 2, yOffset + 40, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(getstat("wrs_obtained"), 'ui.mainmenu.button', xOffset, yOffset + 40, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					local wr = getstat("recent_wr")
					local rwr = wr 
					if rwr ~= "Loading..." then 
						rwr = wr[2] .. " (" .. TIMER:GetFormatted(wr[3] or 0) .. ")" 
						if not wr[3] then rwr = "-" end end 
					draw.SimpleText("Most recent WR: ", 'ui.mainmenu.button2', xOffset - GetWide(rwr) - 2, yOffset + 60, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(rwr, 'ui.mainmenu.button', xOffset, yOffset + 60, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					-- Second Row 
					yOffset = yOffset + 100
					xOffset = 15 

					draw.SimpleText("Average Statistics", "ui.mainmenu.title", xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					yOffset = yOffset + 24

					draw.SimpleText(getstat("avgmapcomp"), 'ui.mainmenu.button', xOffset + GetWide("Map completions: ") + 5, yOffset, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Map completions: ", 'ui.mainmenu.button2', xOffset, yOffset, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					draw.SimpleText("#"..getstat("avgpos"), 'ui.mainmenu.button', xOffset + GetWide("Map placement: ") + 5, yOffset + 20, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Map placement: ", 'ui.mainmenu.button2', xOffset, yOffset + 20, UI_ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					xOffset = width - 15 

					draw.SimpleText("Tier played: ", 'ui.mainmenu.button2', xOffset - GetWide(getstat("avgtier")) - 2, yOffset, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(getstat("avgtier"), 'ui.mainmenu.button', xOffset, yOffset, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					draw.SimpleText("WR Tier: ", 'ui.mainmenu.button2', xOffset - GetWide(getstat("avgwrtier")) - 2, yOffset + 20, UI_ACCENT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					draw.SimpleText(getstat("avgwrtier"), 'ui.mainmenu.button', xOffset, yOffset + 20, UI_TEXT1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end 

				UI:DrawBanner(pan.tmp, "Statistics for " .. ply.name .. " (" .. TIMER:GetFullStateByStyleMode(TopListStyle, TopListMode) ..  ")")
			end)
		end 

		if hasmore then 
			timer.Simple(0.5, function()
				pan.ScrollPan.HitBottom = function()
					RequestTopList(TopListMode, TopListStyle, page + 1) 
					pan.ScrollPan.HitBottom = function() end
				end
			end)
		end
	end 

	function CL(hault)
		-- wipey wipe 
		for k, v in pairs(pan.ScrollPan.contents or {}) do 
			v:Remove()
			pan.ScrollPan.contents[k] = nil
		end

		if pan.ScrollPan.contents then 
			local base = pan.ScrollPan
			if (#base.contents * 40) > base:GetTall() then 
				base.scrollbar = true
			else
				base.scrollbar = false 
			end
		end

		-- Addy add 
		if not hault then 
			UpdateTopList(1, TopListHM[TopListMode][TopListStyle])
		end
	end

	function pan.mode:OnSelect(index, value, data)
		TopListMode = data
		if not TopList[TopListMode] or not TopList[TopListMode][TopListStyle] then 
			CL(true)
			RequestTopList(TopListMode, TopListStyle, 1)
		else 
			TopListCurrent = #TopList[TopListMode][TopListStyle]
			
			CL()
		end
	end

	function pan.style:OnSelect(index, value, data)
		TopListStyle = data
		if not TopList[TopListMode] or not TopList[TopListMode][TopListStyle] then 
			CL(true)
			RequestTopList(TopListMode, TopListStyle, 1)
		else 
			TopListCurrent = #TopList[TopListMode][TopListStyle]
			CL()
		end
	end

	function pan:Paint()
		if TopList and TopList[TopListMode] and TopList[TopListMode][TopListStyle] and #TopList[TopListMode][TopListStyle] > 0 then 
			draw.SimpleText("Displaying "..TopListCurrent.."/"..TopListAmount[TopListMode][TopListStyle].." people on "..TIMER:GetFullStateByStyleMode(TopListStyle, TopListMode), "ui.mainmenu.button", 0, 15, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("No times avaliable", "ui.mainmenu.button", 0, 15, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end


UI.ModesForMaps = UI.ModesForMaps or {}
UI:AddListener("ModesForMaps", function(_, data)
	local map = data[1]
	local modes = data[2]	

	print(map)
	PrintTable(modes)
	if not UI.ModesForMaps[map] then 
		UI.ModesForMaps[map] = modes
		CHANGE_MODES(UI.ModesForMaps[map])
	end
end)

