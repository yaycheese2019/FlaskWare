local target = nil
local buaInNoclip = false
local buaInSilent = false
local buaNoclipOrigin = Vector(0,0,0)
local buaSilentAngles = Angle(0,0,0)
local buaSwitch = 0
local buaTime = 0
local buaBounce = 0

flask_selected = nil

include("playerglow.lua")
include("mainGui.lua")
include("mainConVars.lua")

concommand.Add( "flask_target", function( ply, cmd, args )
	target = Entity(tonumber(flask_selected))
	flask_lock:SetInt(1)
end )

concommand.Add( "flask_noclip", function( ply, cmd, args )
	if(buaInNoclip == false) then
		buaNoclipOrigin = ply:EyePos()
		buaInNoclip = true
	else
		buaInNoclip = false
	end
end )

concommand.Add( "flask_remove_hooks", function( ply, cmd, args )
	hook.Remove("Think", "buaThink")
	hook.Remove("PostDrawTranslucentRenderables", "buaDraw")
	hook.Remove("HUDPaint", "buaHud")
	hook.Remove("CalcView", "buaCalcView")
	hook.Remove("CreateMove", "buaMove")
end )


function buaValid(e)
	-- If true then the entity can be targeted.
	
	if(!e:IsValid()) then return false end
	if(e == LocalPlayer()) then return false end
	
	if(e:IsPlayer()) then return true end
	if(e:IsNPC()) then return true end
	
	return false
end

function buaColor(e)
	if(target == e) then
		return Color(0,255,255)
	end
	if(e:IsPlayer() && e:IsAdmin()) then
		return Color(0,64,255)
	end
	return Color(255,255,255)
end

function buaCol(color)
	return (color[1].." "..color[2].." "..color[3])
end

function buaFactor(ent)
	local sort = flask_sort:GetInt()
	if sort == 1 then
		return (ent:EyePos() - LocalPlayer():EyePos()):Length()
	end
	if sort == 2 then
		local aimVector = LocalPlayer():GetAimVector()
		local entVector = ent:EyePos() - LocalPlayer():EyePos()
		local angCos = aimVector:Dot(entVector) / entVector:Length()
		return (1 - angCos)
	end
	if sort == 3 then
		return ent:Health()
	end
end

function FixMovement(cmd, ang)
	local old_ang = buaSilentAngles
	local new_ang = ang
	
	local diff = math.AngleDifference(old_ang.y, new_ang.y)
	
	local moveVec = Vector(cmd:GetSideMove(), cmd:GetForwardMove(), 0)
	
	moveVec:Rotate(Angle(0,diff,0))
	
	cmd:SetSideMove(moveVec.x)
	cmd:SetForwardMove(moveVec.y)
end

hook.Add( "Think", "buaThink", function()
	
	if flask_spam:GetBool() then
		buaSwitch = (buaSwitch + 1) % 4
		if buaSwitch == 0 then
			LocalPlayer():ConCommand("ulx build")
		end
		if buaSwitch == 2 then
			LocalPlayer():ConCommand("ulx pvp")
		end
	end
	
	local plr = LocalPlayer()
	if !flask_lock:GetBool() then
		target = nil
		local dist = nil
		local maxdist = math.huge
		local eye = plr:EyePos()
		
		if(buaInNoclip) then
			eye = buaNoclipOrigin
		end
		for _, ply in ents.Iterator() do
			if(buaValid(ply)) then
				local org = ply:EyePos()
				local tr = util.TraceLine( {
					start = 	eye,
					endpos =	org,
					filter = 	{plr,ply},
					mask =		MASK_SHOT
				} )
				if (tr.Fraction >= 0.99) then
					dist = buaFactor(ply)
					if(dist <= maxdist) then
						target = ply
						maxdist = dist
					end
				end
			end
		end
	end
end )

