-- "gamemodes\\bhop\\gamemode\\userinterface\\cl_ui.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- UI API
-- by Justa

-- Theme 
local theme = theme.getTheme(THEME_UI).settings.scheme 

UI_PRIMARY = theme["Primary"]
UI_SECONDARY = theme["Secondary"]
UI_TRI = theme["Tri"]
UI_ACCENT = theme["Accent"]
UI_TEXT1 = theme["Main Text"]
UI_TEXT2 = theme["Secondary Text"]
UI_HIGHLIGHT = theme["Highlight"]

-- Allow changing of these variables 
hook.Add("theme.update", "UpdateUIVariables", function(type, theme)
	theme = theme.settings.scheme 

	UI_PRIMARY = theme["Primary"]
	UI_SECONDARY = theme["Secondary"]
	UI_TRI = theme["Tri"]
	UI_ACCENT = theme["Accent"]
	UI_TEXT1 = theme["Main Text"]
	UI_TEXT2 = theme["Secondary Text"]
	UI_HIGHLIGHT = theme["Highlight"]
end)

-- Start to initialize the UI api here
-- I do it this way so it's just nicely organised.
UI = UI or {}
UI.ActiveNumberedUIPanel = false

-- LocalPlayer
local lp = LocalPlayer

-- NumberedUI
surface.CreateFont("hud.numberedui.css1", {font = "Roboto", size = 19, weight = 500, antialias = true})
surface.CreateFont("hud.numberedui.css2", {font = "Roboto", size = 18, weight = 500, antialias = true})
surface.CreateFont("hud.numberedui.kawaii1", {font = "Open Sans", size = 19, weight = 500, antialias = true})

-- Scoreboard
surface.CreateFont("hud.subinfo", {font = "Tahoma", size = 12, weight = 300, antialias = true})

-- Zone Editor
surface.CreateFont("hud.zedit.title", {font = "Roboto", size = 28, weight = 0, antialias = true, italic = false})
surface.CreateFont("hud.zedit", {font = "Roboto", size = 19, weight = 0, antialias = true, italic = false})

-- Generic
surface.CreateFont("hud.smalltext", {font = "Roboto", size = 14, weight = 0, antialias = true})
surface.CreateFont("hud.subtitle", {font = "Roboto", size = 18, weight = 0, antialias = true, italic = false})
surface.CreateFont("hud.subtitleverdana", {font = "Verdana", size = 14, weight = 0, antialias = true, italic = false})
surface.CreateFont("hud.subinfo2", {font = "Roboto", size = 10, weight = 0, antialias = true})
surface.CreateFont("hud.subinfo", {font = "Roboto", size = 12, weight = 300, antialias = true})
surface.CreateFont("hud.simplefont", {font = "Roboto", size = 21, weight = 900, antialias = true})

-- Fonts
surface.CreateFont("hud.title", {font = "coolvetica", size = 20, weight = 100, antialias = true})
surface.CreateFont("hud.title2.1", {font = "Verdana", size = 14, weight = 0, antialias = true})
surface.CreateFont("hud.smalltext", {font = "Roboto", size = 14, weight = 0, antialias = true})
surface.CreateFont("ascii.font", {font = "", size = 9, weight = 0, antialias = true})
surface.CreateFont("hud.title2", {font = "Roboto", size = 16, weight = 0, antialias = true})
surface.CreateFont("hud.credits", {font = "Tahoma", size = 12, weight = 100, antialias = true})
surface.CreateFont("zedit.cam", {font = "Roboto", size = 100, weight = 300, antialias = true})

surface.CreateFont("ui.mainmenu.close", {size = 20, weight = 1000, font = "Verdana Regular"})
surface.CreateFont("ui.mainmenu.button", {size = 18, weight = 500, font = "Roboto"})
surface.CreateFont("ui.mainmenu.button-bold", {size = 18, weight = 600, font = "Roboto"})
surface.CreateFont("ui.mainmenu.button2", {size = 19, weight = 500, font = "Roboto"})
surface.CreateFont("ui.mainmenu.desc", {size = 17, weight = 500, font = "Roboto", additive=true})
surface.CreateFont("ui.mainmenu.title", {size = 20, weight = 500, font = "Roboto"})
surface.CreateFont("ui.mainmenu.title2", {size = 20, weight = 500, font = "Roboto"})

