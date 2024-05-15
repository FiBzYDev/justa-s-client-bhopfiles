-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_scrollbase.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

function PANEL:Init()
    self.title = "No title"
    self.cache = {}
    self.cache_objs = {}
    self.option_func = function() end 
end 

function PANEL:SetTitle(title)
    self.title = title 
end 

function PANEL:AddStyleMode(style, mode, seg)
    local width, height = self:GetSize()

    style, mode = style and style or 1, mode and mode or 1 
    local styles, modes = {}, {}

    -- I should do this somewhere else* 
    for k, v in pairs(TIMER.Styles) do 
        table.insert(styles, {v[1], k})
    end 

    -- Default modes.
    table.insert(modes, {"Normal", 1})
    table.insert(modes, {"Bonus", 2})

    if seg then 
        table.insert(modes, {"Segmented Normal", -1})
        table.insert(modes, {"Segmented Bonus", -2})
    end

    self.style_dropdown = BuildDropdown(self, width - 170 - 170 - 10, 0, 170, 30, styles, style) 
    self.mode_dropdown = BuildDropdown(self, width - 170, 0, 170, 30, modes, mode)
    self.style = style 
    self.mode = mode  

    function self:SetStyle(style)
        self.style = style 
    end 

    function self:SetMode(mode)
        self.mode = mode 
    end 

    function self:GetStyle()
        return self.style  
    end 

    function self:GetMode()
        return self.mode 
    end 

    function self:Update()
        self.cache = {}
        for k, v in pairs(self.cache_objs) do 
            v:Remove()
        end 
        self.cache_objs = {}
        self.ScrollPan.contents = {}

        self:OnUpdate()
    end 

    function self:OnUpdate() end

    function self.style_dropdown:OnSelect(index, value, data)
        self:GetParent():SetStyle(data)
        self:GetParent():Update()
    end 

    function self.mode_dropdown:OnSelect(index, value, data)
        self:GetParent():SetMode(data)
        self:GetParent():Update()
    end 
end 

function PANEL:InitScrollPanel(options, len, lensplit)
    local width, height = self:GetSize()

    self.len = len 
    self.lensplit = lensplit 

    self.ScrollPan = UI:ScrollablePanel(self, 0, 39, width, height - 44, {
		options, len, lensplit
	})
end 

function PANEL:SetNoSort(nosort)
    self.ScrollPan.nosort = nosort 
end 

function PANEL:RequestData(dataId, arguments, callback)
    arguments = arguments or {}
    NETWORK:StartNetworkMessage(false, dataId, unpack(arguments))
    NETWORK:GetNetworkMessage(dataId.."_get", function(client, data)
        for k, v in pairs(data or {}) do 
            self.cache[k] = v 
            self.cache_objs[k] = UI:MapScrollable(self.ScrollPan, callback(k, v), {self.len, self.lensplit}, function(this)
                self.option_func(this, k, v) 
            end)
        end 
    end)
end 

function PANEL:ForceData(data, callback)
    for k, v in pairs(data) do 
        self.cache[k] = v 
        self.cache_objs[k] = UI:MapScrollable(self.ScrollPan, callback(k, v), {self.len, self.lensplit}, function(this)   
            self.option_func(this, k, v) 
        end)
    end 
end 

function PANEL:SetOptionFunction(func)
    self.option_func = func 
end 

function PANEL:Paint(width, height)
    if self.title then 
        draw.SimpleText(self.title, "ui.mainmenu.button", 0, 15, UI_TEXT1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end 
end 

vgui.Register("vgui.scrollbase", PANEL, "EditablePanel")