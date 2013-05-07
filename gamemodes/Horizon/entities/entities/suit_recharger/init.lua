AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("suit_recharger")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	phys:EnableMotion(false)
	
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/suit_recharger.mdl" )
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
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "support"	
		
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:resourceExchange(ply)

	-- use this function to place generate/consume resource function calls
	
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
			availEnergy = res[2]
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
	
	
	GAMEMODE:consumeResource( self.networkID, "energy", energyAmt )
	GAMEMODE:consumeResource( self.networkID, "air", airAmt )
	GAMEMODE:consumeResource( self.networkID, "coolant", coolantAmt )


end
 
function ENT:Use( activator, caller )
 
 
	if ( activator:IsPlayer() && self.networkID != nil ) then
 		
		self:resourceExchange(activator)
				 
	end
 
end

   
function ENT:Think()
	
	if self.networkID != nil then
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do		
			
			if res[1] == "energy" then
			
				self.dispEnergy = res[2]
				self.dispStorableEnergy = res[3]				
		
			end
			
			if res[1] == "air" then
			
				self.dispAir = res[2]
				self.dispStorableAir = res[3]
		
			end
			
			if res[1] == "coolant" then
			
				self.dispCoolant = res[2]
				self.dispStorableCoolant = res[3]			
		
			end
		end
	
	end
	
	if self.networkID == nil then
		self.dispEnergy = 0
		self.dispStorableEnergy = 0
		self.dispAir = 0
		self.dispStorableAir = 0
		self.dispCoolant = 0
		self.dispStorableCoolant = 0
	end
	
	self:devUpdate()

	self.Entity:NextThink( CurTime() + 1 )
	return true	
	
    
end

function ENT:OnRemove()

	GAMEMODE:unlinkDevice( self )

end

function ENT:devUpdate()
	net.Start( "netSuitRecharger" )
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
 