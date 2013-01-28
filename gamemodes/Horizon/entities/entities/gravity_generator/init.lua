AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "npc/turret_floor/deploy.wav" )
util.PrecacheSound( "npc/turret_floor/retract.wav" )
 
include('shared.lua')
util.AddNetworkString( "netGravGen" )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("gravity_generator")
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
	
	self.availableEnergy = 0
	self.totalStorable = 0
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "support"	
	self.Active = false
	self.range = 256
	
	self.gravenv = nil
	
	--Resource Rates
	self.energyRate = 50
	
	if not (WireAddon == nil) then
        self.WireDebugName = self.PrintName
        self.Inputs = Wire_CreateInputs(self, { "On" })
        self.Outputs = Wire_CreateOutputs(self, { "Active" })
    end
			
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:resourceExchange(ply)
	
	GAMEMODE:consumeResource( self.networkID, "energy", ( self.energyRate * FrameTime() ) )

end


function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
	
	if self.Active == false and self.availableEnergy > 50 then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "apc_engine_start" )
	self.Entity:EmitSound( "npc/turret_floor/deploy.wav" )
	self:GetPhysicsObject():EnableMotion(false)
	self.Active = true
	local sequence = self:LookupSequence("deploy")
	self:ResetSequence(sequence)
	
	if self.gravenv == self.currentEnv then self.currentEnv = nil end
	
	self.gravenv = ents.Create("hzn_environment")
	self.gravenv:SetPos( self:GetPos() )
	if self.currentEnv then
		self.gravenv:SetKeyValue("pltradius", self.range)
		self.gravenv:SetKeyValue("pltgravity", self.currentEnv.dt.Gravity + 0.5)
		self.gravenv:SetKeyValue("pltbreathable", string.upper(tostring(self.currentEnv.dt.Breathable)))
		if self.currentEnv.dt.Temp == 3 then
			self.gravenv:SetKeyValue("plttemp", "HOT" )
		end
		if self.currentEnv.dt.Temp == 2 then
			self.gravenv:SetKeyValue("plttemp", "TEMPERATE" )
		end
		if self.currentEnv.dt.Temp == 1 then
			self.gravenv:SetKeyValue("plttemp", "COLD" )
		end
		self.gravenv:SetKeyValue("pltpriority", "3" )
		if self.currentEnv.dt.Minerals == 1 then
			elf.gravenv:SetKeyValue("pltminerals", "MORPHITE" )
		end
		if self.currentEnv.dt.Minerals == 2 then
			elf.gravenv:SetKeyValue("pltminerals", "NOCXIUM" )
		end
	else
		self.gravenv:SetKeyValue("pltradius", self.range)
		self.gravenv:SetKeyValue("pltgravity", 0.5)
		self.gravenv:SetKeyValue("pltbreathable", "FALSE")
		self.gravenv:SetKeyValue("plttemp", "COLD" )
		self.gravenv:SetKeyValue("pltpriority", "3" )
	end
	self.gravenv:Spawn()
end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	self:GetPhysicsObject():EnableMotion(true)
	self.Active = false
	local sequence = self:LookupSequence("retract")
	self:ResetSequence(sequence)	

	local entsinrange = ents.FindInSphere( self.gravenv:GetPos(), self.range )
	
	
	
	for _, myent in pairs(entsinrange) do
		GAMEMODE:setDefaultEnv( myent )
	end
	GAMEMODE:setDefaultEnv( self )
	self.gravenv.dt.Radius = 0
	self.gravenv:Remove()
	self.gravenv = nil
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

	-- generate/consume resources if active- findPlayers() will call the required methods
	
	if self.Active == true then			
		self:resourceExchange()
	end	
	
	-- update the status balloon	
	self:devUpdate()
	
	self.Entity:NextThink( CurTime() )
	return true	
    
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

function ENT:OnRemove()
	if self.networkID != nil then
		GAMEMODE:unlinkDevice( self )
	end
	
	if self.Active then
		self.Entity:StopSound( "apc_engine_start" )
		self.Entity:EmitSound( "apc_engine_stop" )
		self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	end
	
	if self.gravenv then
		local entsinrange = ents.FindInSphere( self.gravenv:GetPos(), self.range )
		for _, myent in pairs(entsinrange) do
			GAMEMODE:setDefaultEnv( myent )
		end
		GAMEMODE:setDefaultEnv( self )
		self.gravenv.dt.Radius = 0
		self.gravenv:Remove()
		self.gravenv = nil
	end
end

function ENT:devUpdate()
	net.Start( "netGravGen" )
		net.WriteEntity( self )
		net.WriteFloat( self.availableEnergy )
		net.WriteFloat( self.totalStorable )
		-- net.WriteFloat( self.networkID )
		net.WriteBit( self.Active )
	net.Broadcast()
end
 