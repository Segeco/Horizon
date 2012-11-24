AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("water_tank")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/water_tank.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "storage"
	self.maxWater = 1200
	self.Water = 0
	self.totalWater = self.Water
	self.resourcesUsed = {"water"}

        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end
 
 
function ENT:Think()

	-- update status baloon, and discard excess resources
	
	self:devUpdate()
	self:trimResources()
	
	-- calculate the total water available on the network.
	if self.networkID != nil then	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do			
			if res[1] == "water" then				
				self.totalWater = res[2]			
			end
			
		end
	end
	
	if self.networkID == nil then
		self:resetResources()
	end
    
end

function ENT:trimResources()

	if self.Water > self.maxWater then self.Water = self.maxWater end

end

function ENT:resetResources()

	self.totalWater = self.Water

end

function ENT:updateResCount(resName, newAmt)

	if resName == "water" then
	
		if self.Water < self.maxWater then
			self.Water = newAmt
		end
	
	end

end

function ENT:reportResources( netID )
	
	for _, res in pairs( GAMEMODE.networks[netID][1] ) do	
			
		if res[1] == "water" then	
			res[2] = res[2] + self.Water			
			res[3] = res[3] + self.maxWater			
		end
	end

end

function ENT:devUpdate()
	umsg.Start("water_tank_umsg")
	umsg.Entity(self)
	umsg.Short( self.totalWater )
	umsg.End()
end


 