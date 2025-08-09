local listLength = 0
local scrollFrame
local slider
local scrollChild
local previousSelection = "Online"
local previousSpecFilter = "All specs"
local previousProfessionFilter = "All professions"
local previousKeySort = ""
local direction = "ASC"
local currentKeySort = ""
local playerName = UnitName("player")
local playerRank = ""

-- cache dei 13 row e sotto-widget
local rows = {}
-- ultimo offset usato dallo scroll (per evitare update inutili)
local lastOffset = -1

local function lc(s)
	return s and s:lower() or ""
end
local function uc(s)
	return s and s:upper() or ""
end
local function trim(s)
	return (s and s:match("^%s*(.-)%s*$")) or ""
end

function LaFratellanza_SplitString(inputString)
	local words = {}
	for word in string.gmatch(inputString or "", "[^%s/-]+") do
		table.insert(words, lc(word))
	end
	return words
end

function LaFratellanza_RefreshMembers()
	SetCVar("guildShowOffline", 1)
	GuildRoster()
end

function LaFratellanza_DecodeNote(elements, result, name)
	local indexProf = 1
	local indexSpec = 1

	for _, element in ipairs(elements) do
		if element == "main" then
			result.isAlt = false
		elseif element == "alt" then
			result.isAlt = true
		else
			if LaFratellanza_prof_table[element] ~= nil then
				if indexProf == 1 then
					result["prof"].main = LaFratellanza_prof_table[element]
					indexProf = 2
				elseif indexProf == 2 then
					result["prof"].off = LaFratellanza_prof_table[element]
				end
			elseif LaFratellanza_spec_table[element] ~= nil then
				if indexSpec == 1 then
					result["spec"].main = LaFratellanza_spec_table[element]
					indexSpec = 2
				elseif indexSpec == 2 then
					result["spec"].off = LaFratellanza_spec_table[element]
				end
			elseif LaFratellanza_guild_roster_names[element] then
				result.altOf = LaFratellanza_guild_roster_names[element]
			end
		end
	end
end

function LaFratellanza_GetMemberProps(idx, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class)
	local result = {
		idx = idx,
		name = name,
		lvl = lvl,
		cl = cl,
		zone = zone or "",
		note = note or "",
		offNote = offNote or "",
		online = online,
		status = status,
		class = class,
		rank = lc(trim(rank or "")),
		rankIndex = rankIndex,
		prof = {},
		spec = {},
		isAlt = false,
		altOf = "",
	}

	-- coerenza ALT
	if lc(trim(rank or "")) == "alt" then
		result.isAlt = true
	end

	local elements = LaFratellanza_SplitString(note or "")
	LaFratellanza_DecodeNote(elements, result, name)
	return result
end

-- ===== NOTE FRAME =====

