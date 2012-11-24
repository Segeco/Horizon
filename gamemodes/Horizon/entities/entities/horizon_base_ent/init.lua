AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')


function ENT:OnRemove()
	if self.networkID != nil then
		GAMEMODE:unlinkDevice( self )
	end
end

