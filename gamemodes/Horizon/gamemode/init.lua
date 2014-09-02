AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
include('sv_resources.lua')
include('sv_networking.lua')

DEFINE_BASECLASS( "gamemode_sandbox" )

//Cache
local nextPlyUpdate = 0
local SunObj

function GM:InitPostEntity()

	self.networks = {}
    self.nextNet = 1
			
	for _, ent in pairs(ents.GetAll()) do
	
		self:setDefaultEnv(ent)	
	
	end
	
	SunObj = ents.FindByClass("env_sun")[1]
end

function GM:PlayerInitialSpawn( ply )
	ply.HZN_ShouldDoSpawnImmune = true
end

function GM:PlayerSpawn( ply )

	self.BaseClass:PlayerSpawn(ply)
	
	-- Assign default suit values
	ply.suitAir = 0
	ply.maxAir = 200
	
	ply.suitCoolant = 0
	ply.maxCoolant = 200
	
	ply.suitPower = 0
	ply.maxPower = 200
	
	ply:SuitUpdate()
	
	
end

function GM:GetPlayerInfo(ply)

	value = ply.suitAir
	return value

end

function GM:findEntEnvironment(ent)

	local entEnv = ent.currentEnv
	if entEnv == nil then
		return false
	end
	
	return true

end

function GM:compareEnv(env, curEnv)

	local env1 = env.dt.Priority
	local env2 = curEnv.dt.Priority
	
	if env2 < env1 then
		return true
	end
	
	return true

end

function GM:setEnvironment(ent, env)

	
	local curEnv = ent.currentEnv
	if self:compareEnv(env, curEnv) then
		ent.currentEnv = env
		if env.dt.Breathable then
			ent.Habitable = true
		end
		if env.dt.Temp == 1 then
			ent.Temp = "cold"
		end
		if env.dt.Temp == 2 then
			ent.Temp = "temperate"
		end
		if env.dt.Temp == 3 then
			ent.Temp = "hot"
		end		
		self:adjGravity(ent, env)
	end
	

end

function GM:adjGravity( ent, env)

	local gravity = env.dt.Gravity
	
	if ent:IsPlayer() then
	
		if gravity == 0 then
		
			ent:SetGravity(.0000001)
			
		
		else
		
			ent:SetGravity(gravity)
					
		end
		
			
	else
	
	if gravity > 0 then
		
		if ent:GetPhysicsObjectCount() then
			local i = 0
			while i < ent:GetPhysicsObjectCount() do
			 
			    physobs = ent:GetPhysicsObjectNum(i)
			    physobs:EnableGravity(true)
				physobs:EnableDrag(true)
			    i = i + 1
			end
		elseif (ent:IsValid()) then
			ent:GetPhysicsObject():EnableGravity(true)
			ent:GetPhysicsObject():EnableDrag(true)
		end
	
	end
	
	if gravity == 0 then
	
		if ent:GetPhysicsObjectCount() then
			local i = 0
			while i < ent:GetPhysicsObjectCount() do
			 
			    physobs = ent:GetPhysicsObjectNum(i)
			    physobs:EnableGravity(false)
				physobs:EnableDrag(false)
			    i = i + 1
			end
		elseif (ent:IsValid()) then
			ent:GetPhysicsObject():EnableGravity(false)
			ent:GetPhysicsObject():EnableDrag(false)
		end
	
	end	
	
	end

end

function GM:setDefaultEnv(ent)

	ent.currentEnv = nil
		
	if ent:IsPlayer() then
		
		ent.Habitable = false
		ent.Temp = "cold"
		ent:SetGravity(.0000001)
			
	else
		
		local i = 0
		while i < ent:GetPhysicsObjectCount() do
		 
		    physobs = ent:GetPhysicsObjectNum(i)
		    physobs:EnableGravity(false)
			physobs:EnableDrag(false)
		    i = i + 1
		end
		
	end
	
end

function GM:HurtPlayer( ply )

	if ply:IsValid() then
		ply:SetHealth( ply:Health() - 20 )				
		ply:EmitSound("buttons/combine_button3.wav")
		if ply:Health() < 1 then ply:Kill() end
	end
	
end

