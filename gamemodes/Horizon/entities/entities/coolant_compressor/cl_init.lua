include('shared.lua')
 
function ENT:Draw( )
	
		if self.dispEnergy == nil then
			self.dispEnergy = 0
		end
			
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Coolant Compressor\n" .. "Energy: ".. self.dispEnergy, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();

end

function gen_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispEnergy = um:ReadShort()
	
end
usermessage.Hook("gen_umsg", gen_umsg_hook)