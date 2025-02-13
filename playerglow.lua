outline = {}

local outlined = {}
local clear = true

function outline.Add(ent, col)
	outlined[ent] = col
	clear = false
end

function DrawInfo(ent, col)
	local point = ent:EyePos()
	local data2D = point:ToScreen()
	
	if ( not data2D.visible ) then return end
	
	local nm
	if ent:IsPlayer() then
		nm = ent:Nick()
	else
		nm = ent:GetClass()
	end
	
	draw.SimpleText( nm, "Default", data2D.x, data2D.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

hook.Add("HUDPaint","playeroutlines",function()
	hook.Run("PreDrawOutlines")
	
	if clear then return end
	
	local drawAng = Angle(0,0,0)
	
	cam.Start3D()
		for k,v in next,outlined do
			render.DrawWireframeBox(k:GetPos(), drawAng, k:OBBMins(), k:OBBMaxs(), v)
		end
	cam.End3D()
	
	for k,v in next,outlined do
		DrawInfo(k,v)
	end
	
	clear = true
	table.Empty(outlined)
end)