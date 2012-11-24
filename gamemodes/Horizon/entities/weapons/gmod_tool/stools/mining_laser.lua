TOOL.Category = "Mining"
TOOL.Name = "Mining Laser"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"

if ( CLIENT ) then
    language.Add( "Tool.mining_laser.name", "Mining Laser" );
    language.Add( "Tool.mining_laser.desc", "Split Rocks!" );
	language.Add( "Tool.mining_laser.0", "Left Click to place laser" );
end

TOOL.ClientConVar[ "weldToTarget" ] = "0";
TOOL.ClientConVar[ "key" ] = "5";



function TOOL:LeftClick( trace )

if ( not trace.HitPos ) then return false; end
	
	if ( trace.Entity:IsPlayer() ) then return false; end
	
	if ( SERVER and not util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false; end
	
	if ( CLIENT ) then return true; end

	local ply = self:GetOwner();
	local weldToTarget = self:GetClientNumber( "weldToTarget" ) == 1;
	local key = self:GetClientNumber( "key" );
	local Ang = trace.HitNormal:Angle();
	Ang.pitch = Ang.pitch + 90 -- angleOffset;
	
	
	local laser = ents.Create( "mining_laser" )
		if ( not laser:IsValid() ) then return false; end

		laser:SetAngles( Ang );			
		laser:Spawn();
		
		numpad.OnDown( ply, key, "lsr_active", laser );
		numpad.OnUp( ply, key, "lsr_inactive", laser );
	

	local min = laser:OBBMins();
	laser:SetPos( trace.HitPos - trace.HitNormal * min.z );
	
	if ( trace.Entity:IsValid() or trace.Entity:IsWorld() ) then
		if weldToTarget then
			local const = constraint.Weld( laser, trace.Entity, trace.PhysicsBone, 0, 0 );
		end
	end

	undo.Create( "mining_laser" );
		undo.AddEntity( laser );
		undo.AddEntity( const );
		undo.SetPlayer( ply );
	undo.Finish();

	ply:AddCleanup( "mining lasers", laser );

	return true;
end
	
	


function TOOL:Reload( tr )

	
	
end

function TOOL:UpdateGhostLaserEmitter( ent, player )
	if ( not ent or not ent:IsValid() ) then return; end

	local tr = util.GetPlayerTrace( player, player:GetAimVector() );
	local trace = util.TraceLine( tr );

	if ( not trace.Hit or trace.Entity:IsPlayer() or trace.Entity:GetClass() == "mining_laser" ) then
		ent:SetNoDraw( true );
		return;
	end

	local Ang = trace.HitNormal:Angle();
	Ang.pitch = Ang.pitch + 90 - self:GetClientNumber( "angleoffset" );

	local min = ent:OBBMins();
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z );
	ent:SetAngles( Ang );
		
	ent:SetNoDraw( false );
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "Mining Laser", Description = "Options!" })
 
	panel:AddControl("CheckBox", {
	    Label = "Weld To Target",
	    Command = "mining_laser_weldToTarget"
	})
	
	panel:AddControl( "Numpad", {	
	
		Label = "Key:",
		Command = "mining_laser_key",
		ButtonSize = 22 } );
	
end

function TOOL:Think()
	if ( not self.GhostEntity or not self.GhostEntity:IsValid() or self.GhostEntity:GetModel() ~= "models/props_junk/garbage_plasticbottle003a.mdl" ) then
		self:MakeGhostEntity( "models/mining_laser.mdl", Vector( 0, 0, 0 ), Angle( 0, 0, 0) );
	end

	self:UpdateGhostLaserEmitter( self.GhostEntity, self:GetOwner() );
end




