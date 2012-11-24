include('shared.lua')
include('shared.lua')
 
function ENT:Draw( )

		if self.dispWater == nil then
		
			self.dispWater = 0
		
		end
		
	
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Water Tank\n" .. "Water: ".. self.dispWater, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();

end

function gen_umsg_hook( um )
	
	local entity = um:ReadEntity()
	entity.dispWater = um:ReadShort()	
	
end
usermessage.Hook("water_tank_umsg", gen_umsg_hook)