hook.Add( "PostDrawTranslucentRenderables", "buaDraw", function()

	if ( !flask_esp:GetBool() ) then return end
	
	render.SetColorMaterial()
	render.IgnoreZ = true
	
	if(flask_cham_enable:GetBool()) then
		local CURRENT_CHAM = flask_cham:GetString()
		local drawCol = Color(0,255,0)
		
		if CURRENT_CHAM then
			for _, obj in ipairs(ents.FindByClass(CURRENT_CHAM)) do
				render.DrawWireframeBox(obj:GetPos(),obj:GetAngles(),obj:OBBMins(),obj:OBBMaxs(),drawCol)
			end
		end
	end
	
	render.IgnoreZ = false
end )

hook.Add( "PreDrawOutlines", "buaOutline", function()

	if ( !flask_esp:GetBool() ) then return end
	local nohealth = Color( 255, 0, 0 )
	for _, ent in ents.Iterator() do
		if buaValid(ent) then
			local hp = (ent:Health() / ent:GetMaxHealth())
			local col = buaColor(ent):Lerp(nohealth, 1 - hp)
			outline.Add(ent,col)
		end
	end
end )

hook.Add( "CalcView", "buaCalcView", function( ply, pos, angles, fov )
	-- Noclip Controls
	local view = {
		origin = pos,
		angles = angles,
		fov = fov,
	}
	if(flask_view:GetBool()) then
		-- Move the camera to the target
		view.origin = target:EyePos()
		view.angles = target:EyeAngles()
	end
	if buaInSilent then
		view.angles = buaSilentAngles
	end
	if flask_thirdperson:GetBool() then
		view.origin = ply:EyePos() - (buaSilentAngles:Forward()* 100)
		view.drawviewer = true
	end
	if(buaInNoclip) then
		view.origin = buaNoclipOrigin
		view.drawviewer = true
		local f = ply:EyeAngles()
		local s = ply:EyeAngles() + Angle(0,90,0)
		s.x = 0 -- Reset the pitch angle
		
		-- Speed calculations
		local speed = 1000
		if(ply:KeyDown(IN_DUCK)) then speed = 250 end -- Reduce if player is holding ctrl
		if(ply:KeyDown(IN_SPEED)) then speed = 2000 end -- Increase if player is sprinting
		speed = speed * (CurTime() - buaTime)
		
		-- Movement
		if(ply:KeyDown(IN_FORWARD)) then
			buaNoclipOrigin = buaNoclipOrigin + f:Forward() * speed
		end
		if(ply:KeyDown(IN_BACK)) then
			buaNoclipOrigin = buaNoclipOrigin - f:Forward() * speed
		end
		if(ply:KeyDown(IN_MOVELEFT)) then
			buaNoclipOrigin = buaNoclipOrigin + s:Forward() * speed
		end
		if(ply:KeyDown(IN_MOVERIGHT)) then
			buaNoclipOrigin = buaNoclipOrigin - s:Forward() * speed
		end
	end
	buaTime = CurTime()
	return view
end )

function RunAimBot(cmd)
	
	local wep = LocalPlayer():GetActiveWeapon()
	
	if flask_aimkey:GetInt() > 0 then
		if !input.IsKeyDown(flask_aimkey:GetInt()) then return end
	end
	
	if (target && target:IsValid()) then
		local org = target:GetPos() + target:OBBCenter()
		
		-- prediction
		org = org + target:GetAbsVelocity() * engine.TickInterval()
		org = org - LocalPlayer():GetAbsVelocity() * engine.TickInterval()
		
		local angs = (org - LocalPlayer():GetShootPos()):Angle()
		if flask_recoil:GetBool() then
			angs = angs - LocalPlayer():GetViewPunchAngles()
		end
		cmd:SetViewAngles(angs)
		if flask_autoshoot:GetBool() then
			cmd:AddKey(IN_ATTACK) -- Shoot if autoshoot is enabled
		end
	end
end

