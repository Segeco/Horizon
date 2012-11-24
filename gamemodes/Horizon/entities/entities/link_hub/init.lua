AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("link_hub")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/props_junk/plasticbucket001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "networking"
	
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end




 