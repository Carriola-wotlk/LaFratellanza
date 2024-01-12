local listLength = 0;
local scrollFrame;
local slider;
local scrollChild;
local previousSelection = "Online";
local previousSpecFilter = "All specs";
local previousProfessionFilter = "All professions";
local previousKeySort = "";
local direction = 'ASC';
local currentKeySort = "";
local playerName = UnitName("player");
local playerRank = "";

function LaFratellanza_SplitString(inputString)
    local words = {};
    for word in string.gmatch(inputString, "[^%s/-]+") do
        table.insert(words, LaFratellanza_ToLowerCase(word));
    end
    return words;
end

function LaFratellanza_RefreshMembers() --lasciare così questa funzione
    GuildRoster();

    -- set a true della variabile config guildShowOffline (se è disattivata, getNumGuildMembers torna solo il numero di player online)
    SetCVar("guildShowOffline", 1); --questo oltre a mostrare anche i membri offline trigghera GUILD_ROSTER_UPDATE
    SetCVar("guildShowOffline", 0);
end

function LaFratellanza_DecodeNote(elements, result, name)
    local indexProf = 1;
    local indexSpec = 1;

    for i, element in ipairs(elements) do

        if element == "main" then
            result.isAlt = false;
        elseif element == "alt" then
            result.isAlt = true;
        else
            if LaFratellanza_prof_table[element] ~= nil then
                if indexProf == 1 then
                    result["prof"].main = LaFratellanza_prof_table[element];
                    indexProf = 2;
                elseif indexProf == 2 then
                    result["prof"].off = LaFratellanza_prof_table[element];
                end
            elseif LaFratellanza_spec_table[element] ~= nil then
                if indexSpec == 1 then
                    result["spec"].main = LaFratellanza_spec_table[element];
                    indexSpec = 2;
                elseif indexSpec == 2 then
                    result["spec"].off = LaFratellanza_spec_table[element];
                end
            elseif LaFratellanza_guild_roster_names[element] then
                result.altOf = LaFratellanza_guild_roster_names[element];
            end
        end

    end
end

function LaFratellanza_GetMemberProps(idx, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class)
    local result = { idx = idx, name = name, lvl = lvl, cl = cl, zone = zone, note = note, offNote = offNote, online = online, status = status, class = class,
            rank =  LaFratellanza_ToLowerCase(LaFratellanza_Trim(rank)),
            rankIndex = rankIndex,
            prof = {},
            spec = {},
            isAlt = false,
            altOf = '',
        };
        
        -- ALT ha uno spazio alla fine
        -- todo: stringa da trimmare
        if rank == "ALT " then
            result.isAlt = true;
        end

    local elements = LaFratellanza_SplitString(note);
    LaFratellanza_DecodeNote(elements, result, name);
    return result;
end

