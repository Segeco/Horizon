AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!

util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("water_splitter")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/water_splitter.mdl" )	
	self.deviceType = "generator"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.availableEnergy = 0
	self.availableWater = 0
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.health = 1000
	
	--Resource Rates
	self.airRate = 15
	self.hydrogenRate = 15
	self.energyRate = 60
	self.waterRate = 60

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end	
    
end

function ENT:resourceExchange()

	-- use this function to place generate/consume resource function calls	
	
	GAMEMODE:generateResource( self.networkID, "air", ( self.airRate * FrameTime() ) )
	GAMEMODE:generateResource( self.networkID, "hydrogen", ( self.hydrogenRate * FrameTime() ) )
	GAMEMODE:consumeResource( self.networkID, "energy", ( self.energyRate * FrameTime() ) )
	GAMEMODE:consumeResource( self.networkID, "water", ( self.waterRate * FrameTime() ) )


end
 

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then	
	if self.Active == false and self.availableEnergy > self.energyRate then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "apc_engine_start" )
	
	self.Active = true
	
	local sequence = self:LookupSequence("active")
	self:ResetSequence(sequence)	

end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	
	self.Active = false
	
	local sequence = self:LookupSequence("idle")
	self:ResetSequence(sequence)	

end

   
function ENT:Think()

	
	
	-- Check to see if the device is part of a network
	
	if self.networkID == nil and self.Active == true then
		self:deviceTurnOff()
	end
	
	-- Check to see if the device has the required resources to function
	
	if self.availableEnergy < self.energyRate and self.Active == true then
		self:deviceTurnOff()
	end	
	
	if self.availableWater < self.waterRate and self.Active == true then
		self:deviceTurnOff()
	end
	
	--If the entity is part of a network, find relevant available resources on said network
	
	if self.networkID != nil then
	
		local energyFound = true
		local waterFound = true
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do
			
			if res[1] == "energy" then			
				self.availableEnergy = res[2]
				energyFound = true
			end
			
			if res[1] == "water" then			
				self.availableWater = res[2]
				waterFound = true
			end
			
		end
		
		if energyFound == false then self.availableEnergy = 0 end
		if waterFound == false then self.availableWater = 0 end
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableEnergy = 0
			self.availableWater = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
	self.availableEnergy = 0
	self.availableWater = 0
	end

	-- generate/consume resources if active
	
	if self.Active == true then			
		self:resourceExchange()
	end	
	
	-- update the status balloon	
	self:devUpdate()
	
	self.Entity:NextThink( CurTime() )
	return true	
    
end

function ENT:devUpdate()
	umsg.Start("water_splitter_umsg")
	umsg.Entity(self)
	umsg.Short( self.availableEnergy )
	umsg.Short( self.availableWater )
	umsg.End()
end
 