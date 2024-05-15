-- "gamemodes\\bhop\\gamemode\\userinterface\\cl_menu.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- F1/!options/!menu 
-- by Justa

-- Building a basic button 
local function BuildSimpleButton(self, name, func, x, y, w, h, side, cfont)
	local butt = self:Add('DButton')
	butt:SetPos(x, y)
	butt:SetSize(w, h)
	butt:SetText("")
	butt.Paint = function(pan, width, height)
		if side and self.selected == pan then 
			surface.SetDrawColor(UI_ACCENT)
			surface.DrawRect(1, 1, width - 2, height - 2)
		end

		draw.SimpleText(name, cfont and cfont or "ui.mainmenu.button", side and 28 or width / 2, height / 2, (self.selected == pan and not side) and UI_ACCENT or UI_TEXT1, side and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	butt.OnMousePressed = function(pan)
		self.selected = pan
		func()
	end

	-- selected row 
	if (not self.selected) then 
		self.selected = butt
	end

	return butt
end

-- Building selections 
local function BuildSelections(self, height, ...)
	local spacing = 28
	local len = 0

	-- Ya
	self.selections = {}

	-- Go through our options 
	for key, o in pairs({...}) do 
		local func = function()
			o.func()
		end

		-- Calculations
		surface.SetFont('ui.mainmenu.button') 
		local x = len
		local y = 0
		local w = select(1, surface.GetTextSize(o.name)) + (spacing * 2)
		local h = height

		-- Add the button
		self.selections[key] = BuildSimpleButton(self, o.name, func, x, y, w, h, false, "ui.mainmenu.button-bold")
		self.selections[key].w = w 
		self.selections[key].x = x
		len = len + w
	end
end

-- Circular avatar
local cos, sin, rad = math.cos, math.sin, math.rad
local function BuildCircularAvatar(base, x, y, radius, steamid64)
	local pan = base:Add('DPanel')
	pan:SetPos(x, y)
	pan:SetSize(radius * 2, radius * 2)
	pan.mask = radius

	pan.avatar = pan:Add('AvatarImage')
	pan.avatar:SetPaintedManually(true)
	pan.avatar:SetSize(pan:GetWide(), pan:GetTall())
	pan.avatar:SetSteamID(steamid64, 184)

	-- yikes 
	function pan:Paint(w, h)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
   		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    	render.SetStencilReferenceValue(1)

    	local circle, t = {}, 0
    	for i = 1, 360 do 
    		t = rad(i * 720) / 720 
    		circle[i] = {x = w/2 + cos(t) * self.mask, y = h/2 + sin(t) * self.mask}
    	end
    	draw.NoTexture()
    	surface.SetDrawColor(color_white)
    	surface.DrawPoly(circle)

    	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
   		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    	render.SetStencilReferenceValue(1)

    	self.avatar:SetPaintedManually(false)
    	self.avatar:PaintManual()
    	self.avatar:SetPaintedManually(true)

    	render.SetStencilEnable(false)
    	render.ClearStencil()
	end
end

-- Shortens a name 
local function SnippedName(nick)
	if #nick > 21 then 
			nick = nick:Left(18) .. "..."
	end 
	return nick
end

-- Select Menu 
function UI:SelectMenu(enum)
	if (not self.mainmenu) then return end 
	local side = self.mainmenu.sidepanel
	side:SetOptions(enum)
end

TEXT_CREDITS = {
	{"col", color_white},
	"Developer:\n",
	{"col", Color(0, 50, 200)},
	"\bjusta",
	{"col", color_white},
	" (www.steamcommunity.com/id/just_adam) \n",
	{"font", "mid"},
	"\nTesters:",
	{"col", Color(200, 50, 0)},
	"\nSad Rainbow",
	{"col", color_white},
	" (https://steamcommunity.com/id/sadrainbow)\n",
	{"col", Color(200, 50, 0)},
	"Cat",
	{"col", color_white},
	" (https://steamcommunity.com/id/onlywitness)\n",
	"\nSpecial thanks to:",
	{"col", Color(0, 200, 50)},
	"\nh3xcat ", {"col", color_white}, "- luabsp", {"col", Color(0, 200, 50)},
	"\nclazstudio ", {"col", color_white}, "- showclips and showtriggers", {"col", Color(0, 200, 50)},
	"\nGravious ", {"col", color_white}, "- Inspiration",
}

TEXT_RULES = {
	"1. No cheating\n",
	"2. No exploiting (Gamemode/Lua exploits NOT map exploits)\n",
	"3. No malcious attacks against the server or players (ex. DDOS)\n",
	"4. All profanity is allowed but targeting one player constantly is not\n",
	"5. Don't be a dick."
}

TEXT_NOTADDEDYET = {
	"This has not been implemented yet."
}

TEXT_H2P = {
	"adadadadadadadadadadadadadadadadadadadadadadadadadaadada\nbreathbreathbreath\nadadadadadadadadadadaadadadadadadadadadadadadadadadda\nmaybe a w in there\nadadadadadadadadada"
}

-- Simple text based gui
local fonts = {
	["big"] = "HUDTimer",
	["mid"] = "ui.mainmenu.button"
}
local function CreateTextbasedMenu(text) 
	return function(pan)
		local rich = pan:Add('RichText')
		rich:SetPos(0, 0)
		rich:SetSize(pan:GetWide(), pan:GetTall())
		rich:SetVerticalScrollbarEnabled(false)

		local clickable = {}

		function rich:PerformLayout()
			self:SetFGColor(Color(255, 255, 255))
			self:SetFontInternal("ui.mainmenu.button")
		end
		
		for k, v in pairs(text) do 
			if type(v) == 'string' then 
				rich:AppendText(v)
			else
				local method = v[1]

				if (method == 'font') then 
				--	rich:SetFontInternal(fonts[v[2]])
				end 

				if (method == 'link') then 
					rich:InsertClickableTextStart('test')
					rich:AppendText(v[2])
					rich:InsertClickableTextEnd()
				end

				if (method == 'col') then 
					rich:InsertColorChange(v[2].r, v[2].g, v[2].b, 255)
				end
			end
		end

		function rich:ActionSignal(name, val)
			if (name == 'TextClicked') then 
				if (clickable[val]) then 
					gui.OpenURL(clickable[val])
				end
			end
		end
	end
end

function BuildDropdown(parent, x, y, w, h, ops, id)
	local combo = parent:Add('DComboBox')
	combo:SetPos(x, y)
	combo:SetSize(w, h)
	combo:SetFont('ui.mainmenu.button')
	combo.ops = ops
	combo:SetTextColor(UI_TEXT1)

	for k, v in pairs(ops) do 
		combo:AddChoice(v[1], v[2] or v[1])
	end

	combo:ChooseOptionID(id or 1)

	function combo:Paint(width, height)
		local col = UI_PRIMARY
		col = Color(col.r + 10, col.g + 10, col.b + 10, 255)
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, width, height)
	end

	return combo
