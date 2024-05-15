-- "gamemodes\\bhop\\gamemode\\essential\\sh_movement.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Bunny Hop
-- by justa

-- Cache LocalPlayer
local lp = LocalPlayer

-- Cache math funcs 
local clamp = math.Clamp

-- Cache other funcs 
local ft, ct = FrameTime, CurTime
local sl, ls = string.lower, {}
local bn, ba, bo = bit.bnot, bit.band, bit.bor
local gf = {}

-- Player Jumps storage
PlayerJumps = {}

-- Firstly, the main movement function that facilitates movement.
function GM:Move(client, data)
	-- Is the client valid?
	if not IsValid(client) then return end 

	-- If this is a local file, and the player isn't themselves don't run this function.
	if lp and (client ~= lp()) then return end 

	-- They're not alive?
	if (not client:Alive()) then return end 

	-- Some values we're going to need to play with 
	local velocity = data:GetVelocity()
	local velocity2d = velocity:Length2D()
	local style = TIMER:GetStyle(client)
	local mode = TIMER:GetMode(client)
	local onGround = client:IsOnGround()
	local aa, mv = 500, (style == 9 and 49.2 or 32.8)
	local aim = data:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = data:GetForwardSpeed()
	local smove = data:GetSideSpeed() 

	-- Facilitate Start Zone speed cap 
	if client.InStartZone and (not client:GetNWInt('inPractice', false)) and style != 11 then 
		-- Check if they're in a style that has an adjusted speedcap 
		local speedcap = 280
		if (style == 3) or (style == 4) or (style == 5) then 
			speedcap = 450 
		end 

		-- If they're over this speed then make sure their speed is altered 
		if (velocity2d > speedcap) and (not client.Teleporting) then 
			local diff = velocity2d - speedcap
			velocity:Sub(Vector(velocity.x > 0 and diff or -diff, velocity.y > 0 and diff or -diff, 0))
			data:SetVelocity(velocity)
			return false
		end
	end

	-- Stamina (Credits: Gravious)
	if onGround and not gf[ client ] then
		gf[ client ] = 0
	elseif onGround and gf[ client ] then
		gf[ client ] = gf[ client ] + 1
		if gf[ client ] > 12 then
			client:SetDuckSpeed( 0.4 )
			client:SetUnDuckSpeed( 0.2 )
		end
	elseif not onGround then
		gf[ client ] = 0
		client:SetDuckSpeed( 0 )
		client:SetUnDuckSpeed( 0 )
	end
	
	if onGround and style == 6 and (not client:IsBot()) then
		local v = velocity
		local vl = velocity2d
		local c = ct()

		if client.AirStam then
			data:SetVelocity( v - (0.04 * v) )
			
			if client.AirStam == 4 then
				client.Gtime = c
			end
			
			client.AirStam = client.AirStam - 1
			if client.AirStam < 0 then
				client.AirStam = nil
			end
		end
		
		if client.Gtime then
			if client.Gtime == c then
				client.Gset = 0
			elseif client.Gset then
				if client.Gset < 4 then
					client.Gset = client.Gset + 1
					return
				end
				
				local dt = c - client.Gtime
				if dt < 1 then
					local p = (1 - dt) / 16
					data:SetVelocity( v - (p * v) )
				else
					client.Gtime = nil
					client.Gset = nil
				end
			end
		end
	end

	-- Alter movement based on style 
	if (style == 1) or (style == 8) or (style == 9) or (style == 10) or (style == 11) then 
		smove = data:KeyDown(IN_MOVERIGHT) and smove + 500 or smove
		smove = data:KeyDown(IN_MOVELEFT) and smove - 500 or smove
	elseif (style == 2) then  
		fmove = data:KeyDown(IN_FORWARD) and fmove + 500 or fmove 
		fmove = data:KeyDown(IN_BACK) and fmove - 500 or fmove
	elseif (style == 6) then 
		aa, mv = client:Crouching() and 20 or 50, 32.4
	elseif (style == 7) then 
		aa, mv = 120, 32.4
	end

	-- Let's do this!
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	-- Wish velocity
	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	-- ALter wish speed to correct value
	local wishspeed = wishvel:Length()
	local maxspeed = data:GetMaxSpeed()
	if wishspeed > maxspeed then
		wishvel = wishvel * (maxspeed / wishspeed)
		wishspeed = maxspeed
	end

	-- Clamp wishspeed
	local wishspd = wishspeed
	wishspd = clamp(wishspd, 0, mv)

	-- Wish direction and new speed
	local wishdir = wishvel:GetNormal()
	local current = velocity:Dot( wishdir )
	local addspeed = wishspd - current

	-- This is for Momentum Hud
	client.ctick = (client.ctick or 0) + 1
	if (client.ctick % 12) == 1 then 
		client.current = velocity2d
	end

	-- Gain Stats
	if SERVER and (not client:IsBot()) then 
		local gaincoeff = 0
		client.tick = (client.tick or 0) + 1

		if (current ~= 0) and (wishspd ~= 0) and (current < 30) then 
			gaincoeff = (wishspd - math.abs(current)) / wishspd
			client.rawgain = client.rawgain + gaincoeff
		end
	end

	-- No additional speed?
	if addspeed <= 0 then return end

	-- Accel
	local accelspeed = aa * ft() * wishspeed
	if accelspeed > addspeed then
		accelspeed = addspeed
	end

	-- Edited velocity
	local vel = velocity + (wishdir * accelspeed)

	-- Stamina
	if style == 6 then
		if not client.AirStam or client.AirStam < 4 then client.AirStam = 4 end
		if client.Gset then client.Gset = nil end
	end

	-- Speed 
	if (client.topspeed or 0) < velocity2d then 
		client.topspeed = velocity2d
	end

	-- Now if they're not on the ground we need to make an air strafe occur 
	if (not onGround) then 
		data:SetVelocity(vel)
		return false
	end
