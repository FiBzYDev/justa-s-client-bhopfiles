-- "gamemodes\\bhop\\gamemode\\userinterface\\cl_themes.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Themes
-- this file isn't completed at all, this is just temporary so greatchar doesn't bite my head off
Settings:Register("StartZone", Color( 0, 230, 0, 255 ))
Settings:Register("EndZone", Color( 180, 0, 0, 255 ))
Settings:Register("BonusStart", Color( 127, 140, 141 ))
Settings:Register("BonusEnd", Color( 52, 73, 118 ))

-- Module
if not Theme then 
Theme = {}
local themes = {}

-- Register Theme
function Theme:Register(ty, id, name, options)
	themes[id] = {name = name, ty = ty, options = options}

	-- We're just gonna piggyback off cl_settings 
	Settings:Register(id, themes[id])
	self:SetupPreference(id, options)
end

-- Translate id to idk 
function Theme:Translate(id)
	if themes[id] then 
		return themes[id].name 
	else 
		return "????"
	end
end

-- theres no uh way to make preference atm 
function Theme:SetupPreference(id, ops)
	local idk 
	for k, v in pairs(ops) do 
		if v["Colours"] then 
			idk = k 
			break 
		end
	end
	Settings:Register('preference.'..id, idk)
end

function Theme:BuildNew(ty, name, id, basePreset, ops)
	Settings:SetValue('preference.'..id, name)

	-- now add the options 
	themes[id].options[name] = ops
	themes[id].options[name].isCustom = true
	Settings:SetValue(id, themes[id])
	self:RemoveCache()
end

function Theme:UpdateValue(id, pref, mod, k, v)
	print(id, pref, mod, k, v)
	themes[id].options[pref][mod][k] = v 
	Settings:SetValue(id, themes[id])
end

-- Add settings for selected HUD, Scoreboard, UI and Numbered UI and whatever else i add loll 
Settings:Register('selected.hud', 'hud.momentum', {'hud.flow', 'hud.momentum', 'hud.css', 'hud.simple'})

-- HUD themes
Theme:Register("HUD", "hud.flow", "Flow Network (Re-Design)", {
	["Transparent"] = {
		["Colours"] = {
			["Primary Colour"] = Color(44, 44, 44, 170),
			["Secondary Colour"] = Color(38, 38, 38, 170),
			["Accent Colour"] = Color(80, 30, 40, 170),
			["Text Colour"] = color_white,
			["Outlines Colour"] = color_black
		},

		["Toggles"] = {
			["Outlines"] = false,
			["Strafe HUD"] = true,
		}
	},

	["Grey"] = {
		["Colours"] = {
			["Primary Colour"] = Color(44, 44, 44, 255),
			["Secondary Colour"] = Color(38, 38, 38, 255),
			["Accent Colour"] = Color(80, 30, 40, 255),
			["Text Colour"] = color_white,
			["Outlines Colour"] = color_black
		},

		["Toggles"] = {
			["Outlines"] = false,
			["Strafe HUD"] = true
		}
	}
})

Theme:Register("HUD", "hud.momentum", "Momentum Mod", {
	["Regular"] = {
		["Colours"] = {
			["Box Colour"] = Color(0, 0, 0, 100),
			["Speed Positive"] = Color(0, 160, 200),
			["Speed Negative"] = Color(200, 0, 0),
			["Text Colour #1"] = color_white,
			["Text Colour #2"] = Color(0, 160, 200)
		},

		["Toggles"] = {
			["Outlines"] = true
		}
	}
})


-- HUD themes
Theme:Register("HUD", "hud.css", "Counter Strike: Source", {
	["Regular"] = {
		["Colours"] = {
		},

		["Toggles"] = {
		},
	}
})

Theme:Register("HUD", "hud.simple", "Simplistic", {
	["Regular"] = {
		["Colours"] = {
			["Text Colour"] = color_white
		},

		["Toggles"] = {
		},
	}
})


