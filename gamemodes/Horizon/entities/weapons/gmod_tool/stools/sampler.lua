TOOL.Category = "Debug"
TOOL.Name = "Sampler Tool"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"



function TOOL:LeftClick( tr )

	if (!tr.Entity:IsValid(tr.Entity.linkable)) or (tr.Entity:IsPlayer()) then return end
	
	target = tr.Entity
	
		
	for _, v in pairs (GAMEMODE.networks[target.networkID]) do
		print (v)
	end
	
	
	if (CLIENT) then return true end
	
	return true
	
end

