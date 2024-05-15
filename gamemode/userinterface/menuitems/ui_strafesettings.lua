-- "gamemodes\\bhop\\gamemode\\userinterface\\menuitems\\ui_strafesettings.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

-- {name, desc, type, data: {}}
local settings = {
    {"SSJ", "SSJ master switch.", UISETTING_MODULE, {"ssj_enabled"}},
    {"Prestrafe", "Shows your first jump.", UISETTING_MODULE, {"ssj_prestrafe"}},
    {"First jump tick", "Shows your tick when you first jump compared to when you left the start zone.", UISETTING_MODULE, {"ssj_firstjump"}},
    {"Jump frequency", "Controls the frequency that chat messages occur, 1 = every jump, 6 = every six, etc...", UISETTING_MODULE, {"ssj_jumpfrequency"}},
    {"Height difference", "Shows your height difference per jump.", UISETTING_MODULE, {"ssj_height"}},
    {"Speed difference", "Shows your speed difference per jump.", UISETTING_MODULE, {"ssj_speed"}},
    {"Gain", "Shows your gain per jump.", UISETTING_MODULE, {"ssj_gain"}},
    {"Strafes", "Shows your strafes per jump.", UISETTING_MODULE, {"ssj_strafes"}},
    {"Time", "Shows the time difference between jumps.", UISETTING_MODULE, {"ssj_time"}},
    {"Chat messages", "Toggles whether you should see chat messages or not.", UISETTING_MODULE, {"ssj_chat"}},
    {"Shorten", "Shortens chat message.", UISETTING_MODULE, {"ssj_shorten"}},
    {"HUD", "Toggles whether you should see the SSJ HUD or not.", UISETTING_MODULE, {"ssj_hud"}},
    {"HUD fade duration", "How many seconds should pass before the HUD starts to fade away.", UISETTING_CVAR, {"bhop_ssj_fadeduration", "float"}},
    {"Console messages", "If you have chat messages off, turning this on will print them to your console instead.", UISETTING_MODULE, {"ssj_console"}},
    {"Observer statistics", "Toggles whether you see other people's SSJ in spectate.", UISETTING_MODULE, {"ssj_observer"}}
}

function PANEL:Start()
    self:SetSettings(settings)
end 

vgui.Register("vgui.strafesettings", PANEL, "vgui.settingbase")