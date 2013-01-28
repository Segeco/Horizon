include('shared.lua')

function ENT:Draw( )

	self:DrawModel();
	Wire_Render(self.Entity)

end

net.Receive( "netRemoteSuitCharger", function()
	local entity = net.ReadEntity()	
	entity.dispEnergy = math.Round( net.ReadFloat() )
	entity.dispStorableEnergy = math.Round( net.ReadFloat() )
	entity.dispAir = math.Round( net.ReadFloat() )
	entity.dispStorableAir = math.Round( net.ReadFloat() )
	entity.dispCoolant = math.Round( net.ReadFloat() )
	entity.dispStorableCoolant = math.Round( net.ReadFloat() )
	-- entity.networkID = net.ReadFloat()
	entity.Active = net.ReadBit()
end )

function DrawInfo()
	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity

	if ent.dispEnergy == nil then ent.dispEnergy = 0 end
	if ent.dispStorableEnergy == nil then ent.dispStorableEnergy = 0 end
	if ent.dispAir == nil then ent.dispAir = 0 end
	if ent.dispStorableAir == nil then ent.dispStorableAir = 0 end
	if ent.dispCoolant == nil then ent.dispCoolant = 0 end
	if ent.dispStorableCoolant == nil then ent.dispStorableCoolant = 0 end

	if tr.Entity:IsValid() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 150 then
	 	if tr.Entity:GetClass() == "remote_suitcharger" then
	 		local text = ent.PrintName .. 
	 					 "\nEnergy: " .. commas( ent.dispEnergy ) .. "/" .. commas( ent.dispStorableEnergy ) ..
	 					 "\nAir: " .. commas( ent.dispAir ) .. "/" .. commas( ent.dispStorableAir ) ..
	 					 "\nCoolant: " .. commas( ent.dispCoolant ) .. "/" .. commas( ent.dispStorableCoolant )

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
hook.Add( "HUDPaint", "DrawInfoRemoteSuitCharger", DrawInfo )