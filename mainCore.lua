local target = nil
local buaInNoclip = false
local buaNoclipOrigin = Vector(0,0,0)
local buaTime = 0

flask_selected = nil
flask_ignore = {}

include("mainGui.lua")
include("mainConVars.lua")

flask_esp = GetConVar("flask_esp")
flask_view = GetConVar("flask_view")
flask_lock = GetConVar("flask_lock")
flask_autoshoot = GetConVar("flask_autoshoot")
flask_cham = GetConVar("flask_cham")
flask_cham_enable = GetConVar("flask_cham_enable")
flask_recoil = GetConVar("flask_recoil")
flask_bhop = GetConVar("flask_bhop")
flask_autostrafe = GetConVar("flask_autostrafe")
flask_trigger = GetConVar("flask_trigger")
flask_aimbot = GetConVar("flask_aimbot")
flask_aimkey = GetConVar("flask_aimkey")
flask_triggerkey = GetConVar("flask_triggerkey")
flask_sort = GetConVar("flask_sort")
flask_range = GetConVar("flask_range")
flask_propkey = GetConVar("flask_propkey")
flask_prop_push = GetConVar("flask_prop_push")
flask_prop_push_delta = GetConVar("flask_prop_push_delta")

--[[
	Features:
	- AimBot
	- Aim Key
	- AutoShoot
	- TriggerBot
	- Trigger Key
	- Auto Prop Push
	- Auto Prop Push Key
	- Auto Prop Push Delta
	- Bhop
	- Autostrafe
	
	- ESP
	- Target POV
	- Target Lock
	- Entity Chams
	- Anti Recoil
	- Sorting Method
	- Max Range
	
	- Target Ignore
	
	- Targets players, NPCs, nextbots
]]--

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
	
	if(!e:IsValid()) then return false end -- Don't target NULL
	if(e == LocalPlayer()) then return false end -- Don't target self
	if flask_ignore[e:EntIndex()] then return false end -- Check if target is ignored
	
	if(e:IsPlayer() && e:Alive()) then return true end
	if(e:IsNPC()) then return true end
	if(e:IsNextBot()) then return true end
	
	return false
end

function buaColor(e)
	if(target == e) then
		return Color(255,0,0)
	end
	if(e:IsPlayer() && e:IsAdmin()) then
		return Color(0,64,255)
	end
	return Color(255,255,255)
end

function buaCol(color)
	return (color[1].." "..color[2].." "..color[3])
end

hook.Add( "Think", "buaThink", function()
	local plr = LocalPlayer()
	if !flask_lock:GetBool() then
		target = nil
		local dist = nil
		local maxdist = flask_range:GetFloat()
		local eye = plr:EyePos()
		local sort = flask_sort:GetInt()
		
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
					dist = (ply:EyePos() - eye)
					if sort == 2 then
						dist:Normalize()
						dist = (dist - plr:GetForward()):Length()
					else
						dist = dist:Length()
					end
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
	--[[local col = nil
	
	for _, ply in ents.Iterator() do
		if(buaValid(ply)) then
			col = buaColor(ply)
			render.DrawWireframeBox(ply:GetPos(),Angle(0,0,0),ply:OBBMins(),ply:OBBMaxs(),col)
		end
	end
	]]--
	
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

hook.Add( "HUDPaint", "buaHud", function()
	if ( !flask_esp:GetBool() ) then return end
	local col = nil
	for _, ent in ents.Iterator() do
		if(buaValid(ent)) then
			local point = ent:GetPos() + ent:OBBCenter() -- Gets the position of the entity, specifically the center
			local data2D = point:ToScreen() -- Gets the position of the entity on your screen

			-- The position is not visible from our screen, don't draw and continue onto the next prop
			if ( not data2D.visible ) then continue end

			-- Draw a simple text over where the prop is
			
			col = buaColor(ent)
			
			local nm = nil
			if ent:IsPlayer() then
				nm = ent:Nick()
			else
				nm = ent:GetModel()
			end
			
			draw.SimpleText( nm, "Default", data2D.x, data2D.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( ent:Health().."/"..ent:GetMaxHealth(), "Default", data2D.x, data2D.y+30, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
	if(buaInNoclip) then
		view.origin = buaNoclipOrigin
		--view.drawviewer = true
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

function perfectDelta(speed, plr)
	local speedVar = plr:GetMaxSpeed() * 100
	local airVar = GetConVar("sv_airaccelerate"):GetFloat()
	local wishSpeed = 90.0
	local term = wishSpeed / airVar / speedVar / speed
	
	if (term < 1.0 && term > -1.0) then
		return math.acos(term)
	end
	return 0.0;
end

function buaAutoStrafe(plr,cmd)

	if !flask_autostrafe:GetBool() then return end
	
	local speed = plr:GetVelocity():Length2D()
	if speed < 2.0 then return end
	local vel = plr:GetVelocity()
	local pDelta = perfectDelta(speed,plr)
	
	if pDelta then
		local yaw = math.rad(cmd:GetViewAngles().y)
		local velDir = math.atan2(vel.y, vel.x) - yaw
		local wishAng = math.atan2(-cmd:GetSideMove(), cmd:GetForwardMove())
		local delta = math.AngleDifference(math.deg(velDir), math.deg(wishAng))
		
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
	return
end

function RunAimBot(cmd)
	
	local k = flask_aimkey:GetInt()
	if k > 0 then
		if !input.IsKeyDown(k) then return end
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

function RunTrigger(cmd)
	local k = flask_triggerkey:GetInt()
	
	if k > 0 then
		if !input.IsKeyDown(k) then return end
	end
	
	
	local trc = LocalPlayer():GetEyeTrace().Entity
	if buaValid(trc) then
		cmd:AddKey(IN_ATTACK)
	end
	
end

function RunPropPush(cmd)
	local k = flask_propkey:GetInt()
	
	if k > 0 then
		if !input.IsKeyDown(k) then return end
	end
	
	cmd:SetMouseWheel(flask_prop_push_delta:GetInt())
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
		buaAutoStrafe(LocalPlayer(),cmd)
	end
	
	if flask_aimbot:GetBool() then
		RunAimBot(cmd)
	end

	if flask_trigger:GetBool() then
		RunTrigger(cmd)
	end

	if flask_prop_push:GetBool() then
		RunPropPush(cmd)
	end

end )