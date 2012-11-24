include('shared.lua')

 
function ENT:Draw( )

	hznFactoryEnt = self
	
	if entID == nil then
		entID = 0
	end
	
	if self.dispEnergy == nil then
		self.dispEnergy = 0
	end
	
	if self.dispMorphite == nil then
		self.dispMorphite = 0
	end
	
	if self.dispNocxium == nil then
		self.dispNocxium = 0
	end
	
	if self.dispIsogen == nil then
		self.dispIsogen = 0
	end
		
	self:DrawModel();

end

local VGUI = {}
function VGUI:Init()

	gwExtractor = {}
	gwExtractor[1] = "Groundwater Extractor"
	gwExtractor[2] = "----------------------"
	gwExtractor[3] = "Use this entity to extract water from planetary"
	gwExtractor[4] = "surfaces. Unit must remain on the ground in order to"
	gwExtractor[5] = "function properly."
	gwExtractor[6] = ""
	gwExtractor[7] = "Consumes ENERGY, produces WATER"
	gwExtractor[8] = ""
	gwExtractor[9] = "Required resources:"
	gwExtractor[10] = ""
	gwExtractor[11] = "[100] Morphite"
	gwExtractor[12] = "[100] Nocxium"
	gwExtractor[13] = "[0] Isogen"
	
	remoteSuitcharger = {}
	remoteSuitcharger[1] = "Remote Suitcharger"
	remoteSuitcharger[2] = "----------------------"
	remoteSuitcharger[3] = "This device replenishes your spacesuit energy within"
	remoteSuitcharger[4] = "a short range. The more people in range, the more"
	remoteSuitcharger[5] = "resources will be consumed."
	remoteSuitcharger[6] = ""
	remoteSuitcharger[7] = "Consumes ENERGY, AIR & COOLANT"
	remoteSuitcharger[8] = "(depending on what is supplied)"
	remoteSuitcharger[9] = "Required resources:"
	remoteSuitcharger[10] = ""
	remoteSuitcharger[11] = "[100] Morphite"
	remoteSuitcharger[12] = "[100] Nocxium"
	remoteSuitcharger[13] = "[0] Isogen"
	
	waterSplitter = {}
	waterSplitter[1] = "Water Splitter"
	waterSplitter[2] = "----------------------"
	waterSplitter[3] = "This device consumes water to produce oxygen and"
	waterSplitter[4] = "hydrogen. No water on your planet? Try the Groundwater"
	waterSplitter[5] = "Extractor."
	waterSplitter[6] = ""
	waterSplitter[7] = "Consumes ENERGY & WATER, produces AIR & HYDROGEN"
	waterSplitter[8] = ""
	waterSplitter[9] = "Required resources:"
	waterSplitter[10] = ""
	waterSplitter[11] = "[100] Morphite"
	waterSplitter[12] = "[100] Nocxium"
	waterSplitter[13] = "[0] Isogen"
	
	hydrogenCoolant = {}
	hydrogenCoolant[1] = "Hydrogen Coolant Compressor"
	hydrogenCoolant[2] = "----------------------"
	hydrogenCoolant[3] = "This device recycles hydrogen into a form of coolant"
	hydrogenCoolant[4] = "Need hydrogen? Better look into the Water Splitter device"
	hydrogenCoolant[5] = ""
	hydrogenCoolant[6] = ""
	hydrogenCoolant[7] = "Consumes ENERGY & HYDROGEN, produces COOLANT"
	hydrogenCoolant[8] = ""
	hydrogenCoolant[9] = "Required resources:"
	hydrogenCoolant[10] = ""
	hydrogenCoolant[11] = "[100] Morphite"
	hydrogenCoolant[12] = "[100] Nocxium"
	hydrogenCoolant[13] = "[0] Isogen"
	
	fusionReactor = {}
	fusionReactor[1] = "Fusion Reactor"
	fusionReactor[2] = "----------------------"
	fusionReactor[3] = "Fueled by hydrogen, this device generates large amounts of energy."
	fusionReactor[4] = "Be sure to supply the reactor with coolant... if you don't, you might"
	fusionReactor[5] = "regret it."
	fusionReactor[6] = ""
	fusionReactor[7] = "Consumes HYDROGEN & COOLANT, produces ENERGY"
	fusionReactor[8] = ""
	fusionReactor[9] = "Required resources:"
	fusionReactor[10] = ""
	fusionReactor[11] = "[100] Morphite"
	fusionReactor[12] = "[100] Nocxium"
	fusionReactor[13] = "[0] Isogen"
	

	local FactoryMenu = vgui.Create( "DFrame" )
	FactoryMenu:SetPos( 50,50 )
	FactoryMenu:SetSize( 550, 300 )
	FactoryMenu:SetTitle( "Horizon Factory" )
	FactoryMenu:SetVisible( true )
	FactoryMenu:SetDraggable( true )
	FactoryMenu:ShowCloseButton( true )
	FactoryMenu:MakePopup()
	
	local schematicBox = vgui.Create("DListView")
	schematicBox:SetParent(FactoryMenu)
	schematicBox:SetPos(10, 35)
	schematicBox:SetSize(150, 185)
	schematicBox:SetMultiSelect(false)
	schematicBox:AddColumn("Schematics") -- Add column
	
	--Schematic Items--
	
		schematicBox:AddLine("Groundwater Extractor")
		schematicBox:AddLine("Water Splitter")
		schematicBox:AddLine("Hydrogen Coolant Proc.")
		schematicBox:AddLine("Remote Suitcharger")
		schematicBox:AddLine("Fusion Reactor")
	
	-------------------
		
	local infoBox = vgui.Create( "DPanel", DermaFrame ) 
	infoBox:SetPos( 170, 35 )
	infoBox:SetSize( 350, 185)
	infoBox:SetParent(FactoryMenu)
	infoBox.Paint = function()    
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 0, infoBox:GetWide(), infoBox:GetTall() )
		
		if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then 
        local selectedValue = schematicBox:GetSelected()[1]:GetValue(1) 
		
		-- Get description data ----------------------
		
		if selectedValue == "Groundwater Extractor" then
		
			itemDesc = gwExtractor
		
		end
		
		if selectedValue == "Water Splitter" then
		
			itemDesc = waterSplitter
		
		end
		
		if selectedValue == "Hydrogen Coolant Proc." then
		
			itemDesc = hydrogenCoolant
		
		end
		
		if selectedValue == "Fusion Reactor" then
		
			itemDesc = fusionReactor
		
		end
		
		if selectedValue == "Remote Suitcharger" then
		
			itemDesc = remoteSuitcharger
		
		end
		
		-- End description data calls ----------------
        		
		--surface.SetFont( "default" )
        surface.SetTextColor( 255, 255, 255, 255 )
		posy = 10
			for _, textLine in pairs (itemDesc) do
			surface.SetTextPos( 15, posy )
			surface.DrawText(textLine)
			posy = posy + 10
			end
		
		end	
		
		surface.SetTextColor( 255, 255, 255, 255 )
		
				
    end
	
	local cancelButton = vgui.Create( "DButton" )
	cancelButton:SetParent( FactoryMenu ) -- Set parent to our "FactoryMenu"
	cancelButton:SetText( "Cancel" )
	cancelButton:SetPos( 440, 250 )
	cancelButton:SetSize( 90, 30 )
	cancelButton.DoClick = function ()
    FactoryMenu:Remove()
	end
	
	local storageButton = vgui.Create( "DButton" )
	storageButton:SetParent( FactoryMenu ) -- Set parent to our "FactoryMenu"
	storageButton:SetText( "Deposit Crate" )
	storageButton:SetPos( 10, 250 )
	storageButton:SetSize( 110, 30 )
	storageButton.DoClick = function ()
	RunConsoleCommand("absorbcrate", entID)
    FactoryMenu:Remove()
	end
	
	local okButton = vgui.Create( "DButton" )
	okButton:SetParent( FactoryMenu ) -- Set parent to our "FactoryMenu"
	okButton:SetText( "BUILD" )
	okButton:SetPos( 340, 250 )
	okButton:SetSize( 90, 30 )
	okButton.DoClick = function ()
	if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then
		RunConsoleCommand( "builditem", schematicBox:GetSelected()[1]:GetValue(1), entID  )
		FactoryMenu:Remove()
	end
	end
	
end
 
	


vgui.Register( "FactoryMenu", VGUI )

function hznFactoryTrigger(um)

	local Window = vgui.Create( "FactoryMenu")
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	
	entID = um:ReadString()
	e = um:ReadEntity()	
	
	--if(not ValidEntity(e)) then return end;
end
usermessage.Hook("hznFactoryTrigger", hznFactoryTrigger)

