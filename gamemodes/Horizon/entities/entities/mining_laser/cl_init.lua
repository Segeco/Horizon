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
	
	if WIRE_CLIENT_INSTALLED then
		Wire_Render(self.Entity)
	end 

end

hook.Add("PreDrawTranslucentRenderables","Lazors",Draw)

net.Receive( "netMiningLas", function()
	local entity = net.ReadEntity()	
	entity.Active = net.ReadBit()
	entity.targetPos = net.ReadVector()
	-- entity.networkID = net.ReadFloat()
end )
