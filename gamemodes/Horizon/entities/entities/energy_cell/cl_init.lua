include('shared.lua')
 
function ENT:Draw( )

	if self.totalEnergy == nil then
		self.totalEnergy = 0
	end
	
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Energy Cell\n" .. "Energy: ".. self.totalEnergy, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();
	Wire_Render(self.Entity)

end

function storage_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.totalEnergy = um:ReadShort()
end
usermessage.Hook("energy_cell_umsg", storage_umsg_hook)