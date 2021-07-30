--[[

	Addon provides various tools for lazy raiders.
	
	Currently done:
	* RandomRoll
	* AutoInvite
	* AutoShare
	* AutoRecruit
	* AutoDisband

]]

local addon = LibStub("AceAddon-3.0"):NewAddon("LazyRaider")

function addon:OnInitialize()

	self.db = LibStub("AceDB-3.0"):New("LazyRaiderDB", {profile = {minimap = {hide = false,},},})
	LibStub("LibDBIcon-1.0"):Register("LazyRaider", LazyRaiderBroker, self.db.profile.minimap)
		
end

function LazyRaider_OnLoad()

	LazyRaider_InitSlashCommands()
	LazyRaider_InitEvent()
	LazyRaider_InitDungeonMod()
	LazyRaider_InitChannelNumeric()
	LazyRaider_InitChannelAlphabetical()
	LazyRaider_AutoInvite = false
	LazyRaider_ShareQuestsOne = false
	LazyRaider_ShareQuestsTwo = false
	LazyRaider_ShareInv = false
	LazyRaider_ShareTrain = false
	LazyRaider_BotMessage = false
	LazyRaider_AutoRecruit = false
	LazyRaider_NinjaRecruit = false
	LazyRaider_ShareFalse = false
	LazyRaider_WgBattleTooltips = ""
	LazyRaider_Interval = 30
	LazyRaider_NinjaInterval = 150
	LazyRaider_LastAnnounce = 0
	LazyRaider_NinjaAnnounce = 0
	LazyRaider_QuestLineOne = 1
	LazyRaider_QuestLineTwo = 1
	LazyRaider_IndexOne = 0
	LazyRaider_IndexTwo = 0
	LazyRaider_RollCount = 0
	LazyRaider_RollName = "None"
	LazyRaider_RecruitType = "None"
	LazyRaider_NinjaType = "None"	
	LazyRaider_PlayerClass = { }
	LazyRaider_PlayerRole = { }
	LazyRaider_ShareTabOne = { }
	LazyRaider_ShareTabTwo = { }
	LazyRaider_EnglishClassNames = { WARRIOR = "Warrior", PALADIN = "Paladin", DRUID = "Druid", DEATHKNIGHT = "Death Knight", PRIEST = "Priest", HUNTER = "Hunter", WARLOCK = "Warlock", ROGUE = "Rogue", MAGE = "Mage", SHAMAN = "Shaman" }
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78LazyRaider|r loaded!")
	
end

function LazyRaider_OnEvent(self, event, ...)
	
	LazyRaider_EventHandlers[event](self, ...)
	
end

function LazyRaider_InitEvent()
	
	LazyRaiderFrame:SetScript("OnEvent", LazyRaider_OnEvent)
	LazyRaiderFrame:SetScript("OnUpdate", LazyRaider_OnUpdate)

	LazyRaider_EventHandlers = { }
	
	LazyRaider_EventHandlers.CHAT_MSG_WHISPER = LazyRaider_OnWhisper
	LazyRaider_EventHandlers.CHAT_MSG_SYSTEM = LazyRaider_OnSystemChat
	LazyRaider_EventHandlers.RAID_ROSTER_UPDATE = LazyRaider_OnMembersChanged
	LazyRaider_EventHandlers.PARTY_MEMBERS_CHANGED = LazyRaider_OnMembersChanged
	LazyRaider_EventHandlers.PARTY_INVITE_REQUEST = LazyRaider_OnInviteRequest
	
	for k, v in pairs(LazyRaider_EventHandlers) do
		LazyRaiderFrame:RegisterEvent(k)
	end

end

function LazyRaider_InitSlashCommands()

	SLASH_LAZYRAIDERHELP1 = "/lazyraider"
	SLASH_LAZYRAIDERHELP2 = "/lr"
	
	SlashCmdList["LAZYRAIDERHELP"] = LazyRaider_Help
	
	SLASH_LAZYRAIDERWINDOW1 = "/lazywindow"
	SLASH_LAZYRAIDERWINDOW2 = "/lw"
	
	SlashCmdList["LAZYRAIDERWINDOW"] = LazyRaider_SetWindow	
	
	SLASH_RANDOMROLL1 = "/randomroll"
	SLASH_RANDOMROLL2 = "/rr"
	
	SlashCmdList["RANDOMROLL"] = LazyRaider_RandomRoll
	
	SLASH_AUTOINVITE1 = "/autoinvite"
	SLASH_AUTOINVITE2 = "/inv"
	
	SlashCmdList["AUTOINVITE"] = LazyRaider_SetAutoInvite

	SLASH_SHAREQUESTS1 = "/sharequests"
	SLASH_SHAREQUESTS2 = "/sq"
	
	SlashCmdList["SHAREQUESTS"] = LazyRaider_SetShareQuests	

	SLASH_BOTMESSAGE1 = "/botmessage"
	SLASH_BOTMESSAGE2 = "/bm"
	
	SlashCmdList["BOTMESSAGE"] = LazyRaider_SetBotMessage	

	SLASH_SHOWROLES1 = "/showroles"
	SLASH_SHOWROLES2 = "/sr"
	
	SlashCmdList["SHOWROLES"] = LazyRaider_SetShowRoles	
	
	SLASH_RECRUIT1 = "/recruit"
	SLASH_RECRUIT2 = "/rec"
	
	SlashCmdList["RECRUIT"] = LazyRaider_Recruit
	
	SLASH_DISBAND1 = "/disband"
	SLASH_DISBAND2 = "/dis"
	
	SlashCmdList["DISBAND"] = LazyRaider_Disband
	
	SLASH_CHANGEROLE1 = "/changerole"
	SLASH_CHANGEROLE2 = "/cr"	
	
	SlashCmdList["CHANGEROLE"] = LazyRaider_ChangeRole	
	
end

function LazyRaider_Help(msg)

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78LazyRaider|r |cff00eeffcommands|r:")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Lazy Window|r: setup window")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/lazywindow|r |cff00eeff/lw|r |cff00ee00on|r |cff00ee00off|r |cff00ee00reset|r")	
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78RandomRoll|r: random rolls an item")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/randomroll|r |cff00eeff/rr|r |cff00ee00ItemLink|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78AutoInvite|r: toggles the auto invite feature")	
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/autoinvite|r |cff00eeff/inv|r |cff00ee00on|r |cff00ee00off|r")	
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78ShareQuests|r: setup for quests sharing")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/sharequests|r |cff00eeff/sq|r |cff00ee00QuestNumber|r |cff00ee00reset|r |cff00ee00help|r")		
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78BotMessage|r: toggles the bot message feature")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/botmessage|r |cff00eeff/bm|r |cff00ee00on|r |cff00ee00off|r")		
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78ShowRoles|r: show roles of your group")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/showroles|r |cff00eeff/sr|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Recruit|r: specified recruitment message")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/recruit|r |cff00eeff/rec|r |cff00ee00mods|r |cff00ee00stop|r |cff00ee00help|r")	
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Disband|r: disband your group")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/disband|r |cff00eeff/dis|r optional:|cff00ee00message|r")	
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Change Role|r: set new role for group member")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/changerole|r |cff00eeff/cr|r |cff00ee00name|r |cff00ee00role|r |cff00ee00help|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	
end

function LazyRaider_SetWindow(msg)

	if (string.lower(msg) == "on") then
		LazyRaiderWindow:Show()
	elseif (string.lower(msg) == "off") then	
		LazyRaiderWindow:Hide()
	elseif 	(string.lower(msg) == "reset") then
		LazyRaiderWindow:ClearAllPoints()
		LazyRaiderWindow:SetPoint("CENTER", 0, 30)	
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Lazy Window|r: default position")
	else
		if LazyRaiderWindow:IsShown() then
			LazyRaiderWindow:Hide()
		else
			LazyRaiderWindow:Show()
		end
	end	

end

function LazyRaider_RandomRoll(msg)

	LazyRaider_ItemLink = string.match(strtrim(msg), "^\124c%x+\124Hitem[:%-%d]+\124h%[[^\124]+%]\124h\124r")
	LazyRaider_ItemLink = (LazyRaider_ItemLink == nil) and "" or (" " .. LazyRaider_ItemLink)
	LazyRaider_RollCount, LazyRaider_RollName, _ = LazyRaider_GetGroupMembers()
	
	if GetNumRaidMembers() > 0 then
		ChatType = "RAID"
	elseif GetNumPartyMembers() > 0 then
		ChatType = "PARTY"
	else
		ChatType = "SAY"
	end
	
	SendChatMessage("Random Rolling" .. LazyRaider_ItemLink, ChatType, nil, nil)
	
	local namesPerLine = 5
	for line = 1, math.floor((LazyRaider_RollCount + namesPerLine - 1) / namesPerLine) do
		local message = ""
		local index = 1 + (line - 1) * namesPerLine
		for i = index, math.min(LazyRaider_RollCount, index + namesPerLine - 1) do
			message = message .. " " .. i .. "-" .. LazyRaider_RollName[i]
		end
		message = strtrim(message)
		SendChatMessage(message, ChatType, nil, nil)
	end
	
	RandomRoll(1, LazyRaider_RollCount)

