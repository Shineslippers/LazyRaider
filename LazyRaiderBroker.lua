local icon = LibStub("LibDBIcon-1.0")

LazyRaiderBroker = LibStub("LibDataBroker-1.1"):NewDataObject("LazyRaiderI", {

	type = "data source",
	text = "LazyRaider",
	icon = "Interface\\AddOns\\LazyRaider\\Icon"
	
})

function LazyRaiderBroker.OnTooltipShow(tooltip)

	
	if LazyRaider_AutoRecruit == false and LazyRaider_NinjaRecruit == false then
		tooltip:AddLine("                  LazyRaider")
	elseif LazyRaider_AutoRecruit == true or LazyRaider_NinjaRecruit == true then
		tooltip:AddLine("                In Progress...")
		tooltip:AddLine(" ")
	end
	if  LazyRaider_AutoRecruit == true then
		tooltip:AddLine("Current mod: |cffff0000"..LazyRaider_RecruitType.."|r", 0.2, 1, 0.2, 1)
		tooltip:AddLine("New message in |cffff0000"..SecondsToTime(LazyRaider_Interval - LazyRaider_LastAnnounce).."|r", 0.2, 1, 0.2, 1)
	end	
	if LazyRaider_NinjaRecruit == true then
		tooltip:AddLine("Current mod: |cffff0000"..LazyRaider_NinjaType.."|r", 0.2, 1, 0.2, 1)
		tooltip:AddLine("New message in |cffff0000"..SecondsToTime(LazyRaider_NinjaInterval - LazyRaider_NinjaAnnounce).."|r", 0.2, 1, 0.2, 1)	
	end	
	tooltip:AddLine(" ")
	tooltip:AddLine("|cffeda55fLeft-Click|r |cff00ee00to open LazyRaider options|r")
	

end

function LazyRaiderBroker.OnClick(self, button)
	
	if button == "RightButton" then
		print("Nothing happend")
	elseif button == "LeftButton" then
		if LazyRaiderWindow:IsShown() then
			LazyRaiderWindow:Hide()
		else
			LazyRaiderWindow:Show()
		end
	end
	
end