-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_uisettings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function CreateHUDMenu(pan)
	-- Needed
	function pan:Reset()
		pan.preset.dd:Remove()
		pan.preset:Remove()

		if (pan.tmp) then 
			pan.tmp:Remove()
		end
	end

	-- which hud to be selected
	local ops = Settings:GetOptions('selected.hud')
	local current = Settings:GetValue('selected.hud')
	local yeboi = {}
	for k, v in pairs(ops) do 
		if (v == current) then 
			current = k 
		end
		yeboi[k] = {Theme:Translate(v), v}
	end

	-- Make the setting
	local selectedhud = BuildSetting(pan, 2, 0, 'Selected HUD', 'This setting controls the style of HUD you would like to use.', 'dd', yeboi, current)

	-- Changing HUD 
	function selectedhud.dd:OnSelect(index, value, data)
		Settings:SetValue('selected.hud', data)
		pan:Reset()
		pan:BuildOptionsOffHUD()
	end

	-- Presets 
	function pan:BuildOptionsOffHUD()
		local current = Settings:GetValue('selected.hud')
		local theme = Theme:Get(current)
		local prests, a, i = {}, false, 1
		for k, v in pairs(theme) do 
			if v["Colours"] then 
				table.insert(prests, {k, k})
				if (k == Theme:GetOptions(current)) and not a then 
					a = i 
				end
				i = i + 1
			end
		end
		local bases = table.Copy(prests)
		table.insert(prests, {'Add new...', 'new'})

		-- Preset
		pan.preset = BuildSetting(pan, 2, 46, 'Theme Preset', 'This setting controls the theme preset of the HUD, select \"Add new...\" to create your own.', 'dd', prests, a)

		-- Changing HUD 
		function pan.preset.dd:OnSelect(index, value, data)
			-- SAFTEY
			if (pan.tmp) then 
				pan.tmp:Remove()
			end

			if (data == 'new') then 
				pan.tmp = UI.mainmenu.BASE:Add('EditablePanel')
				pan.tmp:SetSize(400, 260)
				pan.tmp:Center()
				pan.tmp.themec = UI.mainmenu.themec
				pan.tmp.themet = UI.mainmenu.themet

				function pan.tmp:Paint(width, height)
					surface.SetDrawColor(UI.mainmenu.themec['Secondary Colour'])
					surface.DrawRect(0, 0, width, height)
					draw.SimpleText('Preset Name', 'ui.mainmenu.button', 10, 40, UI.mainmenu.themec['Text Colour'])
					draw.SimpleText('Preset Base', 'ui.mainmenu.button', 10, 100, UI.mainmenu.themec['Text Colour'])
				end

				UI:DrawBanner(pan.tmp, 'Add new preset')
				local col = UI.mainmenu.themec['Primary Colour']
				col = Color(col.r + 10, col.g + 10, col.b + 10, 255)

				-- preset name 
				local name = UI:TextBox(pan.tmp, 10, 62, 380, 30, false, col)
				name:SetFont('ui.mainmenu.button')
				name:SetTextColor(UI.mainmenu.themec['Text Colour 2'])

				-- base 
				local base = BuildDropdown(pan.tmp, 10, 122, 380, 30, bases)

				-- Continue 
				local go = BuildSleekButton(pan.tmp, 10, 180, 380, 30, 'Create Preset', function()
					local name = name:GetValue()
					local basePreset = base:GetValue()
					local build = Theme:GetPreference('HUD', basePreset)
					Theme:BuildNew('HUD', name, select(2, selectedhud.dd:GetSelected()), basePreset, build)
					Settings:SetValue('preference.'..select(2, selectedhud.dd:GetSelected()), name)
					pan.preset.dd:AddChoice(name, name)
					pan.preset.dd:ChooseOption(name, #prests + 1)
					pan.tmp:Remove()
				end)
				local exit = BuildSleekButton(pan.tmp, 10, 220, 380, 30, 'Cancel', function() pan.tmp:Remove() end)
			else 
				Settings:SetValue('preference.'..select(2, selectedhud.dd:GetSelected()), value)
			end

			pan:UpdateSettingsPanel()
		end

		-- Update 
		function pan:UpdateSettingsPanel()
			if pan.settings then 
				pan.settings:Remove()
			end

			local theme = Theme:GetPreference('HUD')
			if not theme.isCustom then return end

			pan.settings = pan:Add('DPanel')
			pan.settings:SetPos(2, 100)
			pan.settings:SetSize(pan:GetWide() - 4, pan:GetTall() - 100)
			pan.settings.Paint = function()
				draw.SimpleText("Colour Selection", "ui.mainmenu.title2", 0, 0, color_white, TEXT_ALIGN_LEFT)
				draw.SimpleText("Toggles Selection", "ui.mainmenu.title2", 0, (pan.settinamount or 0) * 30 + (10 * ((pan.settinamount or 0) - 1)) + 16, color_white, TEXT_ALIGN_LEFT)
			end 

			-- get dem colours boiiiiii
			local i = 1
			local SETTINZ = {}
			for k, v in pairs(theme.Colours) do 
				BuildSetting(pan.settings, 0, 30 * i + (10 * (i - 1)), k, 'This controls the \"'..k.."\" variable.", 'cp', {v}, function(col, self)
					Theme:UpdateValue(select(2, selectedhud.dd:GetSelected()), select(2, pan.preset.dd:GetSelected()), 'Colours', k, col)
				end)
				i = i + 1
			end
			pan.settinamount = i
			for k, v in pairs(theme.Toggles) do 
				BuildSetting(pan.settings, 0, 30 * i + (10 * (i - 1)) + 46, k, 'This toggles the \"'..k.."\" variable.", 'tg', v)
				i = i + 1
			end
		end
		pan:UpdateSettingsPanel()
	end

	pan:BuildOptionsOffHUD()
	function pan:Paint(width, height)
	end
end