end

function LazyRaider_SetAutoInvite(msg)

	if (string.lower(msg) == "on") then
		LazyRaider_AutoInvite = true
		LazyRaiderWindow_AutoInvite_Check:SetChecked(true)
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite enabled")
	elseif (string.lower(msg) == "off") then
		LazyRaider_AutoInvite = false
		LazyRaiderWindow_AutoInvite_Check:SetChecked(false)
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite disabled")
	else
		LazyRaider_AutoInvite = not LazyRaider_AutoInvite
		LazyRaiderWindow_AutoInvite_Check:SetChecked(LazyRaider_AutoInvite)
		DEFAULT_CHAT_FRAME:AddMessage(LazyRaider_AutoInvite and "AutoInvite enabled" or "AutoInvite disabled")
	end
	
end

function LazyRaider_SetShareQuests(msg)
	
	if (string.match(msg, "%d+ %d+") ~= nil) then
		LazyRaider_QuestLineOne, LazyRaider_QuestLineTwo = string.match(msg, "(%d+) (%d+)")
		local questTitleOne, questLevelOne, _, _, isHeaderOne, _, _, _, questIDOne = GetQuestLogTitle(LazyRaider_QuestLineOne)
		local questTitleTwo, questLevelTwo, _, _, isHeaderTwo, _, _, _, questIDTwo = GetQuestLogTitle(LazyRaider_QuestLineTwo)
		if questTitleOne and questTitleTwo and not isHeaderOne and not isHeaderTwo then
			LazyRaider_ShareQuestsOne = true
			LazyRaider_ShareQuestsTwo = true
			LazyRaider_ShareRecOne = "\124cffffff00\124Hquest:"..questIDOne..":"..questLevelOne.."\124h["..questTitleOne.."]\124h\124r"
			LazyRaider_ShareRecTwo = "\124cffffff00\124Hquest:"..questIDTwo..":"..questLevelTwo.."\124h["..questTitleTwo.."]\124h\124r"
			DEFAULT_CHAT_FRAME:AddMessage("1st quest for sharing: "..LazyRaider_ShareRecOne)
			DEFAULT_CHAT_FRAME:AddMessage("2nd quest for sharing:"..LazyRaider_ShareRecTwo)
			LazyRaiderWindow_ShareQuest_FirstButton:SetText(questTitleOne)
			LazyRaiderWindow_ShareQuest_SecondButton:SetText(questTitleTwo)
			UIDropDownMenu_Initialize(LazyRaiderWindow_ShareQuest_FirstMenu, LazyRaider_ShareQuest_Menu, "MENU")
			UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, questTitleOne)
			UIDropDownMenu_Initialize(LazyRaiderWindow_ShareQuest_SecondMenu, LazyRaider_ShareQuest_Menu, "MENU")
			UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, questTitleTwo)
		else
			DEFAULT_CHAT_FRAME:AddMessage("Not valid quest number. Check it on /sq help")
		end
	elseif (string.match(msg, "%d+") ~= nil) then
		LazyRaider_QuestLineOne = string.match(msg, "(%d+)")
		local questTitleOne, questLevelOne, _, _, isHeaderOne, _, _, _, questIDOne = GetQuestLogTitle(LazyRaider_QuestLineOne)
		if questTitleOne ~= nil and not isHeaderOne then
			LazyRaider_ShareQuestsOne = true
			LazyRaider_ShareQuestsTwo = false
			LazyRaider_ShareRecOne = "\124cffffff00\124Hquest:"..questIDOne..":"..questLevelOne.."\124h["..questTitleOne.."]\124h\124r"
			DEFAULT_CHAT_FRAME:AddMessage("Quest for sharing: "..LazyRaider_ShareRecOne)
			LazyRaiderWindow_ShareQuest_FirstButton:SetText(questTitleOne)
			UIDropDownMenu_Initialize(LazyRaiderWindow_ShareQuest_FirstMenu, LazyRaider_ShareQuest_Menu, "MENU")
			UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, questTitleOne)
		else
			DEFAULT_CHAT_FRAME:AddMessage("Not valid quest number. Check it on /sq help")
		end	
	elseif (string.lower(msg) == "reset") then
		DEFAULT_CHAT_FRAME:AddMessage("No quests for sharing anymore")
		LazyRaider_ShareQuestsOne = false
		LazyRaider_ShareQuestsTwo = false
		UIDropDownMenu_SetSelectedValue(LazyRaiderWindow_ShareQuest_FirstMenu, "")
		UIDropDownMenu_SetSelectedValue(LazyRaiderWindow_ShareQuest_SecondMenu, "")
		LazyRaiderWindow_ShareQuest_FirstButton:SetText("")
		LazyRaiderWindow_ShareQuest_SecondButton:SetText("")	
	else
		LazyRaider_ShowShareQuestsSyntax()
	end
		
end

