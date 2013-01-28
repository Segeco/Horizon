AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "npc/turret_floor/deploy.wav" )
util.PrecacheSound( "npc/turret_floor/retract.wav" )
 
include('shared.lua')
util.AddNetworkString( "netRemoteSuitCharger" )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("remote_suitcharger")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	local resCycle
	
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/efg_basic.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.dispEnergy = 0
	self.dispStorableEnergy = 0
	self.dispAir = 0
	self.dispStorableAir = 0
	self.dispCoolant = 0
	self.dispStorableCoolant = 0
	
	self.availEnergy = 0
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "support"	
	self.Active = false
	self.range = 256
	
	--Resource Rates
	self.energyRate = 30
	
			
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:resourceExchange(ply)

	--Total Amounts
	
	local availEnergy = 0
	local availAir = 0
	local availCoolant = 0
	
	local energyNeeded = 0
	local airNeeded = 0
	local coolantNeeded = 0
	
	local energyAmt = 0
	local airAmt = 0
	local coolantAmt = 0
	
	for _, res in pairs ( GAMEMODE.networks[self.networkID][1] ) do
	
		if res[1] == "energy" then 
			availEnergy = ( res[2] + self.energyRate * FrameTime() ) 
		end
		
		if res[1] == "air" then 
			availAir = res[2]
		end
		
		if res[1] == "coolant" then 
			availCoolant = res[2]
		end	
		
	end
	
	--energy
	
	energyNeeded = ply.maxPower - ply.suitPower
	
	if energyNeeded <= availEnergy then
	
		energyAmt = energyNeeded
		ply.suitPower = ply.suitPower + energyAmt
	
	end
	
	if energyNeeded > availEnergy then
	
		energyAmt = availEnergy
		ply.suitPower = ply.suitPower + energyAmt
	
	end
	
	--air
	
	airNeeded = ply.maxAir - ply.suitAir
	
	if airNeeded <= availAir then
	
		airAmt = airNeeded
		ply.suitAir = ply.suitAir + airAmt
	
	end
	
	if airNeeded > availAir then
	
		airAmt = availAir
		ply.suitAir = ply.suitAir + airAmt
	
	end
	
	--coolant
	
	coolantNeeded = ply.maxCoolant - ply.suitCoolant
	
	if coolantNeeded <= availCoolant then
	
		coolantAmt = coolantNeeded
		ply.suitCoolant = ply.suitCoolant + coolantAmt
	
	end
	
	if coolantNeeded > availCoolant then
	
		coolantAmt = availCoolant
		ply.suitCoolant = ply.suitCoolant + coolantAmt
	
	end
	
	
	GAMEMODE:consumeResource( self.networkID, "energy", (energyAmt + (self.energyRate * FrameTime() ) ))
	GAMEMODE:consumeResource( self.networkID, "air", airAmt )
	GAMEMODE:consumeResource( self.networkID, "coolant", coolantAmt )

end

function ENT:findPlayers()

	local entsInRange = ents.FindInSphere(self:GetPos(), self.range)	
	for _, ply in pairs (entsInRange) do	
		if ply:GetClass() == "player" then
			self:resourceExchange(ply)
		end		
	end
	
end



function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
	
	if self.Active == false and self.dispEnergy > 30 then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "apc_engine_start" )
	self.Entity:EmitSound( "npc/turret_floor/deploy.wav" )
	self.Active = true
	local sequence = self:LookupSequence("deploy")
	self:ResetSequence(sequence)

end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	self.Active = false
	local sequence = self:LookupSequence("retract")
	self:ResetSequence(sequence)	

end


function ENT:Think()

	-- Check to see if the device is part of a network
	
	if self.networkID == nil and self.Active == true then
		self:deviceTurnOff()
	end
	
	-- Check to see if the device has the required resources to function	
	
	if self.dispEnergy < self.energyRate and self.Active == true then
		self:deviceTurnOff()
	end	
	
	--If the entity is part of a network, find relevant available resources on said network
	
	if self.networkID != nil then
	
		local energyFound = false
		local airFound = false
		local coolantFound = false
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do
			
			if res[1] == "energy" then
			
				self.dispEnergy = res[2]
				self.dispStorableEnergy = res[3]
				energyFound = true
		
			end
			
			if res[1] == "air" then
			
				self.dispAir = res[2]
				self.dispStorableAir = res[3]
				airFound = true
		
			end
			
			if res[1] == "coolant" then
			
				self.dispCoolant = res[2]
				self.dispStorableCoolant = res[3]
				coolantFound = true
		
			end
		end
		
		if energyFound == false then 
			self.availableEnergy = 0
			self.dispEnergy = 0
			self.dispStorableEnergy = 0
		end
		
		if airFound == false then 
			self.availableAir = 0
			self.dispAir = 0
			self.dispStorableAir = 0
		end
		
		if coolantFound == false then 
			self.availableCoolant = 0
			self.dispCoolant = 0
			self.dispStorableCoolant = 0
		end
		
	
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.dispEnergy = 0
			self.dispStorableEnergy = 0
			self.dispAir = 0
			self.dispStorableAir = 0
			self.dispCoolant = 0
			self.dispStorableCoolant = 0
		end
	
	end
		
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
		self.dispEnergy = 0
		self.dispStorableEnergy = 0
		self.dispAir = 0
		self.dispStorableAir = 0
		self.dispCoolant = 0
		self.dispStorableCoolant = 0
	end

	-- generate/consume resources if active- findPlayers() will call the required methods
	
	if self.Active == true then			
		self:findPlayers()
	end	
	
	-- update the status balloon	
	self:devUpdate()
	
	self.Entity:NextThink( CurTime() )
	return true	
    
end

function ENT:devUpdate()
	net.Start( "netRemoteSuitCharger" )
		net.WriteEntity( self )
		net.WriteFloat( self.dispEnergy )
		net.WriteFloat( self.dispStorableEnergy )
		net.WriteFloat( self.dispAir )
		net.WriteFloat( self.dispStorableAir )
		net.WriteFloat( self.dispCoolant )
		net.WriteFloat( self.dispStorableCoolant )
		-- net.WriteFloat( self.networkID )
	net.Broadcast()
end
 