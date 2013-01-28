AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!

util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )
 
include('shared.lua')
util.AddNetworkString( "netFusionReactor" )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("fusion_reactor")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/fusion_reactor.mdl" )	
	self.deviceType = "generator"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.availableHydrogen = 0
	self.totalStorableHydro = 0
	self.availableCoolant = 0
	self.totalStorableCool = 0
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.health = 1000
	
	--Resource Rates
	self.hydrogenRate = 15
	self.coolantRate = 15
	self.energyRate = 1000

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
	
	GAMEMODE:generateResource( self.networkID, "energy", ( self.energyRate * FrameTime() ) )
	GAMEMODE:consumeResource( self.networkID, "hydrogen", ( self.hydrogenRate * FrameTime() ) )
	GAMEMODE:consumeResource( self.networkID, "coolant", ( self.coolantRate * FrameTime() ) )


end
 

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then	
	if self.Active == false and self.availableHydrogen > self.hydrogenRate then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "k_lab.ambient_powergenerators" )
	self.Entity:EmitSound( "ambient/machines/thumper_startup1.wav" )
	
	self.Active = true
		

end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "k_lab.ambient_powergenerators" )
	
	self.Active = false
		

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
	
	if self.availableHydrogen < self.hydrogenRate and self.Active == true then
		self:deviceTurnOff()
	end	
	
	if self.availableCoolant < self.coolantRate and self.Active == true then
		self:deviceTurnOff()
	end
	
	--If the entity is part of a network, find relevant available resources on said network
	
	if self.networkID != nil then
	
		local hydrogenFound = false
		local coolantFound = false
		
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do
			
			if res[1] == "hydrogen" then			
				self.availableHydrogen = res[2]
				self.totalStorableHydro = res[3]
				hydrogenFound = true
			end
			
			if res[1] == "coolant" then			
				self.availableCoolant = res[2]
				self.totalStorableCool = res[3]
				coolantFound = true
			end
			
		end
		
		if hydrogenFound == false then self.availableHydrogen = 0 end
		if coolantFound == false then self.availableCoolant = 0 end
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableHydrogen = 0
			self.totalStorableHydro = 0
			self.availableCoolant = 0
			self.totalStorableCool = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
		self.availableHydrogen = 0
		self.totalStorableHydro = 0
		self.availableCoolant = 0
		self.totalStorableCool = 0
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
	net.Start( "netFusionReactor" )
		net.WriteEntity( self )
		net.WriteFloat( self.availableHydrogen )
		net.WriteFloat( self.totalStorableHydro )
		net.WriteFloat( self.availableCoolant )
		net.WriteFloat( self.totalStorableCool )
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
 