function LazyRaider_ShowShareQuestsSyntax()

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78ShareQuests|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("Availble numbers:")
	for i = 1, GetNumQuestLogEntries() do 
		local questTitleOne, questLevelOne, _, _, isHeaderOne, _, _, _, questIDOne = GetQuestLogTitle(i)
		if questTitleOne ~= nil and not isHeaderOne then 
			DEFAULT_CHAT_FRAME:AddMessage("[|cff00ee00"..i.."|r] \124cffffff00\124Hquest:"..questIDOne..":"..questLevelOne.."\124h["..questTitleOne.."]\124h\124r")
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/sharequests|r |cff00eeff/sq|r |cff00ee00QuestNumber|r |cff00ee00reset|r |cff00ee00help|r")		
	DEFAULT_CHAT_FRAME:AddMessage("Syntax example: |cff00eeff/sharequests|r |cff00ee001|r")
	DEFAULT_CHAT_FRAME:AddMessage("Syntax example: |cff00eeff/sq|r |cff00ee001|r |cff00ee005|r")
	DEFAULT_CHAT_FRAME:AddMessage("Syntax example: |cff00eeff/sq|r |cff00ee00help|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	
end

function LazyRaider_SetBotMessage(msg)
	
	if (string.lower(msg) == "on") then
		LazyRaider_BotMessage = true
		LazyRaiderWindow_BotMessage_Check:SetChecked(true)
		DEFAULT_CHAT_FRAME:AddMessage("BotMessages enabled")
	elseif (string.lower(msg) == "off") then
		LazyRaider_BotMessage = false
		LazyRaiderWindow_BotMessage_Check:SetChecked(false)
		DEFAULT_CHAT_FRAME:AddMessage("BotMessages disabled")
	else
		LazyRaider_BotMessage = not LazyRaider_BotMessage
		LazyRaiderWindow_BotMessage_Check:SetChecked(LazyRaider_BotMessage)
		DEFAULT_CHAT_FRAME:AddMessage(LazyRaider_BotMessage and "BotMessages enabled" or "BotMessages disabled")
	end

end

function LazyRaider_SetShowRoles(msg)
	
	if LazyRaider_SetGroupRoles() then
		LazyRaider_ShowRoles()
	end
	
end

function LazyRaider_Recruit(msg)
	
	local startstop = string.lower(strsplit(" ", msg))
	local preset = LazyRaider_DungeonMod[string.upper(startstop)]
	local _, _, message = string.match(msg, "[^ ]+ (%w+) (%d+) (.+)")
	local recchannel, interval, _ = string.match(msg, "[^ ]+ (%w+) (%d+)")
	if preset ~= nil and recchannel ~= nil and interval ~= nil then
		LazyRaider_SetGroupRoles()	
		if (startstop == "share" and LazyRaider_BotMessage and LazyRaider_AutoInvite) then
			if (LazyRaider_ShareQuestsOne and LazyRaider_ShareQuestsTwo) then 
				LazyRaider_DungeonName = "Whisper SHARE1 to get "..LazyRaider_ShareRecOne..". SHARE2 to get "..LazyRaider_ShareRecTwo..". SHARE12 to get both."
			elseif LazyRaider_ShareQuestsOne then
				LazyRaider_DungeonName = "Whisper SHARE to get "..LazyRaider_ShareRecOne
			else
				DEFAULT_CHAT_FRAME:AddMessage("You should choose quests for sharing(/sq)")
				return
			end						
		elseif startstop == "share" then
			DEFAULT_CHAT_FRAME:AddMessage("Need to enable AutoInvite(/inv on) and BotMessage(/bm on). Don't forget to choose quests for share(/sq).")
			return				
		-- elseif string.find(startstop, "raid") ~= nil then
			-- if message ~= nil then
				-- LazyRaider_RequiredAchievement = string.match(strtrim(message), "^\124c%x+\124Hachievement[:%-%d%x]+\124h%[[^\124]+%]\124h\124r")
			-- else
				-- LazyRaider_RequiredAchievement = nil
			-- end
			-- DEFAULT_CHAT_FRAME:AddMessage("This feature isn't ready yet.")
			-- return		
		elseif message ~= nil then
			LazyRaider_DungeonName = message
		else
			LazyRaider_ShowRecruitSyntax()
			return
		end	
		local presetnumeric = LazyRaider_ChannelNumeric[string.upper(recchannel)]
		local presetalphabetical = LazyRaider_ChannelAlphabetical[string.upper(recchannel)]
		if presetnumeric ~= nil then
			LazyRaider_Channel = "CHANNEL"
			LazyRaider_ChannelId = recchannel
		elseif presetalphabetical ~= nil then
			LazyRaider_Channel = string.upper(recchannel)
			LazyRaider_ChannelId = nil
		else
			DEFAULT_CHAT_FRAME:AddMessage("Available chat IDs: 1, 2, 3, 4, 5, 6, 7, SAY, YELL, EMOTE, PARTY, RAID, GUILD, BATTLEGROUND")
			return
		end
		LazyRaider_Interval = tonumber(interval)	
		if (LazyRaider_Interval < 30) then
			DEFAULT_CHAT_FRAME:AddMessage("Recruit interval should be atleast 30 seconds. Set to 30 seconds.")
			LazyRaider_Interval = 30
		end		
		preset()
		DEFAULT_CHAT_FRAME:AddMessage("Starting Recruit")		
		LazyRaiderWindow_Recruit_ModButton:SetText(string.upper(startstop))
		UIDropDownMenu_Initialize(LazyRaiderWindow_Recruit_ModMenu, LazyRaiderWindow_Recruit_Mod, "MENU")
		UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, string.upper(startstop))
		LazyRaiderWindow_Recruit_ChannelButton:SetText(string.upper(recchannel))
		UIDropDownMenu_Initialize(LazyRaiderWindow_Recruit_ChannelMenu, LazyRaiderWindow_Recruit_Channel, "MENU")
		UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, string.upper(recchannel))
		LazyRaiderWindow_Recruit_IntervalButton:SetText(interval)
		UIDropDownMenu_Initialize(LazyRaiderWindow_Recruit_IntervalMenu, LazyRaiderWindow_Recruit_Interval, "MENU")
		UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, interval)		
	elseif startstop == "winter" and recchannel ~= nil and interval ~= nil then
		if message then
			LazyRaider_NinjaMessage = message
		else
			LazyRaider_NinjaMessage = ""
		end
		local presetnumeric = LazyRaider_ChannelNumeric[string.upper(recchannel)]
		local presetalphabetical = LazyRaider_ChannelAlphabetical[string.upper(recchannel)]
		if presetnumeric ~= nil then
			LazyRaider_NinjaChannel = "CHANNEL"
			LazyRaider_NinjaId = recchannel
		elseif presetalphabetical ~= nil then
			LazyRaider_NinjaChannel = string.upper(recchannel)
			LazyRaider_NinjaId = nil
		else
			DEFAULT_CHAT_FRAME:AddMessage("Available chat IDs: 1, 2, 3, 4, 5, 6, 7, SAY, YELL, EMOTE, PARTY, RAID, GUILD, BATTLEGROUND")
			return
		end				
		LazyRaider_NinjaInterval = tonumber(interval)
		if (LazyRaider_Interval < 30) then
			DEFAULT_CHAT_FRAME:AddMessage("Recruit interval should be atleast 30 seconds. Set to 30 seconds.")
			LazyRaider_Interval = 30
		end				
		LazyRaider_NinjaType = "Wintergrasp"
		LazyRaider_NinjaAnnounce = LazyRaider_NinjaInterval
		LazyRaider_NinjaRecruit = true	
		DEFAULT_CHAT_FRAME:AddMessage("Starting Wintercruit")
	elseif startstop == "grasp" then
		LazyRaider_NinjaRecruit = false
		LazyRaider_NinjaType = "None"
		DEFAULT_CHAT_FRAME:AddMessage("Stopping Wintercruit")
	elseif startstop == "stop" then
		LazyRaider_AutoRecruit = false
		LazyRaider_RecruitType = "None"
		DEFAULT_CHAT_FRAME:AddMessage("Stopping Recruit")
		UIDropDownMenu_SetSelectedValue(LazyRaiderWindow_Recruit_ModMenu, "")
		LazyRaiderWindow_Recruit_ModButton:SetText("Mod")		
		UIDropDownMenu_SetSelectedValue(LazyRaiderWindow_Recruit_ChannelMenu, "")
		LazyRaiderWindow_Recruit_ChannelButton:SetText("Channel")
		UIDropDownMenu_SetSelectedValue(LazyRaiderWindow_Recruit_IntervalMenu, "")		
		LazyRaiderWindow_Recruit_IntervalButton:SetText("Interval")		
	elseif startstop == "mods" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Available mods|r:")
		DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
		for k, v in pairs(LazyRaider_DungeonMod) do
			DEFAULT_CHAT_FRAME:AddMessage(string.upper(k))
		end		
		DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	else
		LazyRaider_ShowRecruitSyntax()		
	end
	
end

