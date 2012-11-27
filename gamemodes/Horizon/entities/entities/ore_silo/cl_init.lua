include('shared.lua')
include('shared.lua')
 
function ENT:Draw( )

		if self.dispMorphite == nil then
		
			self.dispMorphite = 0
		
		end
		
		if self.dispNocxium == nil then
		
			self.dispNocxium = 0
		
		end
		
		if self.dispIsogen == nil then
		
			self.dispIsogen = 0
		
		end
		
	
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then

		local tr = pl:GetEyeTrace();				
		if( tr.Entity == self ) then
		
			if( EyePos():Distance( self:GetPos() ) < 512 ) then
				
				AddWorldTip( nil, "Ore Silo\n" .. "Morphite: ".. self.dispMorphite .. "\nNocxium: ".. self.dispNocxium .. "\nIsogen: ".. self.dispIsogen, nil, self:LocalToWorld( self:OBBCenter() ), NULL );
			
			end
		
		end
		
	end

	self:DrawModel();
	Wire_Render(self.Entity)

end

function silo_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.dispMorphite = um:ReadShort()
	entity.dispNocxium = um:ReadShort()
	entity.dispIsogen = um:ReadShort()
	
end
usermessage.Hook("silo_umsg", silo_umsg_hook)