function GM:generateResource(netID, resName, amt)

	local tankCount = 0
	local newAmt = 0
	local totalResource = 0
	
	--How many storage units are there on the network?

	for _, ent in pairs( self.networks[netID] ) do
	
		if ent.deviceType == "storage" then
		
			for _, res in pairs( ent.resourcesUsed ) do
			
				if res == resName then
				
					tankCount = tankCount + 1
					
				end
			
			end
		
		end
	
	
	end
	
	--Update amount on the registered table, find out how much to send to individual tanks
	
	for _, res in pairs( self.networks[netID][1] ) do
	
		if res[1] == resName then
		
			res[2] = res[2] + amt
			
						
			if res[2] >= res[3] then				
				res[2] = res[3]
			end
			
			
			newAmt = res[2] / tankCount
		
		end
	
	end
	
	--Update amount on individual tanks
	
	for _, ent in pairs( self.networks[netID] ) do
	
		if ent.deviceType == "storage" then
		
			for _, res in pairs(ent.resourcesUsed) do
			
				if res == resName then 
				
					totalResource = self:GetResourceTotal(netID, resName)
					ent:updateResCount(resName, newAmt, totalResource)
				
				end
			
			end
		
		end
	
	end


end

function GM:consumeResource(netID, resName, amt)

	local tankCount = 0
	local newAmt = 0
	local totalResource = 0
	
	--How many storage units are there on the network?

	for _, ent in pairs( self.networks[netID] ) do
	
		if ent.deviceType == "storage" then
		
			for _, res in pairs( ent.resourcesUsed ) do
			
				if res == resName then
				
					tankCount = tankCount + 1
					
				end
			
			end
		
		end
	
	
	end
	
	--Update amount on the registered table, find out how much to pull from individual tanks
	
	for _, res in pairs( self.networks[netID][1] ) do
	
		if res[1] == resName and res[2] > 0 then
		
			res[2] = res[2] - amt
			newAmt = res[2] / tankCount
		
		end
	
	end
	
	--Update amount on individual tanks
	
	for _, ent in pairs( self.networks[netID] ) do
	
		if ent.deviceType == "storage" then
		
			for _, res in pairs(ent.resourcesUsed) do
			
				if res == resName then 
				
					totalResource = self:GetResourceTotal(netID, resName)
					ent:updateResCount(resName, newAmt, totalResource)
				
				end
			
			end
		
		end
	
	end


end

function GM:GetResourceTotal(netID, resName)

	-- Gets the total amount available of a single resource on a network

	local totalResource

	for _, res in pairs (self.networks[netID][1]) do
	
		if res[1] == resName then
		
			totalResource = res[2]
		
		end
	
	end
	
	return totalResource

end

function GM:UpdateTotalResources(netID)

for _, ent in pairs( self.networks[netID] ) do
	
		if ent.deviceType == "storage" then
		
			ent:GetTotalResource()
		
		end
	
	end
end


function GM:addToResourceList( ent )

		
	if ent.deviceType == "storage" then
	
		for _, resName in pairs( ent.resourcesUsed ) do		
		
			for _, listEntry in pairs ( self.networks[ent.networkID][1] ) do
			
				if listEntry[1] == resName then
					
					return
				end
			
			end
			
			newEntry = {resName, 0, 0}
			table.insert( self.networks[ent.networkID][1], newEntry )
		
		end
	
	end

end

function GM:updateResourceCount( netID )

		--first, zero out resource counts so we can get a fresh count
		
		for _, res in pairs ( self.networks[netID][1] ) do
			
			res[2] = 0
			res[3] = 0
			
		end

		for _, ent in pairs ( self.networks[netID] ) do
						
			if ent.deviceType == "storage" then
				
				ent:reportResources( netID )
			end
		
		end

end