-- Numbered UI Themes
Theme:Register("NumberedUI", "nui.css", "Counter Strike: Source", {
	Regular = {
		["Colours"] = {
			["Primary Colour"] = Color(20, 20, 20, 150),
			["Title Colour"] = color_white,
			["Secondary Colour"] = Color(38, 38, 38, 255),
			["Text Colour"] = Color(224, 181, 113, 255),
			["Accent Colour"] = Color(160, 90, 50)
		},

		["Toggles"] = {}
	}
})

-- Kawaii
Theme:Register("NumberedUI", "nui.kawaii", "Kawaii Clan", {
	["Dark"] = {
		["Colours"] = {
			["Primary Colour"] = Color(27, 27, 27, 255),
			["Secondary Colour"] = Color(21, 21, 21, 255),
			["Accent Colour"] = Color(200, 100, 100, 255),
			["Text Colour"] = color_white,
			["Title Colour"] = color_white
		},

		["Toggles"] = {}
	},

	["Grey"] = {
		["Colours"] = {
			["Primary Colour"] = Color(47, 47, 47, 255),
			["Secondary Colour"] = Color(38, 38, 38, 255),
			["Accent Colour"] = Color(200, 100, 100, 255),
			["Text Colour"] = color_white,
			["Title Colour"] = color_white
		},

		["Toggles"] = {}
	},

	["Clear"] = {
		["Colours"] = {
			["Primary Colour"] = Color(47, 47, 47, 100),
			["Secondary Colour"] = Color(38, 38, 38, 100),
			["Accent Colour"] = Color(200, 100, 100, 255),
			["Text Colour"] = color_white,
			["Title Colour"] = color_white
		},

		["Toggles"] = {}
	},

	["Light"] = {
		["Colours"] = {
			["Primary Colour"] = Color(240, 240, 250),
			["Secondary Colour"] = Color(40, 40, 40),
			["Accent Colour"] = Color(255, 0, 0, 255),
			["Text Colour"] = color_black,
			["Title Colour"] = color_white
		},

		["Toggles"] = {}
	}
})


-- UI Themes
Theme:Register("UI", "ui.dark", "Dark", {
	["Colours"] = {
		["Primary Colour"] = Color(30, 30, 30, 255),
		["Secondary Colour"] = Color(27, 27, 27, 255),
		["Tri Colour"] = Color(21, 21, 21, 255),
		["Accent Colour"] = Color(0, 160, 200),
		["Text Colour"] = color_white,
		["Text Colour 2"] = color_white,
		["Outlines Colour"] = color_black,
		["Outlines Colour 2"] = color_black
	},

	["Toggles"] = {
		["Outlines"] = false
	}
})


-- UI Themes
Theme:Register("UI", "ui.grey", "Grey", {
	["Colours"] = {
		["Primary Colour"] = Color(47, 47, 47, 255),
		["Secondary Colour"] = Color(44, 44, 44, 255),
		["Tri Colour"] = Color(38, 38, 38, 255),
		["Accent Colour"] = Color(160, 40, 40, 255),
		["Text Colour"] = color_white,
		["Text Colour 2"] = color_white,
		["Outlines Colour"] = color_black,
		["Outlines Colour 2"] = Color(30, 30, 30)
	},

	["Toggles"] = {
		["Outlines"] = false
	}
})

Theme:Register("UI", "ui.transparent", "Transparent", {
	["Colours"] = {
		["Primary Colour"] = Color(47, 47, 47, 150),
		["Secondary Colour"] = Color(44, 44, 44, 150),
		["Tri Colour"] = Color(38, 38, 38, 150),
		["Accent Colour"] = Color(160, 40, 40, 150),
		["Text Colour"] = color_white,
		["Text Colour 2"] = color_white,
		["Outlines Colour"] = color_black,
		["Outlines Colour 2"] = Color(30, 30, 30, 150)
	},

	["Toggles"] = {
		["Outlines"] = false
	}
})


Theme:Register("UI", "ui.light", "Light", {
	["Colours"] = {
		["Primary Colour"] = Color(240, 240, 250),
		["Secondary Colour"] = Color(235, 235, 235),
		["Tri Colour"] = Color(40, 40, 40),
		["Accent Colour"] = Color(200, 100, 100, 255),
		["Text Colour"] = color_black,
		["Text Colour 2"] = color_white,
		["Outlines Colour"] = color_white,
		["Outlines Colour 2"] = color_black
	},

	["Toggles"] = {
		["Outlines"] = false
	}
})

