include('shared.lua')
include('shared.lua')
 
function ENT:Draw( )

	self:DrawModel();
	
	if WIRE_CLIENT_INSTALLED then
		Wire_Render(self.Entity)
	end
end

net.Receive( "netMineralCrate", function()
	local entity = net.ReadEntity()
	local dispTable = net.ReadTable()
	entity.dispMorphite = dispTable["Morphite"]["amount"]
	entity.dispMaxMorphite = dispTable["Morphite"]["max"]
	entity.dispNocxium = dispTable["Nocxium"]["amount"]
	entity.dispMaxNocxium = dispTable["Nocxium"]["max"]
	entity.dispIsogen = dispTable["Isogen"]["amount"]
	entity.dispMaxIsogen = dispTable["Isogen"]["max"]
	-- entity.networkID = net.ReadFloat()
end )

function DrawInfo()
	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity

	if ent.dispMorphite == nil then ent.dispMorphite = 0 end
	if ent.dispMaxMorphite == nil then ent.dispMaxMorphite = 0 end
	if ent.dispNocxium == nil then ent.dispNocxium = 0 end
	if ent.dispMaxNocxium == nil then ent.dispMaxNocxium = 0 end
	if ent.dispIsogen == nil then ent.dispIsogen = 0 end
	if ent.dispMaxIsogen == nil then ent.dispMaxIsogen = 0 end

	if tr.Entity:IsValid() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 150 then
	 	if tr.Entity:GetClass() == "mineral_crate" then
	 		local text = ent.PrintName .. 
	 					 "\nMorphite: " .. commas(ent.dispMorphite) .. "/" .. commas(ent.dispMaxMorphite) ..
	 					 "\nNocxium: " .. commas(ent.dispNocxium) .. "/" .. commas(ent.dispMaxNocxium) ..
	 					 "\nIsogen: " .. ent.dispIsogen .. "/" .. commas(ent.dispMaxIsogen)

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
hook.Add( "HUDPaint", "DrawInfoMineralCrate", DrawInfo )