function LazyRaider_ShowRecruitSyntax()

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Recruit|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/recruit|r |cff00ee00mods|r |cff00ee00stop|r |cff00ee00help|r")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/rec|r |cff00ee00mod|r |cff00ee00channel|r |cff00ee00interval|r |cff00ee00message|r")	
	DEFAULT_CHAT_FRAME:AddMessage("-- Syntax example: |cff00eeff/recruit|r |cff00ee00custom 5 30 test|r")
	DEFAULT_CHAT_FRAME:AddMessage("-- Syntax example: |cff00eeff/rec|r |cff00ee00share guild 30|r")
	DEFAULT_CHAT_FRAME:AddMessage("-- Syntax example: |cff00eeff/rec|r |cff00ee00mods|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	
end

function LazyRaider_InitDungeonMod()

	LazyRaider_DungeonMod = { }
	LazyRaider_DungeonMod["D5"] = LazyRaider_FormingFive
	LazyRaider_DungeonMod["D10"] = LazyRaider_FormingTen
	LazyRaider_DungeonMod["D25"] = LazyRaider_FormingTventyfive
	LazyRaider_DungeonMod["CUSTOM"] = LazyRaider_FormingCustom
	LazyRaider_DungeonMod["SHARE"] = LazyRaider_FormingShare

end

function LazyRaider_FormingFive()

	DEFAULT_CHAT_FRAME:AddMessage("Forming a Group(5) party")
	LazyRaider_RecruitType = "Group(d5)"
	LazyRaider_ClassCap = 5
	LazyRaider_RequiredTanks = 1
	LazyRaider_RequiredHealers = 1
	LazyRaider_RequiredDps = 5 - LazyRaider_RequiredTanks - LazyRaider_RequiredHealers
	LazyRaider_LastAnnounce = LazyRaider_Interval
	LazyRaider_AutoRecruit = true

end

function LazyRaider_FormingTen()

	DEFAULT_CHAT_FRAME:AddMessage("Forming a Group(10) raid")
	LazyRaider_RecruitType = "Group(d10)"
	LazyRaider_ClassCap = 5
	LazyRaider_RequiredTanks = 2
	LazyRaider_RequiredHealers = 2
	LazyRaider_RequiredDps = 10 - LazyRaider_RequiredTanks - LazyRaider_RequiredHealers
	LazyRaider_LastAnnounce = LazyRaider_Interval
	LazyRaider_AutoRecruit = true

end

function LazyRaider_FormingTventyfive()

	DEFAULT_CHAT_FRAME:AddMessage("Forming a Group(25) raid")
	LazyRaider_RecruitType = "Group(d25)"
	LazyRaider_ClassCap = 10
	LazyRaider_RequiredTanks = 3
	LazyRaider_RequiredHealers = 5
	LazyRaider_RequiredDps = 25 - LazyRaider_RequiredTanks - LazyRaider_RequiredHealers
	LazyRaider_LastAnnounce = LazyRaider_Interval
	LazyRaider_AutoRecruit = true

end


function LazyRaider_FormingCustom()

	DEFAULT_CHAT_FRAME:AddMessage("Forming a Custom group")
	LazyRaider_RecruitType = "Custom"
	LazyRaider_LastAnnounce = LazyRaider_Interval
	LazyRaider_AutoRecruit = true

end

function LazyRaider_FormingShare()

	DEFAULT_CHAT_FRAME:AddMessage("Forming a Share spam")
	LazyRaider_RecruitType = "Share"
	LazyRaider_LastAnnounce = LazyRaider_Interval
	LazyRaider_AutoRecruit = true
	
end

function LazyRaider_InitChannelNumeric()

	LazyRaider_ChannelNumeric = { }
	LazyRaider_ChannelNumeric["1"] = "1"
	LazyRaider_ChannelNumeric["2"] = "2"
	LazyRaider_ChannelNumeric["3"] = "3"
	LazyRaider_ChannelNumeric["4"] = "4"
	LazyRaider_ChannelNumeric["5"] = "5"
	LazyRaider_ChannelNumeric["6"] = "6"
	LazyRaider_ChannelNumeric["7"] = "7"
	
end

function LazyRaider_InitChannelAlphabetical()

	LazyRaider_ChannelAlphabetical = { }
	LazyRaider_ChannelAlphabetical["SAY"] = "SAY"
	LazyRaider_ChannelAlphabetical["YELL"] = "YELL"
	LazyRaider_ChannelAlphabetical["EMOTE"] = "EMOTE"
	LazyRaider_ChannelAlphabetical["PARTY"] = "PARTY"
	LazyRaider_ChannelAlphabetical["RAID"] = "RAID"
	LazyRaider_ChannelAlphabetical["GUILD"] = "GUILD"
	LazyRaider_ChannelAlphabetical["BATTLEGROUND"] = "BATTLEGROUND"

end

function LazyRaider_Disband(msg)

	local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
	
	if (nameCount > 0) then
		if (msg ~= nil) then
			SendChatMessage("[Disband] " .. msg, GetNumRaidMembers() > 0 and "RAID" or "PARTY", nil, nil)
		end
		
		for i = 1, nameCount do
			if (nameArray[i] ~= UnitName("player")) then
				UninviteUnit(nameArray[i])
			end
		end
	end
end

function LazyRaider_ChangeRole(msg)

	local changename, changerole = string.match(msg:lower(), "(%w+) (%w+)")
	if (changename ~= nil and changerole ~= nil) then
		if LazyRaider_IsInGroup(UnitName(changename)) and LazyRaider_SetGroupRoles() then	
			local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
			for i = 1, nameCount do
				if nameArray[i]:lower() == changename:lower() then			
					LazyRaiderWindow_ChangeRole_NameButton:SetText(nameArray[i])
					UIDropDownMenu_Initialize(LazyRaiderWindow_ChangeRole_NameMenu, LazyRaider_ChangeRole_Name, "MENU")
					UIDropDownMenu_SetSelectedName(UIDROPDOWNMENU_INIT_MENU, nameArray[i])
					LazyRaider_CRBuffer = nameArray[i]
				end
			end
			local tank, dps, heal = LazyRaider_ParseRoles(msg:lower())
			local tankClasses = { ["Warrior"] = true, ["Death Knight"] = true, ["Paladin"] = true, ["Druid"] = true }
			local healerClasses = { ["Priest"] = true, ["Shaman"] = true, ["Paladin"] = true, ["Druid"] = true }
			if ((tank) and (tankClasses[LazyRaider_PlayerClass[UnitName(changename)]])) then
				LazyRaider_PlayerRole[UnitName(changename)] = { ["tank"] = tank }
				LazyRaider_GetRoles()
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..UnitName(changename).."|r role was changed to TANK")
				LazyRaiderWindow_ChangeRole_RoleButton:SetText("Tank")
			elseif (dps) then
				LazyRaider_PlayerRole[UnitName(changename)] = {  ["dps"] = dps }
				LazyRaider_GetRoles()
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..UnitName(changename).."|r role was changed to DPS")
				LazyRaiderWindow_ChangeRole_RoleButton:SetText("Dps")			
			elseif ((heal)and (healerClasses[LazyRaider_PlayerClass[UnitName(changename)]])) then
				LazyRaider_PlayerRole[UnitName(changename)] = { ["heal"] = heal }
				LazyRaider_GetRoles()
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..UnitName(changename).."|r role was changed to HEAL")
				LazyRaiderWindow_ChangeRole_RoleButton:SetText("Heal")				
			else
				DEFAULT_CHAT_FRAME:AddMessage("Incorrect role")
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("Name incorrect or member isn't part of your group")				
		end
	else	
		LazyRaider_ShowChangeRoleSyntax()
	end
	
end

function LazyRaider_ShowChangeRoleSyntax()

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Change Role|r")
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeff/changerole|r |cff00eeff/cr|r |cff00ee00name|r |cff00ee00role|r |cff00ee00help|r")
	DEFAULT_CHAT_FRAME:AddMessage("-- Syntax example: |cff00eeff/changerole|r |cff00ee00takado|r |cff00ee00dps|r")
	DEFAULT_CHAT_FRAME:AddMessage("-- Syntax example: |cff00eeff/cr|r |cff00ee00TaKAdO|r |cff00ee00dPS|r")		
	DEFAULT_CHAT_FRAME:AddMessage("----------------------------------------")

end

function LazyRaider_GetGroupMembers()

	local memberCount = 0
	local nameArray = { }
	local classCount = { ["Warrior"] = 0, ["Paladin"] = 0, ["Druid"] = 0, ["Death Knight"] = 0, ["Priest"] = 0, ["Hunter"] = 0, ["Warlock"] = 0, ["Rogue"] = 0, ["Mage"] = 0, ["Shaman"] = 0 }

	if (GetNumRaidMembers() > 0) then
		for i = 1, 40 do
			local name, _, _, _, class = GetRaidRosterInfo(i)
			if (name ~= nil) then
				memberCount = memberCount + 1
				nameArray[memberCount] = name
				classCount[class] = classCount[class] + 1
			end
		end	
	elseif (GetNumPartyMembers() > 0) then	
		memberCount = 1
		nameArray[1] = UnitName("player")	
		classCount[UnitClass("player")] = 1	
		for i = 1, GetNumPartyMembers() do
			memberCount = memberCount + 1
			nameArray[memberCount] = UnitName("party" .. i)
			classCount[UnitClass("party" .. i)] = classCount[UnitClass("party" .. i)] + 1
		end
	else
		memberCount = 1
		nameArray[1] = UnitName("player")
		classCount[UnitClass("player")] = 1
	end

	return memberCount, nameArray, classCount

end

function LazyRaider_IsInGroup(name)
	
	local nameArray = { }
	
	if (GetNumRaidMembers() > 0) then
		for i = 1, 40 do
			local name = GetRaidRosterInfo(i);
			if (name ~= nil) then
				nameArray[name] = true
			end
		end
		
	elseif (GetNumPartyMembers() > 0) then

		nameArray[UnitName("player")] = true
		for i = 1, GetNumPartyMembers() do
			nameArray[UnitName("party" .. i)] = true
		end
	else
		nameArray[UnitName("player")] = true
	end
	
	return nameArray[name] ~= nil
end

function LazyRaider_OnSystemChat(self, ...)

	local arg1 = ...

	-- ? is the roll delimiter for the Taiwanese WoW version
	if (LazyRaider_RollCount > 1 and string.match(arg1, "%w+[ ?].*%d %(%d%-%d%)") ~= nil) then
		local name, roll, low, high = string.match(arg1, "(%w+)[ ?].*(%d) %((%d)-(%d)%)")
		
		if (name == UnitName("player") and tonumber(low) <= tonumber(roll) and tonumber(roll) <= tonumber(high) and tonumber(low) == 1 and tonumber(high) == LazyRaider_RollCount) then
			local winner = LazyRaider_RollName[tonumber(roll)]
			SendChatMessage(winner .. " won" .. LazyRaider_ItemLink .. "!", ChatType, nil, nil)
			LazyRaider_RollCount = 0
		end
	end
	
	if LazyRaider_ShareQuestsOne then
		if string.match(arg1, "is not in your instance") ~= nil then
			SendChatMessage("Leave instance and repeat your message again to get quest", "WHISPER", nil, arg1:sub(1, (arg1:len()-25)))
		end
		if string.match(arg1, "has accepted your quest") ~= nil and arg1:sub(1, (arg1:len()-24)) == LazyRaider_ShareTrain then
			QuestLogPushQuest(LazyRaider_QuestLineTwo)
			LazyRaider_ShareTrain = false
		end		
		if LazyRaider_BotMessage then		
			if string.match(arg1, "'s quest log is full") ~= nil then
				SendChatMessage("Your quest log is full", "WHISPER", nil, arg1:sub(1, (arg1:len()-20)))
			elseif string.match(arg1, "is not eligible for that quest today") ~= nil then
				SendChatMessage("You are not eligible for that quest", "WHISPER", nil, arg1:sub(1, (arg1:len()-37)))
			elseif string.match(arg1, "is not eligible for that quest") ~= nil then
				SendChatMessage("You are not eligible for that quest", "WHISPER", nil, arg1:sub(1, (arg1:len()-31)))
			elseif string.match(arg1, "is already on that quest") ~= nil then
				SendChatMessage("You are already on that quest", "WHISPER", nil, arg1:sub(1, (arg1:len()-25)))
			-- elseif string.match(arg1, "is busy") ~= nil then
				-- SendChatMessage("You are busy ", "WHISPER", nil, arg1:sub(1, (arg1:len()-23)))	
			elseif string.match(arg1, "has declined your quest") ~= nil then
				SendChatMessage("You decline share", "WHISPER", nil, arg1:sub(1, (arg1:len()-24)))
			end
		end
	end
