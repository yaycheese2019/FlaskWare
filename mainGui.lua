
concommand.Add( "flask_open_gui", function( ply, cmd, args )
	local f = vgui.Create( "DFrame" )
	f:SetSize( 500, 300 )
	f:Center()
	f:SetTitle("FlaskWare Settings")
	f:MakePopup()
	
	local DProperties = vgui.Create( "DProperties", f )
	DProperties:Dock( FILL )
	
	-- dear god...

	local Row3 = DProperties:CreateRow( "Global", "Target Lock" )
	Row3:Setup( "Boolean" )
	Row3:SetValue(GetConVar("flask_lock"):GetBool())
	Row3.DataChanged = function( self, data )
		GetConVar("flask_lock"):SetInt(data)
	end

	local Row5 = DProperties:CreateRow( "Global", "AutoShoot" )
	Row5:Setup( "Boolean" )
	Row5:SetValue(GetConVar("flask_autoshoot"):GetBool())
	Row5.DataChanged = function( self, data )
		GetConVar("flask_autoshoot"):SetInt(data)
	end
	
	local Row11 = DProperties:CreateRow( "Global", "TriggerBot" )
	Row11:Setup( "Boolean" )
	Row11:SetValue(GetConVar("flask_trigger"):GetBool())
	Row11.DataChanged = function( self, data )
		GetConVar("flask_trigger"):SetInt(data)
	end
	
	local Row8 = DProperties:CreateRow( "Global", "No Recoil" )
	Row8:Setup( "Boolean" )
	Row8:SetValue(GetConVar("flask_recoil"):GetBool())
	Row8.DataChanged = function( self, data )
		GetConVar("flask_recoil"):SetInt(data)
	end
	
	local Row1 = DProperties:CreateRow( "Visual", "Enable ESP" )
	Row1:Setup( "Boolean" )
	Row1:SetValue(GetConVar("flask_esp"):GetBool())
	Row1.DataChanged = function( self, data )
		GetConVar("flask_esp"):SetInt(data)
	end

	local Row7 = DProperties:CreateRow( "Visual", "Enable Chams" )
	Row7:Setup( "Boolean" )
	Row7:SetValue(GetConVar("flask_cham_enable"):GetBool())
	Row7.DataChanged = function( self, data )
		GetConVar("flask_cham_enable"):SetInt(data)
	end

	local Row6 = DProperties:CreateRow( "Visual", "Entity to highlight" )
	Row6:Setup( "Generic" )
	Row6:SetValue(GetConVar("flask_cham"):GetString())
	Row6.DataChanged = function( self, data )
		GetConVar("flask_cham"):SetString(data)
	end

	local Row2 = DProperties:CreateRow( "Visual", "Target POV" )
	Row2:Setup( "Boolean" )
	Row2:SetValue(GetConVar("flask_view"):GetBool())
	Row2.DataChanged = function( self, data )
		GetConVar("flask_view"):SetInt(data)
	end
	
	local Row9 = DProperties:CreateRow( "Misc", "Bhop" )
	Row9:Setup( "Boolean" )
	Row9:SetValue(GetConVar("flask_bhop"):GetBool())
	Row9.DataChanged = function( self, data )
		GetConVar("flask_bhop"):SetInt(data)
	end
	
	local Row10 = DProperties:CreateRow( "Misc", "AutoStrafe" )
	Row10:Setup( "Boolean" )
	Row10:SetValue(GetConVar("flask_autostrafe"):GetBool())
	Row10.DataChanged = function( self, data )
		GetConVar("flask_autostrafe"):SetInt(data)
	end
	
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
			print(ply:Nick())
			print(ply:SteamID())
			print(ply:GetWeaponColor())
			print(ply:GetPlayerColor())
		end)

		Menu:Open()
	end
	
	for _, ply in player.Iterator() do
		if ply:IsValid() then
			AppList:AddLine( ply:Nick(), ply:EntIndex() )
		end
	end
	
end )

concommand.Add( "flask_open_bind", function( ply, cmd, args )
	local f = vgui.Create( "DFrame" )
	f:SetSize( 500, 300 )
	f:Center()
	f:SetTitle("Input Menu")
	f:MakePopup()
	
	local T1 = vgui.Create( "DLabel", f )
	T1:Dock(BOTTOM)
	T1:SetText("Aim Key")

	local B1 = vgui.Create( "DBinder", f )
	B1:Dock(BOTTOM)
	B1:SetValue(GetConVar("flask_aimkey"):GetInt())
	
	function B1:OnChange( num )
		GetConVar("flask_aimkey"):SetInt(num)
	end
	
	local T2 = vgui.Create( "DLabel", f )
	T2:Dock(BOTTOM)
	T2:SetText("Trigger Key")

	local B2 = vgui.Create( "DBinder", f )
	B2:Dock(BOTTOM)
	B2:SetValue(GetConVar("flask_triggerkey"):GetInt())
	
	function B2:OnChange( num )
		GetConVar("flask_triggerkey"):SetInt(num)
	end
end )