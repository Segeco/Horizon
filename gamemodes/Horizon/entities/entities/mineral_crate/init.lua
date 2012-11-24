AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheSound( "cavernrock.impacthard" )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("mineral_crate")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/mineral_crate.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
		
	self.maxMorphite = 500
	self.Morphite = 500
	
	self.maxNocxium = 500
	self.Nocxium = 500	
	
	self.maxIsogen = 500
	self.Isogen = 500
	
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end
 
function ENT:Think()

	-- update status baloon, and discard excess resources
	
	self:devUpdate()
	self:trimResources()
	
	    
end

function ENT:StartTouch( hitEnt )
 
			if ( hitEnt:IsValid() and hitEnt:GetClass() == "morphite_ore" and self.Morphite < self.maxMorphite) then
			hitEnt:Remove()
			self.Entity:EmitSound( "cavernrock.impacthard" )
			self.Morphite = self.Morphite + 10		
			end
 	
		if ( hitEnt:IsValid() and hitEnt:GetClass() == "nocxium_ore" and self.Nocxium < self.maxNocxium) then
			hitEnt:Remove()			
			self.Entity:EmitSound( "cavernrock.impacthard" )
			self.Nocxium = self.Nocxium + 10
		end	
	
		if ( hitEnt:IsValid() and hitEnt:GetClass() == "sm_asteroid" and self.Isogen < self.maxIsogen) then
			hitEnt:Remove()			
			self.Entity:EmitSound( "cavernrock.impacthard" )
			self.Isogen = self.Isogen + 5
		end
	
 end
 
 function ENT:trimResources()

	if self.Morphite > self.maxMorphite then self.Morphite = self.maxMorphite end
	if self.Nocxium > self.maxNocxium then self.Nocxium = self.maxNocxium end
	if self.Isogen > self.maxIsogen then self.Isogen = self.maxIsogen end

end


function ENT:devUpdate()
	umsg.Start("crate_umsg")
	umsg.Entity(self)
	umsg.Short( self.Morphite )
	umsg.Short( self.Nocxium )
	umsg.Short( self.Isogen )
	umsg.End()
end


 