
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
	AppList.OnRowSelected = function( lst, index, pnl )
		flask_selected = pnl:GetColumnText( 2 )
	end
	
	for _, ply in player.Iterator() do
		if ply:IsValid() then
			AppList:AddLine( ply:Nick(), ply:EntIndex() )
		end
	end
	
	local b1 = vgui.Create( "DButton", f )
	b1:SetText( "Mark selected player as target" )
	b1:Dock(BOTTOM)
	b1.DoClick = function()
		if flask_selected != "0" then
			RunConsoleCommand("flask_target", flask_selected)
		end
	end
	
	local b2 = vgui.Create( "DButton", f )
	b2:SetText( "Log player's info" )
	b2:Dock(BOTTOM)
	b2.DoClick = function()
		local ent = Entity(flask_selected)
		if ent:IsValid() then
			print("Name:  "..ent:Nick())
			print("Steam ID:  "..ent:SteamID())
			print("Weapon Color:  "..tostring(ent:GetWeaponColor()))
			print("Player Color:  "..tostring(ent:GetPlayerColor()))
			print("Player Model:  "..ent:GetModel())
		end
	end
	
end )