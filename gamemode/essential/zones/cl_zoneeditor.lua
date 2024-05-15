-- "gamemodes\\bhop\\gamemode\\essential\\zones\\cl_zoneeditor.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--[[-------------------------------------------------------------------------
	Bunny Hop 
		by: justa (www.steamcommunity.com/id/just_adam)

		file: essential/zones/cl_zoneeditor.lua
		desc: The Zone Editor administrators can use.
---------------------------------------------------------------------------]]

-- Local Player
local lp = LocalPlayer

-- Translate Zone
local translated = {
	["start"] = "Start Zone",
	["end"] = "End Zone",
	["bStart"] = "Bonus Start Zone",
	["bEnd"] = "Bonus End Zone",
	["anticheat"] = "Anticheat Zone",
	["nanticheat"] = "Normal Anticheat Zone",
	["banticheat"] = "Bonus Anticheat Zone",
	["tpzonestart"] = "Teleport Entrance Zone",
	["tpzoneend"] = "Teleport Exit Zone",
	--["booster"] = "Booster Zone"
}
local function TranslateZone(zoneid)
	return translated[zoneid]
end

-- Table
ZEdit = ZEdit or {}
ZEdit.selected = ZEdit.selected or "start"
ZEdit.List = ZEdit.List or {}
ZEdit.Ents = ZEdit.Ents or {}

-- Options for 'Select Zone'
ZEdit.SelectZoneOptions = {
	{"start"},
	{"end"},
	{"bStart"},
	{"bEnd"},
	{"anticheat"},
	{"nanticheat"},
	{"banticheat"},
	{"tpzonestart"},
	{"tpzoneend"},
	--{"booster"}
}

ZEdit.snaptogrid = 1 
ZEdit.snaptogrid_options = {1, 2, 4, 8, 16, 32, 64}
ZEdit.placementmode = 1 
ZEdit.offset = 0

-- Key delay/limit
local keydelay = 0.2
local keylimit = false
local col = Color(255, 130, 0)

-- Math!
local min, max = math.min, math.max

function ZEdit:ChangeSnap()
	ZEdit.snaptogrid = ZEdit.snaptogrid + 1
	if ZEdit.snaptogrid > table.Count(ZEdit.snaptogrid_options) then 
		ZEdit.snaptogrid = 1 
	end 
end 

function ZEdit:GetPos()
	local p = lp():GetEyeTrace().HitPos
	if ZEdit.placementmode == 2 then 
		p = lp():GetPos()
	end 

	if ZEdit.snaptogrid == 1 then 
		p.y = p.y 
		p.x = p.x + ZEdit.offset
	else 
		local o = ZEdit.snaptogrid_options[ZEdit.snaptogrid]
		p.x = p.x - (p.x % o) + ZEdit.offset
		p.y = p.y - (p.y % o) + ZEdit.offset
	end 

	return p
end 

function ZEdit:StartPlacements()
	ZEdit.StartPlacement = ZEdit:GetPos()
end 

-- Finish Placement
function ZEdit:FinishPlacement(ePos)
	if (not ZEdit.Placing) then
		return UTIL:AddMessage("Admin", "You are not placing a zone and thus cannot finish a zone placement.")
	end

	-- We're no longer placing something.
	ZEdit.Placing = false

	-- Positions
	local sPos = ZEdit.StartPlacement
	local mins = Vector( min(sPos.x, ePos.x), min(sPos.y, ePos.y), min(sPos.z, ePos.z) )
	local maxs = Vector( max(sPos.x, ePos.x), max(sPos.y, ePos.y), max(sPos.z + 128, sPos.z + 128) ) 

	-- If they're trying to get a different zone height.
	if ZEdit.HeightAdjust then 
		maxs = Vector( max(sPos.x, ePos.x), max(sPos.y, ePos.y), max(sPos.z, ePos.z) ) 
	end

	ZEdit.StartPlacement = false 

	-- Now we send this to the server.
	NETWORK:StartNetworkMessage(false, "admin.zones", "newzone", {ZEdit.selected, sPos, ePos, mins, maxs, ZEdit.OPTION or ""})
end