end

function BuildSleekButton(parent, x, y, width, height, title, fu, cust, center)
	center = center == nil and true or false
	local f = parent:Add('DButton')
	f:SetPos(x, y)
	f:SetSize(width, height)
	f:SetText('')
	f.title = title

	function f:Paint(width, height)
		local b = UI_PRIMARY
		local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
		local col2 = Color(b.r + 10, b.g + 10, b.b + 10, 255)
		surface.SetDrawColor(self:IsHovered() and col or col2)
		surface.DrawRect(0, 0, width, height)

		if cust then 
			cust(width, height)
		else 
			draw.SimpleText(self.title, 'ui.mainmenu.button', center and width / 2 or 10, height / 2, UI_TEXT1, center and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	f.OnMousePressed = fu
	return f
end

function BuildToggleButton(parent, x, y, width, height, togglestate)
	local f = parent:Add('DButton')
	f:SetPos(x, y)
	f:SetSize(width, height)
	f:SetText('')
	f.togglestate = togglestate

	function f:Paint(width, height)
		local col = f.togglestate and Color(100, 255, 0) or Color(160, 40, 40, 255)
		draw.RoundedBox(8, 0, 3, width, height - 6, col)
		draw.RoundedBox(8, f.togglestate and width - 20 or 0, 0, 20, height, color_white)
		--surface.DrawCircle(width - 12, 12, 10, color_white)
	end

	function f:OnMousePressed()
		f.togglestate = !f.togglestate
	end
end

function BuildSetting(parent, x, y, title, desc, ty, ops, ...)
	local setting = parent:Add('DPanel')
	setting:SetPos(x, y)
	setting:SetSize(parent:GetWide() - x, 36)
	setting.Paint = function(self, width, height) 
		draw.SimpleText(title, 'ui.mainmenu.button', 0, 0, UI_TEXT1)
		draw.SimpleText(desc, 'ui.mainmenu.desc', 0, 16, UI_TEXT2)
	end

	if (ty == 'dd') then
		local id = {...}
		id = id[1]
		setting.dd = BuildDropdown(setting, setting:GetWide() - 200, 1, 200, 30, ops, id)
	elseif (ty == 'cp') then 
		local ya = {...}
		setting.viewcol = ops[1]
		setting.sb = BuildSleekButton(setting, setting:GetWide() - 200, 1, 200, 30, '', function() 
			parent.tmp = UI.mainmenu.BASE:Add('EditablePanel')
			parent.tmp:SetSize(500, 450)
			parent.tmp:Center()
			parent.tmp.themec = UI.mainmenu.themec
			parent.tmp.themet = UI.mainmenu.themet

			function parent.tmp:Paint(width, height)
				surface.SetDrawColor(UI_SECONDARY)
				surface.DrawRect(0, 0, width, height)
				draw.SimpleText('Colour Picker', 'ui.mainmenu.button', 10, 38, UI_TEXT1)
				draw.SimpleText('Colour Preview', 'ui.mainmenu.button', 10, 300, UI_TEXT1)
				surface.SetDrawColor(self.picker and self.picker:GetColor() or color_white)
				surface.DrawRect(10, 324, width - 20, 30)
			end

			UI:DrawBanner(parent.tmp, 'Edit Colour')

			local col = UI_HIGHLIGHT
			parent.tmp.picker = parent.tmp:Add('DColorMixer')
			parent.tmp.picker:SetPos(10, 60)
			parent.tmp.picker:SetWide(480)
			parent.tmp.picker:SetColor(setting.viewcol)

			local confirm = BuildSleekButton(parent.tmp, 10, 376, 480, 30, 'Confirm', function() 
				local col = parent.tmp.picker:GetColor()
				ya[1](col)
				setting.viewcol = col
				parent.tmp:Remove()
			end)
			local cancel = BuildSleekButton(parent.tmp, 10, 410, 480, 30, 'Cancel', function() parent.tmp:Remove() end)
		end, function(width, height)
			draw.SimpleText('Colour:', 'ui.mainmenu.button', 10, (height / 2) - 1, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(setting.viewcol)
			surface.DrawRect(width - 10 - 20 - 105, 5, 125, height - 10)
		end)
	elseif (ty == 'tg') then 
		setting.tg = BuildToggleButton(setting, setting:GetWide() - 60, 6, 50, 20, ops)
	end

	return setting
end

include("menuitems/ui_scrollbase.lua")
include("menuitems/ui_settingsbase.lua")
include("menuitems/ui_nominate.lua")
include("menuitems/ui_uisettings.lua")
include("menuitems/ui_leaderboard.lua")
include("menuitems/ui_playermanagement.lua")
include("menuitems/ui_banlist.lua")
include("menuitems/ui_personalrecords.lua")
include("menuitems/ui_whitelist.lua")
include("menuitems/ui_worldrecords.lua")
include("menuitems/ui_styles.lua")
include("menuitems/ui_mapsettings.lua")
include("menuitems/ui_strafesettings.lua")
include("menuitems/ui_trainsettings.lua")
include("menuitems/ui_timersettings.lua")
include("menuitems/ui_perfsettings.lua")

-- General
SELECTION_GENERAL = {
	{"Rules", CreateTextbasedMenu(TEXT_RULES)},
	{"Credits", CreateTextbasedMenu(TEXT_CREDITS)}
}

SELECTION_GAMEPLAY = {
	{"Select Style", "vgui.styles"},
	{"Nominate", BuildNominationMenu}
}

SELECTION_LEADERBOARD = {
	{"Top players", CreateTopList},
	{"World records", BuildWorldRecords},
	{"Personal Records", "vgui.personalrecords"},
	{"My world records", "vgui.worldrecords"}
}

SELECTION_SETTINGS = {
	{"Timer", "vgui.timersettings"},
	{"Performance", "vgui.perfsettings"},
	{"SSJ", "vgui.strafesettings"},
	{"Strafe Trainer", "vgui.trainsettings"}
}

SELECTION_UI = {
	{"HUD", CreateHUDMenu}
}

SELECTION_ADMIN = {
	{"Commands", "vgui.commands"},
	{"Ban List", "vgui.banlist"},
	{"Whitelist", "vgui.whitelist"},
	{"Map Settings", "vgui.mapsettings"}
}

-- Function to toggle menu
function UI:ToggleMainmenu(SELECTION_MAIN, SELECTION_MAINID, SELECTION_SUB, options)
	-- Already exists
	if (self.mainmenu) then
		self.mainmenu:SetVisible(false)
		self.mainmenu:Remove() 
		self.mainmenu = nil
		gui.EnableScreenClicker(false)

		return
	end

	-- Screen click 
	gui.EnableScreenClicker(true)

	-- Size (px) 
	-- Sorry 4K displays
	local width = 1000
	local height = 700
	local x, y = 0, 0

	-- Create
	self.mainmenu = UI:BasePanel(width, height)
	self.mainmenu:SetVisible(true)
	self.mainmenu.CPaint = function(pan, width, height)
	end

	local lastKey = CurTime()
	UI.CannotClose = false
	function self.mainmenu.Think() 
		if CurTime() > lastKey + 1 and input.IsKeyDown(KEY_F1) and not UI.CannotClose then 
			UI:ToggleMainmenu()
			UI.CannotClose = true
		end
	end

	-- Size 
	height = 24

	-- Top Panel 
	self.mainmenu.toppanel = self.mainmenu:Add("DPanel")
	self.mainmenu.toppanel:SetPos(x, y)
	self.mainmenu.toppanel:SetSize(width, height)
	self.mainmenu.toppanel.Paint = function(pan, width, height)
	end

	-- Size and pos
	y = 0
	height = 57

	-- Selection menu 
	self.mainmenu.selection = self.mainmenu:Add("DPanel")
	self.mainmenu.selection:SetPos(x, y)
	self.mainmenu.selection:SetSize(width, height)
	self.mainmenu.selection.Paint = function(pan, width, height)
		surface.SetDrawColor(UI_TRI)
		surface.DrawRect(0, 0, width, height)

		-- Selection menu 
		if pan.selections then 
			for k, v in pairs(pan.selections) do
				if k == #pan.selections then continue end
			end
		end
	end

	-- Close button 
	local close = self.mainmenu.selection:Add("DButton")
	close:SetPos(width - 24, 0)
	close:SetSize(20, 20)
	close:SetText("")
	close.Paint = function(pan, width, height)
		draw.SimpleText("x", "ui.mainmenu.close", width / 2, height / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	close.OnMousePressed = function(pan)
		UI:ToggleMainmenu()
	end

	local selects = {
		{
			["name"] = "Information",
			["func"] = function() 
				UI:SelectMenu(SELECTION_GENERAL)
			end
		},
		{
			["name"] = "Gameplay",
			["func"] = function() 
				UI:SelectMenu(SELECTION_GAMEPLAY)
			end
		},
		{
			["name"] = "Leaderboards",
			["func"] = function() 
				UI:SelectMenu(SELECTION_LEADERBOARD)
			end
		},
		{
			["name"] = "Settings",
			["func"] = function() 
				UI:SelectMenu(SELECTION_SETTINGS)
			end
		},
		{
			["name"] = "User Interface",
			["func"] = function() 
				UI:SelectMenu(SELECTION_UI)
			end
		},
		/*{
			["name"] = "VIP",
			["func"] = function() end
		}*/
	}

	if Admin:HasAccessLevel(LocalPlayer(), "zoner") then 
		table.insert(selects, {
			["name"] = "Admin",
			["func"] = function() 
				UI:SelectMenu(SELECTION_ADMIN)
			end
		})
	end 

	-- Build selections 
	BuildSelections(self.mainmenu.selection, 56, unpack(selects))

	-- yep 
	surface.SetFont('ui.mainmenu.button')
	local name = SnippedName(LocalPlayer():Nick())
	self.mainmenu.nlen = select(1, surface.GetTextSize(name))

	-- Size and pos 
	width = 220
	height = 621 + 23
	y = 79 - 22

	-- Side Menu 
	self.mainmenu.sidepanel = self.mainmenu:Add("DPanel")
	self.mainmenu.sidepanel:SetPos(x, y)
	self.mainmenu.sidepanel:SetSize(width, height)
	self.mainmenu.sidepanel.Paint = function(pan, width, height)
		surface.SetDrawColor(UI_SECONDARY)
		surface.DrawRect(0, 0, width, height)
	end

	-- Set options
	self.mainmenu.sidepanel.options = {}
	self.mainmenu.sidepanel.SetOptions = function(pan, options)
		-- clear 
		for k, v in pairs(pan.options) do 
			v:Remove()
			v = nil
		end

		pan.selected = nil

		local len = 0
		for key, o in ipairs(options) do 
			local x = -1
			local y = len
			local w = width + 1
			local h = 54

			local func = function(x)
				self.mainmenu.base:RemoveChildren()
				self.mainmenu.base:SetTitle(o[1])
				self.mainmenu.base.Paint = function() end

				-- yea 
				if self.mainmenu.base.Reset then 
					self.mainmenu.base:Reset()
					self.mainmenu.base.Reset = nil
				end

				-- Better way of doing this.
				if type(o[2]) == 'string' then 
					local w, h = self.mainmenu.base:GetSize()

					self.mainmenu.base.CustomPanel = self.mainmenu.base:Add(o[2])
					self.mainmenu.base.CustomPanel:SetSize(w-2, h)
					self.mainmenu.base.CustomPanel:SetPos(2, 0)

					if self.mainmenu.base.CustomPanel.Start then 
						self.mainmenu.base.CustomPanel:Start()
					end 
				else 
					o[2](self.mainmenu.base, x)
				end 
			end

			if (key == 1) and (self.mainmenu.base) and not SELECTION_SUB then 
				func()
			end

			-- Add the button
			pan.options[key] = BuildSimpleButton(pan, o[1], func, x, y, w, h, true, "ui.mainmenu.button2")
			pan.options[key].o = func
			len = len + h
		end
	end

	-- default 
	self.mainmenu.sidepanel:SetOptions(SELECTION_GENERAL)

	-- size, pos 
	x = 220
	width = 1000 - 220

	height = height - 15

	-- base panel 
	self.mainmenu.BASE = self.mainmenu:Add('DPanel')
	self.mainmenu.BASE:SetPos(x, y)
	self.mainmenu.BASE:SetSize(width, height)
	self.mainmenu.BASE.Paint = function(_,width,height) 
		draw.SimpleText(_.title or "????", "ui.mainmenu.title2", 15, 15, UI_TEXT1, TEXT_ALIGN_LEFT)
		surface.SetDrawColor(Color(100, 100, 100))
		surface.DrawLine(15, 44, width - 15, 44)
	end
	self.mainmenu.base = self.mainmenu.BASE:Add("DScrollPanel")
	self.mainmenu.base:SetPos(14, 54)
	self.mainmenu.base:SetSize(width - 28, height - 50)
	self.mainmenu.base.RemoveChildren = function(pan)
		for k, v in pairs(pan:GetCanvas():GetChildren()) do 
			v:Remove()
		end
	end
	self.mainmenu.base.SetTitle = function(s, d) UI.mainmenu.BASE.title = d end

	local vbar = self.mainmenu.base:GetVBar()
	vbar:SetHideButtons(true)
	
	local parent = self.mainmenu
	function vbar:Paint(width, height)
		local col = UI_PRIMARY
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, width, height)
	end

	function vbar.btnUp:Paint(width, height)
	end

	function vbar.btnDown:Paint(width, height)
	end

	function vbar.btnGrip:Paint(width, height)
		local col = Color(200, 200, 200)
		surface.SetDrawColor(col)
		surface.DrawRect(2, 1, width - 4, height - 2)
	end

	--?
	if SELECTION_MAIN then 
		self.mainmenu.sidepanel:SetOptions(SELECTION_MAIN)
		self.mainmenu.selection.selected = self.mainmenu.selection.selections[SELECTION_MAINID]
		
		if SELECTION_SUB then 
			self.mainmenu.sidepanel.options[SELECTION_SUB].o(options)
			self.mainmenu.sidepanel.selected = self.mainmenu.sidepanel.options[SELECTION_SUB]
		end
	else 
		self.mainmenu.sidepanel.options[1].o()
	end
end

-- Debug concommand
concommand.Add("bhop_menu", function()
	UI:ToggleMainmenu()
end)

-- Main menu -> Gameplay -> Style
UI:AddListener("style", function()
	UI:ToggleMainmenu(SELECTION_GAMEPLAY, 2, 1)
end)

UI:AddListener("nominate", function()
	UI:ToggleMainmenu(SELECTION_GAMEPLAY, 2, 2)
end)

UI:AddListener("wr", function(_, data)
	if (data and data[1] != nil) then 
		UI:ToggleMainmenu(SELECTION_LEADERBOARD, 3, 2, data[1])
	else 
		UI:ToggleMainmenu(SELECTION_LEADERBOARD, 3, 2)
	end 
end)

UI:AddListener("top", function(_, data)
	UI:ToggleMainmenu(SELECTION_LEADERBOARD, 3, 1)
end)

UI:AddListener("adminmenu", function(_, data)
	UI:ToggleMainmenu(SELECTION_ADMIN, 6, 1)
end)

UI:AddListener("ssj", function(_, data)
	UI:ToggleMainmenu(SELECTION_SETTINGS, 4, 3)
end)

UI:AddListener("trainer", function(_, data)
	UI:ToggleMainmenu(SELECTION_SETTINGS, 4, 4)
end)