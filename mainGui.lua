
surface.CreateFont("Font", {
    font = "Arial",
    extended = true,
    size = 20
})

local faded_black = Color(0, 0, 0, 200) -- The color black but with 200 Alpha

function guiCheckBox(p1, p2, p3)
	local check = vgui.Create("DCheckBoxLabel", p1)
	check:Dock(TOP)
	check:SetText(p2)
	check:SetConVar(p3)
	check:SetTooltip(p4)
end

function guiSlider(p1,p2,p3,p4,p5,p6)
	local slide = vgui.Create( "DNumSlider", p1 )
	slide:Dock(TOP)
	slide:SetText( p2 )
	slide:SetTooltip( p4 )
	slide:SetMin( p5 )
	slide:SetMax( p6 )
	slide:SetDecimals( 0 )
	slide:SetConVar( p3 )

end

function guiBind(p1,p2,p3)
	local T1 = vgui.Create( "DLabel", p1 )
	T1:Dock(TOP)
	T1:SetText(p2)

	local B1 = vgui.Create( "DBinder", p1 )
	B1:Dock(TOP)
	B1:SetValue(GetConVar(p3):GetInt())

	function B1:OnChange( num )
		GetConVar(p3):SetInt(num)
	end

end

function guiButton(p1,p2)
	
end

concommand.Add( "flask_open_gui", function( ply, cmd, args )
	local f = vgui.Create( "DFrame" )
	f:SetSize( 500, 300 )
	f:Center()
	f:SetTitle("")
	f:MakePopup()
	f.Paint = function(self, w, h)
	    draw.RoundedBox(2, 0, 0, w, h, faded_black)
	    draw.SimpleText("FlaskWare Settings", "Font", 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	
	local sheet = vgui.Create( "DPropertySheet", f )
	sheet:Dock( FILL )
	
	local Category1 = vgui.Create( "DPanel", sheet)
		guiCheckBox(Category1, "Aimbot", "flask_aimbot", "Enable or disable the aimbot.")
		guiCheckBox(Category1, "AutoShoot", "flask_autoshoot", "Automatically shoot when a target is detected.")
		guiCheckBox(Category1, "Lock Target", "flask_lock", "Lock the target so the aimbot doesn't switch targets")
		guiSlider(Category1, "Sorting Method", "flask_sort", "1 = Distance to player, 2 = Distance to mouse, 3 = Least Health", 1, 3)
	
	local Category2 = vgui.Create( "DPanel", sheet)
		guiCheckBox(Category2, "Enable ESP", "flask_esp", "Enable drawing ESP.")
		guiCheckBox(Category2, "Enable Chams", "flask_cham_enable", "Enable entity chams.")
		guiCheckBox(Category2, "Third Person", "flask_thirdperson", "Try to reduce the recoil")
		guiCheckBox(Category2, "Target POV", "flask_view", "View the world from the POV of the aimbot's target")
		guiCheckBox(Category2, "Compensate Recoil", "flask_recoil", "Try to reduce the recoil")

	local Category3 = vgui.Create( "DPanel", sheet)
		guiCheckBox(Category3, "Auto Jump", "flask_bhop", "Automatically jump when you hit the ground")
		guiCheckBox(Category3, "Directional Strafe", "flask_autostrafe", "Strafe around in the air using the WASD keys.")

	local Category4 = vgui.Create( "DPanel", sheet)
		guiBind(Category4, "Aim Key", "flask_aimkey")
		guiBind(Category4, "Trigger Key", "flask_triggerkey")
	
	local Category5 = vgui.Create( "DPanel", sheet)
		guiCheckBox(Category5, "Buildmode Spam", "flask_spam", "Spam the ulx build and ulx pvp commands.")
	
	
	local Category6 = vgui.Create( "DPanel", sheet)
		guiCheckBox(Category6, "Trigger Bot", "flask_trigger", "Enable the triggerbot.")
		guiCheckBox(Category6, "Bounce Prediction", "flask_trigger_bounce", "Predict the bullet bouncing of most M9K weapons.")
		guiSlider(Category6, "Max Bounces", "flask_bounce_limit", "Max amount of times the bounce prediction runs.", 1, 10)

	
	Category1:SetBackgroundColor(faded_black)
	Category2:SetBackgroundColor(faded_black)
	Category3:SetBackgroundColor(faded_black)
	Category4:SetBackgroundColor(faded_black)
	Category5:SetBackgroundColor(faded_black)
	Category6:SetBackgroundColor(faded_black)
	
	sheet:AddSheet( "Global", Category1 )
	sheet:AddSheet( "Visual", Category2 )
	sheet:AddSheet( "Movement", Category3 )
	sheet:AddSheet( "Key Binds", Category4 )
	sheet:AddSheet( "Misc", Category5 )
	sheet:AddSheet( "Trigger", Category6 )
end )

concommand.Add( "flask_open_list", function( ply, cmd, args )
	flask_selected = "0"
	local f = vgui.Create( "DFrame" )
	f:SetSize( 500, 300 )
	f:Center()
	f:SetTitle("List of Players")
	f:MakePopup()
	
	local AppList = vgui.Create( "DListView", f )
	AppList:Dock( FILL )
	AppList:SetMultiSelect( false )
	AppList:AddColumn( "Name" )
	AppList:AddColumn( "Index" )
	AppList.OnRowRightClick = function( panel, rowIndex, row )
		flask_selected = row:GetValue( 2 )
		local Menu = DermaMenu()
		
		Menu:AddOption("Mark as target", function(pnl)
			RunConsoleCommand("flask_target", tostring(flask_selected))
		end)
		Menu:AddOption("Grab Info", function(pnl)
			local ply = Entity(flask_selected)
			PrintTable( ply:GetPlayerInfo() )
		end)
		Menu:AddOption("Get Profile Page", function(pnl)
			local ply = Entity(flask_selected)
			local plyLink = ("https://steamcommunity.com/profiles/"..ply:SteamID64().."/")
			gui.OpenURL(plyLink)
		end)
		Menu:AddSpacer()
		Menu:AddOption("Steal Weapon Color", function(pnl)
			local ply = Entity(flask_selected)
			RunConsoleCommand("cl_weaponcolor", tostring(ply:GetWeaponColor()))
		end)
		Menu:AddOption("Steal Player Color", function(pnl)
			local ply = Entity(flask_selected)
			RunConsoleCommand("cl_playercolor", tostring(ply:GetPlayerColor()))
		end)

		Menu:Open()
	end
	
	for _, ply in player.Iterator() do
		if ply:IsValid() then
			AppList:AddLine( ply:Nick(), ply:EntIndex() )
		end
	end
	
end )