end

-- Cheers grav, big ups im stealing this 
local function norm(i) if i > 180 then i = i - 360 elseif i < -180 then i = i + 360 end return i end 

-- Setup move for mainly alternative move methods
function GM:SetupMove(client, data)
	-- Not valid?
	if not IsValid(client) or (client:IsBot()) then return end 

	local buttons = data:GetButtons()

	-- Auto Hop
	local style = TIMER:GetStyle(client)
	if (style ~= 6) and (style ~= 7) then 
		if ba(buttons, IN_JUMP) > 0 then
			if client:WaterLevel() < 2 and client:GetMoveType() ~= MOVETYPE_LADDER and not client:IsOnGround() then
				data:SetButtons(ba(buttons, bn(IN_JUMP)))
			end
		end
	end

	-- Stripping movements that a player shouldn't be able to do with their current style
	if (client:GetMoveType() ~= MOVETYPE_NOCLIP) then 
		-- It's different if we're on the ground, we're not CSS!
		if client:OnGround() then 
			-- Speed cap for legit
			if (style == 6) then 
				local vel = data:GetVelocity()
				local ts = ls[client] or 700

				-- Oh dear
				if vel:Length2D() > ts then
					local diff = vel:Length2D() - ts
					vel:Sub(Vector(vel.x > 0 and diff or -diff, vel.y > 0 and diff or -diff, 0))
				end
				
				data:SetVelocity( vel )
			end
		else
			if (style == 2) or (style == 4) then 
				data:SetSideSpeed(0)

				-- W-Only?
				if (style == 4) and (data:GetForwardSpeed() < 0) then 
					data:SetForwardSpeed(0)
				end 

			-- A-Only 
			elseif (style == 5) then 
				data:SetForwardSpeed(0)
					
				if data:GetSideSpeed() > 0 then
					data:SetSideSpeed(0)
				end

			-- HSW
			elseif style == 3 and (data:GetForwardSpeed() == 0 or data:GetSideSpeed() == 0) then
				data:SetForwardSpeed(0)
				data:SetSideSpeed(0)
			end
		end
	end

	-- Sync!!
	if SERVER and not client:IsFlagSet( FL_ONGROUND + FL_INWATER ) and client:GetMoveType() != MOVETYPE_LADDER and TIMER.SyncMonitored[client] and TIMER.SyncAngles[client] then
		-- Normalizes it so we don't have some CRAZY angles lol
		local diff = norm(data:GetAngles().y - TIMER.SyncAngles[client])
		local lastkey = client.lastkey or 6969 

		-- If their camera is angled left / right	
		if (diff > 0) then 
			TIMER.SyncTick[client] = TIMER.SyncTick[client] + 1

			if (ba(buttons, IN_MOVELEFT) > 0) and not (ba(buttons, IN_MOVERIGHT) > 0) then 
				TIMER.SyncA[client] = TIMER.SyncA[client] + 1 
			end 

			if (data:GetSideSpeed() < 0) then 
				TIMER.SyncB[client] = TIMER.SyncB[client] + 1
			end

			if lastkey != 1 then 
				client.strafes = client.strafes + 1 
				client.strafesjump = client.strafesjump + 1
				client.lastkey = 1 
			end
		elseif (diff < 0) then 
			TIMER.SyncTick[client] = TIMER.SyncTick[client] + 1

			if (ba(buttons, IN_MOVERIGHT) > 0) and not (ba(buttons, IN_MOVELEFT) > 0) then 
				TIMER.SyncA[client] = TIMER.SyncA[client] + 1 
			end 

			if (data:GetSideSpeed() > 0) then 
				TIMER.SyncB[client] = TIMER.SyncB[client] + 1
			end

			if lastkey != 0 then 
				client.strafes = client.strafes + 1 
				client.strafesjump = client.strafesjump + 1
				client.lastkey = 0
			end
		end

		-- Update Sync Angles
		TIMER.SyncAngles[client] = data:GetAngles().y
	end
