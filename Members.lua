local listLength = 0;
local membersFrame;
local scrollFrame;
local slider;
local scrollChild;
local previousSelection = "Online";
local previousSpecFilter = "All specs";
local previousProfessionFilter = "All professions";
local previousKeySort = "";
local currentKeySort = "";

function LaFratellanza_SplitString(inputString)
    local words = {};
    for word in string.gmatch(inputString, "[^%s/-]+") do
        table.insert(words, LaFratellanza_ToLowerCase(word));
    end
    return words;
end

function LaFratellanza_RefreshMembers()
    print("refresh");
    GuildRoster();
    LaFratellanza_RosterInit();
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


function LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class)
    local result = { name = name, rank = rank, lvl = lvl, cl = cl, zone = zone, note = note, offNote = offNote, online = online, status = status, class = class,
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


function LaFratellanza_ClearMemberRow()
    for idx = 1, 13 do
        _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Left"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Right"]:SetTexture(nil);
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
        _G["LaFratellanza_Member" .. idx .. "_Note"]:Hide();
        _G["LaFratellanza_Member" .. idx .. "_Invite"]:Hide();
        _G["LaFratellanza_Member" .. idx .. "_Whisper"]:Hide();
    end
end


function LaFratellanza_MemberListUpdate(index)
    LaFratellanza_ClearMemberRow()
    local cycle = #LaFratellanza_guild_roster_filtered

    if cycle > 13 then
        cycle = 13
    end

    for idx = 1, cycle do
        local memberFrame = _G["LaFratellanza_Member" .. idx];

        -- if LaFratellanza_section == 'online' then
        --     _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Left"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-left]]);
        --     _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-right]]);
        -- end

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
            _G[memberFrame:GetName() .. "_MainProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].prof.main);
        end

        if(LaFratellanza_guild_roster_filtered[idx+index].prof.off) then
            _G[memberFrame:GetName() .. "_OffProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. LaFratellanza_guild_roster_filtered[idx+index].prof.off);
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

        _G[memberFrame:GetName() .. "_Rank_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\rank_]] .. LaFratellanza_ToLowerCase(LaFratellanza_Trim(LaFratellanza_guild_roster_filtered[idx+index].rank)));

        if(LaFratellanza_guild_roster_filtered[idx+index].altOf) then
            local main = _G[memberFrame:GetName() .. "_Main_Text"];
            main:SetText(LaFratellanza_guild_roster_filtered[idx+index].altOf);
            main:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
            main:SetTextColor(0.7, 0.7, 0.7);
        end
        
        local note = _G[memberFrame:GetName() .. "_Note"];
        note:Show();
        note:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP");
            GameTooltip:SetText(LaFratellanza_guild_roster_filtered[idx+index].note, 1, 1, 1, true);
            GameTooltip:Show();
        end)

        note:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)
    end
end


function LaFratellanza_MemberListInit()
    for idx = 1, 13 do
        local item = CreateFrame("Frame", "LaFratellanza_Member" .. idx, membersFrame, "LaFratellanza_Member_Template");
        -- _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Left"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-left]]);
        -- _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-right]]);

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
    scrollFrame = CreateFrame("ScrollFrame", "LaFratellanza_Main_Frame_Members_ScrollFrame", membersFrame, "UIPanelScrollFrameTemplate");
    slider = CreateFrame("Slider", "LaFratellanza_Main_Frame_Members_Slider", scrollFrame, "OptionsSliderTemplate");
    scrollChild = CreateFrame("Frame", "LaFratellanza_Main_Frame_Members_ScrollChild", scrollFrame);
    membersFrame.scrollFrame = scrollFrame;
    membersFrame.slider = slider;
    scrollFrame:SetPoint("CENTER", membersFrame, "CENTER", 0, -10);
    scrollFrame:SetSize(768, 430);
    scrollFrame:EnableMouseWheel(true);

    slider:SetSize(25, 445);
    slider:SetPoint("LEFT", membersFrame, "RIGHT", 0, -10);
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
    scrollChild:SetPoint("RIGHT", membersFrame, "LEFT", 0, 0);
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
        local direction = "";
        if(previousKeySort ~= currentKeySort) then
            direction = "ASC";
        else
            direction = "DESC";
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
    membersFrame:Show();

    if(LaFratellanza_is_first_open) then
        LaFratellanza_MembersScrollBarInit();
    end

    LaFratellanza_MembersScrollBarUpdate();

    if(LaFratellanza_is_first_open) then   
        LaFratellanza_MemberListInit();
    else
        LaFratellanza_MemberListUpdate(0);
    end
end


function LaFratellanza_BuildArrayOfName(maxMembers)
    for i = 1, maxMembers do
        local name = GetGuildRosterInfo(i);
        if name ~= nil then
            LaFratellanza_guild_roster_names[string.lower(name)] = name;
        end
    end
end


function LaFratellanza_RosterInit()
    -- set a true della variabile config guildShowOffline (se è disattivata, getNumGuildMembers torna solo il numero di player online)
     SetCVar("guildShowOffline", 1);
     LaFratellanza_guild_roster["online"] = {};
     LaFratellanza_guild_roster["offline"] = {};
     local maxMembers = GetNumGuildMembers();
     membersFrame = _G["LaFratellanza_Main_Frame_Members"];

     if maxMembers ~= nil then
        LaFratellanza_BuildArrayOfName(maxMembers)
         for i = 1, maxMembers do
             local name, rank, _, lvl, cl, zone, note, offNote, online, status, class = GetGuildRosterInfo(i);
             if name ~= nil then
                if online == 1 then
                    table.insert(LaFratellanza_guild_roster["online"], LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class));
                else
                    table.insert(LaFratellanza_guild_roster["offline"], LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class));
                end
             end
         end
         _G["LaFratellanza_Main_Frame_Members_RosterStatus"]:SetText("Online: " .. #LaFratellanza_guild_roster["online"] .. "/" .. #LaFratellanza_guild_roster["online"]+#LaFratellanza_guild_roster["offline"]);
         LaFratellanza_MembersFrameInit();
     end
     SetCVar("guildShowOffline", 0);
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