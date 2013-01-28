AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!


util.PrecacheSound( "k_lab.teleport_malfunction_sound" )
util.PrecacheSound( "k_lab.teleport_discharge" )
util.PrecacheSound( "WeaponDissolve.Beam" )
util.PrecacheSound( "WeaponDissolve.Dissolve" )
 
include('shared.lua')


function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("hzn_factory")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 	
	self:SetModel( "models/hzn_factory.mdl" )
	self.deviceType = "equipment"
	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self.availableEnergy = 0
	self.availableMorphite = 0
	self.availableNocxium = 0
	self.availableIsogen = 0
	self.reqEnergy = 500
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil	
	self.Active = false
	self.timeAtStart = 0
	self.health = 1000
	self.crateID = 0
	
	
	--Initialize item costs--
	self.gwExtractor = {}
	self.gwExtractor[1] = 100
	self.gwExtractor[2] = 100
	self.gwExtractor[3] = 0
	
	self.remoteSuitcharger = {}
	self.remoteSuitcharger[1] = 100
	self.remoteSuitcharger[2] = 100
	self.remoteSuitcharger[3] = 0
	
	self.hydrogenCoolant = {}
	self.hydrogenCoolant[1] = 100
	self.hydrogenCoolant[2] = 100
	self.hydrogenCoolant[3] = 0
	
	self.waterSplitter = {}
	self.waterSplitter[1] = 100
	self.waterSplitter[2] = 100
	self.waterSplitter[3] = 0
	
	self.fusionReactor = {}
	self.fusionReactor[1] = 100
	self.fusionReactor[2] = 100
	self.fusionReactor[3] = 0
	
	self.gravityGenerator = {}
	self.gravityGenerator[1] = 100
	self.gravityGenerator[2] = 100
	self.gravityGenerator[3] = 0
	
	
	
	--End item costs


	------------------------

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end	
    
end


function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		
		if(not self.Create)then
			umsg.Start("hznFactoryTrigger",caller)
			umsg.String(self:GetCreationID())
			umsg.Entity(self.Entity);
			umsg.End()
			self.Player = caller;
		end
			
		
	end
end

function ENT:StartTouch(ent)

	if ent:GetClass() == "mineral_crate" then
	
		if self.crateID == 0 then
		
			self.crateID = ent:GetCreationID()
		
		end
	
	end

end

function ENT:EndTouch(ent)

	if ent:GetClass() == "mineral_crate" then
	
		if self.crateID == ent:GetCreationID() then
		
			self.crateID = 0
		
		end
	
	end

end

function ENT:Dissolve(ent)
	if self:IsPlayer() then return end

	local dissolver = ents.Create( "env_entity_dissolver" )
	dissolver:SetPos( ent:LocalToWorld(ent:OBBCenter()) )
	dissolver:SetKeyValue( "dissolvetype", 0 )
	dissolver:Spawn()
	dissolver:Activate()
	
	local name = "Dissolving_"..math.random()
	ent:SetName( name )
	dissolver:Fire( "Dissolve", name, 0 )
	self.Entity:EmitSound( "WeaponDissolve.Beam" )
	
	dissolver:Fire( "Kill", ent, 0.10 )
	self.Entity:EmitSound( "WeaponDissolve.Dissolve" )
	self.Entity:StopSound( "WeaponDissolve.Beam" )
	
end

function ENT:BeginReplication( product, materials )
		
		GAMEMODE:consumeResource( self.networkID, "morphite", materials[1] )
		GAMEMODE:consumeResource( self.networkID, "nocxium", materials[2] )
		GAMEMODE:consumeResource( self.networkID, "isogen", materials[3] )
		
		local ent = ents.Create("factory_crate")
		ent:SetPos( self:GetPos() + Vector(0,0,60) )
		ent:SetMaterial("models/props_combine/portalball001_sheet")
		ent:Spawn()
		ent.product = product
		ent:SetParent(self.Entity)
		self.activeEntity = ent
		self.Entity:EmitSound( "k_lab.teleport_malfunction_sound" )		
			
		self.timeAtStart = CurTime()
		self.active = true	
			
	return ent

end

function ENT:CompleteCrate()

	
	self.activeEntity:SetSolid( SOLID_VPHYSICS )
	self.activeEntity:SetMaterial(self.activeEntity.Material )
	self.activeEntity:SetParent(nil)
	
	local phys = self.activeEntity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(true)
		phys:Wake()
	end
	
	self.Entity:StopSound( "k_lab.teleport_malfunction_sound" )
	self.Entity:EmitSound( "k_lab.teleport_discharge" )

	self.active = false
	
	
end

