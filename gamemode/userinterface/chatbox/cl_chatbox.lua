-- "gamemodes\\bhop\\gamemode\\userinterface\\chatbox\\cl_chatbox.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
print("Chatbox init")

surface.CreateFont("chatbox.font", {font = "Open Sans", size = 19, weight = 2000, additive=false})

local chatbox
local chatboxPaint 
local chatboxEntryPaint 
local chatboxRichPaint 
local chatboxHid = false 

-- Chessnut's blur function from nutscript
local blur = Material( "pp/blurscreen" )
function ChessnutBlur( panel, layers, density, alpha )
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

function InitChatbox()
    chatbox = vgui.Create("DFrame")
    chatbox:SetSize(ScrW() * 0.375, ScrH() * 0.28)
    chatbox:SetTitle("")
    chatbox:ShowCloseButton(false)
    chatbox:SetDraggable(false)
    chatbox:SetMinWidth(300)
    chatbox:SetMinHeight(100)

    local x, y = chatbox:GetPos()
    local w, h = chatbox:GetSize()
    local entryX = w * 0.01
    local entryWidth = w - (entryX * 2)
    local entryHeight = (h * 0.12)
    local entryY = h - entryX - entryHeight

    chatbox:SetPos(ScrW() * 0.0116, (ScrH() - h) - ScrH() * 0.137) 

    function chatbox:Think()
        if input.IsKeyDown(KEY_ESCAPE) then 
            HideChatbox()
        end 
    end 

    chatbox.entry = chatbox:Add("DTextEntry")
    chatbox.entry:SetPos(entryX, entryY)
    chatbox.entry:SetSize(entryWidth, entryHeight)
    chatbox.entry:SetDrawBorder(false)
    chatbox.entry:SetTextColor(color_white)
    chatbox.entry:SetHighlightColor(Color(0, 100, 200))
    chatbox.entry:SetDrawBackground(false)
    chatbox.entry:SetFont("chatbox.font")
    chatbox.entry:SetCursorColor(color_white)

    function chatbox.entry:OnKeyCodeTyped(keyCode)
        if keyCode == KEY_ESCAPE then 
            HideChatbox()
            gui.HideGameUI()
        elseif keyCode == KEY_ENTER then 
            if string.Trim(self:GetText()) ~= "" then 
                LocalPlayer():ConCommand("say \"" .. self:GetText() .. "\"")

                self:SetText("")
            end 

            HideChatbox()
        end 
    end 

    local richX = entryX 
    local richWidth = entryWidth 
    local richHeight = (h * 0.88) - (entryX * 3)
    local richY = entryY - entryX - richHeight

    local richInitY = entryY - entryX - 2
    chatbox.rich = chatbox:Add("RichText")
    chatbox.rich:SetPos(richX, richInitY)
    chatbox.rich:SetWide(richWidth)
    chatbox.rich:SetTall(0)
   
    -- I couldn't find a function that makes richtext fill from the bottom so idk
    local richHeight2 = math.Round(richHeight - 2, 0)
    function chatbox.rich:NewText()
        local tall = self:GetTall()
        
        if tall <= richHeight2 then 
            local newline = 20

            if newline + tall > richHeight2 then 
                newline = richHeight2 - tall
            end 

            self:SetTall(tall + newline)

            local x, y = self:GetPos()
            self:SetPos(x, y - newline)

            self:CheckScroll()
        end 
    end 

    function chatbox.rich:CheckScroll()
        if (self:GetTall() < richHeight2) or chatboxHid then 
            self:SetVerticalScrollbarEnabled(false)
        else 
            self:SetVerticalScrollbarEnabled(true)
        end 
    end 
    
    function chatbox.entry:Paint(width, height)
        surface.SetDrawColor(180, 180, 180, 40)
        surface.DrawRect(0, 0, width, height)
        derma.SkinHook("Paint", "TextEntry", self, width, height)
    end 
    chatboxEntryPaint = chatbox.entry.Paint 

    function chatbox.rich:Paint(width, height)
    end
    chatboxRichPaint = chatbox.rich.Paint

    function chatbox.rich:Think()
    end 
    
    function chatbox:Paint(width, height)
        ChessnutBlur(self, 10, 20, 255)
        surface.SetDrawColor(200, 200, 200, 50)


        surface.DrawRect(0, 0, width, height - richHeight - entryHeight - (entryX * 2))
        surface.DrawRect(0, height - entryX - 1, width, entryX + 1)
        surface.DrawRect(entryX, height - entryX - entryHeight - entryX, width - (entryX*2), entryX)
        surface.DrawRect(0, entryX, entryX, height - (entryX * 2) - 1)
        surface.DrawRect(entryX + entryWidth, entryX, entryX, height - (entryX * 2) - 1)

        -- Where richtext will be
        surface.SetDrawColor(180, 180, 180, 40)
        surface.DrawRect(richX, richY, richWidth, richHeight)
    end 
    chatboxPaint = chatbox.Paint 

    function chatbox.rich:PerformLayout(width, height)
        self:SetFontInternal("chatbox.font")
    end 

    HideChatbox()
end 

function HideChatbox()
    if not chatbox then return end 
    if chatboxHid then return end 

    chatbox.Paint = function() end 
    chatbox.entry.Paint = function() end 
    chatbox.rich.Paint = function() end 

    chatbox.rich:SetVerticalScrollbarEnabled(false)
    chatbox.rich:GotoTextEnd()

    chatbox:SetMouseInputEnabled(false)
    chatbox:SetKeyBoardInputEnabled(false)
    chatbox.entry:SetText("")

    gui.EnableScreenClicker(false)

    gamemode.Call("FinishChat")

    chatboxHid = true 
end 

function OpenChatbox()
    if not chatbox then 
        InitChatbox()
    end 

    if not chatboxHid then return end 

    chatbox.Paint = chatboxPaint 
    chatbox.entry.Paint = chatboxEntryPaint
    chatbox.rich.Paint = chatboxRichPaint
    chatbox:MakePopup()
    chatbox:ParentToHUD()
    chatbox.entry:RequestFocus()

    chatboxHid = false
    chatbox.rich:CheckScroll()

    gamemode.Call("StartChat")
end 

/*
local detourAddText = chat.AddText
local firstMessage = true 
function chat.AddText(...)
    if not chatbox then 
        InitChatbox()
    end

    if not firstMessage then 
        chatbox.rich:AppendText("\n")
    end 
    firstMessage = false 

    for k, v in pairs({...}) do 
        if type(v) == "table" then 
            chatbox.rich:InsertColorChange(v.r, v.g, v.b, v.a)
        elseif type(v) == "string" then
            chatbox.rich:AppendText(v)
        elseif v:IsPlayer() then 
            chatbox.rich:InsertColorChange(0, 0, 200)
            chatbox.rich:AppendText(v:Nick())
        end 
    end 

    chatbox.rich:NewText()

    detourAddText(...)
end 

function GM:StartChat()
    return true 
end

local function ChatboxCommand(client, bind, pressed)
    if bind == "messagemode" or bind == "messagemode2" then 
        OpenChatbox()

        return true 
    end 
end 
hook.Add("PlayerBindPress", "ChatboxCommand", ChatboxCommand)

hook.Add("HUDShouldDraw", "hidechat", function( name )
	if name == "CHudChat" then
		return false
	end
end)

InitChatbox()*/