--[[-------------------------------------------------------------------------

	Numbered UI Panel
	This is the panel with numbers (1-7) to chose through.

	Usage:
		Defining:
 			panel_obj = UI:NumberedUIPanel(String title, Table options)

	 		options (example):
	 			Argument 1 (table):
	 				"name": "Name that will be displayed"
	 				"function": function()
	 								print("Foo bar")
	 							end
	 				"bool": true (default value)
	 				"customBool": {"Yay", "Nah"} (true/false of bool set above ^)

	Sub Functions
		NumberedUIPanel:UpdateTitle(String title) -> Updates the title of any given panel.
		NumberedUIPanel:UpdateOption(Int id, String name=nil, Color color=nil, Function func=nil) -> Updates an option, set value to nil to keep a part of an option the same.
		NumberedUIPanel:OnThink() -> Called when ever 'Think' is called, overwrite to use.
		NumberedUIPanel:SelectOption(Int optionId) -> Selects the option just as if a player was to.
		NumberedUIPanel:UpdateOptionBool(Int optionId) -> Reverses the state of the bool set to the optionId (true to false, false to true)
		NumberedUIPanel:SetCustomDelay(Float delay) -> Sets a custom key delay in seconds. (default = 0.25 seconds)
		NumberedUIPanel:Exit() -> Exits the numbered ui panel.
		NumberedUIPanel:ForceNextPrevious() -> Forces UI Panel to have a next and previous button without the need of 7 options.
		NumberedUIPanel:UpdateLongestOption() -> Updates panel width to the longest options width, always call this when updating options.
		NumberedUIPanel:OnNext() -> Called when the 'next' button is called, overwrite to use.

---------------------------------------------------------------------------]]

