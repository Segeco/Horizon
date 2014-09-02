AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!

util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
 
include('shared.lua')
util.AddNetworkString( "netHydroConverter" )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("hydro_converter")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/props_lab/reciever_cart.mdl" )	
	self.deviceType = "generator"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self.availableHydrogen = 0
	self.availableEnergy = 0
	self.totalStorableEnergy = 0
	self.totalStorableHydrogen = 0
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.health = 100
	
	--Resource Rates
	self.hydrogenRate = 60
	self.airRate = 30
	self.energyRate = 200

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

function ENT:OnTakeDamage(dmg)

	-- self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
 
	-- if(self.health <= 0) then return; end -- If the health-variable is already zero or below it - do nothing
 
	-- self.health = self.health - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable
 
	-- if(self.health <= 0) then -- If our health-variable is zero or below it
	-- 	local effectdata = EffectData()
	-- 	effectdata:SetOrigin( self:GetPos() )
	-- 	util.Effect( "explosion", effectdata )
	-- 	self:Remove(); -- Remove our entity
	-- end

end

function ENT:resourceExchange()

	-- use this function to place generate/consume resource function calls	
	
	GAMEMODE:generateResource( self.networkID, "air", ( self.airRate * FrameTime() ) )
	GAMEMODE:consumeResource( self.networkID, "energy", ( self.energyRate * FrameTime() ) )
	GAMEMODE:consumeResource( self.networkID, "hydrogen", ( self.hydrogenRate * FrameTime() ) )

end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then	
	if self.Active == false and self.availableEnergy > self.energyRate and self.availableHydrogen > self.hydrogenRate then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "apc_engine_start" )
	
	self.Active = true
	
	--local sequence = self:LookupSequence("active")
	--self:ResetSequence(sequence)	

end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
		
	self.Active = false
	
	--local sequence = self:LookupSequence("idle")
	--self:ResetSequence(sequence)	

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
	
	if self.availableHydrogen < self.hydrogenRate and self.Active == true then
		self:deviceTurnOff()
	end
	
	--If the entity is part of a network, find relevant available resources on said network
	
	if self.networkID != nil then
	
		local energyFound = false
		local hydrogenFound = false
		
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do
			
			if res[1] == "energy" then			
				self.availableEnergy = res[2]
				self.totalStorableEnergy = res[3]
				energyFound = true
			end
			
			if res[1] == "hydrogen" then
				self.availableHydrogen = res[2]
				self.totalStorableHydrogen = res[3]
				hydrogenFound = true
			end
			
		end
		
		if energyFound == false then self.availableEnergy = 0 end
		if hydrogenFound == false then self.availableHydrogen = 0 end
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableEnergy = 0
			self.totalStorableEnergy = 0
			self.availableHydrogen = 0
			self.totalStorableHydrogen = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
		self.availableEnergy = 0
		self.totalStorable = 0	
		self.availableHydrogen = 0
		self.totalStorableHydrogen = 0
	end

	-- generate/consume resources if active
	
	if self.Active == true then			
		self:resourceExchange()
	end	
	
	-- Update the wire outputs, DUH!
	if not (WireAddon == nil) then
        self:UpdateWireOutput()
    end

	-- update the status balloon	
	self:devUpdate()
	
	self.Entity:NextThink( CurTime() )
	return true	
    
end

function ENT:devUpdate()
	net.Start( "netHydroConverter" )
		net.WriteEntity( self )
		net.WriteFloat( self.availableEnergy )
		net.WriteFloat( self.totalStorableEnergy )
		net.WriteFloat( self.availableHydrogen )
		net.WriteFloat( self.totalStorableHydrogen )
		-- net.WriteFloat( self.networkID )
		net.WriteBit( self.Active )
	net.Broadcast()
end
 
function ENT:UpdateWireOutput()
	local activity
	
	if (self.Active ~= true) then
		activity = 0
	else
		activity = 1
	end
	
    Wire_TriggerOutput(self, "Active", activity)
        
end

function ENT:OnRemove()

	if self.Active then

		self.Entity:StopSound( "apc_engine_start" )
		self.Entity:EmitSound( "apc_engine_stop" )

	end

end