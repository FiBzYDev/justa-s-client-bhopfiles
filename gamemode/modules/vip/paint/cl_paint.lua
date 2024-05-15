-- "gamemodes\\bhop\\gamemode\\modules\\vip\\paint\\cl_paint.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
PaintCols = {
    [0] = {"Random", Color(0, 0, 0)},
    {"Red", Color(255, 0, 0)},
    {"Green", Color(0, 255, 0)},
    {"Blue", Color(0, 0, 255)},
    {"Cyan", Color(0, 255, 255)},
    {"Orange", Color(255, 165, 0)},
    {"Yellow", Color(255, 255, 0)},
    {"Purple", Color(128, 0, 128)}
}

local currentPainting = false
local currentSize = 16
local currentColour = 0

local function Paint_Callback(key, var)
    return function()
        if key == 1 then 
            currentPainting = !currentPainting
            if currentPainting then 
                LocalPlayer():ConCommand("+paint")
                UI.Paint:UpdateOption(1, "-paint")
            else 
                LocalPlayer():ConCommand("-paint")
                UI.Paint:UpdateOption(1, "+paint")
            end 
        elseif key == 3 then 
            currentColour = var 
            DoPanelStart()
            NETWORK:StartNetworkMessage(false, "paintCallback", key, var)
        else 
            NETWORK:StartNetworkMessage(false, "paintCallback", key)
        end 
    end 
end 

function SwitchPaintColour()
    if not UI.Paint then return end 
    UI.Paint:UpdateTitle("Paint - Choose Colour")
    UI.Paint.options = {}

    for k, v in pairs(PaintCols) do 
        table.insert(UI.Paint.options, {
            name = v[1],
            ["function"] = Paint_Callback(3, k)
        })
    end 

    UI.Paint:ForceNextPrevious()

    function UI.Paint:OnPrevious(isMax) 
        if isMax then 
            DoPanelStart()
        end 
    end 
end 

function DoPanelStart()
    UI.Paint:UpdateTitle("Paint")

    UI.Paint.options = {
        {name = (currentPainting and "-paint" or "+paint"), ["function"] = Paint_Callback(1)},
        {name = "Size: " .. currentSize .. "px", ["function"] = Paint_Callback(2)},
        {name = "Colour: " .. PaintCols[currentColour][1], ["function"] = SwitchPaintColour}
    }

    UI.Paint:RemoveNextPrevious()
    UI.Paint:UpdateLongestOption()
    UI.Paint.page = 1
end 

function CreatePaintMenu(update, var)
    if UI.Paint and UI.Paint.title then 
        if update == 2 then 
            currentSize = var
            UI.Paint:UpdateOption(2, "Size: "..var.."px")
        end 
    else 
        UI.Paint = UI:NumberedUIPanel("Paint", 
            {name = (currentPainting and "-paint" or "+paint"), ["function"] = Paint_Callback(1)},
            {name = "Size: " .. currentSize .. "px", ["function"] = Paint_Callback(2)},
            {name = "Colour: " .. PaintCols[currentColour][1], ["function"] = SwitchPaintColour}
        )
    end 
end 

NETWORK:GetNetworkMessage("paint", function(client, data)
    if data[1] then 
        CreatePaintMenu(data[1], data[2])
    else 
        CreatePaintMenu()
    end 
end)