function RunBounce(trc,cmd)
	buaBounce = (buaBounce + 1)
	-- M9K Bullets only bounce on metal surfaces
	if buaBounce > flask_bounce_limit:GetInt() then
		return
	end
	if trc.MatType != MAT_METAL then
		return
	end
	
	
	local vec1 = trc.Normal
	local vec2 = trc.HitNormal
	
	local dotp = vec1:Dot(vec2)
	
	vec1 = vec1 + (-2 * (vec2 * dotp))
	
	local tr = util.TraceLine( {
		start = trc.HitPos,
		endpos = trc.HitPos+(vec1*2048),
		filter = nil,
	} )
	
	debugoverlay.Line(trc.HitPos,tr.HitPos, 0.03 )
	
	if buaValid(tr.Entity) then
		cmd:AddKey(IN_ATTACK)
		return
	end
	
	-- Recursion
	RunBounce(tr,cmd)
	
end

function RunTriggerBot(cmd)

	if flask_triggerkey:GetInt() > 0 then
		if !input.IsKeyDown(flask_triggerkey:GetInt()) then return end
	end
	
	local trc = LocalPlayer():GetEyeTrace()
	if buaValid(trc.Entity) then
		cmd:AddKey(IN_ATTACK)
	else
		if flask_trigger_bounce:GetBool() then
			buaBounce = 0
			RunBounce(trc,cmd)
		end
	end
end

function perfectDelta(speed, plr)
	local speedVar = plr:GetMaxSpeed()
	local airVar = GetConVar("sv_airaccelerate"):GetFloat()
	local wishSpeed = 90.0
	local term = wishSpeed / airVar / speedVar * 100.0 / speed
	
	if (term < 1.0 && term > -1.0) then
		return math.acos(term)
	end
	return 0.0;
end

function RunAutoStrafe(plr,cmd)
	local speed = plr:GetVelocity():Length2D()
	if speed < 2.0 then return end
	local vel = plr:GetVelocity()
	local pDelta = perfectDelta(speed,plr)
	
	if pDelta then
		local yaw = math.rad(cmd:GetViewAngles().y)
		local velDir = math.atan2(vel.y, vel.x) - yaw
		local wishAng = math.atan2(-cmd:GetSideMove(), cmd:GetForwardMove())
		local delta = math.rad(math.AngleDifference(math.deg(velDir), math.deg(wishAng)))
		
		local moveDir = nil
		
		if delta < 0.0 then
			moveDir = (velDir + pDelta)
		else
			moveDir = (velDir - pDelta)
		end
		
		local cl_sidespeed = GetConVar("cl_sidespeed"):GetFloat()
		
		cmd:SetForwardMove(math.cos(moveDir) * cl_sidespeed)
		cmd:SetSideMove(-math.sin(moveDir) * cl_sidespeed)
	end
end

hook.Add( "CreateMove", "buaMove", function(cmd)
	if buaInNoclip then
		cmd:ClearMovement() -- Freeze Input if you are in noclip mode
	end
	
	-- Thanks to FedoraWare for the autostrafe code
	
	if !LocalPlayer():IsOnGround() then
		if flask_bhop:GetBool() then
			cmd:RemoveKey(IN_JUMP)
		end
		if flask_autostrafe:GetBool() then
			RunAutoStrafe(LocalPlayer(),cmd)
		end
	end
		
	if flask_trigger:GetBool() then
		RunTriggerBot(cmd)
	end
	
end )

hook.Add( "InputMouseApply", "buaMouse", function( cmd, x, y, angs )
	
	if flask_aimbot:GetBool() then
		RunAimBot(cmd)
	end
	
	if flask_thirdperson:GetBool() then
		buaInSilent = true
	else
		buaInSilent = false
	end
	if buaInSilent then
		local xMult = x * 0.022
		local yMult = y * 0.022
		buaSilentAngles = buaSilentAngles + Angle(yMult, -xMult, 0)
		FixMovement(cmd,cmd:GetViewAngles())
		return true
	end
end )