-- "gamemodes\\bhop\\gamemode\\modules\\cl_strafe.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- HUD module used for my tutorials
-- Edited: justa 
-- Made my own "HUD" module piggy back off this code

local StrafeAxis = 0 -- Saves the last eye angle yaw for checking mouse movement
local StrafeButtons = nil -- Saves the buttons from SetupMove for displaying
local StrafeCounter = 0 -- Holds the amount of strafes
local StrafeLast = nil -- Your last strafe key for counting strafes
local StrafeDirection = nil -- The direction of your strafes used for displaying
local StrafeStill = 0 -- Counter to reset mouse movement

local fb, ik, lp, = bit.band, input.IsKeyDown, LocalPlayer
local function norm( i ) if i > 180 then i = i - 360 elseif i < -180 then i = i + 360 end return i end -- Custom function to normalize eye angles

local StrafeData -- Your Sync value is stored here
local KeyADown, KeyDDown -- For displaying on the HUD
local MouseLeft, MouseRight --- For displaying on the HUD

local ViewGUI = CreateClientConVar( "kawaii_keys", "1", true, false ) -- GUI visibility
surface.CreateFont( "HUDFont2", { size = 20, weight = 800, font = "Tahoma" } )

function ResetStrafes() StrafeCounter = 0 end -- Resets your stafes (global)
function SetSyncData( data ) StrafeData = data end -- Sets your sync data (global)

-- Monitors the buttons and angles
local function MonitorInput( ply, data )
	StrafeButtons = data:GetButtons()
	
	local ang = data:GetAngles().y
	local difference = norm( ang - StrafeAxis )
	
	if difference > 0 then
		StrafeDirection = -1
		StrafeStill = 0
	elseif difference < 0 then
		StrafeDirection = 1
		StrafeStill = 0
	else
		if StrafeStill > 20 then
			StrafeDirection = nil
		end
		
		StrafeStill = StrafeStill + 1
	end
	
	StrafeAxis = ang
end
hook.Add( "SetupMove", "MonitorInput", MonitorInput )

-- Monitors your key presses for strafe counting
local function StrafeKeyPress( ply, key )
	if ply:IsOnGround() then return end
	
	local SetLast = true
	if key == IN_MOVELEFT or key == IN_MOVERIGHT then
		if StrafeLast != key then
			StrafeCounter = StrafeCounter + 1
		end
	else
		SetLast = false
	end
	
	if SetLast then
		StrafeLast = key
	end
end
hook.Add( "KeyPress", "StrafeKeys", StrafeKeyPress )

-- Paints the actual HUD
local function HUDPaintB()
	if not ViewGUI:GetBool() then return end
	if not IsValid( lp() ) then return end

	local data = {pos = {20, 20}, strafe = true, r = (MouseRight != nil), l = (MouseLeft != nil)}

	-- Setting the key colors
	if StrafeButtons then
		if fb( StrafeButtons, IN_MOVELEFT ) > 0 then 
			data.a = true 
		end

		if fb( StrafeButtons, IN_MOVERIGHT ) > 0 then
			data.d = true 
	 	end
	end
	
	-- Getting the direction for the mouse
	if StrafeDirection then
		if StrafeDirection > 0 then
			MouseLeft, MouseRight = nil, Color( 142, 42, 42, 255 )
		elseif StrafeDirection < 0 then
			MouseLeft, MouseRight = Color( 142, 42, 42, 255 ), nil
		else
			MouseLeft, MouseRight = nil, nil
		end
	else
		MouseLeft, MouseRight = nil, nil
	end
	
	-- If we have buttons, display them
	if StrafeButtons then
		if fb( StrafeButtons, IN_FORWARD ) > 0 then
			data.w = true 
		end
		if fb( StrafeButtons, IN_BACK ) > 0 then
			data.s = true
		end
		if ik( KEY_SPACE ) or fb( StrafeButtons, IN_JUMP ) > 0 then
			data.jump = true 
		end
		if fb( StrafeButtons, IN_DUCK ) > 0 then
			data.duck = true
		end
	end
	
	-- Display the amount of strafes
	if StrafeCounter then
		data.strafes = StrafeCounter
	end
	
	-- If we have sync, display the sync
	if StrafeData then
		data.sync = StrafeData
	end
	
	HUD:Draw(2, lp():Team() == TEAM_SPECTATOR and lp():GetObserverTarget() or lp(), data)
end
hook.Add( "HUDPaint", "PaintB", HUDPaintB )