end

function LazyRaider_OnWhisper(self, ...)

	local message, sender, _, _, _, _, _, _, _, _, _, guid = ...
	local _, class = GetPlayerInfoByGUID(guid)
	class = LazyRaider_EnglishClassNames[class]
	LazyRaider_PlayerClass[sender] = class
	local lowerMsg = string.lower(message)
	LazyRaider_InviteMessage = lowerMsg
	if sender ~= UnitName("player") and not LazyRaider_IsInGroup(sender) then
		if (LazyRaider_AutoRecruit and LazyRaider_RecruitType ~= "Custom" and LazyRaider_RecruitType ~= "None") then
		
			local achievement = LazyRaider_RequiredAchievement ~= nil and string.match(message, "\124c%x+\124Hachievement[:%-%d%x]+\124h%[[^\124]+%]\124h\124r") or ""
			local tank, dps, heal = LazyRaider_ParseRoles(lowerMsg)
			local pureClasses = { ["Warrior"] = false, ["Paladin"] = false, ["Druid"] = false, ["Death Knight"] = false, ["Priest"] = false, ["Hunter"] = true, ["Warlock"] = true, ["Rogue"] = true, ["Mage"] = true, ["Shaman"] = false }
			if (pureClasses[class]) then
				tank, dps, heal = false, true, false
			end
			if (LazyRaider_Trigraph(LazyRaider_RequiredAchievement ~= nil, achievement ~= "", true) and (tank or dps or heal)) then
				
				if (LazyRaider_RequiredAchievement ~= nil) then
					local achievementId, achievementGuid, completed = string.match(achievement, "^\124c%x+\124Hachievement:([^:]+):([^:]+):([^:]+):[:%-%d]+\124h%[[^\124]+%]\124h\124r")
					local requiredAchievementId = string.match(LazyRaider_RequiredAchievement, "^\124c%x+\124Hachievement:(%d+)[:%-%d%x]+\124h%[[^\124]+%]\124h\124r")
					if (achievementGuid == strsub(guid, 3)) then
						if (tonumber(completed) ~= 1) then
							SendChatMessage("Sorry, your achievement needs to be completed.", "WHISPER", nil, sender)
							return
						elseif (tonumber(achievementId) ~= tonumber(requiredAchievementId)) then
							SendChatMessage("That's the wrong achievement! Please link your " .. LazyRaider_RequiredAchievement .. " achievement.", "WHISPER", nil, sender)
							return
						end
					elseif (achievementId ~= nil) then
						SendChatMessage("You can't link someone else's achievement.", "WHISPER", nil, sender)
						return
					end
				end
				
				LazyRaider_PlayerRole[sender] = { ["tank"] = tank, ["dps"] = dps, ["heal"] = heal }
				
				if (LazyRaider_NeedPlayer(class, tank, dps, heal)) then
					LazyRaider_ProcessInviteRequest(sender)
				else
					SendChatMessage("Sorry, we don't need your role/class right now.", "WHISPER", nil, sender)
				end

			else
				if (LazyRaider_RequiredAchievement == nil) then
					SendChatMessage("Please whisper me with the role(s) you wish to join as. (tank/dps/heal)", "WHISPER", nil, sender)
				else
					SendChatMessage("Please link your " .. LazyRaider_RequiredAchievement .. " achievement and whisper me with the role(s) you wish to join as. (tank/dps/heal)", "WHISPER", nil, sender)
				end
			end
		
		elseif (LazyRaider_AutoInvite and (string.find(lowerMsg, "inv") ~= nil)) then
			InviteUnit(sender)
			LazyRaider_ShareFalse = true
		end
		
		if LazyRaider_ShareQuestsOne then
			if LazyRaider_BotMessage then
				if not LazyRaider_ShareQuestsTwo and string.find(lowerMsg, "share") == nil then
					SendChatMessage("Whisper to me SHARE to get your quest. Thank you.", "WHISPER", nil, sender)
				elseif LazyRaider_ShareQuestsTwo and string.find(lowerMsg, "share1") == nil and string.find(lowerMsg, "share 1") == nil and string.find(lowerMsg, "share2") == nil and string.find(lowerMsg, "share 2") == nil then
					SendChatMessage("Whisper to me SHARE1 or SHARE2 to get your quest. Thank you.", "WHISPER", nil, sender)
				end
			end
			if not LazyRaider_ShareQuestsTwo and string.find(lowerMsg, "share") ~= nil then
				LazyRaider_ShareInv = sender
				table.insert(LazyRaider_ShareTabOne, sender)
			elseif LazyRaider_ShareQuestsTwo and (string.find(lowerMsg, "share1") ~= nil or string.find(lowerMsg, "share 1") ~= nil or string.find(lowerMsg, "1") ~= nil) and (string.find(lowerMsg, "share2") ~= nil or string.find(lowerMsg, "share 2") ~= nil or string.find(lowerMsg, "2") ~= nil) then
				LazyRaider_ShareInv = sender
				table.insert(LazyRaider_ShareTabOne, sender)
				LazyRaider_ShareTrain = sender
			elseif LazyRaider_ShareQuestsTwo and (string.find(lowerMsg, "share1") ~= nil or string.find(lowerMsg, "share 1") ~= nil) then
				LazyRaider_ShareInv = sender
				table.insert(LazyRaider_ShareTabOne, sender)
			elseif LazyRaider_ShareQuestsTwo and (string.find(lowerMsg, "share2") ~= nil or string.find(lowerMsg, "share 2") ~= nil) then
				LazyRaider_ShareInv = sender
				table.insert(LazyRaider_ShareTabTwo, sender)
			end
		end

		if LazyRaider_ShareInv and LazyRaider_AutoInvite then
			InviteUnit(sender)
			LazyRaider_ShareInv = false
		end
		
	elseif sender ~= UnitName("player") and LazyRaider_IsInGroup(sender) then
				
		if LazyRaider_ShareQuestsOne then
			if LazyRaider_BotMessage then
				if not LazyRaider_ShareQuestsTwo and string.find(lowerMsg, "share") == nil then
					SendChatMessage("Whisper to me SHARE to get your quest. Thank you.", "WHISPER", nil, sender)
				elseif LazyRaider_ShareQuestsTwo and string.find(lowerMsg, "share1") == nil and string.find(lowerMsg, "share 1") == nil and string.find(lowerMsg, "share2") == nil and string.find(lowerMsg, "share 2") == nil then
					SendChatMessage("Whisper to me SHARE1 or SHARE2 to get your quest or . Thank you.", "WHISPER", nil, sender)
				end
			end
			if not LazyRaider_ShareQuestsTwo and string.find(lowerMsg, "share") ~= nil then
				QuestLogPushQuest(LazyRaider_QuestLineOne)
			elseif LazyRaider_ShareQuestsTwo and (string.find(lowerMsg, "share1") ~= nil or string.find(lowerMsg, "share 1") ~= nil or string.find(lowerMsg, "1") ~= nil) and (string.find(lowerMsg, "share2") ~= nil or string.find(lowerMsg, "share 2") ~= nil or string.find(lowerMsg, "2") ~= nil) then
				QuestLogPushQuest(LazyRaider_QuestLineOne)
				LazyRaider_ShareTrain = sender			
			elseif LazyRaider_ShareQuestsTwo and (string.find(lowerMsg, "share1") ~= nil or string.find(lowerMsg, "share 1") ~= nil) then
				QuestLogPushQuest(LazyRaider_QuestLineOne)
			elseif LazyRaider_ShareQuestsTwo and (string.find(lowerMsg, "share2") ~= nil or string.find(lowerMsg, "share 2") ~= nil) then
				QuestLogPushQuest(LazyRaider_QuestLineTwo)
			end			
		end
	end
	
end

