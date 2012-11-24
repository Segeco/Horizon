include( 'shared.lua' )

values = {}
values.air = 0
values.coolant = 0
values.power = 0


function myhud()
	local client = LocalPlayer()
	
	
	if !client:Alive() then return end
	if(client:GetActiveWeapon() == NULL or client:GetActiveWeapon() == "Camera") then return end
			
	centerX = ScrW() / 2
	centerY = ScrH() -100
	
	centerX = centerX - 100
	--centerY = centerY + 395
		
	draw.RoundedBox(4, centerX, centerY, 225, 90, Color(10, 10, 10, 150))
	draw.SimpleText("<Life Support Status>", "Trebuchet18", (centerX + 39), (centerY + 5), Color(0, 255, 0, 100), 0, 0)
	draw.SimpleText("Air", "Trebuchet18", (centerX + 25), (centerY + 25), Color(255, 255, 255, 255), 0, 0)
	draw.SimpleText("Coolant", "Trebuchet18", (centerX + 25), (centerY + 42), Color(255, 255, 255, 255), 0, 0)
	draw.SimpleText("Power", "Trebuchet18", (centerX + 25), (centerY + 59), Color(255, 255, 255, 255), 0, 0)
	
	draw.SimpleText((values.air) .. "%", "Trebuchet18", (centerX + 165), (centerY + 25), Color(255, 255, 255, 255), 0, 0)
	draw.SimpleText((values.coolant) .. "%", "Trebuchet18", (centerX + 165), (centerY + 42), Color(255, 255, 255, 255), 0, 0)
	draw.SimpleText((values.power) .. "%", "Trebuchet18", (centerX + 165), (centerY + 59), Color(255, 255, 255, 255), 0, 0)
end

hook.Add("HUDPaint", "myhud", myhud)

function LS_umsg_hook( um )
	values.air = um:ReadShort()
	values.coolant = um:ReadShort()
	values.power = um:ReadShort()	
end
usermessage.Hook("LS_umsg", LS_umsg_hook)

