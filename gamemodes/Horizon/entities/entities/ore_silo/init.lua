AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
util.AddNetworkString( "netOreSilo" )

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
	self.totalMorphite = self.Morphite	
	
	self.maxNocxium = 10000
	self.Nocxium = 0	
	self.totalNocxium = self.Nocxium	
	
	self.maxIsogen = 10000
	self.Isogen = 0	
	self.totalIsogen = self.Isogen	
	
	self.resourcesUsed = {"morphite", "nocxium", "isogen"}				
	
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if not (WireAddon == nil) then
        self.WireDebugName = self.PrintName
        self.Outputs = Wire_CreateOutputs(self, { "Morphite In Tank", "Total Morphite", "Nocxium In Tank", "Total Nocxium", "Isogen In Tank", "Total Isogen" })
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
	
	-- Update the wire outputs, DUH!
	if not (WireAddon == nil) then
        self:UpdateWireOutput()
    end
	
	if self.networkID == nil then
		self:resetResources()
	end
    
end

function ENT:UpdateWireOutput()
	local tankMorphite
	local networkMorphite
	local tankNocxium
	local networkNocxium
	local tankIsogen
	local networkIsogen
	
	tankMorphite = math.Round( self.Morphite )
	networkMorphite = math.Round( self.totalMorphite )
	tankNocxium = math.Round( self.Nocxium )
	networkNocxium = math.Round( self.totalNocxium )
	tankIsogen = math.Round( self.Isogen )
	networkIsogen = math.Round( self.totalIsogen )
	
    Wire_TriggerOutput(self, "Morphite In Tank", tankMorphite )
    Wire_TriggerOutput(self, "Total Morphite", networkMorphite )
	Wire_TriggerOutput(self, "Nocxium In Tank", tankNocxium )
    Wire_TriggerOutput(self, "Total Nocxium", networkNocxium )
	Wire_TriggerOutput(self, "Isogen In Tank", tankIsogen )
    Wire_TriggerOutput(self, "Total Isogen", networkIsogen )
  
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
	local Content = {
		Morphite = {
			amount = self.Morphite,
			max = self.maxMorphite
		},
		Nocxium = {
			amount = self.Nocxium,
			max = self.maxNocxium
		},
		Isogen = {
			amount = self.Isogen,
			max = self.maxIsogen
		}
	}
	net.Start( "netOreSilo" )
		net.WriteEntity( self )
		net.WriteTable( Content )
		-- net.WriteFloat( self.networkID )
	net.Broadcast()
end


 