function LR_SecondsToClock(seconds)
	local seconds = tonumber(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		if hours == "00" then
			return mins..":"..secs
		else
			return hours..":"..mins..":"..secs	
		end
	end
end

function LazyRaider_OnUpdate(self, elapsed)
	
	LazyRaider_LastAnnounce = LazyRaider_LastAnnounce + elapsed
	LazyRaider_NinjaAnnounce = LazyRaider_NinjaAnnounce + elapsed
	
	if LazyRaider_NinjaRecruit and LazyRaider_NinjaAnnounce >= LazyRaider_NinjaInterval then
			
		if LazyRaider_NinjaType == "Wintergrasp" then
			
			LazyRaider_WgBattleTimer = GetWintergraspWaitTime()
			local zone = GetZoneText()
			if zone == "Wintergrasp" then
				local numUI = GetNumWorldStateUI()
				for i = 1, numUI do
					local qaz, wsx, edc, rfv, tgb, yhn = GetWorldStateUIInfo(i)
					if wsx == 1 and i == 3 then 
						LazyRaider_WgBattleTooltips = "Horde "..edc..", "
					elseif wsx == 1 and i == 4 then 
						LazyRaider_WgBattleTooltips = LazyRaider_WgBattleTooltips.."Allince "..edc..", "					
					elseif wsx == 1 and i == 7 then
						LazyRaider_WgBattleTooltips = LazyRaider_WgBattleTooltips..edc
					end
				end
			else
				LazyRaider_WgBattleTooltips = false
			end	
			
			if LazyRaider_WgBattleTimer == nil then
				LazyRaider_NinjaInterval = 110
				SendChatMessage(LazyRaider_WgBattleTooltips and "\124cffffff00\124Hachievement:2776:"..UnitGUID("player")..":0:0:0:0:0:0:0:0\124h[Wintergrasp]\124h\124r started["..LazyRaider_WgBattleTooltips.."] "..LazyRaider_NinjaMessage or "\124cffffff00\124Hachievement:2776:"..UnitGUID("player")..":0:0:0:0:0:0:0:0\124h[Wintergrasp]\124h\124r is in progress! "..LazyRaider_NinjaMessage, LazyRaider_NinjaChannel, nil, LazyRaider_NinjaId)
			elseif LazyRaider_WgBattleTimer < 2400 then
				LazyRaider_NinjaInterval = 195
				SendChatMessage("\124cffffff00\124Hachievement:2776:"..UnitGUID("player")..":0:0:0:0:0:0:0:0\124h[Wintergrasp]\124h\124r[Next Battle: "..SecondsToTime(LazyRaider_WgBattleTimer).."] "..LazyRaider_NinjaMessage, LazyRaider_NinjaChannel, nil, LazyRaider_NinjaId)
			elseif LazyRaider_WgBattleTimer >= 2400 then
				LazyRaider_NinjaInterval = 1500
				SendChatMessage("\124cffffff00\124Hachievement:2776:"..UnitGUID("player")..":0:0:0:0:0:0:0:0\124h[Wintergrasp]\124h\124r[Next Battle: "..SecondsToTime(LazyRaider_WgBattleTimer).."] "..LazyRaider_NinjaMessage, LazyRaider_NinjaChannel, nil, LazyRaider_NinjaId)		
			end
			LazyRaider_NinjaAnnounce = 0	
		end
	
	end
	
	if (LazyRaider_AutoRecruit and LazyRaider_LastAnnounce >= LazyRaider_Interval) then
		
		if (LazyRaider_RecruitType == "Group(d5)") then
			local memberCount, _, classCount = LazyRaider_GetGroupMembers()
			local _, _, _, numTanks, numHealers, numDps = LazyRaider_GetRoles()		
			LazyRaider_Message = LazyRaider_DungeonName .. "."
			if (numTanks < LazyRaider_RequiredTanks) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredTanks - numTanks) .. LazyRaider_Trigraph((LazyRaider_RequiredTanks - numTanks) > 1, " Tanks", " Tank")
			end
			if (numHealers < LazyRaider_RequiredHealers) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredHealers - numHealers) .. LazyRaider_Trigraph((LazyRaider_RequiredHealers - numHealers) > 1, " Healers", " Healer")
			end
			if (numDps < LazyRaider_RequiredDps) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredDps - numDps) .. " DPS"
			end	
			LazyRaider_Message = "LF"..(5-memberCount).."M "..LazyRaider_Message..". Send whisper with your role!"
			SendChatMessage("" .. LazyRaider_Message, LazyRaider_Channel, nil, LazyRaider_ChannelId)
			LazyRaider_LastAnnounce = 0
		elseif (LazyRaider_RecruitType == "Group(d10)") then
			local memberCount, _, classCount = LazyRaider_GetGroupMembers()
			local _, _, _, numTanks, numHealers, numDps = LazyRaider_GetRoles()		
			LazyRaider_Message = LazyRaider_DungeonName .. "."
			if (numTanks < LazyRaider_RequiredTanks) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredTanks - numTanks) .. LazyRaider_Trigraph((LazyRaider_RequiredTanks - numTanks) > 1, " Tanks", " Tank")
			end
			if (numHealers < LazyRaider_RequiredHealers) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredHealers - numHealers) .. LazyRaider_Trigraph((LazyRaider_RequiredHealers - numHealers) > 1, " Healers", " Healer")
			end
			if (numDps < LazyRaider_RequiredDps) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredDps - numDps) .. " DPS"
			end	
			LazyRaider_Message = "LF"..(10-memberCount).."M "..LazyRaider_Message..". Send whisper with your role!"
			SendChatMessage("" .. LazyRaider_Message, LazyRaider_Channel, nil, LazyRaider_ChannelId)
			LazyRaider_LastAnnounce = 0
		elseif (LazyRaider_RecruitType == "Group(d25)") then
			local memberCount, _, classCount = LazyRaider_GetGroupMembers()
			local _, _, _, numTanks, numHealers, numDps = LazyRaider_GetRoles()		
			LazyRaider_Message = LazyRaider_DungeonName .. "."
			if (numTanks < LazyRaider_RequiredTanks) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredTanks - numTanks) .. LazyRaider_Trigraph((LazyRaider_RequiredTanks - numTanks) > 1, " Tanks", " Tank")
			end
			if (numHealers < LazyRaider_RequiredHealers) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredHealers - numHealers) .. LazyRaider_Trigraph((LazyRaider_RequiredHealers - numHealers) > 1, " Healers", " Healer")
			end
			if (numDps < LazyRaider_RequiredDps) then
				LazyRaider_Message = LazyRaider_Message .. " " .. (LazyRaider_RequiredDps - numDps) .. " DPS"
			end	
			LazyRaider_Message = "LF"..(25-memberCount).."M "..LazyRaider_Message..". Send whisper with your role!"
			SendChatMessage("" .. LazyRaider_Message, LazyRaider_Channel, nil, LazyRaider_ChannelId)
			LazyRaider_LastAnnounce = 0			
		elseif (LazyRaider_RecruitType == "Custom") or (LazyRaider_RecruitType == "Share") then
			SendChatMessage(LazyRaider_DungeonName, LazyRaider_Channel, nil, LazyRaider_ChannelId)
			LazyRaider_LastAnnounce = 0	
		end
	end
	
end

function LazyRaider_OnMembersChanged(self, ...)
	
	if (string.find(LazyRaider_RecruitType, "d5") ~= nil) then
		local memberCount, _, _ = LazyRaider_GetGroupMembers()
		if (memberCount == 5 and LazyRaider_AutoRecruit) then
			
			LazyRaider_AutoRecruit = false
			LazyRaider_RequiredAchievement = nil
			
			LazyRaider_ShowRoles()
			
		end
	elseif (string.find(LazyRaider_RecruitType, "d10") ~= nil) then
		local memberCount, _, _ = LazyRaider_GetGroupMembers()
		if (memberCount >= 2 and GetNumRaidMembers() == 0) then
			ConvertToRaid()
			SetRaidDifficulty(1)
		end
		if (memberCount == 10 and LazyRaider_AutoRecruit) then
			
			LazyRaider_AutoRecruit = false
			LazyRaider_RequiredAchievement = nil
			
			LazyRaider_ShowRoles()
			
		end
	elseif (string.find(LazyRaider_RecruitType, "d25") ~= nil) then
		local memberCount, _, _ = LazyRaider_GetGroupMembers()
		if (memberCount >= 2 and GetNumRaidMembers() == 0) then
			ConvertToRaid()
			SetRaidDifficulty(2)
		end
		if (memberCount == 25 and LazyRaider_AutoRecruit) then
			
			LazyRaider_AutoRecruit = false
			LazyRaider_RecruitType = "None"
			
			LazyRaider_ShowRoles()
			
		end
	end

	if LazyRaider_ShareQuestsOne then 
		local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
		for ia = 1, nameCount do
			if nameArray[ia] ~= UnitName("player") then
				for ib = #LazyRaider_ShareTabOne, 1, -1 do
					if nameArray[ia] == LazyRaider_ShareTabOne[ib] then
						LazyRaider_SharePushOne = true
						table.remove(LazyRaider_ShareTabOne, ib)
					end
				end
				for ib = #LazyRaider_ShareTabTwo, 1, -1 do	
					if nameArray[ia] == LazyRaider_ShareTabTwo[ib] then
						LazyRaider_SharePushTwo = true
						table.remove(LazyRaider_ShareTabTwo, ib)
					end
				end
				if LazyRaider_BotMessage then		
					if (LazyRaider_ShareFalse) or (not LazyRaider_ShareFalse and LazyRaider_SharePushOne or LazyRaider_SharePushTwo) then 
						SendChatMessage("This is Lazy Raider addon. All messages are automatic." , PARTY)
					end
					if LazyRaider_ShareFalse then
						SendChatMessage((not LazyRaider_ShareQuestsTwo and "-- You don't get any quest until whisper SHARE to me") or (LazyRaider_ShareQuestsTwo and "-- You don't get any quest until whisper SHARE1 or SHARE2 to me.") , PARTY)
						LazyRaider_ShareFalse = false
					elseif not LazyRaider_ShareFalse and (LazyRaider_SharePushOne or LazyRaider_SharePushTwo) then
						SendChatMessage((not LazyRaider_ShareQuestsTwo and "-- Didn't got your quest? DON'T LEAVE GROUP, whisper SHARE to me again.") or (LazyRaider_ShareQuestsTwo and "-- Didn't got your quest or wanna get both? DON'T LEAVE GROUP, whisper SHARE1 or SHARE2 to me again.") , PARTY)
					end	
				end					
				if LazyRaider_SharePushOne then 
					QuestLogPushQuest(LazyRaider_QuestLineOne)
					LazyRaider_SharePushOne = false
				elseif LazyRaider_SharePushTwo then
					QuestLogPushQuest(LazyRaider_QuestLineTwo)
					LazyRaider_SharePushTwo = false
				end
			end
		end	
	end

