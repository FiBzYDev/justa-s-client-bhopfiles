-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_nominate.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
TIMER.MapList = TIMER.MapList or {}
TIMER.HasMapList = TIMER.HasMapList or false
TIMER.AwaitingList = false

function BuildLoading(pan)
	local a = pan:Add("DPanel")
	a:SetPos(0, 0)
	local w, h = pan:GetSize()
	a:SetSize(w, h)
	a.Paint = function()
		draw.SimpleText("Loading...", "ui.mainmenu.title", w / 2, h / 2, UI_TEXT1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function Nominate(mp)
	return function()
		LocalPlayer():ConCommand("say !nominate "..mp)
		UI:ToggleMainmenu()
	end
end

function BuildNominationMenu(pan)
	local width, height = pan:GetSize()

	-- wat??
	if not TIMER.HasMapList then 
		TIMER.AwaitingList = true 
		NETWORK:StartNetworkMessage(false, "GetMapList")
		pan.loading = BuildLoading(pan)
		return
	end

	pan.themec = UI.mainmenu.themec
	pan.ScrollPan = UI:ScrollablePanel(pan, 0, 39, width, height - 44, {
		{"Name", "Tier", "Plays"}, 4, {0, 2, 3}
	})

	-- add the maps to the scroll pan 
	for id, map in pairs(TIMER.MapList) do 
		UI:MapScrollable(pan.ScrollPan, {map.name, tonumber(map.tier), tonumber(map.plays)}, {4, {0, 2, 3}}, Nominate(map.name))
	end

	-- searchy boxy 
	local col = UI_PRIMARY
	col = Color(col.r + 10, col.g + 10, col.b + 10, 255)
	pan.Search = UI:SearchBox(pan, width - 200, 0, 200, 30, false, col, function(value)
		-- Clear current
		for k, v in pairs(pan.ScrollPan.contents) do 
			v:Remove()
			pan.ScrollPan.contents[k] = nil
		end

		-- Add 
		for k, v in pairs(TIMER.MapList) do 
			local mapname = v.name
			if (string.find(mapname, value)) then 
				UI:MapScrollable(pan.ScrollPan, {v.name, tonumber(v.tier), tonumber(v.plays)}, {
					4, {0, 2, 3}
				}, Nominate(v.name))
			end
		end

		-- Just because it bugs me
		local base = pan.ScrollPan
		if (#base.contents * 40) > base:GetTall() then 
			base.scrollbar = true
		else
			base.scrollbar = false 
		end
	end)

	-- helper text 
	function pan:Paint()
		draw.SimpleText("You can sort by selecting an option on the top row.", "ui.mainmenu.button", 0, 15, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

NETWORK:GetNetworkMessage("MapList", function(_, data)
	TIMER.MapList = data 
	TIMER.HasMapList = true

	if TIMER.WRMapList then 
		WRLISTADDFUNC()
	elseif TIMER.AwaitingList then 
		TIMER.AwaitingList = false 
		UI.mainmenu.sidepanel:SetOptions(SELECTION_GAMEPLAY)
		UI.mainmenu.selection.selected = UI.mainmenu.selection.selections[2]
		UI.mainmenu.sidepanel.options[2].o(UI.mainmenu.base)
		UI.mainmenu.sidepanel.selected = UI.mainmenu.sidepanel.options[2]
	end
end)