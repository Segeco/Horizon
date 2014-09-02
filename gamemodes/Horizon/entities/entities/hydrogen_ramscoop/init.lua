AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("hydrogen_ramscoop")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/props_wasteland/prison_lamp001c.mdl" )	
	self.deviceType = "generator"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.health = 100
	
	--Resource Rates
	self.hydrogenRate = 10
	

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	    
end

function ENT:OnTakeDamage(dmg)

	-- self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
 
	-- if(self.health <= 0) then return; end -- If the health-variable is already zero or below it - do nothing
 
	-- self.health = self.health - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable
 
	-- if(self.health <= 0) then -- If our health-variable is zero or below it
	-- 	local effectdata = EffectData()
	-- 	effectdata:SetOrigin( self:GetPos() )
	-- 	util.Effect( "explosion", effectdata )
	-- 	self:Remove(); -- Remove our entity
	-- end

end

function ENT:resourceExchange()

	-- use this function to place generate/consume resource function calls	
	
	GAMEMODE:generateResource( self.networkID, "hydrogen", ( self.hydrogenRate * FrameTime() ) )
	
end
   
function ENT:Think()

	if self.networkID != nil then
		if self:GetVelocity():Length() > 0 then
			self:resourceExchange()
		end
	end
	
	self.Entity:NextThink( CurTime() )
	return true	
    
end