end

function LazyRaider_OnInviteRequest(self, ...)

	local sender, tank, healer, DPS, crossrealm, unknown = ...
	if LazyRaider_ShareQuestsOne and LazyRaider_BotMessage then
		DeclineGroup()
		StaticPopup_Hide("PARTY_INVITE")
		SendChatMessage("Mate, don't need inviting. Only whisper to me.", "WHISPER", nil, sender)
	end
	
end

function LazyRaider_ProcessInviteRequest(name)
	
	local _, _, classCount = LazyRaider_GetGroupMembers()
	if (classCount[LazyRaider_PlayerClass[name]] < LazyRaider_ClassCap) then
		InviteUnit(name)
	else
		SendChatMessage("Sorry, we already got " .. (LazyRaider_ClassCap == 1 and "a " or "too many ") .. LazyRaider_PlayerClass[name] .. (LazyRaider_ClassCap == 1 and "." or "s."), "WHISPER", nil, name)
	end
	
	
end

function LazyRaider_NeedPlayer(class, tank, dps, heal)

	local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
	
	local numTanks, numDps, numHealers = 0, 0, 0
	local possibleTanks, possibleHealers = 4 * LazyRaider_ClassCap, 4 * LazyRaider_ClassCap
	
	local tankClasses = { ["Warrior"] = true, ["Death Knight"] = true, ["Paladin"] = true, ["Druid"] = true }
	local healerClasses = { ["Priest"] = true, ["Shaman"] = true, ["Paladin"] = true, ["Druid"] = true }
	
	if (nameCount >= 1) then
		
		for i = 1, nameCount do
			if (tankClasses[LazyRaider_PlayerClass[nameArray[i]]]) then
				possibleTanks = possibleTanks - 1
			end
			if (healerClasses[LazyRaider_PlayerClass[nameArray[i]]]) then
				possibleHealers = possibleHealers - 1
			end
			
			if (numTanks < LazyRaider_RequiredTanks and LazyRaider_PlayerRole[nameArray[i]].tank) then
				numTanks = numTanks + 1
			elseif (numHealers < LazyRaider_RequiredHealers and LazyRaider_PlayerRole[nameArray[i]].heal) then
				numHealers = numHealers + 1
			elseif (numDps < LazyRaider_RequiredDps and LazyRaider_PlayerRole[nameArray[i]].dps) then
				numDps = numDps + 1
			end
		end
		
		if (numTanks < LazyRaider_RequiredTanks and tank and tankClasses[class] and LazyRaider_Trigraph(healerClasses[class], possibleHealers - 1 + numHealers >= LazyRaider_RequiredHealers, true)) then
			return true
		end
		if (numDps < LazyRaider_RequiredDps and dps and LazyRaider_Trigraph(healerClasses[class], possibleHealers - 1 + numHealers >= LazyRaider_RequiredHealers, true) and LazyRaider_Trigraph(tankClasses[class], possibleTanks - 1 + numTanks >= LazyRaider_RequiredTanks, true)) then
			return true
		end
		if (numHealers < LazyRaider_RequiredHealers and heal and healerClasses[class] and LazyRaider_Trigraph(tankClasses[class], possibleTanks - 1 + numTanks >= LazyRaider_RequiredTanks, true)) then
			return true
		end

	end
	
	return false

end

function LazyRaider_Trigraph(condition, iftrue, iffalse)
	if condition then
		return iftrue
	else
		return iffalse
	end
end

function LazyRaider_GetRoles()
	
	local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
	local numTanks, numDps, numHealers = 0, 0, 0
	local tanks, healers, dpsers = { }, { }, { }
	
	local tankClasses = { ["Warrior"] = true, ["Death Knight"] = true, ["Paladin"] = true, ["Druid"] = true }
	local healerClasses = { ["Priest"] = true, ["Shaman"] = true, ["Paladin"] = true, ["Druid"] = true }
	
	 for i = 1, nameCount do
		local name = nameArray[i]

		if (LazyRaider_PlayerRole[name].tank and tankClasses[LazyRaider_PlayerClass[name]]) then
			numTanks = numTanks + 1
			tanks[numTanks] = name
		elseif (LazyRaider_PlayerRole[name].heal and healerClasses[LazyRaider_PlayerClass[name]]) then
			numHealers = numHealers + 1
			healers[numHealers] = name 			
		else
			numDps = numDps + 1
			dpsers[numDps] = name
		end
	end	
	return tanks, healers, dpsers, numTanks, numHealers, numDps
end

function LazyRaider_ShowRoles()

	if GetNumRaidMembers() > 0 then
		ChatType = "RAID"
	elseif GetNumPartyMembers() > 0 then
		ChatType = "PARTY"
	else
		ChatType = "SAY"
	end
	
	local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
	local numTanks, numDps, numHealers = 0, 0, 0
	local tanks, healers, dpsers = { }, { }, { }
	
	local tankClasses = { ["Warrior"] = true, ["Death Knight"] = true, ["Paladin"] = true, ["Druid"] = true }
	local healerClasses = { ["Priest"] = true, ["Shaman"] = true, ["Paladin"] = true, ["Druid"] = true }
	
	for i = 1, nameCount do
		local name = nameArray[i]
		if (LazyRaider_PlayerRole[name].tank and tankClasses[LazyRaider_PlayerClass[name]]) then
			numTanks = numTanks + 1
			tanks[numTanks] = name
		elseif (LazyRaider_PlayerRole[name].heal and healerClasses[LazyRaider_PlayerClass[name]]) then
			numHealers = numHealers + 1
			healers[numHealers] = name
		else
			numDps = numDps + 1
			dpsers[numDps] = name
		end
	end
	
	local namesPerLine = 5
	for line = 1, math.floor((numTanks + namesPerLine - 1) / namesPerLine) do
		local message = "Tanks: "
		local index = 1 + (line - 1) * namesPerLine
		local first = true
		for i = index, math.min(numTanks, index + namesPerLine - 1) do
			if (not first) then
				message = message .. ", "
			end
			message = message .. tanks[i]
			first = false
		end
		message = strtrim(message)
		
		SendChatMessage(message, ChatType, nil, nil)
	end
	
	for line = 1, math.floor((numHealers + namesPerLine - 1) / namesPerLine) do
		local message = "Healers: "
		local index = 1 + (line - 1) * namesPerLine
		local first = true
		for i = index, math.min(numHealers, index + namesPerLine - 1) do
			if (not first) then
				message = message .. ", "
			end
			message = message .. healers[i]
			first = false
		end
		message = strtrim(message)
		
		SendChatMessage(message, ChatType, nil, nil)
	end
			
	for line = 1, math.floor((numDps + namesPerLine - 1) / namesPerLine) do
		local message = "DPS: "
		local index = 1 + (line - 1) * namesPerLine
		local first = true
		for i = index, math.min(numDps, index + namesPerLine - 1) do
			if (not first) then
				message = message .. ", "
			end
			message = message .. dpsers[i]
			first = false
		end
		message = strtrim(message)
		
		SendChatMessage(message, ChatType, nil, nil)
	end