function LaFratellanza_InitNoteFrame()
	LaFratellanza_note_frame = CreateFrame("Frame", "LaFratellanza_Note_Frame", LaFratellanza_main_frame)
	LaFratellanza_note_frame:SetSize(256, 256)
	LaFratellanza_note_frame:SetPoint("LEFT", LaFratellanza_main_frame, "BOTTOMRIGHT", -15, 160)
	LaFratellanza_note_frame:SetBackdrop({
		bgFile = "Interface\\AddOns\\LaFratellanza\\texture\\frames\\finestra-laterale.tga",
		tile = false,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	LaFratellanza_note_frame:SetFrameLevel(LaFratellanza_main_frame:GetFrameLevel() - 1)

	LaFratellanza_note_frame_title = LaFratellanza_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	LaFratellanza_note_frame_title:SetPoint("TOPLEFT", LaFratellanza_note_frame, "TOPLEFT", 30, -30)
	LaFratellanza_note_frame_title:SetText("")

	local personalNotesLabel = LaFratellanza_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	personalNotesLabel:SetPoint("TOPLEFT", LaFratellanza_note_frame_title, "BOTTOMLEFT", 0, -15)
	personalNotesLabel:SetText("Note personali: ")

	LaFratellanza_note_frame_personal_note =
		CreateFrame("EditBox", "LaFratellanza_EditBox_Personal", LaFratellanza_note_frame)
	LaFratellanza_note_frame_personal_note:SetMultiLine(true)
	LaFratellanza_note_frame_personal_note:SetFontObject(GameFontNormal)
	LaFratellanza_note_frame_personal_note:SetWidth(200)
	LaFratellanza_note_frame_personal_note:SetPoint("TOPLEFT", personalNotesLabel, "BOTTOMLEFT", 0, -3)
	LaFratellanza_note_frame_personal_note:SetText("")
	LaFratellanza_note_frame_personal_note:HighlightText()
	LaFratellanza_note_frame_personal_note:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	LaFratellanza_note_frame_personal_note:SetTextInsets(8, 8, 8, 8)
	LaFratellanza_note_frame_personal_note:SetMaxLetters(40)

	local officerNotesLabel = LaFratellanza_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	officerNotesLabel:SetPoint("TOPLEFT", LaFratellanza_note_frame_personal_note, "BOTTOMLEFT", 0, -12)
	officerNotesLabel:SetText("Note officer: ")

	LaFratellanza_note_frame_officer_note =
		CreateFrame("EditBox", "LaFratellanza_EditBox_Officer", LaFratellanza_note_frame)
	LaFratellanza_note_frame_officer_note:SetMultiLine(true)
	LaFratellanza_note_frame_officer_note:SetFontObject(GameFontNormal)
	LaFratellanza_note_frame_officer_note:SetWidth(200)
	LaFratellanza_note_frame_officer_note:SetPoint("TOPLEFT", officerNotesLabel, "BOTTOMLEFT", 0, -3)
	LaFratellanza_note_frame_officer_note:SetText("")
	LaFratellanza_note_frame_officer_note:HighlightText()
	LaFratellanza_note_frame_officer_note:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	LaFratellanza_note_frame_officer_note:SetTextInsets(8, 8, 8, 8)
	LaFratellanza_note_frame_officer_note:SetMaxLetters(40)

	local closeButton =
		CreateFrame("Button", "LaFratellanza_Note_CloseButton", LaFratellanza_note_frame, "UIPanelButtonTemplate")
	closeButton:SetSize(80, 25)
	closeButton:SetText("Chiudi")
	closeButton:SetPoint("BOTTOMLEFT", LaFratellanza_note_frame, "BOTTOMLEFT", 30, 25)
	closeButton:SetScript("OnClick", function()
		LaFratellanza_note_frame_title:SetText("")
		LaFratellanza_note_frame_personal_note:SetText("")
		LaFratellanza_note_frame_officer_note:SetText("")
		LaFratellanza_note_frame:Hide()
	end)

	LaFratellanza_note_frame_save =
		CreateFrame("Button", "LaFratellanza_Note_SaveButton", LaFratellanza_note_frame, "UIPanelButtonTemplate")
	LaFratellanza_note_frame_save:SetSize(80, 25)
	LaFratellanza_note_frame_save:SetText("Salva")
	LaFratellanza_note_frame_save:SetPoint("LEFT", closeButton, "RIGHT", 10, 0)

	LaFratellanza_note_frame:Hide()
end

function LaFratellanza_OpenEditNote(name, idx, note)
	LaFratellanza_note_frame:Show()
	LaFratellanza_note_frame_title:SetText(uc(name or ""))

	if (note or ""):match("^(.-)\n\n(.+)$") then
		local personal, officer = note:match("^(.-)\n\n(.+)$")
		LaFratellanza_note_frame_personal_note:SetText(personal or "")
		-- "Officer Note: "
		LaFratellanza_note_frame_officer_note:SetText(officer and string.sub(officer, 14) or "")
	else
		LaFratellanza_note_frame_personal_note:SetText(note or "")
		LaFratellanza_note_frame_officer_note:SetText("")
	end

	LaFratellanza_note_frame_save:SetScript("OnClick", function()
		local personalNotes = LaFratellanza_note_frame_personal_note:GetText()
		local officerNotes = LaFratellanza_note_frame_officer_note:GetText()
		GuildRosterSetPublicNote(idx, personalNotes or "")
		GuildRosterSetOfficerNote(idx, officerNotes or "")
		LaFratellanza_note_frame_title:SetText("")
		LaFratellanza_note_frame_personal_note:SetText("")
		LaFratellanza_note_frame_officer_note:SetText("")
		LaFratellanza_note_frame:Hide()
		LaFratellanza_RefreshMembers()
	end)
end

-- ===== LISTA MEMBRI =====
local function Row_SetTextColor(row, r, g, b)
	row.nameText:SetTextColor(r, g, b)
	row.lvlText:SetTextColor(r, g, b)
	row.zoneText:SetTextColor(r, g, b)
end

function LaFratellanza_ClearMemberRow()
	for idx = 1, 13 do
		local row = rows[idx]
		if row then
			row.classIcon:SetTexture(nil)
			row.nameText:SetText("")
			row.lvlText:SetText("")
			row.mainSpec:SetTexture(nil)
			row.offSpec:SetTexture(nil)
			row.mainProf:SetTexture(nil)
			row.offProf:SetTexture(nil)
			row.zoneText:SetText("")
			row.mainText:SetText("")
			row.rankTex:SetTexture(nil)
			row.noteBtn:Hide()
			row.inviteBtn:Hide()
			row.whisperBtn:Hide()
			row._rowIndex = nil
		end
	end
end

-- handler UNICI (si appoggiano su row._rowIndex)
local function OnInviteClick(self)
	local i = self:GetParent()._rowIndex
	local m = i and LaFratellanza_guild_roster_filtered[i]
	if m and m.name then
		InviteUnit(m.name)
	end
end

local function OnWhisperClick(self)
	local i = self:GetParent()._rowIndex
	local m = i and LaFratellanza_guild_roster_filtered[i]
	if m and m.name then
		ChatFrame_SendTell(m.name)
	end
end

local function OnMainProfClick(self)
	local i = self:GetParent()._rowIndex
	local m = i and LaFratellanza_guild_roster_filtered[i]
	if m and m.prof and m.prof.main and m.name and LaFratellanza_channel then
		SendAddonMessage(LaFratellanza_channel, "Req:" .. m.prof.main, "WHISPER", m.name)
	end
end

local function OnOffProfClick(self)
	local i = self:GetParent()._rowIndex
	local m = i and LaFratellanza_guild_roster_filtered[i]
	if m and m.prof and m.prof.off and m.name and LaFratellanza_channel then
		SendAddonMessage(LaFratellanza_channel, "Req:" .. m.prof.off, "WHISPER", m.name)
	end
end

local function OnNoteEnter(self)
	local i = self:GetParent()._rowIndex
	local m = i and LaFratellanza_guild_roster_filtered[i]
	if not m then
		return
	end
	local textNote = m.note or ""
	if (m.offNote or "") ~= "" then
		textNote = textNote .. "\n\nOfficer Note: " .. m.offNote
	end
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetWidth(400)
	GameTooltip:SetText(textNote, 1, 1, 1, true)
	GameTooltip:Show()
end

local function OnNoteLeave()
	GameTooltip:Hide()
end

local function OnNoteClick(self)
	local i = self:GetParent()._rowIndex
	local m = i and LaFratellanza_guild_roster_filtered[i]
	if not m then
		return
	end
	if
		(playerRank == "guild master") or (LaFratellanza_Rank_Edit_Note and LaFratellanza_Rank_Edit_Note[playerRank])
	then
		local textNote = m.note or ""
		if (m.offNote or "") ~= "" then
			textNote = textNote .. "\n\nOfficer Note: " .. m.offNote
		end
		LaFratellanza_OpenEditNote(m.name, m.idx, textNote)
	end
end

function LaFratellanza_MemberListUpdate(index)
	LaFratellanza_ClearMemberRow()

	local total = #LaFratellanza_guild_roster_filtered
	local cycle = total - index
	if cycle > 13 then
		cycle = 13
	end
	if cycle < 0 then
		cycle = 0
	end

	for idx = 1, cycle do
		local memberFrame = _G["LaFratellanza_Member" .. idx]
		local row = rows[idx]
		local m = LaFratellanza_guild_roster_filtered[idx + index]
		if not m then
			break
		end

		memberFrame._rowIndex = idx + index
		row._rowIndex = memberFrame._rowIndex

		-- alpha + colori
		if LaFratellanza_section == "offline" then
			memberFrame:SetAlpha(0.6)
			Row_SetTextColor(row, 0.5, 0.5, 0.5)
		else
			memberFrame:SetAlpha(1)
			Row_SetTextColor(row, 0.9, 0.9, 0.9)
		end

		-- class icon (easter egg Cipollino)
		if m.name == "Cipollino" then
			row.classIcon:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\Cipollino]])
		else
			row.classIcon:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. (m.class or ""))
		end

		row.nameText:SetText(m.name or "")
		row.lvlText:SetText(m.lvl or "")

		if m.spec and m.spec.main then
			row.mainSpec:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. m.spec.main .. (m.class or ""))
		else
			row.mainSpec:SetTexture(nil)
		end
		if m.spec and m.spec.off then
			row.offSpec:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. m.spec.off .. (m.class or ""))
		else
			row.offSpec:SetTexture(nil)
		end

		if m.prof and m.prof.main then
			row.mainProf:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. m.prof.main)
			row.mainProfBtn:Show()
		else
			row.mainProf:SetTexture(nil)
			row.mainProfBtn:Hide()
		end

		if m.prof and m.prof.off then
			row.offProf:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. m.prof.off)
			row.offProfBtn:Show()
		else
			row.offProf:SetTexture(nil)
			row.offProfBtn:Hide()
		end

		local zoneText = m.zone or ""
		if string.len(zoneText) > 21 then
			zoneText = string.sub(zoneText, 1, 21) .. "..."
		end
		row.zoneText:SetText(zoneText)

		if LaFratellanza_section == "offline" then
			row.inviteBtn:Hide()
			row.whisperBtn:Hide()
		else
			row.inviteBtn:Show()
			row.whisperBtn:Show()
		end

		-- rank texture
		row.rankTex:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\rank_]] .. tostring(m.rankIndex or ""))

		if m.altOf and m.altOf ~= "" then
			row.mainText:SetText(m.altOf)
			row.mainText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
			row.mainText:SetTextColor(0.7, 0.7, 0.7)
		else
			row.mainText:SetText("")
		end

		row.noteBtn:Show()
	end
