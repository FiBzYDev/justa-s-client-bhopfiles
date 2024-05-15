-- "gamemodes\\bhop\\gamemode\\userinterface\\cl_hud.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- HUD
-- by Justa

-- Font
surface.CreateFont( "HUDTimerMed", { size = 20, weight = 4000, font = "Trebuchet24" } )
surface.CreateFont( "HUDTimerMedThick", { size = 22, weight = 40000, font = "Trebuchet24" } )
surface.CreateFont( "HUDTimerBig", { size = 28, weight = 400, font = "Trebuchet24" } )
surface.CreateFont( "HUDTimerUltraBig", { size = 48, weight = 4000, font = "Trebuchet24" } )
surface.CreateFont( "HUDTimerKindaUltraBig", { size = 28, weight = 4000, font = "Trebuchet24" } )

surface.CreateFont( "HUDHeaderBig", { size = 44, font = "Coolvetica" } )
surface.CreateFont( "HUDHeader", { size = 30, font = "Coolvetica" } )
surface.CreateFont( "HUDTitle", { size = 24, font = "Coolvetica" } )
surface.CreateFont( "HUDTitleSmall", { size = 20, font = "Coolvetica" } ) 

surface.CreateFont( "HUDFont", { size = 22, weight = 800, font = "Tahoma" } )
surface.CreateFont( "HUDFontSmall", { size = 14, weight = 800, font = "Tahoma" } )
surface.CreateFont( "HUDLabelSmall", { size = 12, weight = 800, font = "Tahoma" } )
surface.CreateFont( "HUDLabelMed", { size = 15, weight = 550, font = "Verdana" } )
surface.CreateFont( "HUDLabel", { size = 17, weight = 550, font = "Verdana" } )

surface.CreateFont( "HUDSpecial", { size = 17, weight = 550, font = "Verdana", italic = true } )
surface.CreateFont( "HUDSpeed", { size = 16, weight = 800, font = "Tahoma" } )
surface.CreateFont( "HUDTimer", { size = 17, weight = 800, font = "Trebuchet24" } )
surface.CreateFont( "HUDMessage", { size = 30, weight = 800, font = "Verdana" } )
surface.CreateFont( "HUDCounter", { size = 144, weight = 800, font = "Coolvetica" } )

-- Converting a time
local fl, fo  = math.floor, string.format
local function ConvertTime( ns )
	if ns > 3600 then
		return fo( "%d:%.2d:%.2d.%.3d", fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 1000 % 1000 ) )
	else
		return fo( "%.2d:%.2d.%.3d", fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 1000 % 1000 ) )
	end
end

local function cTime(ns)
	if (type(ns)=='boolean') then ns = 0 end 

	if ns > 3600 then
		return fo( "%d:%.2d:%.2d.%.1d", fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 10 % 10 ) )
	elseif ns > 60 then 
		return fo( "%.1d:%.2d.%.1d", fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 10 % 10 ) )
	else
		return fo( "%.1d.%.1d", fl( ns % 60 ), fl( ns * 10 % 10 ) )
	end
end

-- Neat :)
HUD = {}
HUD.Ids = {"Counter Strike: Source", "Flow Network"}

-- Themes
local sync = "Sync: N/A%"
local SSJStats = {"", 0, 0, false} 

-- Blur
local blur = Material("pp/blurscreen")

