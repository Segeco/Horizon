include('shared.lua')
 
function ENT:Draw( )
	
		if self.dispEnergy == nil then
			self.dispEnergy = 0
		end
		
		if self.dispHydrogen == nil then
			self.dispHydrogen = 0
		end
			
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Hydrogen Coolant Processor\n" .. "Energy: ".. self.dispEnergy .. "\nHydrogen: " .. self.dispHydrogen, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();
	Wire_Render(self.Entity)

end

function gen_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispEnergy = um:ReadShort()
	entity.dispHydrogen = um:ReadShort()
	
end
usermessage.Hook("hydrogen_coolant_umsg", gen_umsg_hook)