function GM:splitNetwork( networkID )
	      
	local newNetworks = {}
	local tempList = {}
	local blackList = {}
	local failcheck = false
	local networkDevices = {}
	
	for _, device in pairs(self.networks[networkID]) do
	
		if device.linkable == true then
		
			device.networkID = nil
			table.insert(networkDevices, device)
						
		end
	end
	
	self.networks[networkID] = nil
	
		
	for _, device in pairs( networkDevices ) do
	
			
		if !self:dupeCheck( device, tempList ) then
				
				table.insert(tempList, device )
							
			for _, chDevice in pairs( device.connections ) do
			
				if !self:dupeCheck( chDevice, tempList )  then
				
					table.insert(tempList, chDevice)
				
				end
			
			end
		
		end
		
		for _, entry in pairs( tempList ) do
		
			if !self:dupeCheck(entry, tempList) then
			
				table.insert(tempList, entry)				
			
			end
			
			for _, chDevice in pairs( entry.connections ) do
				
					if !self:dupeCheck(chDevice, tempList) then
						table.insert(tempList, chDevice)
					end
				
			end
		
		end	
		
		for _, entry in pairs( tempList ) do
		
			if self:dupeCheck( entry, blackList ) then
			failcheck = true
			end
			
			if entry.connections == nil then
			failcheck = true
			end
		
		end
		
		if failcheck == false then
		
				
			table.insert(newNetworks, tempList)		
					
			for _, bl in pairs ( tempList ) do
		
				table.insert( blackList, bl )
		
			end
			
				
		end
		
		tempList = nil
		tempList = {}
		failcheck = false
	
	end
	
	
	return newNetworks
	
end

function GM:dupeCheck( ent, list )

	for _, entry in pairs( list ) do
	
		if entry == ent then
			
			return true
			
		end
	
	end	

end


function GM:unlinkDevice( device )

	local networkID = device.networkID
	local tempList = {}
	local newNetworks = {}
			
	--Sever all direct connections
	
	for _, ent in pairs( self.networks[networkID] ) do
	
		if ent.linkable == true then
		
			for _, conn in pairs( ent.connections ) do
				
				if conn != device then
				
					table.insert(tempList, conn)
				
				end				
		
			end
			
			ent.connections = nil
			ent.connections = tempList
			tempList = nil
			tempList = {}
	
		end
	end
	
	device.connections = nil
		
	--Sever all network connections
	tempList = nil
	
	tempList = {}
	tempList[1] = {}
		
	for _, ent in pairs( self.networks[networkID] ) do
	
		if ent.linkable == true then
		
			if ent.connections != nil then
				
				table.insert(tempList, ent)
				
			end
		
		end
	
	end
	
	device.connections = {}
	
	for _, entry in pairs(tempList) do
	
	end	
	
	device.networkID = nil
		
	self.networks[networkID] = nil
	self.networks[networkID] = tempList
	
	newNetworks = self:splitNetwork( networkID )
	
	
	for _, network in pairs( newNetworks ) do
	
		self.networks[self.nextNet] = {}
		self.networks[self.nextNet][1] = {}
	
		for _, ent in pairs( network ) do
						
			ent.networkID = self.nextNet
						
			table.insert( self.networks[self.nextNet], ent )
			self:addToResourceList( ent )
		
		end
		
		self:updateResourceCount( self.nextNet )
		self:UpdateTotalResources( self.nextNet )
				
		self.nextNet = self.nextNet + 1
		
			
	end
	
	if device.deviceType == "storage" then
		device:resetResources()
	end
		
end


function GM:fixStragglers()

	--temporary stopgap measure to prevent single item networks.
	for _, network in pairs(self.networks) do
	
		for _, ent in pairs(network) do
		
				
			if ent.linkable == true then
			
				if ent.connections != nil then
				
					if table.maxn (ent.connections) == 0 then						
						ent.networkID = nil
					end
				
				end
			
			end
		
		end
	
	end
	
end

function GM:GetMapCoords()

 local x = math.random(-15000, 15000)
 local y = math.random(-15000, 15000)
 local z = math.random(-15000, 15000)
 
 local coords = Vector(x, y, z)
 
 return coords

end

function GM:ChooseAsteroidType()

	local x = math.random(1, 100)
	local asteroidType = "med_asteroid"
	
	if x < 11 then asteroidType = "lg_asteroid" end
	
	return asteroidType

end

