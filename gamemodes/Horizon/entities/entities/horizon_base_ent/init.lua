AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')


function ENT:OnRemove()
	if self.networkID != nil then
		GAMEMODE:unlinkDevice( self )
	end
end

function ENT:PreEntityCopy()

	local connIndex = {}
	local dupeInfo = {}	
	dupeInfo.devices = {}
	
	 if not (WireAddon == nil) then
                local wireInfo = WireLib.BuildDupeInfo(self.Entity)
                if wireInfo then
                        duplicator.StoreEntityModifier( self.Entity, "WireDupeInfo", wireInfo )
                end
        end

	
	for _, dev in pairs( self.connections ) do
		connIndex[dev:EntIndex()] = dev
	end
	
	
	
	for ent2ID, ent2 in pairs( connIndex ) do
		if ( ent2 and ent2:IsValid() ) then
			table.insert(dupeInfo.devices, ent2ID)
		end
	end

	if dupeInfo.devices then
	
		duplicator.StoreEntityModifier(self.Entity, "hznDupeInfo", dupeInfo)
	end

end



function ENT:PostEntityPaste(pl, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.hznDupeInfo
	
	for _, entBID in pairs (dupeInfo.devices) do
		local entB = CreatedEntities[ entBID ]
		
		if entB and entB:IsValid() then		
							
			self:LinkDupes(self, entB)
								
		end
	end
	
	if not (WireAddon == nil) and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end


end


function ENT:LinkDupes(entA, entB)

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
					
		
	end
	
	if entA.networkID != nil and entB.networkID == nil then
			
		--add each other to connections table
		table.insert(entA.connections, entB)					
		table.insert(entB.connections, entA)
					
		entB.networkID = entA.networkID
					
		table.insert(GAMEMODE.networks[entA.networkID], entB)
					
		if entB.deviceType == "storage" then
			GAMEMODE:addToResourceList( entB )
		end
					
		GAMEMODE:updateResourceCount( entA.networkID )
					
	end
	
	if entB.networkID != nil and entA.networkID == nil then
				
		--add each other to connections table
		table.insert(entA.connections, entB)					
		table.insert(entB.connections, entA)
					
		entA.networkID = entB.networkID
					
		table.insert(GAMEMODE.networks[entB.networkID], entA)
					
		if entA.deviceType == "storage" then
			GAMEMODE:addToResourceList( entA )
		end
					
		GAMEMODE:updateResourceCount( entB.networkID )
					
	end
	
	if entA.networkID !=nil and entB.networkID != nil and entA.networkID != entB.networkID then
		
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




