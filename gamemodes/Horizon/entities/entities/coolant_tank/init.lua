AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("coolant_tank")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/coolant_tank.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "storage"
	self.maxCoolant = 1200
	self.coolant = 0
	self.totalCoolant = self.coolant
	self.nwMaxCoolant = self.maxCoolant
	self.resourcesUsed = {"coolant"}				
	
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if not (WireAddon == nil) then
        self.WireDebugName = self.PrintName
        self.Outputs = Wire_CreateOutputs(self, { "Coolant In Tank", "Total Coolant" })
    end
	
end
 
function ENT:Think()

	-- update status baloon, and discard excess resources
	
	self:devUpdate()
	self:trimResources()
			
	if self.networkID == nil then
		self:resetResources()
	end
	
	-- Update the wire outputs, DUH!
	if not (WireAddon == nil) then
        self:UpdateWireOutput()
    end
	

    
end

function ENT:GetTotalResource()
-- calculate the total energy available on the network.
	if self.networkID != nil then	
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do			
			if res[1] == "coolant" then				
				self.totalCoolant = res[2]
				self.nwMaxCoolant = res[3]
			end			
		end
	end
end

function ENT:UpdateWireOutput()
	local tankCoolant
	local networkCoolant
	
	tankCoolant = self.coolant
	networkCoolant = self.totalCoolant	
	
    Wire_TriggerOutput(self, "Coolant In Tank", math.Round( tankCoolant ) )
    Wire_TriggerOutput(self, "Total Coolant", math.Round( networkCoolant ) )
  
end

function ENT:trimResources()

	if self.coolant > self.maxCoolant then self.coolant = self.maxCoolant end

end

function ENT:resetResources()

	self.totalCoolant = self.coolant
	self.nwMaxCoolant = self.maxCoolant

end

function ENT:updateResCount(resName, newAmt, totalRes)

	if resName == "coolant" then
	
		if self.coolant <= self.maxCoolant then
			self.coolant = newAmt
		end
		
		self.totalCoolant = totalRes
	
	end

end

function ENT:reportResources( netID )
	
	for _, res in pairs( GAMEMODE.networks[netID][1] ) do	
			
		if res[1] == "coolant" then	
			res[2] = res[2] + self.coolant			
			res[3] = res[3] + self.maxCoolant			
		end
	end

end

function ENT:devUpdate()
	net.Start( "netCoolantTank" )
		net.WriteEntity( self )
		net.WriteFloat( self.totalCoolant )
		net.WriteFloat( self.nwMaxCoolant )
		-- net.WriteFloat( self.networkID )
	net.Broadcast()
end


 