function UI:NumberedUIPanel(title, ...)
	-- Options
	local options = {...}

	-- Let's create our panel
	local pan = vgui.Create("DPanel")

	-- Page options
	pan.hasPages = #options > 7 and true or false
	pan.page = 1

	-- Positioning and Sizing
	local width = 200
	local height = 75 + ((pan.hasPages and 9 or #options) * 20)
	pan.trueHeight = height
	local xPos, yPos = 20, (ScrH() / 2) - (height / 2)

	-- Set up
	pan:SetSize(width, height)
	pan:SetPos(xPos, yPos)
	pan.title = title
	pan.options = options

	-- Our theme
	local theme, id = Theme:GetPreference("NumberedUI")
	pan.themec = theme["Colours"]
	pan.themet = theme["Toggles"]
	pan.themeid = id

	-- Remove other numbered panel if open
	if (self.ActiveNumberedUIPanel) then
		self.ActiveNumberedUIPanel:Exit()
	end

	-- Check if there's a toggleable boolean in the options, and if there is set a prefix.
	-- Also lets get the largest option by name length here as well.
	local largest = ""
	for index, option in pairs(pan.options) do
		if (option.bool ~= nil) then
			local o1 = option.customBool and option.customBool[1] or "ON"
			local o2 = option.customBool and option.customBool[2] or "OFF"
			option.defname = option.name
			option.name = option.name .. ": " .. (option.bool and o1 or o2) .. " "
		end

		largest = (#option.name > #largest) and option.name or largest
	end

	-- Get width of largest option
	surface.SetFont(pan.themeid == "nui.css" and "hud.numberedui.css2" or "hud.numberedui.kawaii1")
	local w, y = surface.GetTextSize(largest)

	-- Set the panels width larger than default if the text width goes beyond it.
	if (w > 180) then
		pan:SetWide(w + 40)
	end

	-- Paint the panel
	-- Todo: Themes, the style should be changeable
	pan.Paint = function(self, width, height)
		-- Our theme
		local theme, id = Theme:GetPreference("NumberedUI")
		self.themec = theme["Colours"]
		self.themet = theme["Toggles"]
		self.themeid = id

		-- Options we gotta print
		local start = 1 + ((self.page - 1) * 7)
		local finish = ((self.page - 1) * 7) + 7

		-- Counter Strike: Source 
		if (self.themeid == "nui.css") then 
			-- Colours
			local base = self.themec["Primary Colour"]
			local title = self.themec["Title Colour"]
			local text = color_white

			-- Print the box
			draw.RoundedBox(16, 0, 0, width, height, base)

			-- Title
			draw.SimpleText(self.title, "hud.numberedui.css1", 10, 15, title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Options
			local i = 1
			for index = start, finish do
				-- No option
				if (not self.options[index]) then break end

				local option = self.options[index]
				draw.SimpleText(i .. ". " .. option.name, "hud.numberedui.css2", 10, 25 + (i * 20), option.col and option.col or text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				i = i + 1
			end

			-- Index
			local index = self.hasPages and 7 or #self.options

			-- Exit
			draw.SimpleText("0. Exit", "hud.numberedui.css2", 10, 35 + ((index + (self.hasPages and 3 or 1)) * 20), title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Pages?
			if (self.hasPages) then
				draw.SimpleText("8. Previous", "hud.numberedui.css2", 10, 35 + ((index + 1) * 20), title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText("9. Next", "hud.numberedui.css2", 10, 35 + ((index + 2) * 20), title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		elseif (self.themeid == "nui.kawaii") then
			-- Colours
			local base = self.themec["Primary Colour"]
			local base2 = self.themec["Secondary Colour"]
			local text = self.themec["Text Colour"]
			local title = self.themec["Title Colour"]

			-- Box
			surface.SetDrawColor(base)
			surface.DrawRect(0, 0, width, height)

			-- Boom boom boom boom
			surface.SetDrawColor(base2)
			surface.DrawRect(0, 0, width, 30)

			-- Title
			draw.SimpleText(self.title, "hud.title", 10, 15, title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Print options
			local i = 1
			for index = start, finish do
				-- No option
				if (not self.options[index]) then break end

				local option = self.options[index]
				draw.SimpleText(i .. ". " .. option.name, "hud.numberedui.kawaii1", 10, 25 + (i * 20), option.col and option.col or text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				i = i + 1
			end

			-- Index
			local index = self.hasPages and 7 or #self.options

			-- Exit
			draw.SimpleText("0. Exit", "hud.numberedui.kawaii1", 10, 35 + ((index + (self.hasPages and 3 or 1)) * 20), text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Pages?
			if (self.hasPages) then
				draw.SimpleText("8. Previous", "hud.numberedui.kawaii1", 10, 35 + ((index + 1) * 20), text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText("9. Next", "hud.numberedui.kawaii1", 10, 35 + ((index + 2) * 20), text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end

	-- Think
	pan.keylimit = false
	pan.Think = function(self)
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
		if (key > 0) and (key <= 9) and (not self.keylimit) then
			if (key == 8) and (self.hasPages) then
				if (self.page == 1) then 
					self:OnPrevious(self.page == 1)
				else
					self.page = (self.page == 1 and 1 or self.page - 1)
					self:OnPrevious()
				end
			elseif (key == 9) and (self.hasPages) then
				local max = math.ceil(#self.options / 7)
				self.page = self.page == max and self.page or self.page + 1
				self:OnNext(self.page == max)
				self:UpdateLongestOption()
			else
				local pageAddition = (self.page - 1) * 7
				if (not self.options[key + pageAddition]) or (not self.options[key + pageAddition]["function"]) then
					return end

				self.options[key + pageAddition]["function"]()
			end

			-- Reset delay
			self.keylimit = true
			timer.Simple(self.keydelay or 0.25, function()
				-- Bug fix
				if not IsValid(self) then return end
				self.keylimit = false
			end)
		elseif (key == 0) then
			self:OnExit()
			self:Exit()
		end

		-- Call an extra think function if one is set
		self:OnThink()
	end

	-- Update Title
	function pan:UpdateTitle(title)
		self.title = title
	end

	-- Update option
	function pan:UpdateOption(optionId, title, colour, f)
		if (not self.options[optionId]) then
			return end

		if (title) then
			self.options[optionId]["name"] = title
		end

		if (colour) then
			self.options[optionId]["col"] = colour
		end

		if (f) then
			self.options[optionId]["function"] = f
		end
	end

	-- Update option bool
	function pan:UpdateOptionBool(optionId)
		if (not self.options[optionId]) or (self.options[optionId].bool == nil) then
			return end

		self.options[optionId].bool = (not self.options[optionId].bool)

		-- Name
		local o1 = self.options[optionId].customBool and self.options[optionId].customBool[1] or "ON"
		local o2 = self.options[optionId].customBool and self.options[optionId].customBool[2] or "OFF"
		self.options[optionId].name = self.options[optionId].defname .. ": [" .. (self.options[optionId].bool and o1 or o2) .. "] "
	end

	-- On Think
	-- This should just be overwritten if you need to use it.
	function pan:OnThink()
	end

	-- Exit
	function pan:Exit()
		UI.ActiveNumberedUIPanel = false
		self:Remove()
		pan = nil
	end

	-- On Exit
	function pan:OnExit()
	end

	-- Select option
	function pan:SelectOption(id)
		self.options[id]["function"]()
	end

	-- Set custom delay
	function pan:SetCustomDelay(delay)
		self.keydelay = delay
	end

	-- Force next/previous
	function pan:ForceNextPrevious(bool)
		self.hasPages = true
		self:SetTall(75 + 180)

		local posx, posy = self:GetPos()
		self:SetPos(posx, ScrH() / 2 - ((75 + 180) / 2))
	end

	-- Revert 
	function pan:RemoveNextPrevious()
		self.hasPages = false 
		self:SetTall(self.trueHeight)
		local posx, posy = self:GetPos()
		self:SetPos(posx, ScrH() / 2 - ((self.trueHeight) / 2))
	end

	-- Update longest option
	function pan:UpdateLongestOption()
		local largest = ""

		local start = 1 + ((self.page - 1) * 7)
		local finish = ((self.page - 1) * 7) + 7
		for index = start, finish do
			if (not self.options[index]) then 
				break 
			end

			local option = self.options[index]
			largest = (#option.name > #largest) and option.name or largest
		end

		-- Get width of largest option
		surface.SetFont(self.themeid == "nui.css" and "hud.numberedui.css2" or "hud.numberedui.kawaii1")
		local width_largest = select(1, surface.GetTextSize(largest))
		print(width_largest)

		-- Set the panels width larger than default if the text width goes beyond it.
		if (width_largest > 160) then
			self:SetWide(width_largest + 40)
		end
	end

	-- On Next
	-- This should be overwritten if you need to use it
	function pan:OnNext()
	end

	function pan:OnPrevious()
		self:UpdateLongestOption()
	end

	-- Set Active Numbered UI Panel
	-- This is important, as if another numbered UI panel was opened, there would be overlap.
	self.ActiveNumberedUIPanel = pan

	-- Return
	return pan
end

-- Base panel
function UI:BasePanel(width, height, x, y, p, shouldntPopup, base)
	local ui = vgui.Create(base or "EditablePanel", p or false)
	ui:SetSize(width, height)

	if not shouldntPopup then 
		ui:MakePopup()
	end 

	-- Center or setpos
	if (not x) or (not y) then
		ui:Center()
	else 
		ui:SetPos(x, y)
	end

	-- Paint
	ui.theme = Theme:GetPreference("UI") 
	ui.themec, ui.themet = ui.theme["Colours"], ui.theme["Toggles"]
	function ui:Paint(width, height)
		-- Update values
		self.theme = Theme:GetPreference("UI") 
		self.themec, self.themet = self.theme["Colours"], self.theme["Toggles"]

		-- Colours
		local primary = self.themec["Primary Colour"]
		local outlines = self.themet["Outlines"]
		local outline_col = self.themec["Outlines Colour"]

		surface.SetDrawColor(primary)
		surface.DrawRect(0, 0, width, height)

		-- Outlines?
		if (outlines) then
			surface.SetDrawColor(outline_col)
			surface.DrawOutlinedRect(0, 0, width, height)
		end

		-- Painting custom
		self:CPaint(width, height)
	end

	-- To be overridden 
	function ui:CPaint(width, height)
	end

	-- Return the UI module
	return ui
end

-- Draw banner 
function UI:DrawBanner(panel, title)
	-- Old func
	local _Paint = panel.Paint 

	-- New func
	function panel:Paint(width, height)
		_Paint(self, width, height)

		-- Banner
		surface.SetDrawColor(self.themec["Tri Colour"])
		surface.DrawRect(0, 0, width, 30)

		-- Outlines
		if (self.themet["Outlines"]) then 
			surface.SetDrawColor(self.themec["Outlines Colour"])
			surface.DrawOutlinedRect(0, 0, width, 30)
		end

		-- Title
		draw.SimpleText(title, "hud.title", 10, 6, self.themec["Text Colour 2"], TEXT_ALIGN_LEFT)
	end
end

-- Close button 
function UI:AddCloseButton(panel)
	-- Old func
	local _Paint = panel.Paint 

	-- New func
	function panel:Paint(width, height)
		_Paint(self, width, height)

		-- Our close button
		draw.SimpleText("x", "hud.title", width - 20, 5, self.themec["Text Colour 2"], TEXT_ALIGN_LEFT)
	end

	-- On exit
	function panel:OnExit()
		gui.EnableScreenClicker(false)
	end

	-- Invis button
	panel._close = panel:Add("DButton")
	panel._close:SetSize(15, 15)
	panel._close:SetPos(panel:GetWide() - 20, 8)
	panel._close:SetText("")
	panel._close.Paint = function() end
	panel._close.OnMousePressed = function(self)
		panel:OnExit()
		panel:Remove()
		panel = nil 
	end
end

-- Text Box
function UI:TextBox(parent, x, y, width, height, outlines, bg)
	-- Text box
	local textbox = parent:Add("DTextEntry")
	textbox.col = UI_TEXT1
	textbox:RequestFocus()
	textbox:SetSize(width, height)

	local xP, yP = parent:GetPos()
	textbox:SetPos(x,y)
	textbox:SetFont("ui.mainmenu.button")

	-- Paint
	function textbox:Paint(width, height)
		if (bg) then 
			surface.SetDrawColor(bg)
			surface.DrawRect(0, 0, width, height)
		end

		if (outlines) then 
			-- todo theme outline
			surface.SetDrawColor(UI_TEXT1)
			surface.DrawOutlinedRect(0, 0, width, height)
		end 

		self:DrawTextEntryText(self.col, Color(30, 130, 255), Color(255, 255, 255))
		self:CPaint(width, height)
	end

	function textbox:CPaint() end

	-- Return 
	return textbox
end

-- Scrollable Panel
function UI:ScrollablePanel(parent, x, y, width, height, data)
	-- Scroll
	local ui = parent:Add("DScrollPanel")

	-- Top
	local top = parent:Add("DPanel")
	top:SetPos(x, y)
	top:SetSize(width, 20)

	-- Paint
	function top:Paint(width, height)
		local col = UI_TRI
		local text = UI_TEXT2
		surface.SetDrawColor(Color(100,100,100))
		surface.DrawRect(0, height - 2, width, 1)
		--surface.DrawRect(0, 0, width, height)

		-- Draw titles
		for k, v in pairs(data[1]) do 
			local x = (width / data[2]) * data[3][k]

			local align = TEXT_ALIGN_LEFT
			if k == #data[1] and (#data[1] ~= 1) then 
				align = TEXT_ALIGN_RIGHT
				x = width - (ui.scrollbar and 16 or 0) - 20
			end 

		    -- Map name
			draw.SimpleText(v, "hud.smalltext",  10+x, 0, text, align, TEXT_ALIGN_TOP)
		end
	end

	local sortbutts = {}
	local lastsorted = {1, 0}
	for k, v in pairs(data[1]) do 
		local x = (width / data[2]) * data[3][k]

		sortbutts[k] = top:Add("DButton")
		sortbutts[k]:SetPos(x, 0)
		sortbutts[k]:SetWide(100)
		sortbutts[k].Paint = function() end
		sortbutts[k]:SetText("")
		sortbutts[k].OnMousePressed = function()
			if ui.nosort then return end
			-- remove current
			local copied = table.Copy(ui.contents)
			for k, v in pairs(ui.contents) do 
				ui.contents[k]:Remove()
				ui.contents[k] = nil 
			end

			-- sort 
			if (lastsorted[1] == k) and (lastsorted[2] == 0) then 
				table.sort(copied, function(a, b)
					lastsorted = {k, 1}
					return (tonumber(a.data[k]) and tonumber(a.data[k]) or a.data[k]) > (tonumber(b.data[k]) and tonumber(b.data[k]) or b.data[k])
				end)
			else 
				table.sort(copied, function(a, b)
					lastsorted = {k, 0}
					return (tonumber(a.data[k]) and tonumber(a.data[k]) or a.data[k]) < (tonumber(b.data[k]) and tonumber(b.data[k]) or b.data[k])
				end)
			end

			-- readd
			for k, v in pairs(copied) do
				UI:MapScrollable(ui, v.data, v.custom, v.onClick)
			end
		end
	end

	-- Set up 
	ui:SetSize(width, height - 21)
	ui:SetPos(x, y + 21)

	-- VBar
	local vbar = ui:GetVBar()
	vbar:SetHideButtons(true)

	-- The main bar
	function vbar:Paint(width, height)
	end

	function vbar.btnUp:Paint(width, height)
	end

	function vbar.btnDown:Paint(width, height)
	end

	function vbar.btnGrip:Paint(width, height)
		local col = Color(100,100,100)
		surface.SetDrawColor(col)
		surface.DrawRect(1, 0, width - 1, height)
	end

	local old = ui.SetVisible 
	function ui:SetVisible(arg)
		old(self, arg)
		top:SetVisible(arg)
	end 

	-- Return
	return ui, top
end

-- Scrollable
function UI:Scrollable(base, height, hoverCol, data, custom)
	-- Hmm?
	if (not base.contents) then 
		base.contents = {}
	end

	-- Panel
	local ui = base:Add("DButton")
	ui:SetPos(0, height * #base.contents)
	ui:SetSize(base:GetWide(), height)
	ui:SetText("")
	ui.data = data
	ui.custom = custom 
	ui.hoverCol = hoverCol
	ui.height = height
	ui.hoverFade = 0 
	ui.fcol = false 

	local initialy = height / 2
	
	-- its so bad 
	if not base:GetParent().themec then 
		base:GetParent().themec = base:GetParent():GetParent().themec
	end

	-- Draw
	function ui:Paint(width, height)
		local accent = UI_ACCENT
		accent = Color(accent.r, accent.g, accent.b, self.hoverFade)

		if ((hoverCol) and (self.isHovered)) or self.fcol then 
			surface.SetDrawColor(self.fcol and self.fcol or accent)
			surface.DrawRect(0, 0, width - (base.scrollbar and 16 or 0), height)
		end 

		-- Draw dat sheet
		local text = UI_TEXT1
		for k, v in pairs(data) do
			local x = (width / #data) * (k - 1)
			if (custom) then 
				x = (width / custom[1]) * custom[2][k]
			end

			local align = TEXT_ALIGN_LEFT
			if k == #data and (#data ~= 1) then 
				x = width - (base.scrollbar and 16 or 0) - 20
				align = TEXT_ALIGN_RIGHT
			end 

			-- Map name
			if type(v) == 'table' then 
				if v[1] == 'name' then 
					draw.SimpleText(UTIL:GetPlayerName(v[2]), "ui.mainmenu.button", 10 + x, initialy, text, align, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText(v[1], "ui.mainmenu.button", 10 + x, initialy, v[2], align, TEXT_ALIGN_CENTER)
				end 
			else
				draw.SimpleText(v, "ui.mainmenu.button", 10 + x, initialy, text, align, TEXT_ALIGN_CENTER)
			end
		end

		self:CPaint(width, height)
	end

	-- Custom paint
	function ui:CPaint()
	end

	-- Force col
	function ui:SetColor(cust)
		if cust then 
			self.fcol = cust 
		else 
			self.fcol = Color(UI_ACCENT.r, UI_ACCENT.g, UI_ACCENT.b, 75)
		end 
	end 

	-- Rem col 
	function ui:RemoveColor()
		self.fcol = false 
	end 

	-- Think
	function ui:Think()
		if self.isHovered and not self:IsHovered() then 
			self.hoverFade = 0 
		elseif self.isHovered and self.hoverFade < 75 then 
			self.hoverFade = self.hoverFade + 0.75
		end 

		self.isHovered = self:IsHovered()
	end

	-- Insert
	table.insert(base.contents, ui)

	-- Will there be a scrollbar?
	if (#base.contents * height) > base:GetTall() then 
		base.scrollbar = true
	end

	-- Return
	return ui
end

-- Map panel
function UI:MapScrollable(base, data, custom, onClick)
	-- Panel
	local ui = self:Scrollable(base, 40, true, data, custom)
	ui.onClick = onClick

	-- On click
	function ui:OnMousePressed()
		onClick(self, data)
	end

	function ui:SizeToAndAdjustOthers(w, h, t, d, revert)
		local inith = self:GetTall()

		self:SizeTo(w, h, t, 0)
		self.inith = inith 
		
		if not revert then 
			self.adjusted = true 
		end

		local foundSelf = false 
		local movedReverted = false
		for k, v in pairs(base.contents) do 
			if v == self then 
				foundSelf = true 
				continue
			elseif v.adjusted then 
				if not foundSelf then 
					v:SizeTo(w, v.inith, t, d)
				else end
				v.adjusted = false
			end

			if foundSelf then
				local x, y = v:GetPos() 
				v:MoveTo(w, y + h - inith, t, 0)
			end
		end
	end

	return ui
end

-- Search box
function UI:SearchBox(parent, x, y, width, height, outlines, bg, search)
	local box = self:TextBox(parent, x, y, width, height, outlines, bg)
	box:SetFont("hud.title2.1")

	-- Paint 
	function box:CPaint(width, height)
		if (not self.changed) then
			local text = parent.themec["Text Colour"]
			draw.SimpleText("Search...", "hud.title2.1", 3, height / 2, text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	-- On input
	box:SetUpdateOnType(true)
	function box:OnValueChange(value)
		box.changed = true
		search(value)
	end

	return box
end

-- Scrollable UI Panel
function UI:ScrollableUIPanel(title, desc, search, data, should_search)
	-- Get our base
	local width = 600
	local height = 510
	local base = self:BasePanel(width, height)

	-- Draw a banner 
	self:DrawBanner(base, title)

	-- Close button
	self:AddCloseButton(base)

	-- Paint
	function base:CPaint(width, height)
		-- Text colour
		local text = base.themec["Text Colour"]

		-- Desc
		draw.SimpleText(desc, "hud.title2.1", 10, 50, text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Hint: You can press the titles to sort by them.", "hud.smalltext", 10, height - 10, text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	-- Add scroll panel
	base.ScrollPanel = self:ScrollablePanel(base, 10, 70, width - 20, height - 90, data)

	-- Search box
	if (not should_search) then 
		base.SearchBox = UI:SearchBox(base, width - 160, 37, 150, 26, true, false, search)
	end

	-- Exit
	function base:Exit()
		-- yeh
		if base.OnExit then 
			base:OnExit()
		end
		
		base:Remove()
		base = nil
		gui.EnableScreenClicker(false)
	end

	-- Return panel
	return base
end

-- Simple UI input box
function UI:SimpleInputBox(title, callback, close)
	local width = 300
	local height = 115
	local base = self:BasePanel(width, height)

	self:DrawBanner(base, title)

	if (close) then 
		self:AddCloseButton(base)
	end

	local b = UI_PRIMARY
	local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
	local box = self:TextBox(base, 10, 40, width - 20, 30, false, col)
	box:SetFont("hud.title2.1")

	-- Button
	local b = base:Add("DButton")
	b:SetPos(10, 75)
	b:SetSize(width - 20, 30)
	b:SetText("")
	function b:Paint(w,h)
		surface.SetDrawColor(base.themec["Tri Colour"])
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText("Confirm", "hud.title2.1", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function b:OnMousePressed()
		callback(box:GetText())
		base:Remove()
	end

	function base:GetOutput()
		return self.output or false 
	end
	
	return base
end

function UI:BuildSimpleButton(self, name, func, x, y, w, h)
	local butt = self:Add('DButton')
	butt:SetPos(x, y)
	butt:SetSize(w, h)
	butt:SetText("")
	butt.Paint = function(pan, width, height)
		surface.SetDrawColor(pan:IsHovered() and self.themec["Tri Colour"] or self.themec["Secondary Colour"])
		surface.DrawRect(0, 0, width, height)
		draw.SimpleText(name, "ui.mainmenu.button", width / 2, height / 2, self.themec["Text Colour"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	butt.OnMousePressed = function(pan)
		func()
	end

	return butt
end

function UI:DialogBox(title, answers, yes, no)
	answers = answers or {"Yes", "No"}
	local width = 320 
	local height = 60 
	local base = self:BasePanel(width, height)
	self:DrawBanner(base, title)

	local fyes = function() yes() base:Remove() gui.EnableScreenClicker(false) end
	local fno = function() no() base:Remove() gui.EnableScreenClicker(false) end
	local yesbutt = self:BuildSimpleButton(base, answers[1], fyes, 0, 30, width / 2, 30)
	local nobutt = self:BuildSimpleButton(base, answers[2], fno, width / 2, 30, width / 2, 30)

	return base
end

function UI:NumberInput(parent, x, y, width, height, default, min, max, title, allowDecimals, callback, disable) 
	local entry = parent:Add('DNumberWang')
    entry:SetPos(x, y)
    entry:SetSize(width, height)
    entry:SetFont("ui.mainmenu.button")
	entry:SetTextColor(UI_TEXT1)
	entry:HideWang()

    function entry:Paint(width, height)
        local b = UI_PRIMARY
		local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, width, height, 2)

        surface.SetFont("ui.mainmenu.button")
        local w, h = surface.GetTextSize(self:GetText())

        draw.SimpleText(title, "ui.mainmenu.button", w+6, height / 2, Color(200, 200, 200), UI_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
		self:DrawTextEntryText(UI_TEXT1, Color(30, 130, 255), Color(255, 255, 255))
    end

	entry.min = min 
	entry.max = max 
    entry:SetMin(min)
    entry:SetMax(max)

    if allowDecimals then 
        entry:SetDecimals(3)
	else 
		entry:SetDecimals(0)
	end 

	entry:SetValue(default)

	if not disable then 
		entry:SetUpdateOnType(true)
	else 
		entry:SetUpdateOnType(false)
	end 

    function entry:OnValueChange(newVal)
		newVal = tonumber(newVal)

		if not newVal then return end 
		
		if newVal > self.max then 
			newVal = self.max 
			entry:SetValue(self.max)
			entry:SetText(self.max)
		elseif newVal < self.min then 
            newVal = self.min
			entry:SetValue(self.min)
			entry:SetText(self.min)
        end 

        callback(newVal)
	end 
	
	return entry 
end 

function UI:TextEntry(parent, x, y, width, height, default, len, callback)
	local b = UI_PRIMARY
	local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
	local entry = self:TextBox(parent, x, y, width, height, false, col)

	entry:SetText(default)
	entry:SetUpdateOnType(true)
	function entry:OnValueChange(var)
		if #var > len then 
			var = var:Left(len)
			entry:SetText(var)
		end 

		callback(var)
	end 

	return entry
end 

function UI:SteamID(parent, x, y, width, height, default, len, callback)
	local entry = self:TextEntry(parent, x, y, width, height, default, len, callback)

	function entry:OnValueChange(var)
		if #var > len then 
			var = var:Left(len)
			entry:SetText(var)
		end 

		if Admin:ValidSteamID(var:upper()) then 
			self.col = Color(0, 200, 0)
		else 
			self.col = Color(200, 0, 0)
		end

		callback(var)
	end 
	
	return entry 
end 

function UI:CheckBox(parent, x, y, size, default, callback)
	local pan = vgui.Create('DButton', parent)
	pan:SetPos(x, y)
	pan:SetSize(size, size)
	pan:SetText("")
	pan.checked = default 

	function pan:OnMousePressed()
		self.checked = (not self.checked)
		callback(self.checked)
	end 

	local b = UI_PRIMARY
	local col = Color(b.r + 25, b.g + 25, b.b + 25, 255)
	function pan:Paint(width, height)
		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(0, 0, width, height, 4)

		--surface.SetDrawColor(UI_ACCENT)
		if self.checked then 
			surface.DrawRect(6, 6, width - 12, height - 12)
		end 
	end 
end 


--[[-------------------------------------------------------------------------
	Checkpoints
]]---------------------------------------------------------------------------]]
local function CP_Callback(id)
	return function() UI:SendCallback("checkpoints", {id}) end
end

-- Listener
UI:AddListener("checkpoints", function(_, data)
	local update = data[1] or false

	-- Update?
	if update and (UI.checkpoints) and (UI.checkpoints.title) then
		if (update == "angles") then
			UI.checkpoints:UpdateOptionBool(7)
			return
		end

		if (update == "close") then 
			UI.checkpoints:Exit()
			UI.checkpoints = nil 
			return
		end

		local current = data[2]
		local all = data[3] or nil

		-- no current?
		if (not current) or (not all) or (current == 0) or (all == 0) then
			UI.checkpoints:UpdateTitle((LocalPlayer():GetNWInt("segmented", false) and "Segments" or "Checkpoints"))
			return
		end

		UI.checkpoints:UpdateTitle((LocalPlayer():GetNWInt("segmented", false) and "Segment: " or "Checkpoint: ") .. current .. " / " .. all)
	elseif (not UI.checkpoints) or (not UI.checkpoints.title) then
		local options = {{["name"] = "Save checkpoint", ["function"] = CP_Callback("save")},
			{["name"] = "Teleport to checkpoint", ["function"] = CP_Callback("tp")},
			{["name"] = "Next checkpoint", ["function"] = CP_Callback("next")},
			{["name"] = "Previous checkpoint", ["function"] = CP_Callback("prev")},
			{["name"] = "Delete checkpoint", ["function"] = CP_Callback("del")},
			{["name"] = "Reset checkpoints", ["function"] = CP_Callback("reset")},
			{["name"] = "Use Angles", ["function"] = CP_Callback("angles"), ["bool"] = true}}

		if LocalPlayer().mode < 0 then 
			options[7] = nil 
		end

		title = (LocalPlayer().mode < 0 and "Segments" or "Checkpoints")
		if update == "newpan" then 
			local current = data[2]
			local all = data[3] or nil

			if all then 
				title = (LocalPlayer().mode < 0 and "Segment: " or "Checkpoint: ") .. current .. " / " .. all
			end
		end

		if (update == "close") then return end

		UI.checkpoints = UI:NumberedUIPanel(title,
			unpack(options)
		)
	end
end)