end

function LaFratellanza_MemberListInit()
	for idx = 1, 13 do
		local item = CreateFrame(
			"Frame",
			"LaFratellanza_Member" .. idx,
			LaFratellanza_members_frame,
			"LaFratellanza_Member_Template"
		)
		if idx == 1 then
			item:SetPoint("TOP", 0, -60)
		else
			item:SetPoint("TOP", _G["LaFratellanza_Member" .. (idx - 1)], "BOTTOM", 0, 0)
		end

		-- costruisco la cache dei widget
		rows[idx] = {
			frame = item,
			classIcon = _G[item:GetName() .. "_ClassIcon_Texture"],
			nameText = _G[item:GetName() .. "_Name_Text"],
			lvlText = _G[item:GetName() .. "_Level_Text"],
			mainSpec = _G[item:GetName() .. "_MainSpec_Texture"],
			offSpec = _G[item:GetName() .. "_OffSpec_Texture"],
			mainProf = _G[item:GetName() .. "_MainProf_Texture"],
			offProf = _G[item:GetName() .. "_OffProf_Texture"],
			zoneText = _G[item:GetName() .. "_Zone_Text"],
			inviteBtn = _G[item:GetName() .. "_Invite"],
			whisperBtn = _G[item:GetName() .. "_Whisper"],
			rankTex = _G[item:GetName() .. "_Rank_Texture"],
			mainText = _G[item:GetName() .. "_Main_Text"],
			noteBtn = _G[item:GetName() .. "_Note"],
			mainProfBtn = _G[item:GetName() .. "_MainProf"],
			offProfBtn = _G[item:GetName() .. "_OffProf"],
			_rowIndex = nil,
		}

		-- bind handler UNA VOLTA
		rows[idx].inviteBtn:SetScript("OnClick", OnInviteClick)
		rows[idx].whisperBtn:SetScript("OnClick", OnWhisperClick)
		rows[idx].mainProfBtn:SetScript("OnClick", OnMainProfClick)
		rows[idx].offProfBtn:SetScript("OnClick", OnOffProfClick)
		rows[idx].noteBtn:SetScript("OnEnter", OnNoteEnter)
		rows[idx].noteBtn:SetScript("OnLeave", OnNoteLeave)
		rows[idx].noteBtn:SetScript("OnClick", OnNoteClick)
	end

	LaFratellanza_is_first_open = false
	LaFratellanza_MemberListUpdate(0)