-- Draw function
function ZEdit:Draw()
	-- Title
	draw.SimpleText("Zone Management Tool", "hud.zedit.title", 14, 10, col, TEXT_ALIGN_LEFT)

	-- Function to draw an option nicely
	local options = {} 
	function draw_option(text, c, cust)
		local height = 36 + #options * 24
		draw.SimpleText((cust or (#options + 1)) .. " | " .. text, "hud.zedit", 14, height + 10, c or color_white, TEXT_ALIGN_LEFT)
		table.insert(options, text)
	end

	-- Draw our options on the top left hand of the screen.
	draw_option("Select Zone", self.SelectZone and col)
	draw_option("Place New Zone (" .. TranslateZone(self.selected) .. ")", self.Placing and col)
	draw_option("Cancel Placement")
	draw_option("Zone Height Adjustment", self.HeightAdjust and col)
	draw_option("Snap to Grid: " .. ZEdit.snaptogrid_options[ZEdit.snaptogrid] .. "px")
	draw_option("Placement Mode: " .. (ZEdit.placementmode == 1 and "Click" or "Player Position"))
	draw_option("Remove Zone")
	draw_option("Set zone offset: "..ZEdit.offset.." units")
	draw_option("Exit Management Tool", color_white, "0")

	-- Setup
	local funcs = {}

	-- Event 
	local function press_event()
		local key = -1

		-- Get current key down
		for id = 1, 10 do
			if input.IsKeyDown(id) then
				key = id - 1
				break
			end
		end

		-- Check if player is typing
		if (lp and IsValid(lp()) and lp():IsTyping()) or gui.IsConsoleVisible() then
			key = -1
		end

		-- Call custom function set by the option
		if (key > 0) and (key <= 8) and (not keylimit) and (not ZEdit.SelectZone) and (not ZEdit.RemoveZone) then
			funcs[key]()

			-- Reset delay
			keylimit = true
			timer.Simple(keydelay, function()
				-- Bug fix
				keylimit = false
			end)
		elseif key == 0 and (not ZEdit.SelectZone) and (not ZEdit.RemoveZone) then 
			funcs[0]()
		end
	end

	-- Select Zone
	funcs[1] = function()
		-- Select Zone already open, so we don't open it.
		if ZEdit.SelectZone then return end 

		-- If we're in something else
		if ZEdit.Placing then 
			return UTIL:AddMessage("Admin", "You must first stop placing a zone before changing your selection.")
		end

		-- Turn it on
		ZEdit.SelectZone = UI:ScrollableUIPanel("Select a Zone", "Select a zone to select it.", nil, {
			{"Zone"}, 1, {0}
		}, true)

		-- Pretty Options
		local pOptions = {}
		local pOptionsID = {}
		for k, v in pairs(ZEdit.SelectZoneOptions) do 
			local translated = TranslateZone(v[1])
			table.insert(pOptions, {translated})
			pOptionsID[translated] = v[1]
		end

		-- Add
		for k, v in pairs(pOptions) do 
			UI:MapScrollable(ZEdit.SelectZone.ScrollPanel, v, {1, {0}}, function()
				if (pOptionsID[v[1]] == "bStart") or (pOptionsID[v[1]] == "bEnd") then 
					UI:SimpleInputBox("Please input the Bonus ID (default = 1)", function(op)
						-- Check
						if (not tonumber(op)) or (tonumber(op) < 1) then 
							UTIL:AddMessage("Admin", "Invalid Bonus ID entered, please try again.")
							return
						end

						ZEdit.OPTION = tonumber(op)
						ZEdit.selected = pOptionsID[v[1]]
						ZEdit.SelectZone:Exit()
					end)
				else 
					ZEdit.selected = pOptionsID[v[1]]
					ZEdit.SelectZone:Exit()
				end
			end)
		end

		-- On Exit
		ZEdit.SelectZone.OnExit = function(self)
			ZEdit.SelectZone = false
			gui.EnableScreenClicker(false)
		end
	end

	-- Place New Zone
	funcs[2] = function()
		if (ZEdit.Placing) then 
			return UTIL:AddMessage("Admin", "You are already placing a zone.")
		end

		-- Start placement
		UTIL:AddMessage("Admin", "You are now placing a zone, click once to start your placement and click again to finish it.")
		ZEdit.Placing = true
	end

	-- Enable height adjust
	funcs[4] = function()
		ZEdit.HeightAdjust = (not ZEdit.HeightAdjust)
		UTIL:AddMessage("Admin", "You have ", ZEdit.HeightAdjust and "enabled" or "disabled", col, " Zone Height Adjustment", color_white, ".")
	end

	-- Cancel Placement
	funcs[3] = function()
		if (not ZEdit.Placing) then
			return UTIL:AddMessage("Admin", "You are not placing a zone and thus cannot cancel a zone placement.")
		end

		ZEdit.Placing = false
		ZEdit.StartPlacement = false 
		UTIL:AddMessage('Admin', 'Your zone placement has been cancelled.')
	end

	-- Snap 
	funcs[5] = function()
		ZEdit:ChangeSnap()
		local option = ZEdit.snaptogrid_options[ZEdit.snaptogrid]
		UTIL:AddMessage("Admin", "The editor will now snap every " .. option .. " pixels.")
	end

	funcs[6] = function() 
		if ZEdit.placementmode == 1 then 
			ZEdit.placementmode = 2 
		else 
			ZEdit.placementmode = 1 
		end 

		local p = ZEdit.placementmode == 1 and "Click" or "Player Position"
		UTIL:AddMessage("Admin", "The editor will now go by " .. p)
	end 

	funcs[7] = function()
		ZEdit.RemoveZone = UI:ScrollableUIPanel("Remove Zone", "Select a zone to remove it.", nil, {
			{"ZoneID", "Zone Type"}, 2, {0, 1}
		}, true)

		for k, v in pairs(ZEdit.List) do 
			UI:MapScrollable(ZEdit.RemoveZone.ScrollPanel, {k, v[3]}, nil, function()
				UI:SimpleInputBox("Confirm ZoneID", function(op)
					if not tonumber(op) then return end 

					if tonumber(op) == k then 
						NETWORK:StartNetworkMessage(false, "admin.removezone", k)
					end 

					ZEdit.RemoveZone:Exit()
				end)
			end)
		end 

		ZEdit.RemoveZone.OnExit = function(self)
			ZEdit.RemoveZone = false
			gui.EnableScreenClicker(false)
		end
	end 

	funcs[8] = function()
		ZEdit.offset = (ZEdit.offset == 0 and 1 or 0)
		UTIL:AddMessage("Admin", "Offset set to "..ZEdit.offset.." units.")
	end

	-- Exit
	funcs[0] = function()
		ZEdit.Placing = false
		ToggleZoneEditor()
	end

	-- Yep
	press_event()
end

-- Drawing a zone
local LastClick = 0 

function MousePressed()
	if input.IsMouseDown(MOUSE_LEFT) and LastClick < CurTime() then 
		LastClick = CurTime() + 0.5 
		return true 
	else 
		return false 
	end 
end 

hook.Add("PostDrawOpaqueRenderables", "ZEdit.Zones", function()
	if ZEdit.Placing and MousePressed() then 
		if not ZEdit.StartPlacement then 
			ZEdit:StartPlacements()
		else 
			ZEdit:FinishPlacement(ZEdit:GetPos())
		end 
	elseif ZEdit.Placing then
		local sPos = ZEdit.StartPlacement or ZEdit:GetPos()
		local ePos = ZEdit:GetPos()
		local mins = Vector( min(sPos.x, ePos.x), min(sPos.y, ePos.y), min(sPos.z, ePos.z) )
		local maxs = Vector( max(sPos.x, ePos.x), max(sPos.y, ePos.y), max(sPos.z + 128, sPos.z + 128) ) 

		-- If they're trying to get a different zone height.
		if ZEdit.HeightAdjust then 
			maxs = Vector( max(sPos.x, ePos.x), max(sPos.y, ePos.y), max(sPos.z, ePos.z) ) 
		end

		UTIL:DrawZone(mins, maxs, TIMER.ZoneColours[ZEdit.selected])
	end

	if ZEdit.state then 
		local recordsAng = LocalPlayer():EyeAngles()
		recordsAng:RotateAroundAxis( LocalPlayer():EyeAngles():Right(), 90 )
		recordsAng:RotateAroundAxis( LocalPlayer():EyeAngles():Forward(), 90 )
		recordsAng.roll = 90

		for k, v in pairs(ZEdit.List) do 
			local pos = (v[1] + v[2]) / 2

			cam.Start3D2D( pos, recordsAng, 0.10 )
			
			draw.SimpleText("Zone ID: " .. k, "zedit.cam", 0, -50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Zone Type: " .. v[3], "zedit.cam", 0, 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cam.End3D2D()
		end 
	end 
end)

-- Toggling it 
function ToggleZoneEditor()
	ZEdit.StartPlacement = false 
	ZEdit.state = (not ZEdit.state)
	UTIL:AddMessage("Admin", "You have ", ZEdit.state and "entered" or "exited", " the ", col, "Zone Management Tool", color_white, ".")

	if (ZEdit.state) then 
		UTIL:AddMessage("Admin", "Your timer has been permanently disabled until this tool is disabled.")

		NETWORK:StartNetworkMessage(false, "admin.getzones")
	else
		UTIL:AddMessage('Admin', 'Your timer has been restored.')
	end
end

NETWORK:GetNetworkMessage("admin.retrievezones", function(_, data)
	ZEdit.List = data[1]
end)

-- Getting stuff from the server.
NETWORK:GetNetworkMessage("ZEdit", function(_, arguments)
	local id = arguments[1]

	-- Toggling Zone Editor
	if (id == "toggle") then 
		ToggleZoneEditor()
	end
end)

NETWORK:GetNetworkMessage("zones.avaliable", function(_, data)
	local modes = data[1]
	TIMER.modes = modes 

	TIMER.zones = {}
	for k, v in pairs(ents.FindByClass("ent_timer")) do 
		table.insert(TIMER.zones, v)
	end 
end)