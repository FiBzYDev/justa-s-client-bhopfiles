-- "gamemodes\\bhop\\gamemode\\userinterface\\numbered\\ui_replay.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- User Interface module ("Replays")
-- by justa

-- Data 
local data = {}
local panel = false

local function style_select(mode, style)
	return function()
		UI:SendCallback("replayselect", {mode, style})
		panel:Exit()
		panel = nil
	end
end

local function translate(mode)
	return TIMER:TranslateMode(mode) == "" and "Normal" or TIMER:TranslateMode(mode)
end

-- Mode select
function mode_select2(mode)
	return function()
		-- Update the title, lets be fancy
		panel:UpdateTitle((mode < 0 and "Segmented " or "") .. translate(math.abs(mode)) .. " replays")

		-- We need to now pick our style
		panel.options = {}

		-- Force next prev 
		panel:ForceNextPrevious()

		-- Update our options again 
		local options = {}
		for k, v in pairs(botdata[mode]) do 
			table.insert(options, {["name"] = TIMER:TranslateStyle(k) .. " (" .. TIMER:GetFormatted(v.time) .. " by ".. v.name .. ")", ["function"] = style_select(mode, k)})
		end
		panel.options = options 

		-- If we're tryna go back from this menu we wanna basically revert back to the mode menu.
		function panel:OnPrevious(isMax)
			-- Okay so are we maxed?
			if isMax then 
				panel:goto_start()
			end

			self:UpdateLongestOption()
		end

		-- Refresh
		panel:UpdateLongestOption()
	end
end

local function goto_start(panel)
	local options = {}
	for i = 1, (#botdata) do
		if not botdata[i] then continue end 
		info = botdata[i] 
		table.insert(options, {["name"] = translate(i), ["function"] = mode_select2(i)})
	end
	for i = -20, 0 do
		if not botdata[i] then continue end 
		info = botdata[i] 
		table.insert(options, {["name"] = "Segmented " .. translate(math.abs(i)), ["function"] = mode_select2(i)})
	end

	panel.options = options 
	panel:UpdateLongestOption()
	panel:UpdateTitle("Replays")
	panel:RemoveNextPrevious()
end

-- Main function 
local function ToggleReplayMenu()
	-- If the panel is already open we're just going to close it.
	if (panel) then 
		panel:Exit()
		panel = nil
		return 
	end

	-- We need to set up our options. 
	local options = {}
	for i = 1, (#botdata) do
		if not botdata[i] then continue end 
		info = botdata[i] 
		table.insert(options, {["name"] = translate(i), ["function"] = mode_select2(i)})
	end
	for i = -20, 0 do
		if not botdata[i] then continue end 
		info = botdata[i] 
		table.insert(options, {["name"] = "Segmented " .. translate(math.abs(i)), ["function"] = mode_select2(i)})
	end

	-- Let's create our panel 
	panel = UI:NumberedUIPanel("Replays", unpack(options))
	panel.goto_start = goto_start

	-- On close
	function panel:OnExit()
		panel = false
	end
end

-- Listener
UI:AddListener("replay", function(_, data)
	botdata = data[1]

	if (botdata[1]) and (botdata[1][1]) then 
		botdata[1][1] = nil 
		if (table.Count(botdata[1]) == 0) then 
			botdata[1] = nil 
		end 
	end

	ToggleReplayMenu()
end)