end

function LaFratellanza_MembersScrollBarInit()
	scrollFrame = CreateFrame(
		"ScrollFrame",
		"LaFratellanza_Main_Frame_Members_ScrollFrame",
		LaFratellanza_members_frame,
		"UIPanelScrollFrameTemplate"
	)
	slider = CreateFrame("Slider", "LaFratellanza_Main_Frame_Members_Slider", scrollFrame, "OptionsSliderTemplate")
	scrollChild = CreateFrame("Frame", "LaFratellanza_Main_Frame_Members_ScrollChild", scrollFrame)

	LaFratellanza_members_frame.scrollFrame = scrollFrame
	LaFratellanza_members_frame.slider = slider

	scrollFrame:SetPoint("CENTER", LaFratellanza_members_frame, "CENTER", 0, -10)
	scrollFrame:SetSize(768, 430)
	scrollFrame:EnableMouseWheel(true)

	slider:SetSize(25, 445)
	slider:SetPoint("LEFT", LaFratellanza_members_frame, "RIGHT", 0, -10)
	slider:SetBackdrop({
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeSize = 8,
		insets = { left = 3, right = 3, top = 6, bottom = 6 },
	})
	_G[slider:GetName() .. "Low"]:SetText("")
	_G[slider:GetName() .. "High"]:SetText("")