HUD.Themes = {
	["hud.css"] = function(pl, data)
		local base = Color(20, 20, 20, 150)
		local text = color_white

		if (data.strafe) then 
			sync = data.sync or sync
			return
		end

		-- Current Vel
		local velocity = math.floor(pl:GetVelocity():Length2D())

		-- Strings
		local time = "Time: "
		local pb = "PB: "
		local style = TIMER:GetStyle(pl)
		local mode = TIMER:GetMode(pl)
		local stylename = TIMER:GetFullStateByStyleMode(style, mode) .. (pl:IsBot() and " Bot" or "")

		-- Personal best
		local personal = ConvertTime(data.pb or 0)

		-- Current Time
		local current = data.current < 0 and 0 or data.current
		local currentf = cTime( TIMER:GetTime(pl) )
		
		-- Jumps
		jumps = pl.jumps or 0

		-- Activity 
		local activity = pl.time and 1 or 2
		activity = (pl:GetNWInt("inPractice", false) or (pl.finished)) and 3 or activity
		activity = (activity == 1 and (pl:IsBot() and 4 or 1) or activity)

		-- Outer box
		local width = string.len(stylename) < 15 and 130 or 200
		width = string.len(stylename) < 25 and width or 260
		local height = {124, 64, 44, 84}
		height = height[activity]
		local xPos = (ScrW() / 2) - (width / 2)
		local yPos = ScrH() - height - 60 - (LocalPlayer():Team() == TEAM_SPECTATOR and 50 or 0)

		draw.RoundedBox(16, xPos, yPos, width, height, base)

		-- HUD on the bottom
		if (activity == 1) then 
			draw.SimpleText(stylename, "HUDTimer", ScrW() / 2, yPos + 20, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)		
			draw.SimpleText(time .. currentf, "HUDTimer", ScrW() / 2, yPos + 40, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Jumps: " .. jumps or 0, "HUDTimer", ScrW() / 2, yPos + 60, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Sync: "..(pl.sync or 0).."%", "HUDTimer", ScrW() / 2, yPos + 80, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
			draw.SimpleText("Speed: " .. velocity, "HUDTimer", ScrW() / 2, yPos + 100, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
		elseif (activity == 2) then
			draw.SimpleText("In Start Zone", "HUDTimer", ScrW() / 2, yPos + 20, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Speed: " .. velocity, "HUDTimer", ScrW() / 2, yPos + 40, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
		elseif (activity == 3) then
			draw.SimpleText("Speed: " .. velocity, "HUDTimer", ScrW() / 2, yPos + 20, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
		elseif (activity == 4) then 
			draw.SimpleText(stylename, "HUDTimer", ScrW() / 2, yPos + 20, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)		
			draw.SimpleText(time .. currentf, "HUDTimer", ScrW() / 2, yPos + 40, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Speed: " .. velocity, "HUDTimer", ScrW() / 2, yPos + 60, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)		
		end

		local wr, wrn
		if (not TIMER.WorldRecord) or (not TIMER.WorldRecord[mode]) or (not TIMER.WorldRecord[mode][style]) then 
			wr = "No time recorded"
			wrn = ""
		else 
			wr = ConvertTime(TIMER.WorldRecord[mode][style].time)
			wrn = "(" .. TIMER.WorldRecord[mode][style].name .. ")"
		end

		-- Top 
		draw.SimpleText("WR: " .. wr .. " " .. wrn, "HUDTimerBig", 10, 6, text)
		draw.SimpleText(pb .. personal, "HUDTimerBig", 10, 34, text)	

		-- Spec 
		if (LocalPlayer():Team() == TEAM_SPECTATOR) then 
			-- Draw big box
			surface.SetDrawColor(base)
			surface.DrawRect(0, ScrH() - 80, ScrW(), ScrH())

			-- Name
			local name = pl:Name()

			-- Bot?
			if (pl:IsBot()) then 
				name = pl.pb and (TIMER:GetFullStateByStyleMode(pl.style, pl.mode) .. " Replay (" .. (pl.name .. ")")) or "Waiting..."

				if (pl:Nick() == "Multi-Style Replay") then 
					draw.SimpleText("Press E to change replay", "HUDTimer", ScrW() - 20, ScrH() - 40, text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end
			end

			-- Did I press E 
			if input.IsKeyDown(KEY_E) and (not LocalPlayer().cane) and pl:IsBot() and pl:Nick() == "Multi-Style Replay" and (not LocalPlayer():IsTyping()) then 
				LocalPlayer():ConCommand("say !replay")
				LocalPlayer().cane = true
				timer.Simple(1, function()
					LocalPlayer().cane = false 
				end)
			end

			draw.SimpleText(name, "HUDTimer", ScrW() / 2, ScrH() - 40, text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)		
		end	
	end,

	-- Flow Network
	["hud.flow"] = function(pl, data)
		-- Size
		local width = 230
		local height = 95

		-- Positions
		local xPos = 40
		local yPos = 40


		local theme = Theme:GetPreference("HUD")
		local BASE = theme["Colours"]["Secondary Colour"]
		local INNER = theme["Colours"]["Primary Colour"]
		local BAR = theme["Colours"]["Accent Colour"]
		local TEXT = theme["Colours"]["Text Colour"]
		local OUTLINE = theme["Toggles"]["Outlines"] and theme["Colours"]["Outlines Colour"] or Color(0, 0, 0, 0)

		-- Strafe HUD?
		if (data.strafe) then 
			xPos = xPos + 5

			-- Height/Width is a bit different on this
			height = height + 35
			width = width

			-- Easy calculations
			local x, y, w, h = 0, 0, 0, 0

			-- Draw base 
			surface.SetDrawColor(BASE)
			surface.DrawRect(ScrW() - xPos - width, ScrH() - yPos - height, width + 5, height)

			-- Draw inners
			surface.SetDrawColor(INNER)
			surface.DrawRect(ScrW() - xPos + 5 - width, ScrH() - yPos - (height - 5), width - 5, 55)
			
			-- A
			x, y, w, h = ScrW() - xPos + 5 - width, ScrH() - yPos - (height - 65), (width / 2) - 5, 27
			surface.SetDrawColor(data.a and BAR or INNER)
			surface.DrawRect(x, y, w, h)
			draw.SimpleText("A", "HUDTimer", x + w/2, y + h/2, TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			-- D
			x, y = ScrW() - xPos + 5 - width/2, ScrH() - yPos - (height - 65)
			surface.SetDrawColor(data.d and BAR or INNER)
			surface.DrawRect(x, y, w, h)
			draw.SimpleText("D", "HUDTimer", x + w/2, y + h/2, TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			-- Left
			x, y = ScrW() - xPos + 5 - width, ScrH() - yPos - (height - 97)
			surface.SetDrawColor(data.l and BAR or INNER)
			surface.DrawRect(x, y, w, h)
			draw.SimpleText("Mouse Left", "HUDTimer", x + w/2, y + h/2, TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			-- Right
			x = ScrW() - xPos + 5 - width/2
			surface.SetDrawColor(data.r and BAR or INNER)
			surface.DrawRect(x, y, w, h)
			draw.SimpleText("Mouse Right", "HUDTimer", x + w/2, y + h/2, TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			-- Extra Keys
			x, y = ScrW() - xPos + 15 - width, ScrH() - yPos - (height - 20)
			draw.SimpleText("Extras: ", "HUDTimer", x, y, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Strafes
			draw.SimpleText("Strafes: " .. (data.strafes or 0), "HUDTimer", x, y + 23, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			x = ScrW() - xPos - 10
			draw.SimpleText("Duck", "HUDTimer", x, y, data.duck and BAR or TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText("Jump", "HUDTimer", x - 42, y, data.jump and BAR or TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText("S", "HUDTimer", x - 88, y, data.s and BAR or TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText("W", "HUDTimer", x - 108, y, data.w and BAR or TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(('Sync: '..(pl.sync or 0)..'%' or "Sync: 0%"), "HUDTimer", x, y + 23, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			-- Outlines
			surface.SetDrawColor(OUTLINE)
			surface.DrawOutlinedRect(ScrW() - xPos - width, ScrH() - yPos - height, width + 5, height)
			surface.DrawOutlinedRect(ScrW() - xPos + 5 - width, ScrH() - yPos - (height - 5), width - 5, 55)
			surface.DrawOutlinedRect(ScrW() - xPos + 5 - width, ScrH() - yPos - (height - 65), (width / 2) - 5, 27)
			surface.DrawOutlinedRect(ScrW() - xPos + 5 - width/2, ScrH() - yPos - (height - 65), (width / 2) - 5, 27)
			surface.DrawOutlinedRect(ScrW() - xPos + 5 - width, ScrH() - yPos - (height - 97), (width / 2) - 5, 27)
			surface.DrawOutlinedRect(ScrW() - xPos + 5 - width/2, ScrH() - yPos - (height - 97), (width / 2) - 5, 27)

			return 
		end

		-- In spec
		if LocalPlayer():Team() == TEAM_SPECTATOR then
			local ob = pl
			if IsValid( ob ) and ob:IsPlayer() then
				local nStyle = TIMER:GetStyle(ob)
				local szStyle = TIMER:TranslateStyle(nStyle)
				
				local header, pla
				if ob:IsBot() then
					header = "Spectating Bot"
					pla =  (ob.name and ob.name or "ERROR") .. " (" .. szStyle .. " style)"
				else
					header = "Spectating"
					pla = ob:Name() .. " (" .. szStyle .. ")"
				end

				draw.SimpleText( header, "HUDHeaderBig", ScrW() / 2, ScrH() - 58 - 40, Color(25, 25, 25, 255), TEXT_ALIGN_CENTER )
				draw.SimpleText( header, "HUDHeaderBig", ScrW() / 2, ScrH() - 60 - 40, Color(214, 59, 43, 255), TEXT_ALIGN_CENTER )
				draw.SimpleText( pla, "HUDHeader", ScrW() / 2, ScrH() - 18 - 40, Color(25, 25, 25, 255), TEXT_ALIGN_CENTER )
				draw.SimpleText( pla, "HUDHeader", ScrW() / 2, ScrH() - 20 - 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			end
		end

		-- Current Vel
		local velocity = math.floor(pl:GetVelocity():Length2D())

		-- Strings
		local time = "Time: "
		local pb = "PB: "

		-- Personal best
		local personal = pl:IsBot() and pl.pb or data.pb 
		local personalf = ConvertTime(personal) .. data.recTp

		-- Current Time
		local current = data.current
		local currentf = ConvertTime(current) .. data.curTp

		-- Start Zone
		if pl:GetNWInt("inPractice", false) then 
			currentf = ""
			personalf = ""
			time = "Timer Disabled"
			pb = "Practice mode has no timer"
		elseif (not pl.time) then 
			currentf = ""
			personalf = ""
			time = "Timer Disabled"
			pb = "Leave the zone to start timer"
		end

		-- Draw base 
		surface.SetDrawColor(BASE)
		surface.DrawRect(xPos, ScrH() - yPos - 95, width, height)

		-- Draw inners
		surface.SetDrawColor(INNER)
		surface.DrawRect(xPos + 5, ScrH() - yPos - 90, width - 10, 55)
		surface.DrawRect(xPos + 5, ScrH() - yPos - 30, width - 10, 25)

		-- Bar
		local cp = math.Clamp(velocity, 0, 3500) / 3500
		surface.SetDrawColor(BAR)
		surface.DrawRect(xPos + 5, ScrH() - yPos - 30, cp * 220, 25)

		-- Text
		draw.SimpleText(time, "HUDTimer", (currentf != "" and xPos + 12 or xPos + width / 2), ScrH() - yPos - 75, TEXT, (currentf != "" and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER), TEXT_ALIGN_CENTER)
		draw.SimpleText(pb, "HUDTimer", (currentf != "" and xPos + 13 or xPos + width / 2), ScrH() - yPos - 50, TEXT, (currentf != "" and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER), TEXT_ALIGN_CENTER)
		draw.SimpleText(velocity .. " u/s", "HUDTimer", xPos + 115, ScrH() - yPos - 18, TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(currentf, "HUDTimer", xPos + width - 12, ScrH() - yPos - 75, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(personalf, "HUDTimer", xPos + width - 12, ScrH() - yPos - 50, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		-- Draw Outlines
		surface.SetDrawColor(OUTLINE)
		surface.DrawOutlinedRect(xPos, ScrH() - yPos - 95, width, height)
		surface.DrawOutlinedRect(xPos + 5, ScrH() - yPos - 90, width - 10, 55)
		surface.DrawOutlinedRect(xPos + 5, ScrH() - yPos - 30, width - 10, 25)
	end,

	["hud.momentum"] = function(pl, data)
		local width = 200
		local height = 100
		local xPos = (ScrW() / 2) - (width / 2)
		local yPos = ScrH() - 90 - height

		local theme = Theme:GetPreference("HUD")
		local box = theme["Colours"]["Box Colour"]
		local tc = theme["Colours"]["Text Colour #1"]
		local tc2 = theme["Colours"]["Text Colour #2"]
		local su = theme["Colours"]["Speed Positive"]
		local sd = theme["Colours"]["Speed Negative"]

		-- Strafe hud?
		if (data.strafe) then 
			local sync = pl.sync or 0
			if (sync ~= 0) and (type(sync) == 'number') then 
				local col = sync > 93 and su or tc 
				col = sync < 90 and sd or col
				col = sync == 0 and color_white or col

				draw.SimpleText("Sync", "HUDTimerMedThick", ScrW() / 2, yPos + height + 10, tc, TEXT_ALIGN_CENTER)
				draw.SimpleText(sync, "HUDTimerKindaUltraBig", ScrW() / 2, yPos + height + 34, col, TEXT_ALIGN_CENTER)

				-- Sync bar thingy
				local barwidth = sync / 100 * (width + 10)
				surface.SetDrawColor(col)
				surface.DrawRect(xPos - 10, ScrH() - 24, barwidth, 16)
			end

			-- Keys!
			return
		end

		-- Needed
		local start = false
		if (not pl:GetNWInt("inPractice", false)) and (pl.time == false) then 
			start = true 
		end

		-- Main box
		surface.SetDrawColor(box)
		surface.DrawRect(xPos, yPos, width, height)

		-- Speed
		local speed = pl:GetVelocity():Length2D()

		-- Old speed?
		pl.speedcol = pl.speedcol or tc
		pl.current = pl.current or 0 
		local diff = speed - pl.current
		if pl.current == speed or speed == 0 then 
			pl.speedcol = tc
		elseif diff > -2 then 
			pl.speedcol = su
		elseif diff < -2 then
			pl.speedcol = sd
		end
		-- Draw
		draw.SimpleText(math.ceil(speed), "HUDTimerKindaUltraBig", ScrW() / 2, yPos - 80, (pl:GetMoveType() == MOVETYPE_NOCLIP) and tc or pl.speedcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Time
		local status = "No Timer"
		local time = TIMER:GetTime(pl)

		-- Checks
		if (pl.time) then
			status = cTime(time)
		end

		if (pl.finished) then 
			status = cTime(pl.finished)

			if not pl.status then 
				draw.SimpleText("Map Completed", "HUDTimer", ScrW() / 2, yPos - 14, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end 
		end

		-- Print
		draw.SimpleText(status, "HUDTimerKindaUltraBig", ScrW() / 2, yPos + 20, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Start zone?
		if (start) then 
			draw.SimpleText("Start Zone", "HUDTimer", ScrW() / 2, yPos - 14, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if pl:GetNWInt("inPractice", false) then 
			draw.SimpleText("Practicing", "HUDTimer", ScrW() / 2, yPos - 14, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if (pl:IsBot()) and (not start) and (pl.time) and (pl.pb) then
			local per = math.ceil(((pl.status and pl.finished or (CurTime() - pl.time)) / pl.pb) * 100) 
			draw.SimpleText("Progress: " .. per .. "%", "HUDTimer", ScrW() / 2, yPos - 14, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if pl:IsBot() then 
			draw.SimpleText("Status: " .. (pl.status and "Paused" or "Playing (" .. pl.speed .. "x)"), "HUDTimer", ScrW() / 2, yPos + height - 10, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end 

		-- Map name 
		draw.SimpleText("Map: " .. game.GetMap(), "HUDTimer", 10, 8, tc, TEXT_ALIGN_LEFT)

		-- Spectator?
		if (LocalPlayer():Team() == TEAM_SPECTATOR) then 
			local name = pl:Nick()
			if (pl:IsBot()) then 
				name = pl.pb and (TIMER:GetFullStateByStyleMode(pl.style, pl.mode) .. " Replay (" .. (pl.name .. ")")) or "Waiting..."
				if (pl:Nick() == "Multi-Style Replay") then 
					draw.SimpleText("Press E to change replay", "HUDTimer", ScrW() / 2, ScrH() - 50, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			-- Say there name 
			draw.SimpleText("Spectating", "HUDTimerKindaUltraBig", ScrW() / 2, 30, tc2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(name, "HUDTimerKindaUltraBig", ScrW() / 2, 56, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			-- Did I press E 
			if input.IsKeyDown(KEY_E) and (not LocalPlayer().cane) and pl:IsBot() and pl:Nick() == "Multi-Style Replay" and (not LocalPlayer():IsTyping()) then 
				LocalPlayer():ConCommand("say !replay")
				LocalPlayer().cane = true
				timer.Simple(1, function()
					LocalPlayer().cane = false 
				end)
			end
		end


		-- Personal best and WR
		local wr, wrn
		local mode = TIMER:GetMode(pl)
		local style = TIMER:GetStyle(pl)
		if (not TIMER.WorldRecord) or (not TIMER.WorldRecord[mode]) or (not TIMER.WorldRecord[mode][style]) then 
			wr = "No time recorded"
			wrn = ""
		else 
			wr = ConvertTime(TIMER.WorldRecord[mode][style].time)
			wrn = "(" .. TIMER.WorldRecord[mode][style].name .. ")"
		end

		-- Top 
		local personal = ConvertTime(data.pb or 0)
		draw.SimpleText("World Record: " .. wr .. " " .. wrn, "HUDTimer", 9, 28, tc)
		draw.SimpleText("Personal Best: " .. personal, "HUDTimer", 10, 48, tc)	
	end,

	["hud.simple"] = function(pl, data)
		local theme = Theme:GetPreference("HUD")
		local tc = theme["Colours"]["Text Colour"]
		local wr, wrn
		local mode = TIMER:GetMode(pl)
		local style = TIMER:GetStyle(pl)

		if data.strafe then return end

		overwrite_ssj = false 
		if (LocalPlayer():Team() == TEAM_SPECTATOR) then 
			local name = pl:Nick()
			if (pl:IsBot()) then 
				name = pl.pb and (TIMER:GetFullStateByStyleMode(pl.style, pl.mode) .. " Replay (" .. (pl.name .. ")")) or "Waiting..."
				if (pl:Nick() == "Multi-Style Replay") then 
					overwrite_ssj = "Press E to change replay"
				end
			end

			-- Say there name 
			draw.SimpleText("Spectating", "hud.simplefont", ScrW() / 2, 30, tc2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(name, "hud.simplefont", ScrW() / 2, 56, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			-- Did I press E 
			if input.IsKeyDown(KEY_E) and (not LocalPlayer().cane) and pl:IsBot() and pl:Nick() == "Multi-Style Replay" and (not LocalPlayer():IsTyping()) then 
				LocalPlayer():ConCommand("say !replay")
				LocalPlayer().cane = true
				timer.Simple(1, function()
					LocalPlayer().cane = false 
				end)
			end
		end

		if (not TIMER.WorldRecord) or (not TIMER.WorldRecord[mode]) or (not TIMER.WorldRecord[mode][style]) then 
			wr = "No time recorded"
			wrn = ""
		else 
			wr = ConvertTime(TIMER.WorldRecord[mode][style].time)
			wrn = "(" .. TIMER.WorldRecord[mode][style].name .. ")"
		end

		-- Top 
		local personal = ConvertTime(data.pb or 0)
		draw.SimpleText("Map: " .. game.GetMap(), "hud.simplefont", 10, 8, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("World Record: " .. wr .. " " .. wrn, "hud.simplefont", 9, 28, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Personal Best: " .. personal, "hud.simplefont", 10, 48, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)	

		local zonestatus = TIMER:GetFullState(pl)
		local addition = (SSJStats[4] and (" (" .. SSJStats[3] .. "%, " .. (SSJStats[2] > 0 and "+" or "") .. SSJStats[2] .. ")") or "")
		local ssjtext = (SSJStats[1] ~= 0 and SSJStats[1] or "")
		local rank = TIMER:GetRank(pl)

		local jumps = "Jumps: " .. (pl.jumps or 0)
		local sync = "Sync: " .. (pl.sync or 0) .. "%"

		if (not pl:GetNWInt("inPractice", false)) and (pl.time == false) then 
			zonestatus = "Start Zone" 

			if not pl:IsBot() then 
				if type(rank[1]) == 'boolean' then 
					ssjtext = "Unranked"
				else 
					ssjtext = "Rank: #" .. rank[1]
				end 
				jumps = ""
				sync = ""
			end
		end

		if pl:GetNWInt("inPractice", false) then 
			zonestatus = "Practicing"
		end

		-- speed
		draw.SimpleText(math.floor(pl:GetVelocity():Length2D()), "hud.simplefont", ScrW() / 2, (ScrH() / 2) - 180, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- cur time 
		local status = "Disabled"
		local time = TIMER:GetTime(pl)

		-- Checks
		if (pl.time) then
			status = TIMER:GetFormatted(time)
		end

		if (pl.finished) and not (pl.status) then 
			status = cTime(pl.finished)
			zonestatus = "Map Completed"
			--draw.SimpleText("Map Completed", "HUDTimer", ScrW() / 2, yPos - 14, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText("Time: " .. status, "hud.simplefont", ScrW() / 2, ScrH() - 130, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
		draw.SimpleText(zonestatus, "hud.simplefont", ScrW() / 2, ScrH() - 100, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(overwrite_ssj and overwrite_ssj or (ssjtext .. addition), "hud.simplefont", ScrW() / 2, ScrH() - 70, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(pl:IsBot() and "" or sync, "hud.simplefont", ScrW() - 100, ScrH() - 70, tc, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)	
		draw.SimpleText(pl:IsBot() and "" or jumps, "hud.simplefont", 100, ScrH() - 70, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	
	end,
}

local duration_cvar = CreateClientConVar("bhop_ssj_fadeduration", 1.5, true, false, "Controls how long in seconds pass before SSJHud fades", 0, 10)
cvars.AddChangeCallback("bhop_ssj_fadeduration", function(cvar, old, new)
	duration = tonumber(new)
end)

local last_jump = 0
local duration = duration_cvar:GetFloat()
local alpha = 255

-- Capture data for ssj 
NETWORK:GetNetworkMessage("SSJ", function(_, data)
	local current = data[1]
	local difference = data[2]
	local gain = data[3]
	local colour = difference > 0 and Color(0, 200, 0) or Color(200, 0, 0)
	local prev = data[4]
	
	SSJStats = {current, difference, gain, prev}
	last_jump = CurTime()
	alpha = 255
end)

-- SSJ hud
local function SSJ_HUD()
	if (last_jump + duration < CurTime()) then 
		alpha = alpha - 0.5
	end 

	local current, difference, gain, prev = unpack(SSJStats)
	local colour = Color(255, 255, 255, alpha)

	-- Previous?
	if (prev) then 
		if (gain >= 80) then 
			colour = Color(0, 160, 200, alpha)
		elseif (gain > 70) and (gain <= 79.99) then 
			colour = Color(0, 200, 0, alpha)
		elseif (gain > 60) and (gain <= 69.99) then 
			colour = Color(220, 150, 0, alpha)
		else 
			colour = Color(200, 0, 0, alpha)
		end 

		draw.SimpleText(math.floor(prev), "HUDTimerKindaUltraBig", ScrW() / 2, (ScrH() / 2) - 140, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(gain .. "%", "HUDTimerKindaUltraBig", ScrW() / 2, (ScrH() / 2) - 60, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText(current, "HUDTimerUltraBig", ScrW() / 2, (ScrH() / 2) - 100, colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Strafe trainer stuff 
local function GetColour(percent)
	local offset = math.abs(1 - percent)
	if offset < 0.05 then 
		return Color(0, 160, 200)
	elseif (0.05 <= offset) and (offset < 0.1) then 
		return Color(0, 200, 0)
	elseif (0.1 <= offset) and (offset < 0.25) then 
		return Color(220, 255, 0)
	elseif (0.25 <= offset) and (offset < 0.5) then 
		return Color(200, 150, 0)
	else 
		return Color(200, 0, 0)
	end
end

local lp = LocalPlayer
local function Display()
	if not strafetrainer:GetBool() then return end
	if IsValid(lp():GetObserverTarget()) and lp():GetObserverTarget():IsBot() then return end

	local c = GetColour(CurrentTrainValue)
	local x = ScrW() / 2 
	local y = (ScrH() / 2) + 100
	local w = 240
	local size = 4
	local msize = size / 2
	local h = 14
	local movething = 22
	local spacing = 6
	local endingval = math.floor(CurrentTrainValue * 100)
	surface.SetDrawColor(c)

	if endingval >= 0 and endingval <= 200 then 
		local move = w * (CurrentTrainValue/2)
		surface.DrawRect(x - (w / 2) + move, y - (movething/2) + (size / 2), size, movething)
	else
		draw.SimpleText("Invalid", "HUDTimerKindaUltraBig", x, y + (size / 2), c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	y = y + 32
	surface.DrawRect(x - (w / 2) + size, y, w - (size*2), size)
	surface.DrawRect(x - (w / 2), y - h, size, h + size)
	surface.DrawRect(x + (w / 2) - size, y - h, size, h + size)
	surface.DrawRect(x - (msize / 2), y + size, msize, h)
	draw.SimpleText("100", "HUDTimer", x, y + size + spacing + h, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	y = y - (32 * 2)
	surface.DrawRect(x - (w / 2) + size, y, w - (size*2), size)
	surface.DrawRect(x - (w / 2), y, size, h + size)
	surface.DrawRect(x + (w / 2) - size, y, size, h + size)
	surface.DrawRect(x - (msize / 2), y - h, msize, h)


	draw.SimpleText(endingval, "HUDTimer", x, y - h - spacing, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	
end 
hook.Add("HUDPaint", "StrafeTrainer", Display)


local spechud = CreateClientConVar("bhop_hidespec", 0, true, false, "Draw spectator hud", 0, 1)
concommand.Add("bhop_hidespec_toggle", function(client, cmd, args)
	spechud:SetBool(!spechud:GetBool())
end)


local function DrawSpecHUD()
	if spechud:GetBool() then return end 

	local lp = LocalPlayer()
	local txt = "Spectating %s (%s):"
	local SpecList = {}

	if lp:Alive() and lp.SpectatorList and #lp.SpectatorList > 0 then
		SpecList = lp.SpectatorList
		txt = string.format(txt, "You", tostring(#lp.SpectatorList))
	elseif lp:Team() == TEAM_SPECTATOR and IsValid(lp:GetObserverTarget()) and lp:GetObserverTarget().SpectatorList and #lp:GetObserverTarget().SpectatorList > 0 then 
		SpecList = lp:GetObserverTarget().SpectatorList
		txt = string.format(txt, lp:GetObserverTarget():GetName(), tostring(#lp:GetObserverTarget().SpectatorList))
	else 
		return 
	end

	draw.SimpleText(txt, "ui.mainmenu.button", ScrW() - 20, ScrH() / 2 - (#SpecList * 10), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	for i = 1, #SpecList do 
		local spectator = SpecList[i]
		if (not spectator) or (not IsValid(spectator)) then 
			SpecList[i] = nil
			continue 
		end 
		draw.SimpleText(spectator:GetName(), "ui.mainmenu.button", ScrW() - 20, ScrH() / 2 + (i * 20) - (#SpecList * 10), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

function HUD:Draw(style, client, data) 
	-- Zone edit.
	if (ZEdit) and (ZEdit.state) then 
		ZEdit:Draw()
		return
	end

	-- SSJ?
	if (SETTING:Get(LocalPlayer(), 'ssj_hud')) then 
		SSJ_HUD()
	end

	local theme, id = Theme:GetPreference("HUD")
	self.Themes[id](client, data)
	DrawSpecHUD()
end

local HUDItems = { CHudHealth = true, CHudBattery = true, CHudAmmo = true, CHudSecondaryAmmo = true, CHudSuitPower = true }
function GM:HUDShouldDraw(element)
	if HUDItems[element] then 
		return false 
	end 

	return true 
end

function GM:HUDDrawTargetID()
	return false 
end 

-- Current World Record
current_world_record = 0

local function GetWR()
	local o = IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() or LocalPlayer()
	local s = TIMER:GetStyle(o)
	local m = TIMER:GetMode(o)
	if (not TIMER.WorldRecord) then return 0 end
	return TIMER.WorldRecord[m] and (TIMER.WorldRecord[m][s] and TIMER.WorldRecord[m][s].time or 0) or 0
end

local function GetTimePiece( nCompare, nStyle )
	local nDifference = nCompare - GetWR()
	local nAbs = math.abs( nDifference )

	if nDifference < 0 then
		return fo( " [ -%.2d:%.2d]", fl( nAbs / 60 ), fl( nAbs % 60 ) )
	elseif nDifference == 0 then
		return " [WR]"
	else
		return fo( " [+%.2d:%.2d]", fl( nAbs / 60 ), fl( nAbs % 60 ) )
	end
end

function GM:HUDPaintBackground()
	local nWidth, nHeight = ScrW(), ScrH() - 30
	local nHalfW = nWidth / 2
	local lpc = LocalPlayer()
	
	if not IsValid( lpc ) then return end
	
	if lpc:Team() == TEAM_SPECTATOR then
		local ob = lpc:GetObserverTarget()
		if IsValid(ob) and ob:IsPlayer() then
			local nStyle = TIMER:GetStyle(ob)
			local szStyle = TIMER:TranslateStyle(nStyle)
	
			local nCurrent, nRecord, nSpeed = TIMER:GetTime(ob) or 0, select(2, TIMER:GetPersonalBest(ob, ob.mode, ob.style)) or 0, ob:GetVelocity():Length2D()
			HUD:Draw(2, ob, {pos = {Xo, Yo}, pb = nRecord, current = nCurrent, curTp = GetTimePiece(nCurrent, nStyle), recTp = GetTimePiece(nRecord, nStyle)})
		end

		if not CSRemote then return end
	else
		local nCurrent, nSpeed, Tbest = TIMER:GetTime(lpc) or 0, lpc:GetVelocity():Length2D(), select(2, TIMER:GetPersonalBest(lpc, lpc.mode, lpc.style)) or 0
		HUD:Draw(2, lpc, {pos = {Xo, Yo}, pb = Tbest, current = nCurrent, curTp = GetTimePiece(nCurrent, nStyle), recTp = GetTimePiece(Tbest, nStyle)})
		
		local w = lpc:GetActiveWeapon()
		if IsValid( w ) and w.Clip1 then
			local nAmmo = lpc:GetAmmoCount( w:GetPrimaryAmmoType() )
			local szWeapon = w:Clip1() .. " / " .. nAmmo
			if nAmmo == 0 then return end
			draw.SimpleText( szWeapon, "HUDHeader", nWidth - 18, ScrH() - 18, Color(25, 25, 25, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( szWeapon, "HUDHeader", nWidth - 20, ScrH() - 20, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		end
		
		if CSRemote then return end
	end
end