end

function LazyRaider_SetGroupRoles()
	
	local _, tank, heal, dps = GetLFGRoles()
	if (tank or heal or dps) then
		local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
		for i = 1, nameCount do
			local nameless = nameArray[i]
			if LazyRaider_PlayerRole[nameless] == nil and nameless ~= UnitName("player") then 
				LazyRaider_PlayerClass[UnitName(nameless)] = UnitClass(nameless)
				LazyRaider_PlayerRole[nameless] = { ["tank"] = tank, ["dps"] = dps, ["heal"] = heal }
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..nameless.."|r got new role DPS")	
			elseif LazyRaider_PlayerRole[nameless] == nil and nameless == UnitName("player") then
				LazyRaider_PlayerClass[UnitName("player")] = UnitClass("player")
				LazyRaider_PlayerRole[UnitName("player")] = { ["tank"] = tank, ["dps"] = dps, ["heal"] = heal }
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff78Player|r role got from Dingeon Finder tool")
			end
		end
		
		return true
	else
		DEFAULT_CHAT_FRAME:AddMessage("You have to select a role in the LFG tool")
		return false
	end	

end

function LazyRaider_ParseRoles(msg)
	return string.find(msg, "tank") ~= nil or string.find(msg, "prot") ~= nil or string.find(msg, "tang") ~= nil,
		string.find(msg, "dps") ~= nil or string.find(msg, "mage") ~= nil or string.find(msg, "arcane") ~= nil or string.find(msg, "fire") ~= nil or string.find(msg, "frost") ~= nil or string.find(msg, "rogue") ~= nil or string.find(msg, "assasin") ~= nil or string.find(msg, "combat") ~= nil or string.find(msg, "sub") ~= nil or string.find(msg, "warlock") ~= nil or string.find(msg, "lock") ~= nil or string.find(msg, "affli") ~= nil or string.find(msg, "demo") ~= nil or string.find(msg, "destro") ~= nil or string.find(msg, "ret") ~= nil or string.find(msg, "retro") ~= nil or string.find(msg, "retri") ~= nil or string.find(msg, "boomkin") ~= nil or string.find(msg, "bala") ~= nil or string.find(msg, "owl") ~= nil or string.find(msg, "fury") ~= nil or string.find(msg, "fwar") ~= nil or string.find(msg, "arms") ~= nil or string.find(msg, "awar") ~= nil or string.find(msg, "enha") ~= nil or string.find(msg, "enhancement") ~= nil or string.find(msg, "elem") ~= nil or string.find(msg, "ele") ~= nil or string.find(msg, "elemental") ~= nil or string.find(msg, "shadow") ~= nil or string.find(msg, "sp") ~= nil or string.find(msg, "spriest") ~= nil or string.find(msg, "hunter") ~= nil or string.find(msg, "hunt") ~= nil or string.find(msg, "bm") ~= nil or string.find(msg, "mm") ~= nil or string.find(msg, "surv") ~= nil or string.find(msg, "unholy") ~= nil or string.find(msg, "enh") ~= nil or string.find(msg, "moonkin") ~= nil or string.find(msg, "boomy") ~= nil, 		
		string.find(msg, "heal") ~= nil or string.find(msg, "rdudu") ~= nil or string.find(msg, "holy") ~= nil or string.find(msg, "hpal") ~= nil or string.find(msg, "resto") ~= nil or string.find(msg, "coh") ~= nil or string.find(msg, "disc") ~= nil or string.find(msg, "tree") ~= nil or string.find(msg, "rsham") ~= nil or string.find(msg, "rdru") ~= nil
end

function LazyRaiderWindow_Recruit_Mod()
	
	for k, v in pairs(LazyRaider_DungeonMod) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = k
		info.arg1 = k			
		info.func = LazyRaiderWindow_Recruit_ModSelect
		UIDropDownMenu_AddButton(info)
	end
	
end

function LazyRaiderWindow_Recruit_ModSelect(self, arg1, arg2, checked)

	if (not checked) then
		UIDropDownMenu_SetSelectedValue(UIDROPDOWNMENU_OPEN_MENU, self.value)
		LazyRaiderWindow_Recruit_ModBuffer = arg1
		LazyRaiderWindow_Recruit_ModButton:SetText(arg1)
	end
	
end

function LazyRaiderWindow_Recruit_Channel()
	
	for k,v in pairs(LazyRaider_ChannelNumeric) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.arg1 = v		
		info.func = LazyRaiderWindow_Recruit_ChannelSelect
		UIDropDownMenu_AddButton(info)
	end
	
	for k,v in pairs(LazyRaider_ChannelAlphabetical) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.arg1 = v		
		info.func = LazyRaiderWindow_Recruit_ChannelSelect
		UIDropDownMenu_AddButton(info)
	end	
	
end

function LazyRaiderWindow_Recruit_ChannelSelect(self, arg1, arg2, checked)

	if (not checked) then
		UIDropDownMenu_SetSelectedValue(UIDROPDOWNMENU_OPEN_MENU, self.value)
		LazyRaiderWindow_Recruit_ChannelBuffer = arg1
		LazyRaiderWindow_Recruit_ChannelButton:SetText(arg1)
	end
	
end

function LazyRaiderWindow_Recruit_Interval()
	
	local intervals = { [1] = "30", [2] = "45", [3] = "60", [4] = "90", [5] = "120", [6] = "180", [7] = "240", [8] = "300", [9] = "450", [10] = "600"}
	for k,v in ipairs(intervals) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.arg1 = v			
		info.func = LazyRaiderWindow_Recruit_IntervalSelect
		UIDropDownMenu_AddButton(info)
	end
	
end

function LazyRaiderWindow_Recruit_IntervalSelect(self, arg1, arg2, checked)

	if (not checked) then
		UIDropDownMenu_SetSelectedValue(UIDROPDOWNMENU_OPEN_MENU, self.value)
		LazyRaiderWindow_Recruit_IntervalBuffer = arg1
		LazyRaiderWindow_Recruit_IntervalButton:SetText(arg1)
	end
	
end

function LazyRaider_ShareQuest_Menu()

	for i = 1, GetNumQuestLogEntries() do 
		local info = UIDropDownMenu_CreateInfo()
		local questTitleOne, questLevelOne, _, _, isHeaderOne, _, _, _, questIDOne = GetQuestLogTitle(i)
		info.text = questTitleOne
		info.arg1 = this:GetName()
		info.value = i
		if isHeaderOne then 
			info.isTitle = true
		end
		info.func = LazyRaider_ShareQuest_MenuSelect
		UIDropDownMenu_AddButton(info)
	end

end

function LazyRaider_ShareQuest_MenuSelect(self, arg1, arg2, checked)

	if (not checked) then
		if arg1 == "LazyRaiderWindow_ShareQuest_FirstButton" then 		
			LazyRaider_SQFBuffer = self.value
			LazyRaider_SetShareQuests(self.value)
		elseif arg1 == "LazyRaiderWindow_ShareQuest_SecondButton" then
			if LazyRaider_ShareQuestsOne == true then
				LazyRaider_SetShareQuests(LazyRaider_QuestLineOne.." "..self.value)
				LazyRaider_SQSBuffer = self.value
			elseif LazyRaider_ShareQuestsOne ~= true then
				DEFAULT_CHAT_FRAME:AddMessage("You should choose first quest for sharing")
			end
		end
	end
	
end

function LazyRaider_ChangeRole_Name()
	
	local nameCount, nameArray, _ = LazyRaider_GetGroupMembers()
	for i = 1, nameCount do
		local info = UIDropDownMenu_CreateInfo()
		info.text = nameArray[i]
		info.arg1 = nameArray[i]
		info.func = LazyRaider_ChangeRole_NameSelect
		UIDropDownMenu_AddButton(info)
	end
	
end

function LazyRaider_ChangeRole_NameSelect(self, arg1, arg2, checked)

	if (not checked) then	
		UIDropDownMenu_SetSelectedValue(UIDROPDOWNMENU_OPEN_MENU, self.value)
		LazyRaider_CRBuffer = arg1
		LazyRaiderWindow_ChangeRole_NameButton:SetText(arg1)
	end
	
end

function LazyRaider_ChangeRole_Role()
	
	local roles = { [1] = "Tank", [2] = "Dps", [3] = "Heal", }
	for k,v in ipairs(roles) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.arg1 = v
		info.func = LazyRaider_ChangeRole_RoleSelect
		UIDropDownMenu_AddButton(info)
	end
	
end

function LazyRaider_ChangeRole_RoleSelect(self, arg1, arg2, checked)

		if LazyRaider_CRBuffer then		
			LazyRaider_ChangeRole(LazyRaider_CRBuffer.." "..arg1)
		else 
			DEFAULT_CHAT_FRAME:AddMessage("You should choose name")
		end
	
end