end

function LaFratellanza_MembersScrollBarUpdate()
	local minValue = 1
	local addValue = 0
	if listLength > 13 and (listLength - 13) % 5 ~= 0 then
		addValue = (5 - ((listLength - 13) % 5)) * 32
	end
	local maxValue = (listLength * 32) + addValue
	scrollChild:SetSize(665, maxValue)
	scrollChild:SetPoint("RIGHT", LaFratellanza_members_frame, "LEFT", 0, 0)
	scrollFrame:SetScrollChild(scrollChild)

	local stepSize = 5 * 32
	scrollFrame:SetScript("OnVerticalScroll", function(self, value)
		local newValue = math.floor(value / stepSize + 0.5) * stepSize
		newValue = math.max(0, math.min(maxValue, newValue))
		if newValue ~= lastOffset then
			lastOffset = newValue
			if newValue == 0 then
				LaFratellanza_MemberListUpdate(0)
			else
				LaFratellanza_MemberListUpdate(newValue / 32)
			end
		end
	end)
end

function LaFratellanza_GuildRoster_Filtered()
	LaFratellanza_guild_roster_filtered = {}

	if (LaFratellanza_prof_filter ~= "All professions") or (LaFratellanza_spec_filter ~= "All specs") then
		for _, member in ipairs(LaFratellanza_guild_roster[LaFratellanza_section] or {}) do
			local passSpec = (LaFratellanza_spec_filter == "All specs")
				or (
					member.spec
					and (member.spec.main == LaFratellanza_spec_filter or member.spec.off == LaFratellanza_spec_filter)
				)
			local passProf = (LaFratellanza_prof_filter == "All professions")
				or (
					member.prof
					and (member.prof.main == LaFratellanza_prof_filter or member.prof.off == LaFratellanza_prof_filter)
				)
			if passSpec and passProf then
				table.insert(LaFratellanza_guild_roster_filtered, member)
			end
		end
	else
		LaFratellanza_guild_roster_filtered = LaFratellanza_guild_roster[LaFratellanza_section] or {}
	end
end

function LaFratellanza_GuildRoster_Sorted()
	if previousKeySort ~= currentKeySort then
		direction = "ASC"
	elseif direction == "ASC" then
		direction = "DESC"
	else
		direction = "ASC"
	end

	table.sort(LaFratellanza_guild_roster_filtered, function(a, b)
		local ka = a[currentKeySort]
		local kb = b[currentKeySort]
		if ka == kb then
			return (a.name or "") < (b.name or "")
		end
		if ka == nil then
			return false
		end
		if kb == nil then
			return true
		end
		if direction == "ASC" then
			return ka < kb
		else
			return ka > kb
		end
	end)

	previousKeySort = currentKeySort
end

function LaFratellanza_MembersFrameInit()
	LaFratellanza_GuildRoster_Filtered()

	if currentKeySort ~= "" then
		LaFratellanza_GuildRoster_Sorted()
	end

	listLength = #LaFratellanza_guild_roster_filtered

	if LaFratellanza_navBar_current_button == "membri" then
		LaFratellanza_ShowMembersFrame()
	end

	if LaFratellanza_is_first_open then
		LaFratellanza_MembersScrollBarInit()
		LaFratellanza_MemberListInit()
	end

	LaFratellanza_MembersScrollBarUpdate()
	lastOffset = -1
	LaFratellanza_MemberListUpdate(0)
end

function LaFratellanza_BuildArrayOfName(maxMembers)
	LaFratellanza_guild_roster_names = {}
	for i = 1, maxMembers do
		local name = GetGuildRosterInfo(i)
		if name ~= nil then
			LaFratellanza_guild_roster_names[string.lower(name)] = name
		end
	end
end

