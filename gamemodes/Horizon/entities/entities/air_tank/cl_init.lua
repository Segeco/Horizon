include('shared.lua')
 
function ENT:Draw( )

		if self.dispAir == nil then
		
			self.dispAir = 0
		
		end
		
	
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Air Tank\n" .. "Air: ".. self.dispAir, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();
	Wire_Render(self.Entity)

end

function gen_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispAir = um:ReadShort()
	
end
usermessage.Hook("air_tank_umsg", gen_umsg_hook)