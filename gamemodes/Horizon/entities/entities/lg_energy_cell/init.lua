AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
util.AddNetworkString( "netLgEnerCell" )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("lg_energy_cell")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/props_c17/substation_stripebox01a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "storage"
	self.maxEnergy = 50000
	self.energy = 0
	self.totalEnergy = self.energy
	self.nwMaxEnergy = self.maxEnergy
	self.resourcesUsed = {"energy"}				
	
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if not (WireAddon == nil) then
        self.WireDebugName = self.PrintName
        self.Outputs = Wire_CreateOutputs(self, { "Energy In Cell", "Total Energy" })
    end
end
 
function ENT:Think()

	-- update status balloon, and discard excess resources
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

function ENT:UpdateWireOutput()
		
    Wire_TriggerOutput(self, "Energy In Cell", math.Round( self.energy ) )
    Wire_TriggerOutput(self, "Total Energy", math.Round( self.totalEnergy ) )
  
end

function ENT:trimResources()

	if self.energy > self.maxEnergy then self.energy = self.maxEnergy end

end

function ENT:resetResources()

	self.totalEnergy = self.energy
	self.nwMaxEnergy = self.maxEnergy

end

function ENT:updateResCount(resName, newAmt, totalRes)

	if resName == "energy" then
	
		if self.energy <= self.maxEnergy then
			self.energy = newAmt
		end
		
		self.totalEnergy = totalRes
		
	
	end

end

function ENT:GetTotalResource()
-- calculate the total energy available on the network.
	if self.networkID != nil then	
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do			
			if res[1] == "energy" then				
				self.totalEnergy = res[2]
				self.nwMaxEnergy = res[3]
			end			
		end
	end
end

function ENT:reportResources( netID )
	
	for _, res in pairs( GAMEMODE.networks[netID][1] ) do	
			
		if res[1] == "energy" then	
			res[2] = res[2] + self.energy			
			res[3] = res[3] + self.maxEnergy			
		end
	end

end

function ENT:devUpdate()
	net.Start( "netLgEnerCell" )
		net.WriteEntity( self )
		net.WriteFloat( self.totalEnergy )
		net.WriteFloat( self.nwMaxEnergy )
		-- net.WriteFloat( self.networkID )
	net.Broadcast()
end


 