AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("air_tank")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/air_tank.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "storage"
	self.maxAir = 1200
	self.Air = 0
	self.totalAir = self.Air
	self.resourcesUsed = {"air"}

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
			if res[1] == "air" then				
				self.totalAir = res[2]			
			end
			
		end
	end
	
	if self.networkID == nil then
		self:resetResources()
	end
	
	    
end

function ENT:trimResources()

	if self.Air > self.maxAir then self.Air = self.maxAir end

end

function ENT:resetResources()

	self.totalAir = self.Air

end

function ENT:updateResCount(resName, newAmt)

	if resName == "air" then
	
		if self.Air < self.maxAir then
			self.Air = newAmt
		end
	
	end

end

function ENT:reportResources( netID )
	
	for _, res in pairs( GAMEMODE.networks[netID][1] ) do	
			
		if res[1] == "air" then	
			res[2] = res[2] + self.Air			
			res[3] = res[3] + self.maxAir			
		end
	end

end

function ENT:devUpdate()
	umsg.Start("air_tank_umsg")
	umsg.Entity( self )
	umsg.Short( self.totalAir )
	umsg.End()
end


 