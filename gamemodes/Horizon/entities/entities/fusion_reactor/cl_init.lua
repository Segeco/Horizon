include('shared.lua')
 
function ENT:Draw( )
	
		if self.dispHydrogen == nil then
			self.dispHydrogen = 0
		end
		
		if self.dispCoolant == nil then
			self.dispCoolant = 0
		end
			
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Fusion Reactor\n" .. "Hydrogen: ".. self.dispHydrogen .. "\nCoolant: " .. self.dispCoolant, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();

end

function reactor_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispHydrogen = um:ReadShort()
	entity.dispCoolant = um:ReadShort()
	
end
usermessage.Hook("reactor_umsg", reactor_umsg_hook)