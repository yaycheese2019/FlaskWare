local randPoint = nil
local intrestTime = 512

-- Just a walkbot that walks around randomly on the navmesh

hook.Add( "CreateMove", "walkBotThink", function(cmd)
	if !randPoint then
		local n = VectorRand(-1000,1000)
		n.z = 0
		randPoint = LocalPlayer():GetPos() + n
		intrestTime = 512
	else
		local angs = (randPoint - LocalPlayer():GetPos())
		if(angs:Length() < 50) then
			randPoint = nil
		end
		if(angs:Length() > 1000) then
			randPoint = nil
		end
		angs = angs:Angle()
		angs.x = 0
		cmd:SetViewAngles(angs)
	end
	cmd:SetForwardMove(10000)
	intrestTime = intrestTime - 1
	if(intrestTime < 0) then
		randPoint = nil
	end
end )