AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!

util.PrecacheSound( "trainyard.train_move" )
util.PrecacheSound( "trainyard.train_idle" )
util.PrecacheSound( "trainyard.train_brake" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("mining_drill")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent
	
	

end

function ENT:SpawnChunk()

	

	if self.currentEnv.dt.Minerals == 2 then
		local ent = ents.Create("nocxium_ore")
		
		x = math.random(75)
		y = math.random(75)

		ent:SetPos( self:GetPos() + Vector(x, y, 15) )
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		return ent
	end
	
	if self.currentEnv.dt.Minerals == 1 then
		local ent = ents.Create("morphite_ore")
		
		x = math.random(75)
		y = math.random(75)

		ent:SetPos( self:GetPos() + Vector(x, y, 15) )
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		return ent
	end
end
 
function ENT:Initialize()
 	
	self:SetModel( "models/mining_drill.mdl" )	
	self.deviceType = "generator"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.availableEnergy = 0
	self.storableEnergy = 0
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.health = 1000
	self.interval = 0
	self.isOnGround = false
		
	--animation timing stuff
	local animTime = 0
	local duration = 0
	local activiating = false
	
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
 

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then	
	if self.Active == false and self.availableEnergy > self.energyRate then self:deviceTurnOn() return end
	if self.Active == true then self:deviceTurnOff() return end		
		
	end
end

function ENT:deviceTurnOn()

	self.Entity:EmitSound( "trainyard.train_move" )
	self.Entity:EmitSound( "trainyard.train_idle" )
	
	self.Active = true
	self:SetState(true)
	
	local sequence = self:LookupSequence("start")
	self.activating = true
	self.duration = self:SequenceDuration(sequence)
	self.animTime = CurTime()
	self:ResetSequence(sequence)

end

function ENT:deviceTurnOff()

	self.Entity:StopSound( "trainyard.train_move" )
	self.Entity:StopSound( "trainyard.train_idle" )
	self.Entity:EmitSound( "trainyard.train_brake" )
	
	self.Active = false
	self:SetState(false)
	
	local sequence = self:LookupSequence("stop")
	self:ResetSequence(sequence)	

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

function ENT:SwitchToActive()

	local sequence = self:LookupSequence("active")
	self:ResetSequence(sequence)

end

function ENT:GroundCheck()

	local pos = self:GetPos()
	
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = (pos + Vector(0,0,-25) )
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

	self:GroundCheck()
	
	-- used for startup animation sequence
	if self.activating == true then	
	
		if self.Active and (CurTime() >= (self.animTime + self.duration)) then
			self:SwitchToActive()
			self.activating = false
		end			
	end

		
	-- check to see if the entity is IN an environment
	
	if self.currentEnv == nil and self.Active == true then
		self:deviceTurnOff()
	end
	
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
				self.storableEnergy = res[3]
				energyFound = true
			end
		end
		
		if energyFound == false then self.availableEnergy = 0 end
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableEnergy = 0
			self.storableEnergy = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
		self.availableEnergy = 0
		self.storableEnergy = 0
	end

	-- generate/consume resources if active
	
	if self.Active == true then			
		self:resourceExchange()	
		
		if self.timer == nil then
			self.timer = CurTime()
		end
		
		if CurTime() >= (self.timer + self.interval) then
			if self.isOnGround == true then
				self:SpawnChunk()
				self.timer = CurTime()
				self.interval = math.random(10, 60)
			end
		end
		
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
	net.Start( "netMiningDrill" )
		net.WriteEntity( self )
		net.WriteFloat( self.availableEnergy )
		net.WriteFloat( self.storableEnergy )
		net.WriteBit( self.Active )
		-- net.WriteFloat( self.networkID )
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

		self.Entity:StopSound( "trainyard.train_move" )
		self.Entity:StopSound( "trainyard.train_idle" )
		self.Entity:EmitSound( "trainyard.train_brake" )

	end

end