function builditem(ply, cmd, args)

	--Get self info
	for _, ent in pairs(ents.FindByClass("hzn_factory")) do
	
		if ent:GetCreationID() == tonumber(args[2]) then
		
		--Remote Suitcharger-----------------------------
			if args[1] == "Remote Suitcharger" then
			
				if ent.remoteSuitcharger[1] <= ent.availableMorphite then
					
					if ent.remoteSuitcharger[2] <= ent.availableNocxium then
					
						if ent.remoteSuitcharger[3] <= ent.availableIsogen then
							
							if ent.reqEnergy <= ent.availableEnergy then
							
								
								ent:BeginReplication("remote_suitcharger", ent.remoteSuitcharger)
							
								else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Energy") return
							end
							
							else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Isogen") return 
						end
					
						else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Nocxium") return
					end
					
					else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Morphite") return
				end			
			
			end
			
			--Groundwater Extractor-----------------------------
			
			if args[1] == "Groundwater Extractor" then
			
				if ent.gwExtractor[1] <= ent.availableMorphite then
					
					if ent.gwExtractor[2] <= ent.availableNocxium then
					
						if ent.gwExtractor[3] <= ent.availableIsogen then
							
							if ent.reqEnergy <= ent.availableEnergy then
							
								
								ent:BeginReplication("groundwater_extractor", ent.gwExtractor)
							
								else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Energy") return
							end
							
							else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Isogen") return 
						end
					
						else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Nocxium") return
					end
					
					else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Morphite") return
				end			
			
			end
			
			--Hydrogen Coolant Processor-----------------------------
			
			if args[1] == "Hydrogen Coolant Proc." then
			
				if ent.hydrogenCoolant[1] <= ent.availableMorphite then
					
					if ent.hydrogenCoolant[2] <= ent.availableNocxium then
					
						if ent.hydrogenCoolant[3] <= ent.availableIsogen then
							
							if ent.reqEnergy <= ent.availableEnergy then
							
								
								ent:BeginReplication("hydrogen_coolant", ent.hydrogenCoolant)
							
								else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Energy") return
							end
							
							else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Isogen") return 
						end
					
						else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Nocxium") return
					end
					
					else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Morphite") return
				end			
			
			end
			
			--Water Splitter-----------------------------
			
			if args[1] == "Water Splitter" then
			
				if ent.waterSplitter[1] <= ent.availableMorphite then
					
					if ent.waterSplitter[2] <= ent.availableNocxium then
					
						if ent.waterSplitter[3] <= ent.availableIsogen then
							
							if ent.reqEnergy <= ent.availableEnergy then
							
								
								ent:BeginReplication("water_splitter", ent.waterSplitter)
							
								else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Energy") return
							end
							
							else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Isogen") return 
						end
					
						else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Nocxium") return
					end
					
					else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Morphite") return
				end			
			
			end	

			--Fusion Reactor-----------------------------
			
			if args[1] == "Fusion Reactor" then
			
				if ent.fusionReactor[1] <= ent.availableMorphite then
					
					if ent.fusionReactor[2] <= ent.availableNocxium then
					
						if ent.fusionReactor[3] <= ent.availableIsogen then
							
							if ent.reqEnergy <= ent.availableEnergy then
							
								
								ent:BeginReplication("fusion_reactor", ent.fusionReactor)
							
								else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Energy") return
							end
							
							else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Isogen") return 
						end
					
						else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Nocxium") return
					end
					
					else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Morphite") return
				end			
			
			end		
			
			--Gravity Generator--------------------------
			
			if args[1] == "Gravity Generator" then
			
				if ent.gravityGenerator[1] <= ent.availableMorphite then
					
					if ent.gravityGenerator[2] <= ent.availableNocxium then
					
						if ent.gravityGenerator[3] <= ent.availableIsogen then
							
							if ent.reqEnergy <= ent.availableEnergy then
							
								
								ent:BeginReplication("gravity_generator", ent.gravityGenerator)
							
								else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Energy") return
							end
							
							else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Isogen") return 
						end
					
						else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Nocxium") return
					end
					
					else ply:PrintMessage(HUD_PRINTCENTER, "Insufficient Morphite") return
				end			
			
			end		
		-----------------------------------------------------------			
		-----------------------------------------------------------
			
			break
		
		end
	
	end

end

concommand.Add("builditem", builditem)

function absorbcrate(ply, cmd, args)

	--Get self info
	for _, ent in pairs(ents.FindByClass("hzn_factory")) do
	
		if ent:GetCreationID() == tonumber(args[1]) then
		
			if ent.crateID == 0 then return end
			if ent.networkID == nil then return end
			
			for _, crate in pairs(ents.FindByClass("mineral_crate")) do
			
				if crate:GetCreationID() == ent.crateID then
				
					GAMEMODE:generateResource( ent.networkID, "morphite", crate.Morphite )
					GAMEMODE:generateResource( ent.networkID, "nocxium", crate.Nocxium )
					GAMEMODE:generateResource( ent.networkID, "isogen", crate.Isogen )
					
					ent:Dissolve(crate)
					
					break
			
				end
			end
			break
		
		end
	
	end

end

concommand.Add("absorbcrate", absorbcrate)

   
function ENT:Think()

	if self.active == true then
				
		if CurTime() >= (self.timeAtStart + 10) then
		
			self:CompleteCrate()
		
		end
	
	end


	--If the entity is part of a network, find relevant available resources on said network
	
	if self.networkID != nil then
	
		local energyFound = false
		local morphiteFound = false
		local nocxiumFound = false
		local isogenFound = false
	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do	
			if res[1] == "energy" then		
				self.availableEnergy = res[2]
				energyFound = true
			end
			
			if res[1] == "morphite" then		
				self.availableMorphite = res[2]
				morphiteFound = true
			end
			
			if res[1] == "nocxium" then			
				self.availableNocxium = res[2]
				nocxiumFound = true
			end
			
			if res[1] == "isogen" then			
				self.availableIsogen = res[2]
				isogenFound = true
			end
		end
		
		if energyFound == false then self.availableEnergy = 0 end
		if morphiteFound == false then self.availableMorphite = 0 end
		if nocxiumFound == false then self.availableNocxium = 0 end
		if isogenFound == false then self.availableIsogen = 0 end
		
		if GAMEMODE.networks[self.networkID][1][1] == nil then
			self.availableEnergy = 0
			self.availableMorphite = 0
			self.availableNocxium = 0
			self.availableIsogen = 0
		end
	
	end
	
	-- if the entity is no longer part of a network, clear available resources
	
	if self.networkID == nil then	
	self.availableEnergy = 0
	self.availableMorphite = 0
	self.availableNocxium = 0
	self.availableIsogen = 0
	end

	-- generate/consume resources if active
	
	
					
	self.Entity:NextThink( CurTime() )
	return true	
    
end

 