AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
 

function ENT:Initialize()

	local radius = self.dt.Radius;
	
	self:SetSolid( SOLID_BBOX )
	self:SetNotSolid( true )
	self:SetTrigger( true )
	self:SetNoDraw( true )
	self:DrawShadow( false )
	self:SetModel( "models/props_c17/oildrum001.mdl" )	
	self:PhysicsInitSphere(radius)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionBounds(
		Vector( -radius, -radius, -radius ),
		Vector( radius, radius, radius )
	)
	
end

function ENT:StartTouch( ent )

	if ent.isAsteroid == true then
	
		ent:Collision()
	
	end
	
end


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


function ENT:KeyValue( key, value )

	key = string.lower( key );
	
	if( key == "pltname" ) then
	
		self.name = tostring( value );
		
	end
	
	if( key == "pltradius" ) then
	
		self.dt.Radius = tonumber( value );
		
	end
	
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
	
	if( key == "pltminerals" ) then
	
		if tostring(value) == "MORPHITE" then
			self.dt.Minerals = 1
		end	
		
		if tostring(value) == "NOCXIUM" then
			self.dt.Minerals = 2
		end	
		
	end
	
end