end

-- Whenever a player hits the ground 
local scrollpow, normpow = 268.4, 290
function GM:OnPlayerHitGround(client, isWater)
	local style = TIMER:GetStyle(client)

	-- Jump power stuff, i honestly dk 
	if (style == 6) or (style == 7) then 
		client:SetJumpPower(scrollpow)
		timer.Simple(0.3, function() if not IsValid(client) or not client.SetJumpPower or not normpow then return end client:SetJumpPower(normpow) end)
	end

	-- Add a jump!
	if SERVER and PlayerJumps[client] then 
		TIMER:SetJumps(client, PlayerJumps[client] + 1)
	end
end

-- View
local ut, mm = util.TraceLine, math.min
local HullDuck = _C["Player"].HullDuck
local HullStand = _C["Player"].HullStand
local ViewDuck = _C["Player"].ViewDuck
local ViewStand = _C["Player"].ViewStand

local function InstallView( ply )
	if not IsValid( ply ) then return end
	local maxs = ply:Crouching() and HullDuck or HullStand
	local v = ply:Crouching() and ViewDuck or ViewStand
	local offset = ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset()

	local tracedata = {}
	local s = ply:GetPos()
	s.z = s.z + maxs.z
	tracedata.start = s
	
	local e = Vector( s.x, s.y, s.z )
	e.z = e.z + (12 - maxs.z)
	e.z = e.z + v.z
	tracedata.endpos = e
	tracedata.filter = ply
	tracedata.mask = MASK_PLAYERSOLID
	
	local trace = ut( tracedata )
	if trace.Fraction < 1 then
		local est = s.z + trace.Fraction * (e.z - s.z) - ply:GetPos().z - 12
		if not ply:Crouching() then
			offset.z = est
			ply:SetViewOffset( offset )
		else
			offset.z = mm( offset.z, est )
			ply:SetViewOffsetDucked( offset )
		end
	else
		ply:SetViewOffset( ViewStand )
		ply:SetViewOffsetDucked( ViewDuck )
	end
end
hook.Add( "Move", "InstallView", InstallView )

