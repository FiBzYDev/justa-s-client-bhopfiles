-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_playermanagement.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Let's change how we do this 
-- 30/12/2020

local PANEL = {}

function PANEL:Start()
    local width, height = self:GetSize()

    self.commandList = UI:ScrollablePanel(self, 0, 0, 220, height, {{"Command"}, 1, {0}})
    self.commands = Admin:GetCommandsForUser(LocalPlayer())
    self.currentCommand = false 
    self.currentPlayer = false 

    for k, v in pairs(self.commands) do
        UI:MapScrollable(self.commandList, {v.title}, nil, function(this)
            if self.selected then 
                if self.selected == this then return end

                self.selected:RemoveColor()
            end 

            self:SetCommand(v)
            this:SetColor()
            
            self.selected = this 
            self.currentCommand = v 
        end)
    end 

    self.playerList = UI:ScrollablePanel(self, 225, 0, 220, height, {{"Player", "Access Level"}, 2, {0, 1}})

    for k, v in pairs(player.GetHumans()) do 
        UI:MapScrollable(self.playerList, {v:Nick(), Admin:GetUserRank(v).name}, nil, function(this)  
            if self.psel then 
                if self.psel == this then return end

                self.psel:RemoveColor()
            end 

            this:SetColor()

            self.currentPlayer = v 
            self.arguList:SetVisible(true)
            self.arguList:SetArguments(self.currentCommand.arguments)

            self.psel = this 
        end)
    end 

    self.arguList = self:Add("DPanel")
    self.arguList:SetPos(225 + 220 + 5, 0)
    self.arguList:SetSize(width - (225 + 220 + 6), height)
    self.arguList.args = {}

    self.arguList.Paint = function(this, w, h)
        surface.SetDrawColor(100, 100, 100)
        surface.DrawRect(0, 18, w, 1)

        draw.SimpleText("Arguments", "hud.smalltext", 0, 0, UI_TEXT2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        for k, v in pairs(this.args) do 
            if not v or not IsValid(v) then continue end 

            local x, y = v:GetPos()

            if not v.arg then continue end 

            draw.SimpleText("Argument: " .. (v.arg.id), "ui.mainmenu.button", x, y - 20, UI_TEXT2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if v.arg.len then 
                draw.SimpleText("(max length: "..v.arg.len..")", "ui.mainmenu.button", w, y - 20, UI_TEXT2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            elseif v.arg.max then 
                draw.SimpleText("(min: "..v.arg.min..", max: "..v.arg.max..")", "ui.mainmenu.button", w, y - 20, UI_TEXT2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            elseif v.arg.typ == "time" then 
                draw.SimpleText("(0 = forever)", "ui.mainmenu.button", w, y - 20, UI_TEXT2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end 
        end 
    end 

    self.arguList.SetArguments = function(this, args)
        for k, v in pairs(this.args) do 
            v:Remove()
        end 

        if this.execute then 
            this.execute:Remove()
        end 

        this.args, this._args = {}, {}

        local y = 45
        local w = this:GetWide()

        for k, v in pairs(args) do 
            if v.typ == "player" and k == 1 then 
                print("ste player to",self.currentPlayer)
                this._args[k] = self.currentPlayer
                continue 
            end 

            if v.typ == "integer" then 
                this.args[k] = UI:NumberInput(this, 0, y, w, 30, v.default, v.min, v.max, v.id, false, function(var)
                    this._args[k] = var 
                end) 

                this._args[k] = v.default 
                this.args[k].arg = v
            elseif v.typ == "time" then 
                this.args[k] = UI:NumberInput(this, 0, y, w, 30, 0, 0, 2147483647, "minutes", false, function(var)
                    this._args[k] = var 
                end) 

                this._args[k] = 0
                this.args[k].arg = v
            elseif v.typ == "string" then 
                this.args[k] = UI:TextEntry(this, 0, y, w, 30, v.default, v.len, function(var)
                    this._args[k] = var 
                end)

                this._args[k] = v.default 
                this.args[k].arg = v
            elseif v.typ == "steamid" then 
                this.args[k] = UI:SteamID(this, 0, y, w, 30, "", 20, function(var)
                    this._args[k] = var:upper()
                end)

                this._args[k] = ""
                this.args[k].arg = v
            end 

            y = y + 55
        end 

        y = y - 20

        this.execute = BuildSleekButton(this, 0, y, w, 30, "Execute Command", function()
            Admin:ExecuteCommand(self.currentCommand.id, this._args)
        end)
    end 

    self.playerList:SetVisible(false)
    self.arguList:SetVisible(false)
end 

function PANEL:SetCommand(cmd)
    local width, height = self:GetSize()

    self.arguList:SetVisible(false)
    
    if self.psel then 
        self.psel:RemoveColor()
        self.psel = nil 
    end 

    -- If there is a player we need to show the list of players.
    if cmd.arguments and #cmd.arguments > 0 and cmd.arguments[1].typ == "player" then 
        self.arguList:SetPos(225 + 220 + 5, 0)
        self.arguList:SetWide(width - (225 + 220 + 6))
        self.playerList:SetVisible(true)
    else 
        self.arguList:SetPos(225, 0)
        self.arguList:SetWide(width - (225 + 1))
        self.playerList:SetVisible(false)
        self.arguList:SetVisible(true)
        self.arguList:SetArguments(cmd.arguments)
    end 
end 

function PANEL:Paint(width, height)
end 

vgui.Register("vgui.commands", PANEL, "EditablePanel")