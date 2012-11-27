include('shared.lua')
include('shared.lua')
 
function ENT:Draw( )

	if self.dispCoolant == nil then

		self.dispCoolant = 0
	
	end
		
	
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Coolant Tank\n" .. "Coolant: ".. self.dispCoolant, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();
	Wire_Render(self.Entity)

end

function gen_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispCoolant = um:ReadShort()
	
end
usermessage.Hook("coolant_tank_umsg", gen_umsg_hook)