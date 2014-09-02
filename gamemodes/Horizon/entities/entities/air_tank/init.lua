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
	self.nwMaxAir = 0
	self.venting = false
	self.totalAir = self.Air
	self.resourcesUsed = {"air"}

        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if not (WireAddon == nil) then
        self.WireDebugName = self.PrintName
        self.Outputs = Wire_CreateOutputs(self, { "Air In Tank", "Total Air" })
    end
end

 
function ENT:Think()

	-- update status baloon, and discard excess resources
	
	self:devUpdate()
	self:trimResources()
	
	-- Update the wire outputs, DUH!
	if not (WireAddon == nil) then
        self:UpdateWireOutput()
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
	self.nwMaxAir = self.maxAir

end

function ENT:GetTotalResource()
-- calculate the total energy available on the network.
	if self.networkID != nil then	
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do			
			if res[1] == "air" then				
				self.totalAir = res[2]
				self.nwMaxAir = res[3]
			end			
		end
	end
end

function ENT:updateResCount(resName, newAmt, totalRes)

	if resName == "air" then
	
		if self.Air <= self.maxAir then
			self.Air = newAmt
		end
		
		self.totalAir = totalRes
	
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

function ENT:UpdateWireOutput()
	local tankAir
	local networkAir
	
	tankAir = self.Air
	networkAir = self.totalAir	
	
    Wire_TriggerOutput(self, "Air In Tank", math.Round( tankAir ) )
    Wire_TriggerOutput(self, "Total Air", math.Round( networkAir ) )
  
end

function ENT:devUpdate()
	net.Start( "netAirTank" )
		net.WriteEntity( self )
		net.WriteFloat( self.totalAir )
		net.WriteFloat( self.nwMaxAir )
		-- net.WriteFloat( self.networkID )
	net.Broadcast()
end


 