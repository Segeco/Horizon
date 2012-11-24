AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" ) 
include('shared.lua')
 
function ENT:Initialize()


	modelChoice = math.random(1, 3)
	if modelChoice == 1 then asteroidModel = "models/sm_asteroid001.mdl" end
	if modelChoice == 2 then asteroidModel = "models/sm_asteroid002.mdl" end
	if modelChoice == 3 then asteroidModel = "models/sm_asteroid003.mdl" end
 	
	self:SetModel( asteroidModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
				
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 100 )
	end
end

 