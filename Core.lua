LaFratellanza = CreateFrame("Frame")
LaFratellanza_main_button = CreateFrame("Button", "LaFratellanzaInitialButton", UIParent, "UIPanelButtonTemplate")

LaFratellanza_main_button:SetPoint("LEFT", 0, 0)
LaFratellanza_main_button:SetSize(100, 30)
LaFratellanza_main_button:SetText("La Fratellanza")
LaFratellanza_main_button:SetMovable(true)
LaFratellanza_main_button:RegisterForDrag("LeftButton")
LaFratellanza_main_button:SetScript("OnDragStart", LaFratellanza_main_button.StartMoving)
LaFratellanza_main_button:SetScript("OnDragStop", LaFratellanza_main_button.StopMovingOrSizing)

local playerName = UnitName("player")

-- throttle per evitare troppe chiamate a GUILD_ROSTER_UPDATE
local lastRosterAt = 0
local THROTTLE = 0.20

-- stato base
LaFratellanza_section = "online"
LaFratellanza_spec_filter = "All specs"
LaFratellanza_prof_filter = "All professions"
LaFratellanza_is_first_open = true
LaFratellanza_rosterInProgress = false
LaFratellanza_guild_roster = { online = {}, offline = {} }

function LaFratellanza_CloseMainFrame()
	LaFratellanza_ShowMembersFrame()
	_G["LaFratellanza_Main_Frame"]:Hide()

	-- quando chiudo riporto il client a non mostrare gli offline nella UI di gilda
	SetCVar("guildShowOffline", 0)

	LaFratellanza_guild_roster = { online = {}, offline = {} }
end

function LaFratellanza_ShowMainFrame()
	local f = _G["LaFratellanza_Main_Frame"]
	f:Show()

	LaFratellanza_navBar_current_button = "membri"
	LaFratellanza_ShowMembersFrame()

	SetCVar("guildShowOffline", 1)

	if not LaFratellanza_rosterInProgress then
		LaFratellanza_RosterBuild()
	end

	LaFratellanza_RefreshMembers()
end

function LaFratellanza_MainFrameToggle()
	if _G["LaFratellanza_Main_Frame"]:IsShown() then
		LaFratellanza_CloseMainFrame()
	else
		LaFratellanza_ShowMainFrame()
	end
end

function LaFratellanza_MenuButton_OnClick(self)
	local buttonName = self:GetName()
	if buttonName == "LaFratellanza_Button1" then
		LaFratellanza_navBar_current_button = "membri"
		LaFratellanza_ShowMembersFrame()
	elseif buttonName == "LaFratellanza_Button2" then
		LaFratellanza_navBar_current_button = "regolamento"
		LaFratellanza_ShowRulesFrame()
	end
end

LaFratellanza_main_button:SetScript("OnClick", function()
	LaFratellanza_MainFrameToggle()
end)

LaFratellanza:RegisterEvent("GUILD_ROSTER_UPDATE")
LaFratellanza:RegisterEvent("CHAT_MSG_ADDON")
LaFratellanza:RegisterEvent("PLAYER_LOGOUT")
LaFratellanza:RegisterEvent("PLAYER_LOGIN")

-- Mostra i messaggi delle professioni direttamente nella chat principale
local function LF_AddToDefaultChat(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 0.75, 1.0)
end

LaFratellanza:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
	if event == "PLAYER_LOGIN" then
		if LaFratellanza_channel and type(LaFratellanza_channel) == "string" then
			pcall(RegisterAddonMessagePrefix, LaFratellanza_channel)
		end

		LaFratellanza_main_frame = _G["LaFratellanza_Main_Frame"]
		LaFratellanza_members_frame = _G["LaFratellanza_Main_Frame_Members"]

		LaFratellanza_InitNoteFrame()
		LaFratellanza_RefreshMembers()
		LaFratellanza_RulesFrameInit()
		LaFratellanza_RosterBuild()
		GuildRoster()
	elseif event == "PLAYER_LOGOUT" then
		SetCVar("guildShowOffline", 0)
	elseif event == "CHAT_MSG_ADDON" and prefix == LaFratellanza_channel then
		local msgType = string.sub(message or "", 1, 3)
		local payload = string.sub(message or "", 5) or ""

		if msgType == "Req" then
			-- qualcuno ha richiesto il link della professione "payload"
			local _, link = GetSpellLink(payload)
			local toSend = "Res:"
				.. "|cff00A2FF ------| "
				.. playerName
				.. ":|r "
				.. (link or (GetSpellInfo(payload) or payload))
				.. "|cff00A2FF |------ |r"
			SendAddonMessage(LaFratellanza_channel, toSend, "WHISPER", sender)
		elseif msgType == "Res" then
			-- visualizza direttamente in chat normale
			LF_AddToDefaultChat(payload)
		end
	elseif event == "GUILD_ROSTER_UPDATE" then
		-- throttle + guard
		local mf = _G["LaFratellanza_Main_Frame"]
		if mf and mf:IsShown() then
			local now = GetTime()
			if not LaFratellanza_rosterInProgress and (now - lastRosterAt) > THROTTLE then
				lastRosterAt = now
				LaFratellanza_RosterBuild()
			end
		end
	end
end)

tinsert(UISpecialFrames, "LaFratellanza_Main_Frame")
