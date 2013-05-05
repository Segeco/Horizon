include('shared.lua')
 
function ENT:Draw( )

	self:DrawModel();
	
	if WIRE_CLIENT_INSTALLED then
		Wire_Render(self.Entity)
	end
end

net.Receive( "netAirTank", function()
		local entity = net.ReadEntity()	
		entity.dispAir = math.Round( net.ReadFloat() )
		entity.dispMaxAir = math.Round( net.ReadFloat() )
		-- entity.networkID = net.ReadFloat()
	end )

function DrawInfo()
	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity

	if ent.dispAir == nil then ent.dispAir = 0 end
	if ent.dispMaxAir == nil then ent.dispMaxAir = 0 end

	if tr.Entity:IsValid() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 150 then
	 	if tr.Entity:GetClass() == "air_tank" then
	 		local text = ent.PrintName .. 
	 					 "\nAir: " .. commas( ent.dispAir ) .. "/" .. commas( ent.dispMaxAir )

	 		local yOffset = 0
	 		local center = ent:LocalToWorld( ent:OBBCenter() + Vector(0, -0.5, yOffset) ):ToScreen()
	 		surface.SetFont("DermaDefaultBold")
			local w, t = surface.GetTextSize(text)
			local boxWide, boxTall = w+20, t+8
	 		local gradientUp = surface.GetTextureID("gui/gradient_up")

	 		draw.RoundedBox( 4, center.x-(boxWide/2), center.y-3, boxWide, boxTall, Color( 0, 0, 0, 255 ) )
	 		draw.RoundedBox( 4, (center.x-(boxWide/2))+1, (center.y-3)+1, boxWide-2, boxTall-2, Color( 75, 75, 75, 255 ) )
	 		
			surface.SetDrawColor(25, 25, 25, 220)
			surface.SetTexture(gradientUp)
			surface.DrawTexturedRect(center.x-((boxWide/2)-1), center.y-3, boxWide-1, boxTall)

	 		draw.DrawText(text, "DermaDefaultBold", center.x + 1, center.y + 1, Color(0, 0, 0, 200), 1)
	 		draw.DrawText(text, "DermaDefaultBold", center.x, center.y, Color(255, 255, 255, 200), 1)
		end
	end
end
hook.Add( "HUDPaint", "DrawInfoAirTank", DrawInfo )