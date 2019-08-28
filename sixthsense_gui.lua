-- Class definition for the GUI class
SixthSense_GUI = {}
SixthSense_GUI.__index = SixthSense_GUI


function SixthSense_GUI:new()
	local self = {}
	self.model = {}
	setmetatable(self, SixthSense_GUI);
	
	local parent_frame = CreateFrame("Frame", nil, UIPARENT)
	local background = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile="", tile=false,}
	local widgets = {}

	for i = 1, 11 do
		local anchor = CreateFrame("Frame","6SIconAnchor"..i, self.parent_frame)
		
		anchor:SetFrameStrata("HIGH")
		anchor:SetMovable(true)
		
		anchor:SetBackdrop(background)
		anchor:SetHeight(15)
		anchor:SetWidth(15)
		anchor:SetBackdropColor(1,0,0,1)
		anchor:EnableMouse(true)
		anchor:SetMovable(true)
		anchor:SetScript("OnMouseDown", function(self,button) if button == "LeftButton" then self:StartMoving() end end)
		anchor:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing(); SixthSense_SaveWidgetLocations() end end)
		anchor:Show()
		
		local t = anchor:CreateTexture(nil,"BACKGROUND")
		t:SetTexture("Int7erface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
		t:SetAllPoints(anchor)
		anchor.texture = t
		
		anchor:SetPoint("CENTER", 1, 1)
		
		widgets[i] = anchor
	end
	return self
end

-- ---------------------------------------------------------- --
function SixthSense_GUI:CreateTestFrame(unit_id, x_pos, y_pos)
	local width = 128 * 1 -- self.options_db.profile.frame_scale
	local height = 64 * 1 -- self.options_db.profile.frame_scale
	
	local frame = CreateFrame("Frame", nil, UI_PARENT)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetWidth(width) 			-- Set these to whatever height/width is needed 
	frame:SetHeight(height) 		-- for your Texture
	
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self,button) if button == "LeftButton" then self:StartMoving() end end)
	frame:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing(); SixthSense_SaveWidgetLocations() end end)

	local t = frame:CreateTexture(nil,"BACKGROUND")
	t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
	t:SetAllPoints(frame)
	frame.texture = t

	frame:SetPoint("CENTER", x_pos, y_pos)
	frame:Show()
end


function SixthSense_GUI:Initialise()

end
	
function SixthSense_SaveWidgetLocations()

end
