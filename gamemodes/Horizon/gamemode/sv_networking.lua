local Ent = FindMetaTable('Entity')
local Ply = FindMetaTable('Player')

//It may be better to just replace this with DTVars.

//Make a cache to avoid duplicate broadcasts.
local stateCache = stateCache or {}

//Turn item on with true and off by false.
function Ent:SetState(onoff)
	local index = self:EntIndex()
	if stateCache[index] == onoff then return end
	
	stateCache[index] = onoff
	
	net.Start('hznState')
		net.WriteEntity(self)
		net.WriteBit(onoff)
	net.Broadcast()
end

//Send entity state on request.
//We use this to get states when a client find out about a entity. When it enters the player PVS
local function SendState(lng, ply)

	local ent = net.ReadEntity()
	if !IsValid(ent) or !GAMEMODE:IsHznClass(ent:GetClass()) then return end
	
	net.Start('hznState')
		net.WriteEntity(ent)
		net.WriteBit((stateCache[ent:EntIndex()] == true))
	net.Send(ply)
end
net.Receive('hznGetState', SendState)

//Check if suit states are the same and if not send to client.
function Ply:SuitUpdate()
	if (self.suitAir == self.suitAirLast
	and self.suitCoolant == self.suitCoolantLast
	and self.suitPower == self.suitPowerLast) then return end
	
	self.suitAirLast		= self.suitAir
	self.suitCoolantLast	= self.suitCoolant
	self.suitPowerLast		= self.suitPower
	
	net.Start('hznSuit')
		net.WriteUInt(self.suitAir, 8)
		net.WriteUInt(self.suitCoolant, 8)
		net.WriteUInt(self.suitPower, 8)
	net.Send(self)
end

local function RemoveFromCache(ent)
	if stateCache[ent:EntIndex()] != nil then
		stateCache[ent:EntIndex()] = nil
	end
end
hook.Add('EntityRemoved', 'hznRemoveCache', RemoveFromCache)

//Add all net messages.
util.AddNetworkString('netAirComp')
util.AddNetworkString('netAirTank')
util.AddNetworkString('netCoolComp')
util.AddNetworkString('netCoolantTank')
util.AddNetworkString('netEnerCell')
util.AddNetworkString('netFusionReactor')
util.AddNetworkString('netGravGen')
util.AddNetworkString('netGroundWExtractor')
util.AddNetworkString('netHydrogenCoolant')
util.AddNetworkString('netHydrogenTank')
util.AddNetworkString('netMineralCrate')
util.AddNetworkString('netMiningDrill')
util.AddNetworkString('netMiningLas')
util.AddNetworkString('netOreSilo')
util.AddNetworkString('netRemoteSuitCharger')
util.AddNetworkString('netSuitRecharger')
util.AddNetworkString('netWaterPump')
util.AddNetworkString('netWaterSplit')
util.AddNetworkString('netWaterTank')
util.AddNetworkString('hznSuit')
util.AddNetworkString('hznState')
util.AddNetworkString('hznGetState')
