AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "d3_citadel.weapon_zapper_beam_loop2" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("mining_laser")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/mining_laser.mdl" )	
	self.deviceType = "mining"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.availableEnergy = 0	
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.health = 1000
	self.targetPos = Vector(0, 0, 0)
	
	--Resource Rates
	self.energyRate = 60

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end	
	
	if not (WireAddon == nil) then
        self.WireDebugName = self.PrintName
        self.Inputs = Wire_CreateInputs(self, { "On" })
        self.Outputs = Wire_CreateOutputs(self, { "Active" })
    end
    
end

function ENT:resourceExchange()

	-- use this function to place generate/consume resource function calls	
	
	GAMEMODE:consumeResource( self.networkID, "energy", ( self.energyRate * FrameTime() ) )


end

function ENT:deviceTurnOn()
	
	self.Active = true
	self:SetState(true)
		
	self:EmitSound( "d3_citadel.weapon_zapper_beam_loop2" )
	
end

function ENT:deviceTurnOff()
	
	self.Active = false
	self:SetState(false)

	self:StopSound( "d3_citadel.weapon_zapper_beam_loop2" )
	
end

function ENT:OnRemove()

	if self.Active then
	
		self:StopSound( "d3_citadel.weapon_zapper_beam_loop2" )
	
	end

end

function ENT:TriggerInput(iname, value)
    if (iname == "On") then
        if (value ~= 1) then
            self:deviceTurnOff()
        else
            self:deviceTurnOn()
        end
    end
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
	
	--If the entity is part of a network, find relevant available resources on said network
	
	if self.networkID != nil then
	
		local energyFound = false
		
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do
			
			if res[1] == "energy" then			
				self.availableEnergy = res[2]
				energyFound = true
			end
			
		end
		
		if energyFound == false then self.availableEnergy = 0 end
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableEnergy = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
	self.availableEnergy = 0	
	end

	-- generate/consume resources if active
	
	
	if self.Active == true then			
		self:resourceExchange()
		
		local pos = self:GetPos()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = self:LocalToWorld(Vector(0, 0, 2000))
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)		
		self.targetPos = self:WorldToLocal(trace.HitPos)
		if trace.Hit then
		
			local effectData = EffectData()
			effectData:SetStart(trace.HitPos)
			effectData:SetOrigin(trace.HitPos)
			effectData:SetScale( 1 )
			util.Effect( "StunstickImpact", effectData )
			
			if trace.Entity.isAsteroid == true then
				trace.Entity.asteroidHealth = trace.Entity.asteroidHealth - 1
				if trace.Entity.asteroidHealth < 1 then trace.Entity:AsteroidSplit() end
			end
		
		end
		
				
	end	
	
	-- Update the wire outputs, DUH!
	if not (WireAddon == nil) then
        self:UpdateWireOutput()
    end
	
	
	
	self:devUpdate()

	
	self.Entity:NextThink( CurTime() )
	return true	
    
end

function ENT:devUpdate()
	net.Start( "netMiningLas" )
		net.WriteEntity( self )
		net.WriteBit( self.Active )
		net.WriteVector( self.targetPos )
		-- net.WriteFloat( self.networkID )
	net.Broadcast()
end

numpad.Register( "lsr_active", function( pl, ent, onoff )
	if ( !IsValid( ent) ) then return false end
	
	if onoff then
		ent:deviceTurnOn()
	else
		ent:deviceTurnOff()
	end
end)

function ENT:UpdateWireOutput()
	local activity
	
	if (self.Active ~= true) then
		activity = 0
	else
		activity = 1
	end
	
    Wire_TriggerOutput(self, "Active", activity)
        
end

 