function GM:SpawnAsteroid()
		
	local coords = self:GetMapCoords()
	
	local spawnHazards = ents.FindInSphere(coords, 500)
	if spawnHazards != nil then coords = self:GetMapCoords() end -- if there's something in the way, get new coordinates and try again.
	
	local asteroidType = self:ChooseAsteroidType()

	local ent = ents.Create(asteroidType)
	ent:SetPos(coords)
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	phys:EnableMotion(false)
	self:setDefaultEnv(ent)
	phys:EnableMotion(true)
	
	local x = math.random(-3000, 3000)
	local y = math.random(-3000, 3000)
	local z = math.random(-3000, 3000)
 
	local a = math.random(-50, 50)
	local b = math.random(-50, 50)
	local c = math.random(-50, 50)
 
 
	ent:GetPhysicsObject():ApplyForceCenter( Vector( x, y, z ) )
	ent:GetPhysicsObject():ApplyForceOffset(Vector( a, b, c ),Vector(0,0,0) )
			
	return ent

end

//We are going to create a table of entitys spawned here to set the environments of them.
//This is faster than scrolling over the whole entity table every tick. We only have what we need.
//If we have a way to detect when a entitys physics object is created that would be a better method.
local EntitysCreated = {}

function GM:OnEntityCreated(ent)
	if IsValid(ent) and ent.currentEnv == nil then
		table.insert(EntitysCreated, ent)
	end
	
	self.BaseClass:OnEntityCreated(ent)
end

//We don't really need to update things faster than the tick rate here.
function GM:Tick()
	
	//Cache
	local CurrentTime = CurTime()
	
	//Go over entitys created and if they have no environment set then give them the default one.
	for k,prop in pairs(EntitysCreated) do
		if IsValid(prop) and prop.currentEnv == nil then
			self:setDefaultEnv(prop)
		end
		
		//Remove the entity from the table.
		EntitysCreated[k] = nil
	end
	--Asteroid timer----------------------------------
	
	if asteroidInterval == nil then 
		asteroidInterval = math.random(300, 500)
		nextAsteroid = (CurrentTime + asteroidInterval)
	end
	
	if CurrentTime > nextAsteroid then 
		self:SpawnAsteroid()
		nextAsteroid = (CurrentTime + asteroidInterval)
	end
	
	---------------------------------------------------
	
	//Player code.
	if CurrentTime < (nextPlyUpdate or 0) then return end
	
	for _,ply in pairs(player.GetAll()) do
		if !ply:IsValid() then return end
	
			local killFlag = 0
		
		
			if !ply.Habitable and ply:Alive() then			
			
				if ply.suitAir > 0 then				
				
					ply.suitAir = ply.suitAir - 1
			
				end
				
				if ply.suitAir == 0 then
			
					killFlag = killFlag + 1
			
				end
				
			end
			
			if ply.Temp == "hot" and ply:Alive() then
		
				if ply.suitCoolant > 0 then
				
					ply.suitCoolant = ply.suitCoolant - 1
					
				end
				
				if ply.suitCoolant == 0 then
				
					killFlag = killFlag + 1
				
				end
				
			end
			
			if ply.Temp == "cold" and ply:Alive() then
			
				if ply.suitPower > 0 then
			
					ply.suitPower = ply.suitPower - 1
					
				end
				
				if ply.suitPower == 0 then
				
					killFlag = killFlag + 1
				
				end
				
			end
		
			//Posistion starts at 0,0,0 so have to get pos here.
			if ply.HZN_ShouldDoSpawnImmune then
				ply.HZN_SpawnImmune = ply:GetPos()
				ply.HZN_ShouldDoSpawnImmune = false
				killFlag = 0
			end
		
		//Spawn immunity until player moves.
			if ply.HZN_SpawnImmune then
				if ply:GetPos() != ply.HZN_SpawnImmune then
					ply.HZN_SpawnImmune = false
				else
					killFlag = 0
				end
			end
		
			if killFlag > 0 then
			
				self:HurtPlayer(ply)
				killFlag = 0
		
			end
	
		ply:SuitUpdate()
	end
	
	nextPlyUpdate = CurrentTime + 1
end

-- Faster than scrolling over entity table a bunch of times.
-- Sun ent never changes so no need to update.
function GM:GetSun()
	return SunObj
end

--Debug functions

function debugMode( client, command, arguments )
     client.suitAir = 200
	 client.suitPower = 200
	 client.suitCoolant = 200
end

concommand.Add( "hzndebug", debugMode )








