include( 'shared.lua' )

values = {}
values.air = 0
values.coolant = 0
values.power = 0

surface.CreateFont( "PixelFont", {
	font 		= "04b03",
	size 		= 8,
	weight 		= 0,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= false,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
} )

function GM:Initialize()
   surface.CreateFont( "PixelFont", {
		font 		= "04b03",
		size 		= 8,
		weight 		= 0,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= false,
		underline 	= false,
		italic 		= false,
		strikeout 	= false,
		symbol 		= false,
		rotary 		= false,
		shadow 		= false,
		additive 	= false,
		outline 	= false
	} )
end

local hps = 0
local aps = 0
local as = 0
local cs = 0
local ps = 0
hook.Add("HUDPaint", "HZN_HUD", function()
	local ply = LocalPlayer()
	local X = ScrW()
	local Y = ScrH()

	local health = math.Clamp(ply:Health(), 0, 100)   -- clamps the health to [0, 100] meaning it will not go above 100 or below 0
    hps = math.Approach(hps, health, 50*FrameTime())
    local hpequation = (212)*(hps/100)

	local armor = math.Clamp(ply:Armor(), 0, 100)   -- clamps the health to [0, 100] meaning it will not go above 100 or below 0
    aps = math.Approach(aps, armor, 50*FrameTime())
    local apequation = (212)*(aps/100)

	-- Left corner
	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( Material("Horizon/corner_left.png") )
	surface.DrawTexturedRect( 5, Y-133, 256, 128 )	
	--Armor
	surface.SetDrawColor( 255, 128, 0, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( 37, Y-27, apequation, 14 )	
	-- Health
	surface.SetDrawColor( 231, 17, 21, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( 37, Y-50, hpequation, 14 )
	-- Nickname
	draw.SimpleText( ply:Nick(), "DermaDefaultBold", 37, Y - 72, Color( 0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( ply:Nick(), "DermaDefaultBold", 36, Y - 73, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

	-- Right corner
	local power = math.Clamp(values.power, 0, 200)
    ps = math.Approach(ps, power, 50*FrameTime())
    local psequation = (212)*(ps/200)

	local air = math.Clamp(values.air, 0, 200)
    as = math.Approach(as, air, 50*FrameTime())
    local asequation = (212)*(as/200)

	local coolant = math.Clamp(values.coolant, 0, 200)
    cs = math.Approach(cs, coolant, 50*FrameTime())
    local csequation = (212)*(cs/200)

	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( Material("Horizon/corner_right.png") )
	surface.DrawTexturedRect( ScrW()-261, Y-133, 256, 128 )
	-- Power
	surface.SetDrawColor( 255, 205, 0, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( ScrW()-249, Y-73, psequation, 14 )
	-- Air
	surface.SetDrawColor( 0, 204, 0, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( ScrW()-249, Y-50, asequation, 14 )
	-- Coolant
	surface.SetDrawColor( 0, 153, 204, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( ScrW()-249, Y-27, csequation, 14 )

	draw.SimpleText( "Energy", "PixelFont", ScrW()-41, Y - 69, Color( 255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText( "Air", "PixelFont", ScrW()-41, Y - 46, Color( 255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText( "Coolant", "PixelFont", ScrW()-41, Y - 23, Color( 255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText( "Health", "PixelFont", 41, Y - 46, Color( 255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( "Armor", "PixelFont", 41, Y - 23, Color( 255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

end)

local function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}) do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HideDefaultHUD", hidehud)

function LS_umsg_hook( um )
	values.air = um:ReadShort()
	values.coolant = um:ReadShort()
	values.power = um:ReadShort()	
end
usermessage.Hook("LS_umsg", LS_umsg_hook)