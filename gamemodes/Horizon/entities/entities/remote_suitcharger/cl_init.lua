include('shared.lua')
 
function ENT:Draw( )

	if self.dispEnergy == nil then
		self.dispEnergy = 0
	end
	
	if self.dispAir == nil then
		self.dispAir = 0
	end
	
	if self.dispCoolant == nil then
		self.dispCoolant = 0
	end
	
	
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Remote Suitcharger\n" .. "Energy: ".. self.dispEnergy .. "\nAir: " .. self.dispAir .. "\nCoolant: " .. self.dispCoolant, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();

end

function remoteSuitcharger_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispEnergy = um:ReadShort()
	entity.dispAir = um:ReadShort()
	entity.dispCoolant = um:ReadShort()
end
usermessage.Hook("remoteSuitcharger_umsg", remoteSuitcharger_umsg_hook)