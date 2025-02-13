
local org = Vector(0,0,0)
local vel = Vector(0,0,0)
local ang = Angle(0,0,0)

local grav = Vector(0,0,-3)

local speed_forward = 0
local speed_sideways = 0

local enabled = false

concommand.Add( "artmove_toggle", function( ply, cmd, args )
	if enabled then
		enabled = false
	else
		enabled = true
		org = LocalPlayer():GetPos()
		vel = Vector(0,0,0)
		ang = LocalPlayer():EyeAngles()
	end
end )

function ApplyGravity()
	vel = (vel + grav)
end

function VelocityStart()
	
	local trc = util.TraceLine( {
		start = org,
		endpos = org+vel,
		filter = nil,
	} )
	
	org = trc.HitPos
end

hook.Add( "Think", "artThink", function( ply, pos, angles, fov )
	if enabled then
		
		ApplyGravity()
		
		local moveAng = ang
		moveAng.x = 0
		
		local wishVec = Vector(speed_forward, speed_sideways, 0)
		
		wishVec:Rotate(moveAng)
		
		vel = (vel + wishVec)
		
		VelocityStart()
	end
end )

hook.Add( "CalcView", "artView", function( ply, pos, angles, fov )
	-- Noclip Controls
	local view = {
		origin = pos,
		angles = angles,
		fov = fov,
	}
	
	if enabled then
		view.origin = org
		view.angles = ang
	end
	
	return view
end )

hook.Add( "CreateMove", "artMove", function(cmd)
	if enabled then
		speed_forward = cmd:GetForwardMove()
		speed_sideways = cmd:GetSideMove()
	end
end )