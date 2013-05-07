AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!

util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("groundwater_extractor")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/groundwater_extractor.mdl" )	
	self.deviceType = "generator"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.availableEnergy = 0
	self.totalStorable = 0
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.health = 1000
	
	--Resource Rates
	self.waterRate = 15
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
	if self.isOnGround == true then
		GAMEMODE:generateResource( self.networkID, "water", ( self.waterRate * FrameTime() ) )
	end
	
	GAMEMODE:consumeResource( self.networkID, "energy", ( self.energyRate * FrameTime() ) )

end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then	
	if self.Active == false and self.availableEnergy > self.energyRate then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "Airboat_engine_idle" )
	
	self.Active = true
	self:SetState(true)

end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "Airboat_engine_idle" )
	self.Entity:EmitSound( "Airboat_engine_stop" )
	self.Entity:StopSound( "apc_engine_start" )
	
	self.Active = false
	self:SetState(false)

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

function ENT:GroundCheck()

	local pos = self:GetPos()
	
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = (pos + Vector(0,0,-10) )
	tracedata.filter = self
	
	local trace = util.TraceLine(tracedata)
	if trace.HitWorld then
		self.isOnGround = true
	end
	
	if trace.HitWorld == false then
		self.isOnGround = false
	end

end
   
function ENT:Think()
	
	-- check to see if the entity is IN an environment
	
	if self.currentEnv == nil and self.Active == true then
		self:deviceTurnOff()
	end
	
	--Check to see if the entity is on the ground
	self:GroundCheck()
	
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
				self.totalStorable = res[3]
				energyFound = true
			end
			
		end
		
		if energyFound == false then self.availableEnergy = 0 end
		
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableEnergy = 0
			self.totalStorable = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
		self.availableEnergy = 0
		self.totalStorable = 0
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
	net.Start( "netGroundWExtractor" )
		net.WriteEntity( self )
		net.WriteFloat( self.availableEnergy )
		net.WriteFloat( self.totalStorable )
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
 