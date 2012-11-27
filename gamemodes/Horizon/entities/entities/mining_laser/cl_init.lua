include('shared.lua')

local Laser = Material( "cable/redlaser" )

ENT.RenderGroup = RENDERGROUP_BOTH;
 
function ENT:Draw()

	if self.Active == nil then self.Active = false end
	if self.targetPos == nil then self.targetPos = Vector(0, 0, 10) end

	self:DrawModel()	 
 
	local Vector1 = self:LocalToWorld( Vector( 0, 0, 0 ) )
	local Vector2 = self:LocalToWorld( self.targetPos )
 
	render.SetMaterial( Laser )
	self:SetRenderBoundsWS( Vector1, Vector2 )

	
	if self.Active == true then
		render.DrawBeam( Vector1, Vector2, 5, 1, 1, Color( 255, 255, 255, 255 ) ) 
		
	end
	
	Wire_Render(self.Entity)
 

end

hook.Add("PreDrawTranslucentRenderables","Lazors",Draw)

function laser_umsg_hook( um )
	
	local entity = um:ReadEntity()	
	entity.Active = um:ReadBool()
	entity.targetPos = um:ReadVector()
	
end
usermessage.Hook("mining_laser_umsg", laser_umsg_hook)