function LaFratellanza_RosterBuild()
	LaFratellanza_rosterInProgress = true

	local maxMembers = GetNumGuildMembers()
	LaFratellanza_guild_roster["online"] = {}
	LaFratellanza_guild_roster["offline"] = {}

	if maxMembers ~= nil then
		LaFratellanza_BuildArrayOfName(maxMembers)
		for i = 1, maxMembers do
			local name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class = GetGuildRosterInfo(i)
			if name ~= nil then
				if name == playerName then
					playerRank = lc(trim(rank))
				end
				local entry = LaFratellanza_GetMemberProps(
					i,
					name,
					rank,
					rankIndex,
					lvl,
					cl,
					zone,
					note,
					offNote,
					online,
					status,
					class
				)
				if online then
					table.insert(LaFratellanza_guild_roster["online"], entry)
				else
					table.insert(LaFratellanza_guild_roster["offline"], entry)
				end
			end
		end

		_G["LaFratellanza_Main_Frame_Members_RosterStatus"]:SetText(
			"Online: "
				.. #LaFratellanza_guild_roster["online"]
				.. "/"
				.. (#LaFratellanza_guild_roster["online"] + #LaFratellanza_guild_roster["offline"])
		)
		LaFratellanza_MembersFrameInit()
	end

	LaFratellanza_rosterInProgress = false
end

-- ===== DROPDOWN & SORT HEADER =====
function LaFratellanza_Status_InitDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = LaFratellanza_Status_DropDownOnClick
	if level == 1 then
		info.text, info.value = "Online", "Online"
		UIDropDownMenu_AddButton(info)
		info.text, info.value = "Offline", "Offline"
		UIDropDownMenu_AddButton(info)
	end
end

function LaFratellanza_Status_DropDownOnClick(self, arg1, arg2, checked)
	if self.value ~= previousSelection then
		previousSelection = self.value
		local dropDownButton = _G["LaFratellanza_Status_DropDownButton"]
		UIDropDownMenu_SetText(dropDownButton, self.value)
		LaFratellanza_section = lc(self.value)
		LaFratellanza_MembersFrameInit()
	end
end

function LaFratellanza_Specs_InitDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = LaFratellanza_Specs_DropDownOnClick
	if level == 1 then
		local specs = {
			"All specs",
			"Frost",
			"Restoration",
			"Feral",
			"Balance",
			"Guardian",
			"BeastMastery",
			"Marksmanship",
			"Survival",
			"Affliction",
			"Destruction",
			"Demonology",
			"Shadow",
			"Discipline",
			"Holy",
			"Fire",
			"Arcane",
			"Protection",
			"Fury",
			"Arms",
			"Retribution",
			"Combat",
			"Assassination",
			"Subtlety",
			"Elemental",
			"Enhancement",
		}
		for _, s in ipairs(specs) do
			info.text = s
			info.value = s
			UIDropDownMenu_AddButton(info)
		end
	end
end

function LaFratellanza_Specs_DropDownOnClick(self, arg1, arg2, checked)
	if self.value ~= previousSpecFilter then
		previousSpecFilter = self.value
		local dropDownButton = _G["LaFratellanza_Specs_DropDownButton"]
		UIDropDownMenu_SetText(dropDownButton, self.value)
		LaFratellanza_spec_filter = self.value
		LaFratellanza_MembersFrameInit()
	end
end

function LaFratellanza_Professions_InitDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = LaFratellanza_Professions_DropDownOnClick
	if level == 1 then
		local profs = {
			"All professions",
			"Alchemy",
			"Blacksmithing",
			"Enchanting",
			"Engineering",
			"Herbalism",
			"Inscription",
			"Jewelcrafting",
			"Leatherworking",
			"Mining",
			"Skinning",
			"Tailoring",
		}
		for _, p in ipairs(profs) do
			info.text = p
			info.value = p
			UIDropDownMenu_AddButton(info)
		end
	end
end

function LaFratellanza_Professions_DropDownOnClick(self, arg1, arg2, checked)
	if self.value ~= previousProfessionFilter then
		previousProfessionFilter = self.value
		local dropDownButton = _G["LaFratellanza_Professions_DropDownButton"]
		UIDropDownMenu_SetText(dropDownButton, self.value)
		LaFratellanza_prof_filter = self.value
		LaFratellanza_MembersFrameInit()
	end
end

function LaFratellanza_Button_Members_Menu_Cliked(self, key)
	currentKeySort = key
	LaFratellanza_MembersFrameInit()
end
