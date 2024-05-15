-- "gamemodes\\bhop\\gamemode\\userinterface\\scoreboards\\cl_default.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
PRIMARY = color_white
SECONDARY = color_white
TRI = color_white
ACCENT = color_white
TEXT = color_white 
OUTLINE = color_white

local scoreboard 
local con = function(ns) return TIMER:GetFormatted(ns) end

local fl, fo  = math.floor, string.format
local function cTime(ns)
	if ns > 3600 then
		return fo( "%d:%.2d:%.2d", fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ) )
	elseif ns > 60 then 
		return fo( "%.1d:%.2d", fl( ns / 60 % 60 ), fl( ns % 60 ) )
	else
		return fo( "%.1d", fl( ns % 60 ) )
	end
end

local function CreateScoreboard(shouldHide)
    if (shouldHide) then
        if not scoreboard then return end 

        CloseDermaMenus()
        scoreboard:Remove()
		scoreboard = nil
		
		gui.EnableScreenClicker(false)
		return
    end

    if scoreboard then return end 
    
    local WIDTH = 1100
    local HEIGHT = 600

    if ScrW() < WIDTH then 
        WIDTH = ScrW() * 0.9 
        HEIGHT = ScrH() * 0.5 
    end

	gui.EnableScreenClicker(true)

	scoreboard = vgui.Create("EditablePanel")
	scoreboard:SetSize(WIDTH, HEIGHT)
    scoreboard:Center()

    scoreboard.spectators = {}

    local height = 54 
    local x = 6
    local width = WIDTH - (x * 2)
    
    function scoreboard:Paint(w, h)
		self.theme = Theme:GetPreference("Scoreboard")
		self.themec = self.theme["Colours"]
        self.themet = self.theme["Toggles"]
        
        PRIMARY = self.themec["Primary Colour"]
        SECONDARY = self.themec["Secondary Colour"]
        TRI = self.themec["Tri Colour"]
        ACCENT = self.themec["Accent Colour"]
        TEXT = self.themec["Text Colour"]
        OUTLINE = self.themec["Outlines Colour"]

        surface.SetDrawColor(TRI)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(PRIMARY)
        surface.DrawRect(x, x, w - (x * 2), (height * 2) + x)

        draw.SimpleText("justa's cool server", "ui.mainmenu.title2", w / 2, (height + x + x) / 2, TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(game.GetMap(), "ui.mainmenu.button", x+x, (height + x + x) / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Timeleft: " .. cTime(GetGlobalFloat("timeleft", 0) - CurTime()), "ui.mainmenu.button", w - x - x, (height + x + x) / 2, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        -- Specs 
        local lst = ""
        for k, v in pairs(self.spectators) do 
            lst = lst .. v:Nick() .. ", "
        end
        
        if string.EndsWith(lst, ", ") then 
            lst = string.sub(lst, 1, #lst - 2)
        else 
            lst = "None"
        end

        draw.SimpleText("Spectators: " .. lst, "ui.mainmenu.button", x + 2, h - (height / 3) - (x / 2) + 1, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Players: " .. #player.GetHumans() .. "/" .. game.MaxPlayers()-2, "ui.mainmenu.button", w - x - 2, h - (height / 3) - (x / 2) + 1, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    scoreboard.bots = scoreboard:Add("DPanel")
    scoreboard.bots:SetPos(x * 2, height + x)
    scoreboard.bots:SetSize(width - (x * 2), height)
    scoreboard.bots.list = {}

    scoreboard.specs = scoreboard:Add("DPanel")
    scoreboard.specs:SetPos(x, HEIGHT - 34)
    scoreboard.specs:SetSize(width, 34)
    scoreboard.specs.Paint = function() end 

    function bDermaMenu(v, a)
        local b = PRIMARY
        local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
        local col2 = Color(b.r + 10, b.g + 10, b.b + 10, 255)

        if not a then 
            scoreboard.menu = DermaMenu()
        else 
            scoreboard.menu = a 
        end 

        scoreboard.menu:SetDrawBorder(false)
        scoreboard.menu:SetDrawColumn(false)
        scoreboard.menu:SetMinimumWidth(200)
        scoreboard.menu.Paint = function(s,w,h) 
            surface.SetDrawColor(s:IsHovered() and col or col2)
            surface.DrawRect(0, 0, w, h)
        end

        if not a then 
            scoreboard.menu:AddOption("Spectate", function()
                LocalPlayer():ConCommand("say !spectate " .. v:Name())
            end)
        end 

        scoreboard.menu:AddOption("Copy SteamID", function() 
            SetClipboardText(v:IsBot() and v.steamid or v:SteamID())
            UTIL:AddMessage("Server", v:Nick(), "'s steamid copied to clipboard.")
        end)

        scoreboard.menu:AddOption("Goto Profile", function() 
            gui.OpenURL("http://www.steamcommunity.com/profiles/" .. (v:IsBot() and util.SteamIDTo64(v.steamid) or v:SteamID64()))
        end)

        if not v:IsBot() then 
            scoreboard.menu:AddSpacer()

            scoreboard.menu:AddOption("Mute Player", function() end)
            scoreboard.menu:AddOption("Gag Player", function() end)

            scoreboard.menu:AddSpacer()

            scoreboard.menu:AddOption("Kick Player", function() end)
            scoreboard.menu:AddOption("Ban Player", function() end)
        end

        for i = 1, scoreboard.menu:ChildCount() do 
            local v = scoreboard.menu:GetChild(i)

            if v.SetTextColor then 
                function v:Paint(w, h) 
                    surface.SetDrawColor(self:IsHovered() and col or col2)
                    surface.DrawRect(0, 0, w, h)
                end
                v:SetTextColor(TEXT)
                v:SetFont("ui.mainmenu.button")
                v:SetIsCheckable(false)
            else 
            end 
        end

        if not a then 
         scoreboard.menu:Open() end
    end

    function scoreboard.specs:OnMousePressed()
        local b = PRIMARY
        local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
        local col2 = Color(b.r + 10, b.g + 10, b.b + 10, 255)

        scoreboard.smenu = DermaMenu()
        self.lst = {}

        scoreboard.smenu:SetDrawBorder(false)
        scoreboard.smenu:SetDrawColumn(false)
        scoreboard.smenu:SetMinimumWidth(200)
        scoreboard.smenu.Paint = function(s,w,h) 
            surface.SetDrawColor(s:IsHovered() and col or col2)
            surface.DrawRect(0, 0, w, h)
        end

        for k, v in pairs(scoreboard.spectators) do 
            local x = scoreboard.smenu:AddSubMenu(v:Nick(), function() 
                bDermaMenu(v, self.lst[k])
            end)

            bDermaMenu(v, x)
        end 

        for i = 1, scoreboard.smenu:ChildCount() do 
            local v = scoreboard.smenu:GetChild(i)

            if v.SetTextColor then 
                function v:Paint(w, h) 
                    surface.SetDrawColor(self:IsHovered() and col or col2)
                    surface.DrawRect(0, 0, w, h)
                end
                v:SetTextColor(TEXT)
                v:SetFont("ui.mainmenu.button")
                v:SetIsCheckable(false)
            else 
            end 
        end
        scoreboard.smenu:Open()
    end 

    local gap = x / 2
    function scoreboard.bots:Paint(w, h)
        surface.SetDrawColor(ACCENT)
        surface.DrawRect(0, 0, (w / 2) - (gap), h)
        surface.DrawRect((w / 2) + (gap), 0, (w / 2), h)

        for k, v in pairs(self.list) do 
            local x = (k - 1) * (w / 2) + (gap * (k - 1))
            local W = w / 2
            local style = TIMER:GetStyle(v)
            local mode = TIMER:GetMode(v)
            local s = TIMER:GetFullStateByStyleMode(style, mode)
            local pb = v.pb or 0 
            local time = v.time or 0
            local per = math.ceil(((CurTime() - time) / pb) * 100) .. "%"

            if not v.time then 
                per = "-"
            end
            
            if v.name then 
                draw.SimpleText(s .. " by " .. v.name, "ui.mainmenu.button", x + 10, h / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else 
                draw.SimpleText(v:Nick() == "Multi-Style Replay" and "!replay" or "No Time Recorded", "ui.mainmenu.button", x + 10, h / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            if v.pb then 
                draw.SimpleText("" .. TIMER:GetFormatted(pb) .. "", "ui.mainmenu.button", x + W - 50, h / 2, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                draw.SimpleText("" .. per .. "", "ui.mainmenu.button", x + W - 10, h / 2, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    function scoreboard.bots:Think() 
        if self:IsHovered() then 
            self:SetCursor("hand")
        end
    end

    function scoreboard.bots:OnMousePressed()
        local cx, cy = self:CursorPos()
        local w, h = self:GetSize()
        for k, v in pairs(self.list) do 
            local x = (k) * (w / 2) + (gap * (k - 1))
            local x1 = (k - 1) * (w / 2) + (gap * (k - 1))
            local clicked = (x > cx and cx > x1)
            if clicked then 
                bDermaMenu(v)
            end
        end
    end

    for k, v in pairs(player.GetBots()) do
        table.insert(scoreboard.bots.list, v)
    end

    local py = (height * 2) + x + x + x
    local ph = HEIGHT - py - (height / 1.5)

    scoreboard.players = scoreboard:Add("DPanel")
    scoreboard.players:SetPos(x, py)
    scoreboard.players:SetSize(width, ph)

    local line = x - 2
    function scoreboard.players:Paint(w, h)
        surface.SetDrawColor(PRIMARY)
        surface.DrawRect(0, 0, w, h)
        draw.RoundedBox(100, (w / 2) - (line / 2), x, line, h - (x * 2), TRI)
    end

    local disabled = false
    function DisableMoving()
        disabled = false 
    end

    function CreatePlayerInfo(pan, ply)
        local w = pan:GetWide()
        
        local p = pan:Add("DPanel")
        p:SetPos(0, #pan.list * 34)
        p:SetSize(w, 34)

        local tw = w - (x * 2)
        surface.SetFont("ui.mainmenu.button")
        
        local nm = ply:Nick()
            if (string.len(nm) > 16) then
                nm = nm:Left(16) .. "..."
            end
        local nx, nh = surface.GetTextSize(nm)

        function p:Paint(pw, phh)
            if not IsValid(ply) then 
                return ScoreboardRefresh()
            end 
            if p:IsHovered() or p:IsChildHovered() then 
                surface.SetDrawColor(SECONDARY)
                surface.DrawRect(0, 0, pw, phh)
                self:SetCursor("hand")
            end

            ph = 34 

			local pRank = TIMER:GetRank(ply)
            
            if ply:GetNWInt("segmented", false) then 
                draw.SimpleText("Segmenting", "ui.mainmenu.button", x, ph / 2, ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            elseif pRank[1] then 
                draw.SimpleText("#" .. pRank[1] .. " | ", "ui.mainmenu.button", x, ph / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                local lw, lh = surface.GetTextSize("#" .. pRank[1] .. " | ")
                local rank = TIMER:TranslateRank(pRank[2])
                draw.SimpleText(rank[1], "ui.mainmenu.button", x + lw, ph / 2, rank[2], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else 
                draw.SimpleText("Unranked", "ui.mainmenu.button", x, ph / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            draw.SimpleText(nm, "ui.mainmenu.button", x + (w * 0.25), ph / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local style = TIMER:GetStyle(ply)
            style = TIMER.Styles[style][2]

            if math.abs(TIMER:GetMode(ply)) > 1 then 
                style = "[" .. (math.abs(TIMER:GetMode(ply)) - 1) .. "] " .. style
            end

            draw.SimpleText(style, "ui.mainmenu.button", x + (w * 0.6), ph / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local place, pb = TIMER:GetPersonalBest(ply)
            pb = pb or 0
            place = place or 0 
            place = place > 0 and "#"..place or ""
            if pb then 
                draw.SimpleText(place, "hud.subinfo", x + (w * 0.74), (ph / 2), TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                draw.SimpleText(TIMER:GetFormatted(pb), "ui.mainmenu.button", x + (w * 0.75), ph / 2, TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            draw.SimpleText(ply:Ping(), "ui.mainmenu.button", w - x, ph / 2, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            draw.SimpleText(ply:GetNWInt("WRs", 0), "hud.subinfo", nx + (w * 0.23) + x + x + 24, (ph / 2), Color(255, 202, 24), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if self.hasextended then 
                local eX, eY = 150 - 34 + x, ph + x + x + 4

                if not self.avatar then 
                    self.avatar = self:Add("AvatarImage")
                    self.avatar:SetPos(x, ph + x)
                    self.avatar:SetSize(150 - x - x - 34, 150 - x - x - 34)
                    self.avatar:SetSteamID(util.SteamIDTo64(ply:SteamID()), 256)
                end

                local rank = Admin:GetUserRank(ply).name 
                
                local pl = ply 
                local status = "In start zone"
                local curr = pl.time or 0
                local inPlay = pl.time
                local finished = pl.finished 

                -- We're finished
               if (pl:GetObserverMode() ~= OBS_MODE_NONE) then
                    local tgt = pl:GetObserverTarget()

                    if tgt and IsValid(tgt) and (tgt:IsPlayer() or tgt:IsBot()) then
                        local nm = (tgt:IsBot() and (TIMER:GetFullStateByStyleMode(tgt.style, tgt.mode) .. " Replay") or tgt:Nick())

                        if (string.len(nm) > 26) then
                            nm = nm:Left(26) .. "..."
                        end

                        status = "Spectating: " .. nm
                    else
                        status = "Spectating"
                    end
                elseif (pl:GetNWInt('inPractice', false)) then
                    status = "Practicing"
                elseif finished then
                    status = "Finished: " .. con(finished)
                elseif (curr > 0) then
                    status = "Running: " .. con(CurTime() - curr)
                end

                draw.SimpleText(rank, "ui.mainmenu.button", eX, eY, ACCENT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(status, "ui.mainmenu.button", tw + x, eY, TEXT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
               
            end
        end
        
        local eX, eY = 150 - 34 + x, ph + x + x + 4

        local function Sleek(parent, x, y, width, height, col, col22, title, fu)
            center = center == nil and true or false
            local f = parent:Add('DButton')
            f:SetPos(x, y)
            f:SetSize(width, height)
            f:SetText('')
            f.title = title
        
            function f:Paint(width, height)
                local b = col
                local col = Color(b.r + 5, b.g + 5, b.b + 5, 255)
                local col2 = Color(b.r + 10, b.g + 10, b.b + 10, 255)
                surface.SetDrawColor(self:IsHovered() and col or col2)
                surface.DrawRect(0, 0, width, height)
                draw.SimpleText(self.title, 'ui.mainmenu.button', width / 2, height / 2, col22, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            f.OnMousePressed = fu
            return f
        end

        local img = p:Add("DImage")
        img:SetPos(nx + (w * 0.25) + x + x, 12)
        img:SetSize(12, 12)
        img:SetImage("bhop/wrstar.png")

        function p:Think()
            if self.extended and not self.buttons then 
                self.stat = Sleek(p, eX, 150 - 30 - x-x, 199, 30, PRIMARY, color_white, "View Statistics", function() 
                    UTIL:AddMessage("Server", "That feature has not been added yet.")
                end)
                self.prof = Sleek(p, eX + 199 + 4, 150 - 30 - x-x, 199, 30, PRIMARY, color_white, "Teleport To", function()
                    LocalPlayer():ConCommand("say !goto " .. ply:Name())
                end)
                self.spec = Sleek(p, eX, 150 - 30 - x - 34-x, 199, 30, PRIMARY, color_white, "Spectate", function() 
                    LocalPlayer():ConCommand("say !spectate " .. ply:Name())
                end)
                self.prof = Sleek(p, eX + 199 + 4, 150 - 30 - x - 34-x, 199, 30, PRIMARY, color_white, "View Profile", function()
                    gui.OpenURL("http://www.steamcommunity.com/profiles/" .. ply:SteamID64())
                end)
               -- self.stat = Sleek(p, tw - 200, 34 + x, 200, 30, PRIMARY, color_white, "View Statistics", function() end)
                self.buttons = true 
            end 
        end

        function p:OnMousePressed(keyCode)
            if keyCode == 108 then 
                bDermaMenu(ply)
                return
            end 
            self.hasextended = true 
            if disabled then return end 
            if not self.extended then 
                disabled = true 
                self:SizeTo(-1, 150, 0.5, 0, -1, DisableMoving)

                local foundself = false 
                for k, v in pairs(pan.list) do 
                    local x, y = v:GetPos()

                    if v != self then 
                        if foundself then  
                            v:MoveTo(-1, y + 150 - 34, 0.5, 0)
                        end
                    else 
                        foundself = true 
                    end
                end 

                self.extended = true 
            else 
                disabled = true
                self:SizeTo(-1, 34, 0.5, 0, -1, DisableMoving)

                local foundself = false 
                for k, v in pairs(pan.list) do 
                    local x, y = v:GetPos()

                    if v != self then 
                        if foundself then  
                            v:MoveTo(-1, y - 150 + 34, 0.5, 0)
                        end
                    else 
                        foundself = true 
                    end
                end 

                self.extended = false
            end
        end

        return p 
    end

    scoreboard.players.normal = scoreboard.players:Add("DScrollPanel")
    scoreboard.players.normal:SetPos(x, x)
    scoreboard.players.normal:SetSize((width / 2) - (line / 2) - (x * 2), ph - (x * 2))
    scoreboard.players.normal.list = {}

    function scoreboard.players.normal:Paint(w, h)
    end

    scoreboard.players.bonus = scoreboard.players:Add("DScrollPanel")
    scoreboard.players.bonus:SetPos(x + (width / 2) + (line / 2), x)
    scoreboard.players.bonus:SetSize((width / 2) - (line / 2) - (x * 2), ph - (x * 2))
    scoreboard.players.bonus.list = {}
    function scoreboard.players.bonus:Paint(w, h)
    end

    ScoreboardRefresh()

    scoreboard.players.normal.VBar:SetWide(0)
    scoreboard.players.bonus.VBar:SetWide(0)
end 

function ScoreboardRefresh()
    if not scoreboard then return end 

    for k, v in pairs(scoreboard.players.bonus.list) do 
        v:Remove()
    end 
    for k, v in pairs(scoreboard.players.normal.list) do 
        v:Remove()
    end 
    scoreboard.players.bonus.list, scoreboard.players.normal.list = {}, {}

    local normal, bonus = {}, {}
    for k, v in pairs(player.GetHumans()) do 
        if v:Team() == TEAM_SPECTATOR then 
            table.insert(scoreboard.spectators, v)
        else 
            if math.abs(TIMER:GetMode(v)) > 1 then 
                table.insert(bonus, v)
            else 
                table.insert(normal, v)
            end
        end
    end

    local srt = function(a, b)
        if not a or not b then return false end
        local ra, rb = TIMER:GetRank(a), TIMER:GetRank(b)
        local _a = ra[1] == 1 and 10000 or ra[2]
        local _b = rb[1] == 1 and 10000 or rb[2]

        if (not _a) or (not _b) or (type(_a) ~= type(_b)) then return false end

        if _a == _b then
            return a:GetNWInt("SpecialRank", 0) > b:GetNWInt("SpecialRank", 0)
        else
            return _a > _b
        end
    end

    table.sort(normal, srt)
    table.sort(bonus, srt)

    for k, v in pairs(normal) do 
        local p = CreatePlayerInfo(scoreboard.players.normal, v)
        table.insert(scoreboard.players.normal.list, p)
    end

    for k, v in pairs(bonus) do 
        local p = CreatePlayerInfo(scoreboard.players.bonus, v)
        table.insert(scoreboard.players.bonus.list, p)
    end
end

function GM:ScoreboardShow()
    CreateScoreboard()
end

function GM:ScoreboardHide()
    CreateScoreboard(true)
end

function GM:HUDDrawScoreBoard() end
