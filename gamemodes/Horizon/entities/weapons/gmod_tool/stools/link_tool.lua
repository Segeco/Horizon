TOOL.Category = "Networking"
TOOL.Name = "Link Tool"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"
TOOL.ClientConVar[ "width" ] = "1.5"
TOOL.ClientConVar[ "material" ] = "cable/cable"

if ( CLIENT ) then
    language.Add( "Tool.link_tool.name", "Link Tool" );
    language.Add( "Tool.link_tool.desc", "Link Horizon Devices" );
	language.Add( "Tool.link_tool.0", "Left click to link two devices. Reload to unlink device." );
end

local timesFired = 0
local cycleComplete = false

function TOOL:Deploy()
	timesFired = 0
	cycleComplete = false
	entA = nil
	entb = nil
	self:ClearObjects()
end

function TOOL:LeftClick( tr )

	if (!tr.Entity:IsValid(tr.Entity.linkable)) or (tr.Entity:IsPlayer()) then return end
	cycleHasrun = false	
		
		if (timesFired == 0) then
		
			entA = tr.Entity					
			timesFired = 1
					
			if (CLIENT) then self:ClearObjects() return true end
				
		
		end
		
			

				
		if entA:GetPos():Distance( tr.Entity:GetPos() ) > 800 then
		
			timesFired = 0
			cycleComplete = false
			cycleHasrun = true
			self:ClearObjects()
			return true
		
		end
		
		-------------- rope code---------
		local iNum = self:NumObjects()
		
		local Phys = tr.Entity:GetPhysicsObjectNum( tr.PhysicsBone )
		self:SetObject( iNum + 1, tr.Entity, tr.HitPos, Phys, tr.PhysicsBone, tr.HitNormal )
		
		if (iNum > 0) then		
		
                local forcelimit = 0
                local addlength  = 100
                local material   = self:GetClientInfo( "material" )
                local width      = self:GetClientNumber( "width" ) or 1.5
                local rigid      = false
               
                // Get information we're about to use
                local Ent1,  Ent2  = self:GetEnt(1),     self:GetEnt(2)
                local Bone1, Bone2 = self:GetBone(1),    self:GetBone(2)
                local WPos1, WPos2 = self:GetPos(1),     self:GetPos(2)
                local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2)
                local length = ( WPos1 - WPos2):Length()
				
				
				if Ent1 != Ent2 then
					local constraint, rope = constraint.Rope( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, length, addlength, forcelimit, width, material, rigid )
				end
		
			
			if Ent1 == Ent2 then
			
				timesFired = 0
				cycleComplete = false
				cycleHasrun = true
				self:ClearObjects()
				return true
			
			end
				
 	
		end
		
		---------------------------------
		
		
		if (tr.Entity != entA) then
				
			
			if cycleComplete == false then
				entB = tr.Entity
				
				if entA.connections == nil then return true end
				if entB.connections == nil then return true end
				
				
				if entA.networkID == nil and entB.networkID == nil then
			
									
					entA.networkID = GAMEMODE.nextNet
					table.insert(entA.connections, entB)
					
			
					entB.networkID = GAMEMODE.nextNet
					table.insert(entB.connections, entA)	
			
					newNetwork = {}
					newNetwork[1] = {}
					newNetwork[2] = entA
					newNetwork[3] = entB
						
					GAMEMODE.networks[GAMEMODE.nextNet] = newNetwork
			
			
					--Now, let's add any new resources to the network's resource list
					for _, ent in pairs( newNetwork ) do
						
						if ent.deviceType == "storage" then
							GAMEMODE:addToResourceList( ent )
						end
					end
			
					--Next, we need to get a count of all resources on the network
					GAMEMODE:updateResourceCount(GAMEMODE.nextNet)
			
					-- Increment to next available network ID
					GAMEMODE.nextNet = GAMEMODE.nextNet + 1			
					
					cycleComplete = true;
				end
			
			end
			
			if entA.networkID != nil and entB.networkID == nil then
			
				if cycleComplete == false then
					
					--add each other to connections table
					table.insert(entA.connections, entB)					
					table.insert(entB.connections, entA)
					
					entB.networkID = entA.networkID
					
					table.insert(GAMEMODE.networks[entA.networkID], entB)
					
					if entB.deviceType == "storage" then
						GAMEMODE:addToResourceList( entB )
					end
					
					GAMEMODE:updateResourceCount( entA.networkID )
					
					cycleComplete = true
				end
			
			end
			
			if entB.networkID != nil and entA.networkID == nil then
				
				if cycleComplete == false then

					--add each other to connections table
					table.insert(entA.connections, entB)					
					table.insert(entB.connections, entA)
					
					entA.networkID = entB.networkID
					
					table.insert(GAMEMODE.networks[entB.networkID], entA)
					
					if entA.deviceType == "storage" then
						GAMEMODE:addToResourceList( entA )
					end
					
					GAMEMODE:updateResourceCount( entB.networkID )
					
					cycleComplete = true
				end
			
			end
			
			if entA.networkID !=nil and entB.networkID != nil then
			
				if entA.networkID == entB.networkID  and cycleComplete == false then

					table.insert(entA.connections, entB)					
					table.insert(entB.connections, entA)
					
					
					cycleComplete = true
				end	
			
				if cycleComplete == false then								
					
					table.insert(entA.connections, entB)					
					table.insert(entB.connections, entA)
					
					local oldNetA = GAMEMODE.networks[entA.networkID]
					local oldNetB = GAMEMODE.networks[entB.networkID]
										
					local NetworkA = GAMEMODE.networks[entA.networkID]
					local NetworkB = GAMEMODE.networks[entB.networkID]
					
					local newNetwork = {}
					newNetwork[1] = {}
					
					for _, ent in pairs( NetworkA ) do
					
						if ent.linkable == true then
							
							ent.networkID = GAMEMODE.nextNet
							table.insert(newNetwork, ent)
						
						end
					
					end
					
					for _, ent in pairs( NetworkB ) do
					
						if ent.linkable == true then
						
							ent.networkID = GAMEMODE.nextNet
							table.insert(newNetwork, ent)
						
						end
					
					end
					
					GAMEMODE.networks[oldNetA] = nil
					GAMEMODE.networks[oldNetB] = nil
					
					GAMEMODE.networks[GAMEMODE.nextNet] = newNetwork
					
					for _, ent in pairs( GAMEMODE.networks[GAMEMODE.nextNet]) do
					
						if ent.deviceType == "storage" then
						
							GAMEMODE:addToResourceList( ent )
						
						end
					
					end
					
					GAMEMODE:updateResourceCount( GAMEMODE.nextNet )
					
					GAMEMODE.nextNet = GAMEMODE.nextNet + 1
										
					
				end
			end
			
									
			timesFired = 0
			cycleComplete = false
			cycleHasrun = true
			self:ClearObjects()
			
						
		end
		
	
	
	if (CLIENT) then return true end
	
	return true
	
end

function TOOL:Reload( tr )

	if tr.Entity.linkable == true then
	
		if tr.Entity.networkID != nil then
			GAMEMODE:unlinkDevice(tr.Entity)
			GAMEMODE:fixStragglers()
		end	
		if (CLIENT) then return true end

		local bool = constraint.RemoveConstraints( tr.Entity, "Rope" )
		return bool
	
	end

	return true
	
end

function TOOL:AddCable(Ent1, Ent2)
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "ComboBox", 
	{ 
		Label = "#tool.presets",
		MenuButton = 1,
		Folder = "link",
		Options =	{ Default = {	link_tool_width='1',	link_tool_material='cable/cable' } },
		CVars =		{				"link_tool_width",		"link_tool_material" } 
	})
	CPanel:AddControl( "Slider", 		{ Label = "Width",		Type = "Float", 	Command = "link_tool_width", 		Min = "0", 	Max = "10" }  )
	CPanel:AddControl( "RopeMaterial", 	{ Label = "Link Material",	convar	= "link_tool_material" }  )
									
end