function LaFratellanza_InitNoteFrame()
    LaFratellanza_note_frame = CreateFrame("Frame", "LaFratellanza_Note_Frame", LaFratellanza_main_frame);
    LaFratellanza_note_frame:SetSize(256, 256);
    LaFratellanza_note_frame:SetPoint("LEFT", LaFratellanza_main_frame, "BOTTOMRIGHT", -15, 160);
    LaFratellanza_note_frame:SetBackdrop({
        bgFile = "Interface\\AddOns\\LaFratellanza\\texture\\frames\\finestra-laterale.tga",
        tile = false,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    LaFratellanza_note_frame:SetFrameLevel(LaFratellanza_main_frame:GetFrameLevel()-1);

    LaFratellanza_note_frame_title = LaFratellanza_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    LaFratellanza_note_frame_title:SetPoint("TOPLEFT", LaFratellanza_note_frame, "TOPLEFT", 30, -30);
    LaFratellanza_note_frame_title:SetText("");

    local personalNotesLabel = LaFratellanza_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    personalNotesLabel:SetPoint("TOPLEFT", LaFratellanza_note_frame_title, "BOTTOMLEFT", 0, -15);
    personalNotesLabel:SetText("Note personali: ");

    LaFratellanza_note_frame_personal_note = CreateFrame("EditBox", "MioAddonEditBox", LaFratellanza_note_frame);
    LaFratellanza_note_frame_personal_note:SetMultiLine(true);
    LaFratellanza_note_frame_personal_note:SetFontObject(GameFontNormal);
    LaFratellanza_note_frame_personal_note:SetWidth(200);
    LaFratellanza_note_frame_personal_note:SetPoint("TOPLEFT", personalNotesLabel, "BOTTOMLEFT", 0, -3);
    LaFratellanza_note_frame_personal_note:SetText("");
    LaFratellanza_note_frame_personal_note:HighlightText();
    LaFratellanza_note_frame_personal_note:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    LaFratellanza_note_frame_personal_note:SetTextInsets(8, 8, 8, 8);
    LaFratellanza_note_frame_personal_note:SetMaxLetters(40);

    local officerNotesLabel = LaFratellanza_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    officerNotesLabel:SetPoint("TOPLEFT",  LaFratellanza_note_frame_personal_note, "BOTTOMLEFT", 0, -12);
    officerNotesLabel:SetText("Note officer: ");

    LaFratellanza_note_frame_officer_note = CreateFrame("EditBox", "MioAddonEditBox", LaFratellanza_note_frame);
    LaFratellanza_note_frame_officer_note:SetMultiLine(true);
    LaFratellanza_note_frame_officer_note:SetFontObject(GameFontNormal);
    LaFratellanza_note_frame_officer_note:SetWidth(200);
    LaFratellanza_note_frame_officer_note:SetPoint("TOPLEFT", officerNotesLabel, "BOTTOMLEFT", 0, -3);
    LaFratellanza_note_frame_officer_note:SetText("");
    LaFratellanza_note_frame_officer_note:HighlightText();
    LaFratellanza_note_frame_officer_note:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    LaFratellanza_note_frame_officer_note:SetTextInsets(8, 8, 8, 8);
    LaFratellanza_note_frame_officer_note:SetMaxLetters(40);

    local closeButton = CreateFrame("Button", "SaveButton", LaFratellanza_note_frame, "UIPanelButtonTemplate");
    closeButton:SetSize(80, 25);
    closeButton:SetText("Chiudi");
    closeButton:SetPoint("BOTTOMLEFT", LaFratellanza_note_frame, "BOTTOMLEFT", 30, 25);

    closeButton:SetScript("OnClick", function()
        LaFratellanza_note_frame_title:SetText("");
        LaFratellanza_note_frame_personal_note:SetText("");
        LaFratellanza_note_frame_officer_note:SetText("");
        LaFratellanza_note_frame:Hide();
    end);

    LaFratellanza_note_frame_save = CreateFrame("Button", "SaveButton", LaFratellanza_note_frame, "UIPanelButtonTemplate");
    LaFratellanza_note_frame_save:SetSize(80, 25);
    LaFratellanza_note_frame_save:SetText("Salva");
    LaFratellanza_note_frame_save:SetPoint("LEFT", closeButton, "RIGHT", 10, 0);

    LaFratellanza_note_frame:Hide();
end

function LaFratellanza_OpenEditNote(name, idx, note)
    LaFratellanza_note_frame:Show();
    LaFratellanza_note_frame_title:SetText(LaFratellanza_ToUpperCase(name));

    if note:match("^(.-)\n\n(.+)$") then
        local personal, officer = note:match("^(.-)\n\n(.+)$");
        LaFratellanza_note_frame_personal_note:SetText(personal);
        LaFratellanza_note_frame_officer_note:SetText(string.sub(officer, 14));
    else 
        LaFratellanza_note_frame_personal_note:SetText(note);
        LaFratellanza_note_frame_officer_note:SetText("");
    end

    LaFratellanza_note_frame_save:SetScript("OnClick", function()
        local personalNotes = LaFratellanza_note_frame_personal_note:GetText();
        local officerNotes = LaFratellanza_note_frame_personal_note:GetText();

        GuildRosterSetPublicNote(idx, personalNotes);
        GuildRosterSetOfficerNote(idx, officerNotes);

        LaFratellanza_note_frame_title:SetText("");
        LaFratellanza_note_frame_personal_note:SetText("");
        LaFratellanza_note_frame_officer_note:SetText("");
        LaFratellanza_note_frame:Hide();
        LaFratellanza_RefreshMembers();
    end);

end

function LaFratellanza_ClearMemberRow()
    for idx = 1, 13 do
        _G["LaFratellanza_Member" .. idx .. "_ClassIcon_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_Name_Text"]:SetText(nil);
        _G["LaFratellanza_Member" .. idx .. "_Level_Text"]:SetText(nil);
        _G["LaFratellanza_Member" .. idx .. "_MainSpec_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_OffSpec_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_MainProf_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_OffProf_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_Zone_Text"]:SetText(nil);
        _G["LaFratellanza_Member" .. idx .. "_Main_Text"]:SetText(nil);
        _G["LaFratellanza_Member" .. idx .. "_Rank_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_Note"]:SetScript("OnEnter", nil);
        _G["LaFratellanza_Member" .. idx .. "_Note"]:SetScript("OnLeave", nil);
        _G["LaFratellanza_Member" .. idx .. "_Note"]:SetScript("OnClick", nil);
        _G["LaFratellanza_Member" .. idx .. "_Note"]:Hide();
        _G["LaFratellanza_Member" .. idx .. "_Invite"]:Hide();
        _G["LaFratellanza_Member" .. idx .. "_Whisper"]:Hide();
    end
end


function LaFratellanza_MemberListUpdate(index)
    LaFratellanza_ClearMemberRow()
    local cycle = #LaFratellanza_guild_roster_filtered;

    if cycle > 13 then
        cycle = 13;
    end

    for idx = 1, cycle do
        local memberFrame = _G["LaFratellanza_Member" .. idx];

        if LaFratellanza_section == 'offline' then
            memberFrame:SetAlpha(0.6);
        else
            memberFrame:SetAlpha(1);
        end

        local classIconTexture = _G[memberFrame:GetName() .. "_ClassIcon_Texture"];
        if LaFratellanza_guild_roster_filtered[idx+index].name == 'Cipollino' then
            classIconTexture:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\Cipollino]]);
        else
            classIconTexture:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].class);
        end
        
        local name = _G[memberFrame:GetName() .. "_Name_Text"];
        name:SetText(LaFratellanza_guild_roster_filtered[idx+index].name);

        local lvl = _G[memberFrame:GetName() .. "_Level_Text"];
        lvl:SetText(LaFratellanza_guild_roster_filtered[idx+index].lvl);

        if(LaFratellanza_guild_roster_filtered[idx+index].spec.main) then
            _G[memberFrame:GetName() .. "_MainSpec_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].spec.main .. LaFratellanza_guild_roster_filtered[idx+index].class);
        end

        if(LaFratellanza_guild_roster_filtered[idx+index].spec.off) then
            _G[memberFrame:GetName() .. "_OffSpec_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].spec.off .. LaFratellanza_guild_roster_filtered[idx+index].class);
        end
        
        if(LaFratellanza_guild_roster_filtered[idx+index].prof.main) then
            local mainProf = _G[memberFrame:GetName() .. "_MainProf"];
            local prof = LaFratellanza_guild_roster_filtered[idx+index].prof.main
            _G[memberFrame:GetName() .. "_MainProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].prof.main);

            mainProf:SetScript("OnClick", function()
                local msg = "Req:" .. prof;
                SendAddonMessage(LaFratellanza_channel, msg, "WHISPER", LaFratellanza_guild_roster_filtered[idx+index].name);
            end)
        end

        if(LaFratellanza_guild_roster_filtered[idx+index].prof.off) then
            local offProf = _G[memberFrame:GetName() .. "_OffProf"];
            local prof = LaFratellanza_guild_roster_filtered[idx+index].prof.off
            _G[memberFrame:GetName() .. "_OffProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].prof.off);

            offProf:SetScript("OnClick", function()
                local msg = "Req:" .. prof;
                SendAddonMessage(LaFratellanza_channel, msg, "WHISPER", LaFratellanza_guild_roster_filtered[idx+index].name);
            end)
        end

        local zone = _G[memberFrame:GetName() .. "_Zone_Text"];

        local zoneText = LaFratellanza_guild_roster_filtered[idx + index].zone;

        if string.len(zoneText) > 21 then
            zoneText = string.sub(zoneText, 1, 21) .. "...";
        end
        zone:SetText(zoneText);

        if LaFratellanza_section == 'offline' then
                name:SetTextColor(0.5, 0.5, 0.5);
                lvl:SetTextColor(0.5, 0.5, 0.5);
                zone:SetTextColor(0.5, 0.5, 0.5);
        else
                name:SetTextColor(0.9, 0.9, 0.9);
                lvl:SetTextColor(0.9, 0.9, 0.9);
                zone:SetTextColor(0.9, 0.9, 0.9);
        end

        local invite = _G[memberFrame:GetName() .. "_Invite"];
        local whisper = _G[memberFrame:GetName() .. "_Whisper"];

        if LaFratellanza_section == 'offline' then
            invite:Hide();
            whisper:Hide();
        else
            invite:Show();
            whisper:Show();

            invite:SetScript("OnClick", function()
                InviteUnit(LaFratellanza_guild_roster_filtered[idx+index].name);
            end)

            whisper:SetScript("OnClick", function()
                ChatFrame_SendTell(LaFratellanza_guild_roster_filtered[idx+index].name);
            end)
        end

        _G[memberFrame:GetName() .. "_Rank_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\rank_]] .. LaFratellanza_guild_roster_filtered[idx+index].rank);

        if(LaFratellanza_guild_roster_filtered[idx+index].altOf) then
            local main = _G[memberFrame:GetName() .. "_Main_Text"];
            main:SetText(LaFratellanza_guild_roster_filtered[idx+index].altOf);
            main:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
            main:SetTextColor(0.7, 0.7, 0.7);
        end
        
        local note = _G[memberFrame:GetName() .. "_Note"];
        note:Show();

        local textNote = LaFratellanza_guild_roster_filtered[idx+index].note;
        if(LaFratellanza_guild_roster_filtered[idx+index].offNote ~= "") then
            textNote = textNote .. "\n\nOfficer Note: " ..  LaFratellanza_guild_roster_filtered[idx+index].offNote
        end
        note:SetScript("OnEnter", function(self)
           
            GameTooltip:SetOwner(self, "ANCHOR_TOP");
            GameTooltip:SetWidth(400);
            GameTooltip:SetText(textNote, 1, 1, 1, true);
            GameTooltip:Show();
        end)

        note:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)

        if(playerRank == "guild master" or LaFratellanza_Rank_Edit_Note[playerRank])then
            note:SetScript("OnClick", function ()
                LaFratellanza_OpenEditNote(LaFratellanza_guild_roster_filtered[idx+index].name, LaFratellanza_guild_roster_filtered[idx+index].note);
            end)
        end

    end
end


function LaFratellanza_MemberListInit()
    for idx = 1, 13 do
        local item = CreateFrame("Frame", "LaFratellanza_Member" .. idx, LaFratellanza_members_frame, "LaFratellanza_Member_Template");

        if idx == 1 then
            item:SetPoint("TOP", 0, -60);
        else
            item:SetPoint("TOP", _G["LaFratellanza_Member" .. idx-1], "BOTTOM", 0, 0);
        end
    end
    LaFratellanza_is_first_open = false;
    LaFratellanza_MemberListUpdate(0);
end


function LaFratellanza_MembersScrollBarInit()
    scrollFrame = CreateFrame("ScrollFrame", "LaFratellanza_Main_Frame_Members_ScrollFrame", LaFratellanza_members_frame, "UIPanelScrollFrameTemplate");
    slider = CreateFrame("Slider", "LaFratellanza_Main_Frame_Members_Slider", scrollFrame, "OptionsSliderTemplate");
    scrollChild = CreateFrame("Frame", "LaFratellanza_Main_Frame_Members_ScrollChild", scrollFrame);
    LaFratellanza_members_frame.scrollFrame = scrollFrame;
    LaFratellanza_members_frame.slider = slider;
    scrollFrame:SetPoint("CENTER", LaFratellanza_members_frame, "CENTER", 0, -10);
    scrollFrame:SetSize(768, 430);
    scrollFrame:EnableMouseWheel(true);

    slider:SetSize(25, 445);
    slider:SetPoint("LEFT", LaFratellanza_members_frame, "RIGHT", 0, -10);
    slider:SetBackdrop({
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 },
    });
    _G[slider:GetName() .. 'Low']:SetText('');
    _G[slider:GetName() .. 'High']:SetText('');
end


function LaFratellanza_MembersScrollBarUpdate()
    local minValue = 1;
    local addValue = 0;
    if listLength > 13 and (listLength-13) % 5 ~= 0 then
        addValue = (5 - ((listLength - 13) % 5)) * 32;
    end
    local maxValue = (listLength*32) + addValue;
    scrollChild:SetSize(665, maxValue);
    scrollChild:SetPoint("RIGHT", LaFratellanza_members_frame, "LEFT", 0, 0);
    scrollFrame:SetScrollChild(scrollChild);

    local stepSize = 5 * 32;

    scrollFrame:SetScript("OnVerticalScroll", function(self, value)
        local newValue = math.max(160, math.floor(value / stepSize + 0.5) * stepSize);
        newValue = math.min(maxValue, math.max(minValue, newValue));

        if(value == 0) then
            LaFratellanza_MemberListUpdate(0);
        else
            LaFratellanza_MemberListUpdate(newValue / 32);
        end
    end)
end


function LaFratellanza_GuildRoster_Filtered()

    LaFratellanza_guild_roster_filtered = {};

    if(LaFratellanza_prof_filter ~= "All professions" or LaFratellanza_spec_filter ~= "All specs") then

        if(LaFratellanza_prof_filter ~= "All professions" and LaFratellanza_spec_filter ~= "All specs") then
            for _, member in ipairs(LaFratellanza_guild_roster[LaFratellanza_section]) do
                if ((member.spec.main == LaFratellanza_spec_filter or member.spec.off == LaFratellanza_spec_filter) and
                    (member.prof.main == LaFratellanza_prof_filter or member.prof.off == LaFratellanza_prof_filter)) then
                    table.insert(LaFratellanza_guild_roster_filtered, member);
                end
            end

        elseif(LaFratellanza_spec_filter ~= "All specs") then
            for _, member in ipairs(LaFratellanza_guild_roster[LaFratellanza_section]) do
                if (member.spec.main == LaFratellanza_spec_filter or member.spec.off == LaFratellanza_spec_filter) then
                    table.insert(LaFratellanza_guild_roster_filtered, member);
                end
            end

        elseif(LaFratellanza_prof_filter ~= "All professions") then
            for _, member in ipairs(LaFratellanza_guild_roster[LaFratellanza_section]) do
                if (member.prof.main == LaFratellanza_prof_filter or member.prof.off == LaFratellanza_prof_filter) then
                    table.insert(LaFratellanza_guild_roster_filtered, member);
                end
            end
        end

    else
        LaFratellanza_guild_roster_filtered = LaFratellanza_guild_roster[LaFratellanza_section];
    end

end


function LaFratellanza_GuildRoster_Sorted()
        if(previousKeySort ~= currentKeySort) then
            direction = "ASC";
        elseif direction == "ASC" then
            direction = "DESC";
        else
            direction = "ASC";
        end

        table.sort(LaFratellanza_guild_roster_filtered, function(a, b)
            if direction == "ASC" then
                return a[currentKeySort] < b[currentKeySort];
            else
                return a[currentKeySort] > b[currentKeySort];
            end
        end)

        previousKeySort = currentKeySort;
end


function LaFratellanza_MembersFrameInit()
    LaFratellanza_GuildRoster_Filtered();

    if currentKeySort ~= "" then
        LaFratellanza_GuildRoster_Sorted();
    end

    listLength = #LaFratellanza_guild_roster_filtered;

    if(LaFratellanza_navBar_current_button == "membri") then
        LaFratellanza_ShowMembersFrame();
    end

    if(LaFratellanza_is_first_open) then
        LaFratellanza_MembersScrollBarInit();
        LaFratellanza_MemberListInit();
    end

    LaFratellanza_MembersScrollBarUpdate();
    LaFratellanza_MemberListUpdate(0);
end


function LaFratellanza_BuildArrayOfName(maxMembers)
    for i = 1, maxMembers do
        local name = GetGuildRosterInfo(i);
        if name ~= nil then
            LaFratellanza_guild_roster_names[string.lower(name)] = name;
        end
    end
end


 function LaFratellanza_RosterBuild()
    LaFratellanza_rosterInProgress = true;

    SetCVar("guildShowOffline", 1);
    LaFratellanza_guild_roster["online"] = {};
    LaFratellanza_guild_roster["offline"] = {};
    local maxMembers = GetNumGuildMembers();
 
    if maxMembers ~= nil then
       LaFratellanza_BuildArrayOfName(maxMembers)
        for i = 1, maxMembers do
            local name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class = GetGuildRosterInfo(i);
            if name ~= nil then
               if name == playerName then
                   playerRank = LaFratellanza_ToLowerCase(LaFratellanza_Trim(rank));
               end
               if online == 1 then
                   table.insert(LaFratellanza_guild_roster["online"], LaFratellanza_GetMemberProps(i, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class));
               else
                   table.insert(LaFratellanza_guild_roster["offline"], LaFratellanza_GetMemberProps(i, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class));
               end
            end
        end
        _G["LaFratellanza_Main_Frame_Members_RosterStatus"]:SetText("Online: " .. #LaFratellanza_guild_roster["online"] .. "/" .. #LaFratellanza_guild_roster["online"]+#LaFratellanza_guild_roster["offline"]);
        LaFratellanza_MembersFrameInit();
    end
    SetCVar("guildShowOffline", 0);
    LaFratellanza_rosterInProgress = false;
 end

function LaFratellanza_Status_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = LaFratellanza_Status_DropDownOnClick;

    if level == 1 then
        info.text = "Online";
        info.value = "Online";
        UIDropDownMenu_AddButton(info);

        info.text = "Offline";
        info.value = "Offline";
        UIDropDownMenu_AddButton(info);
    end
end


function LaFratellanza_Status_DropDownOnClick(self, arg1, arg2, checked)
    if self.value ~= previousSelection then
        previousSelection = self.value;

        local dropDownButton = _G["LaFratellanza_Status_DropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);

        LaFratellanza_section = LaFratellanza_ToLowerCase(self.value);
        LaFratellanza_MembersFrameInit();
    end
end

function LaFratellanza_Specs_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = LaFratellanza_Specs_DropDownOnClick;

    if level == 1 then
        info.text = "All specs";
        info.value = "All specs";
        UIDropDownMenu_AddButton(info);

        info.text = "Frost";
        info.value = "Frost";
        UIDropDownMenu_AddButton(info);

        info.text = "Restoration";
        info.value = "Restoration";
        UIDropDownMenu_AddButton(info);

        info.text = "Feral";
        info.value = "Feral";
        UIDropDownMenu_AddButton(info);

        info.text = "Balance";
        info.value = "Balance";
        UIDropDownMenu_AddButton(info);

        info.text = "Guardian";
        info.value = "Guardian";
        UIDropDownMenu_AddButton(info);

        info.text = "BeastMastery";
        info.value = "BeastMastery";
        UIDropDownMenu_AddButton(info);

        info.text = "Marksmanship";
        info.value = "Marksmanship";
        UIDropDownMenu_AddButton(info);

        info.text = "Survival";
        info.value = "Survival";
        UIDropDownMenu_AddButton(info);

        info.text = "Affliction";
        info.value = "Affliction";
        UIDropDownMenu_AddButton(info);

        info.text = "Destruction";
        info.value = "Destruction";
        UIDropDownMenu_AddButton(info);

        info.text = "Demonology";
        info.value = "Demonology";
        UIDropDownMenu_AddButton(info);

        info.text = "Shadow";
        info.value = "Shadow";
        UIDropDownMenu_AddButton(info);

        info.text = "Discipline";
        info.value = "Discipline";
        UIDropDownMenu_AddButton(info);

        info.text = "Holy";
        info.value = "Holy";
        UIDropDownMenu_AddButton(info);

        info.text = "Fire";
        info.value = "Fire";
        UIDropDownMenu_AddButton(info);

        info.text = "Arcane";
        info.value = "Arcane";
        UIDropDownMenu_AddButton(info);

        info.text = "Protection";
        info.value = "Protection";
        UIDropDownMenu_AddButton(info);

        info.text = "Fury";
        info.value = "Fury";
        UIDropDownMenu_AddButton(info);

        info.text = "Arms";
        info.value = "Arms";
        UIDropDownMenu_AddButton(info);

        info.text = "Retribution";
        info.value = "Retribution";
        UIDropDownMenu_AddButton(info);

        info.text = "Combat";
        info.value = "Combat";
        UIDropDownMenu_AddButton(info);

        info.text = "Assassination";
        info.value = "Assassination";
        UIDropDownMenu_AddButton(info);

        info.text = "Subtlety";
        info.value = "Subtlety";
        UIDropDownMenu_AddButton(info);

        info.text = "Elemental";
        info.value = "Elemental";
        UIDropDownMenu_AddButton(info);

        info.text = "Enhancement";
        info.value = "Enhancement";
        UIDropDownMenu_AddButton(info);
    end
end

function LaFratellanza_Specs_DropDownOnClick(self, arg1, arg2, checked)
    if self.value ~= previousSpecFilter then
        previousSpecFilter = self.value;

        local dropDownButton = _G["LaFratellanza_Specs_DropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);

        LaFratellanza_spec_filter = self.value;
        LaFratellanza_MembersFrameInit();
    end

end


function LaFratellanza_Professions_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = LaFratellanza_Professions_DropDownOnClick;

    if level == 1 then
        info.text = "All professions";
        info.value = "All professions";
        UIDropDownMenu_AddButton(info);

        info.text = "Alchemy";
        info.value = "Alchemy";
        UIDropDownMenu_AddButton(info);

        info.text = "Blacksmithing";
        info.value = "Blacksmithing";
        UIDropDownMenu_AddButton(info);

        info.text = "Enchanting";
        info.value = "Enchanting";
        UIDropDownMenu_AddButton(info);

        info.text = "Engineering";
        info.value = "Engineering";
        UIDropDownMenu_AddButton(info);

        info.text = "Herbalism";
        info.value = "Herbalism";
        UIDropDownMenu_AddButton(info);

        info.text = "Inscription";
        info.value = "Inscription";
        UIDropDownMenu_AddButton(info);

        info.text =  "Jewelcrafting";
        info.value =  "Jewelcrafting";
        UIDropDownMenu_AddButton(info);

        info.text =  "Leatherworking";
        info.value =  "Leatherworking";
        UIDropDownMenu_AddButton(info);

        info.text =  "Mining";
        info.value =  "Mining";
        UIDropDownMenu_AddButton(info);

        info.text = "Skinning";
        info.value = "Skinning";
        UIDropDownMenu_AddButton(info);

        info.text = "Tailoring";
        info.value = "Tailoring";
        UIDropDownMenu_AddButton(info);
    end
end

function LaFratellanza_Professions_DropDownOnClick(self, arg1, arg2, checked)
    if self.value ~= previousProfessionFilter then
        previousProfessionFilter = self.value;

        local dropDownButton = _G["LaFratellanza_Professions_DropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);

        LaFratellanza_prof_filter = self.value;
        LaFratellanza_MembersFrameInit();
    end

end


function LaFratellanza_Button_Members_Menu_Cliked(self, key)
    currentKeySort = key;
    LaFratellanza_MembersFrameInit();
end