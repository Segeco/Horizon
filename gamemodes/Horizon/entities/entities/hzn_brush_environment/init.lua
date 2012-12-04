AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
 


--[[
function ENT:Touch( ent )

	
	currentDist = ent:GetPos():Distance(self:GetPos())
	if currentDist < self.dt.Radius then
	
		
		if !GAMEMODE:findEntEnvironment(ent) then
				
			ent.currentEnv = self
			GAMEMODE:setEnvironment(ent, self)
			
		end
		
				
		if ent.currentEnv != self then
					
			GAMEMODE:setEnvironment(ent, self)
		
		end
		
	end
	
	if currentDist > self.dt.Radius then
		GAMEMODE:setDefaultEnv( ent )
		ent.currentEnv = nil
	end
	
	

end
--]]

function ENT:Initialize()

			
end


function ENT:Touch(ent)

	print (self.dt.Temp)

	
	if !GAMEMODE:findEntEnvironment(ent) then
				
		ent.currentEnv = self
		GAMEMODE:setEnvironment(ent, self)
			
	end
		
	if ent.currentEnv != self then
					
		GAMEMODE:setEnvironment(ent, self)
		
	end


end

function ENT:EndTouch(ent)

	GAMEMODE:setDefaultEnv( ent )
	ent.currentEnv = nil

end


function ENT:KeyValue( key, value )

	key = string.lower( key );
		
	if( key == "pltgravity" ) then
	
		self.dt.Gravity = tonumber( value );
		
	end
	
	if( key == "pltbreathable" ) then
	
		if tostring(value) == "TRUE" then
		self.dt.Breathable = true
		end
		
		if tostring(value) == "FALSE" then
		self.dt.Breathable = false
		end
		
	end
	
	if( key == "plttemp" ) then
	
		if tostring(value) == "HOT" then
			self.dt.Temp = 3
		end
		
		if tostring(value) == "TEMPERATE" then
			self.dt.Temp = 2
		end
		
		if tostring(value) == "COLD" then
			self.dt.Temp = 1
		end
		
	end
	
	if( key == "pltpriority" ) then
	
		self.dt.Priority = tonumber( value );
		
	end
			
end










