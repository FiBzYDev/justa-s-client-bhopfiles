-- "gamemodes\\bhop\\gamemode\\modules\\strafe\\cl_trainer.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
strafetrainer = CreateClientConVar("bhop_strafetrainer", 0, true, false, "Controls strafe trainer", 0, 1)
local strafetrainer_interval = CreateClientConVar("bhop_strafetrainer_interval", 10, true, false, "Controls strafe trainer update rate in ticks", 1, 100)
local strafetrainer_ground = CreateClientConVar("bhop_strafetrainer_ground", 0, true, false, "Should it update on ground", 0, 1)

local interval = (1 / engine.TickInterval())*(strafetrainer_interval:GetInt()/100)
local ground = strafetrainer_ground:GetBool()

cvars.AddChangeCallback("bhop_strafetrainer_interval", function(cvar, old, new)
	interval= (1 / engine.TickInterval()) * (new/100)
end)

cvars.AddChangeCallback("bhop_strafetrainer_ground", function(cvar, old, new)
	ground = (new == "1" and true or false)
end)

local movementSpeed = 32.8
local deg, atan = math.deg, math.atan

local function NormalizeAngle(x)
	if (x > 180) then 
		x = x - 360
	elseif (x <= -180) then 
		x = x + 360
	end 

	return x
end

local function GetPerfectAngle(vel)
	return deg(atan(movementSpeed / vel))
end

local last = 0
local tick = 0
local percentages = {}
CurrentTrainValue = 0
local function StartCommand(client, cmd)
	if (client:IsOnGround() and !ground) then return end
	if cmd:TickCount() == 0 then return end 
    if client:GetMoveType() == MOVETYPE_NOCLIP then return end 

	local vel = client:GetVelocity():Length2D()
	local ang = client:GetAngles().y
	local diff = NormalizeAngle(last - ang)
	local perfect = GetPerfectAngle(vel)
	local perc = math.abs(diff) / perfect 

	if (tick > interval) then 
		local avg = 0 

		for x = 0, interval do 
			avg = avg + percentages[x]
			percentages[x] = 0
		end

		CurrentTrainValue = avg / interval 
		tick = 0 
	else
		percentages[tick] = perc 
		tick = tick + 1
	end

	last = ang
end
hook.Add("StartCommand", "BHOP_strafetrainer", StartCommand)