Theme:Register("UI", "ui.clear", "Transparent", {
	["Colours"] = {
		["Primary Colour"] = Color(47, 47, 47, 80),
		["Secondary Colour"] = Color(44, 44, 44, 80),
		["Tri Colour"] = Color(38, 38, 38, 255),
		["Accent Colour"] = Color(80, 30, 40, 255),
		["Text Colour"] = color_white,
		["Text Colour 2"] = color_white,
		["Outlines Colour"] = color_black,
		["Outlines Colour 2"] = Color(30, 30, 30)
	},

	["Toggles"] = {
		["Outlines"] = false
	}
})

Theme:Register("UI", "ui.default", "Default", {
	["Colours"] = {
		["Primary Colour"] = Color(47, 47, 47, 255),
		["Secondary Colour"] = Color(44, 44, 44, 255),
		["Tri Colour"] = Color(38, 38, 38, 255),
		["Accent Colour"] = Color(0, 160, 200),
		["Text Colour"] = color_white,
		["Text Colour 2"] = color_white,
		["Outlines Colour"] = color_black,
		["Outlines Colour 2"] = Color(30, 30, 30)
	},

	["Toggles"] = {
		["Outlines"] = false
	}
})

-- Scoreboard
Theme:Register("Scoreboard", "scoreboard.kawaii", "Kawaii Clan", {
	HasMulti = true,
	["Clear"] = {
		["Colours"] = {
			["Primary Colour"] = Color(38, 38, 38, 100),
			["Secondary Colour"] = Color(44, 44, 44, 100),
			["Tertiary Colour"] = Color(47, 47, 47, 100),
			["Accent Colour"] = Color(0, 160, 200, 100),
			["Outlines Colour"] = color_black,
			["Text Colour"] = color_white,
			["Text Colour 2"] = Color(200, 200, 200)
		},

		["Toggles"] = {
			["Outlines"] = false
		}
	},

	["Default"] = {
		["Colours"] = {
			["Primary Colour"] = Color(47, 47, 47, 255),
			["Secondary Colour"] = Color(44, 44, 44, 255),
			["Tri Colour"] = Color(38, 38, 38, 255),
			["Accent Colour"] = Color(0, 160, 200),
			["Outlines Colour"] = color_black,
			["Text Colour"] = color_white,
			["Text Colour 2"] = color_black
		},

		["Toggles"] = {
			["Outlines"] = false
		}
	},

	["Light"] = {
		["Colours"] = {
			["Primary Colour"] = Color(65, 342, 43),
			["Secondary Colour"] = Color(23, 341, 4),
			["Tri Colour"] = Color(6, 430, 340),
			["Accent Colour"] = Color(20, 640, 3, 255),
			["Text Colour"] = color_black,
			["Text Colour 2"] = color_white,
			["Outlines Colour"] = color_white,
			["Outlines Colour 2"] = color_black
		},

		["Toggles"] = {
			["Outlines"] = false 
		}
	}
})

local cache = {}
function Theme:GetOptions(id)
	local preference = Settings:GetValue('preference.'..id)
	return preference
end

function Theme:RemoveCache()
	cache = {}
end

-- Get preferance
local sel = "nui.kawaii"
local selop = "Grey"
local sel2 = "scoreboard.kawaii"
local selop2 = "Default"
local sel3 = "hud.momentum"
local selop3 = "Grey"
function Theme:GetPreference(id, base)
	if (id == "UI") then 
		return themes["ui.default"].options
	elseif (id == "NumberedUI") then 
		local theme = themes[sel].options

		-- Multi
		return theme[selop], sel
	elseif (id == "Scoreboard") then 
		local theme = themes[sel2].options

		-- Multi
		if (theme.HasMulti) then 
			return theme[selop2], sel
		else
			return theme, sel
		end
	elseif (id == "HUD") then
		local t = Settings:GetValue('selected.hud')
		local thms = Settings:GetValue(t).options

		-- Multi
		return thms[self:GetOptions(t) or base], t
	end
end

-- Get theme for id
function Theme:Get(id)
	return Settings:GetValue(id).options
end

end