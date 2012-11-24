AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("ore_silo")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/ore_silo.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "storage"
	
	self.maxMorphite = 10000
	self.Morphite = 0	
	
	self.maxNocxium = 10000
	self.Nocxium = 0	
	
	self.maxIsogen = 10000
	self.Isogen = 0	
	
	self.resourcesUsed = {"morphite", "nocxium", "isogen"}				
	
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end
 
function ENT:Think()

	-- update status baloon, and discard excess resources
	
	self:devUpdate()
	self:trimResources()
	
	-- calculate the total air available on the network.
	if self.networkID != nil then	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do			
			if res[1] == "morphite" then	
				self.totalMorphite = res[2]			
			end
			if res[1] == "nocxium" then	
				self.totalNocxium = res[2]			
			end
			if res[1] == "isogen" then	
				self.totalIsogen = res[2]			
			end
		end
	end
	
	if self.networkID == nil then
		self:resetResources()
	end
    
end

function ENT:trimResources()

	if self.Morphite > self.maxMorphite then self.Morphite = self.maxMorphite end
	if self.Nocxium > self.maxNocxium then self.Nocxium = self.maxNocxium end
	if self.Isogen > self.maxIsogen then self.Isogen = self.maxIsogen end

end

function ENT:resetResources()

	self.totalMorphite = self.Morphite
	self.totalNocxium = self.Nocxium
	self.totalIsogen = self.Isogen

end

function ENT:updateResCount(resName, newAmt)

	if resName == "morphite" then
	
		if self.Morphite < self.maxMorphite then
			self.Morphite = newAmt
		end
	
	end
	
	if resName == "nocxium" then
	
		if self.Nocxium < self.maxNocxium then
			self.Nocxium = newAmt
		end
	
	end
	
	if resName == "isogen" then
	
		if self.Isogen < self.maxIsogen then
			self.Isogen = newAmt
		end
	
	end

end

function ENT:reportResources( netID )
	
	for _, res in pairs( GAMEMODE.networks[netID][1] ) do	
			
		if res[1] == "morphite" then	
			res[2] = res[2] + self.Morphite			
			res[3] = res[3] + self.maxMorphite		
		end
		
		if res[1] == "nocxium" then	
			res[2] = res[2] + self.Nocxium			
			res[3] = res[3] + self.maxNocxium		
		end
		
		if res[1] == "isogen" then	
			res[2] = res[2] + self.Isogen			
			res[3] = res[3] + self.maxIsogen		
		end
	end

end

function ENT:devUpdate()
	umsg.Start("silo_umsg")
	umsg.Entity(self)
	umsg.Short( self.totalMorphite )
	umsg.Short( self.totalNocxium )
	umsg.Short( self.totalIsogen )
	umsg.End()
end


 