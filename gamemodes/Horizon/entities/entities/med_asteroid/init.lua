AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" ) 
include('shared.lua')
 
function ENT:Initialize()


	modelChoice = math.random(1, 3)
	if modelChoice == 1 then asteroidModel = "models/med_asteroid001.mdl" end
	if modelChoice == 2 then asteroidModel = "models/med_asteroid002.mdl" end
	if modelChoice == 3 then asteroidModel = "models/med_asteroid003.mdl" end
 	
	self:SetModel( asteroidModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self.isAsteroid = true
	self.asteroidHealth = 2000
	
			
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 100 )
	end
end


function ENT:Collision()

			
	local effectdata = EffectData();
					
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
		
	local effectdata = EffectData();
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
	
	local effectdata = EffectData();
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
		
	local effectdata = EffectData();		
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
				
		self.Entity:Remove();
		
end


function ENT:AsteroidSplit()

			
	local effectdata = EffectData();
					
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
		
	local effectdata = EffectData();
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
	
	local effectdata = EffectData();
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
		
	local effectdata = EffectData();		
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );	
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
	local effectdata = EffectData();	
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) );
		util.Effect( "explosion", effectdata );		
		
				
		self.Entity:Remove();
		
						
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)

		local ent = ents.Create("sm_asteroid")
		ent:SetPos(self:GetPos() + Vector(x, y, z))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		phys:EnableMotion(false)
		GAMEMODE:setDefaultEnv(ent)
		phys:EnableMotion(true)
	
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local z = math.random(-100, 100)
 
		local a = math.random(-2, 2)
		local b = math.random(-2, 2)
		local c = math.random(-2, 2) 
 
		ent:GetPhysicsObject():ApplyForceCenter( Vector( x, y, z ) )
		ent:GetPhysicsObject():ApplyForceOffset(Vector( a, b, c ),Vector(0,0,0) )
		
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)

		local ent = ents.Create("sm_asteroid")
		ent:SetPos(self:GetPos() + Vector(x, y, z))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		phys:EnableMotion(false)
		GAMEMODE:setDefaultEnv(ent)
		phys:EnableMotion(true)
	
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local z = math.random(-100, 100)
 
		local a = math.random(-2, 2)
		local b = math.random(-2, 2)
		local c = math.random(-2, 2) 
 
		ent:GetPhysicsObject():ApplyForceCenter( Vector( x, y, z ) )
		ent:GetPhysicsObject():ApplyForceOffset(Vector( a, b, c ),Vector(0,0,0) )

		
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)

		local ent = ents.Create("sm_asteroid")
		ent:SetPos(self:GetPos() + Vector(x, y, z))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		phys:EnableMotion(false)
		GAMEMODE:setDefaultEnv(ent)
		phys:EnableMotion(true)
	
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local z = math.random(-100, 100)
 
		local a = math.random(-2, 2)
		local b = math.random(-2, 2)
		local c = math.random(-2, 2) 
 
		ent:GetPhysicsObject():ApplyForceCenter( Vector( x, y, z ) )
		ent:GetPhysicsObject():ApplyForceOffset(Vector( a, b, c ),Vector(0,0,0) )

		
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)

		local ent = ents.Create("sm_asteroid")
		ent:SetPos(self:GetPos() + Vector(x, y, z))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		phys:EnableMotion(false)
		GAMEMODE:setDefaultEnv(ent)
		phys:EnableMotion(true)
	
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local z = math.random(-100, 100)
 
		local a = math.random(-2, 2)
		local b = math.random(-2, 2)
		local c = math.random(-2, 2) 
 
		ent:GetPhysicsObject():ApplyForceCenter( Vector( x, y, z ) )
		ent:GetPhysicsObject():ApplyForceOffset(Vector( a, b, c ),Vector(0,0,0) )

		
		local x = math.random(-500, 500)
		local y = math.random(-500, 500)
		local z = math.random(-500, 500)

		local ent = ents.Create("sm_asteroid")
		ent:SetPos(self:GetPos() + Vector(x, y, z))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		phys:EnableMotion(false)
		GAMEMODE:setDefaultEnv(ent)
		phys:EnableMotion(true)
	
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		local z = math.random(-100, 100)
 
		local a = math.random(-2, 2)
		local b = math.random(-2, 2)
		local c = math.random(-2, 2) 
 
		ent:GetPhysicsObject():ApplyForceCenter( Vector( x, y, z ) )
		ent:GetPhysicsObject():ApplyForceOffset(Vector( a, b, c ),Vector(0,0,0) )


	
	
end



   


 