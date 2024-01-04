local navBar = {"membri", "regolamento", "chat", "stats"};
local isMainFrameOpended = false;
local LaFratellanza = CreateFrame("Frame");
local guild_Roster_Names = {}
local guild_Roster = {
    online = {},
    offline = {},
};
local guild_Roster_Filtered = {}
local section = "online";
local profFilter = "All professions";
local specFilter = "All specs";

local isFirstOpen = true;

-- MEMBERS
local listLength = 0;
local membersFrame;
local scrollFrame;
local slider;
local scrollChild;

local profTable = {
    skin = "Skinning",
    skinning = "Skinning",

    alchemy = "Alchemy",
    alc = "Alchemy",
    alk = "Alchemy",
    alch = "Alchemy",
    ak = "Alchemy",

    blacksmithing = "Blacksmithing",
    bla = "Blacksmithing",
    bs = "Blacksmithing",

    enchanting = "Enchanting",
    enc = "Enchanting",
    ench = "Enchanting",

    engineering = "Engineering",
    eng = "Engineering",
    engi = "Engineering",
    engineer = "Engineering",

    herbalism = "Herbalism",
    herb = "Herbalism",
    her = "Herbalism",
    erba = "Herbalism",
    erb = "Herbalism",

    inscription = "Inscription",
    inscript = "Inscription",
    inscr = "Inscription",
    insc = "Inscription",
    ins = "Inscription",

    jewelcrafting = "Jewelcrafting",
    jewel = "Jewelcrafting",
    jew = "Jewelcrafting",
    jc = "Jewelcrafting",
    jw = "Jewelcrafting",

    leatherworking = "Leatherworking",
    leath = "Leatherworking",
    let = "Leatherworking",
    lw = "Leatherworking",

    mining = "Mining",
    minatore = "Mining",
    min = "Mining",

    tailoring = "Tailoring",
    tailor = "Tailoring",
    tail = "Tailoring",
    tai = "Tailoring",
};

local specTable = {
    healer = "Healer",
    tank = "Tank",

    unh = "Unholy",
    unholy = "Unholy",
    frost = "Frost",
    blood = "Blood",

    resto = "Restoration",
    restoration = "Restoration",
    feral = "Feral",
    balance = "Balance",
    pollo = "Balance",
    guardian = "Guardian",

    beastMastery = "BeastMastery",
    bm = "BeastMastery",
    marksmanship = "Marksmanship",
    mm = "Marksmanship",
    survival = "Survival",

    affliction = "Affliction",
    affly = "Affliction",
    affli = "Affliction",
    destruction = "Destruction",
    destro = "Destruction",
    demonology = "Demonology",
    demo = "Demonology",

    shadow = "Shadow",
    sp = "Shadow",
    discipline = "Discipline",
    disci = "Discipline",
    holy = "Holy",

    fire ="Fire",
    arcane = "Arcane",

    protection = "Protection",
    prot = "Protection",
    fury = "Fury",
    arms = "Arms",

    retribution = "Retribution",
    retri = "Retribution",

    combat = "Combat",
    assassination = "Assassination",
    ass = "Assassination",
    subtlety = "Subtlety",
    sub = "Subtlety",

    elemental = "Elemental",
    ele = "Elemental",
    enha = "Enhancement",
    enh = "Enhancement",
    ena = "Enhancement",
};

local mainButton = CreateFrame("Button", "LaFratellanzaInitialButton", UIParent, "UIPanelButtonTemplate");
mainButton:SetPoint("LEFT", 0, 0);
mainButton:SetSize(100, 30);
mainButton:SetMovable(true);
mainButton:SetText("La Fratellanza");



-- UTILS ----------------------------------------------
function Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function ToLowerCase(s)
    return s:lower();
end

function ToUpperCase(s)
    return s:upper();
end

----------------------------------------------------------------

function LaFratellanza_OnLoad(self)
    self.items = {};
    for idx, value in ipairs(navBar) do
        local item = CreateFrame("Button", "LaFratellanza_Button" .. idx, self, "LaFratellanzaMenuButtonTemplate");
        self.items[idx] = item;
        _G["LaFratellanza_Button" .. idx .. "_Voice"]:SetText(value);
        _G["LaFratellanza_Button" .. idx .. "_IconTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. value .. "_icon");

        if idx == 1 then
            item:SetPoint("LEFT", 30, 20);
            _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]]);
        else
            item:SetPoint("TOPLEFT", self.items[idx-1], "BOTTOMLEFT", 0, -12);
        end
    end

end

function LaFratellanza_ShowMembersFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]]);
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_Button3_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_Button4_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\members-bottom-right]]);
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\members-top-right]]);
    _G["LaFratellanza_Main_Frame_Members"]:Show()
end

function LaFratellanza_ShowRulesFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]]);
    _G["LaFratellanza_Button3_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_Button4_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\regolamento-bottom-right]]);
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\regolamento-top-right]]);
    _G["LaFratellanza_Main_Frame_Members"]:Hide()
end

function LaFratellanza_ShowChatFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_Button3_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]]);
    _G["LaFratellanza_Button4_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\chat-bottom-right]]);
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\chat-top-right]]);
    _G["LaFratellanza_Main_Frame_Members"]:Hide();
end

function LaFratellanza_ShowStatsFrame()
    --_G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\regolamento-bottom-right]]);
    --_G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\regolamento-top-right]]);
end



-------------------------------------------
--- MEMBERS FRAME
------------------------------------------
function SplitString(inputString)
    local words = {};
    for word in string.gmatch(inputString, "[^%s/-]+") do
        table.insert(words, string.lower(word));
    end
    return words;
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
            if profTable[element] ~= nil then
                if indexProf == 1 then
                    result["prof"].main = profTable[element];
                    indexProf = 2;
                elseif indexProf == 2 then
                    result["prof"].off = profTable[element];
                end
            elseif specTable[element] ~= nil then
                if indexSpec == 1 then
                    result["spec"].main = specTable[element];
                    indexSpec = 2;
                elseif indexSpec == 2 then
                    result["spec"].off = specTable[element];
                end
            elseif guild_Roster_Names[element] then
                result.altOf = string.upper(element);
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

    local elements = SplitString(note);
    LaFratellanza_DecodeNote(elements, result, name);
    return result;
end


function LaFratellanza_ClearMemberRow()
    for idx = 1, 13 do
        _G["LaFratellanza_Member" .. idx]:SetScript("OnMouseDown", nil);
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
        _G["LaFratellanza_Member" .. idx .. "_Rank_Texture"]:SetTexture(nil);
        _G["LaFratellanza_Member" .. idx .. "_Rank"]:SetScript("OnEnter", nil);
        _G["LaFratellanza_Member" .. idx .. "_Rank"]:SetScript("OnLeave", nil);
    end
end

function LaFratellanza_MemberListUpdate(index)
  
    LaFratellanza_ClearMemberRow()
    for idx = 1, 13 do
        if(guild_Roster_Filtered[idx+index].name) then
            local memberFrame = _G["LaFratellanza_Member" .. idx];
            
            if section == 'online' then
                _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Left"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-left]]);
                _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-right]]);
            end

            if section == 'offline' then
                memberFrame:SetAlpha(0.6);
            else
                memberFrame:SetAlpha(1);
            end

           local classIconTexture = _G[memberFrame:GetName() .. "_ClassIcon_Texture"];
            classIconTexture:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster_Filtered[idx+index].class);
           
            local name = _G[memberFrame:GetName() .. "_Name_Text"];
            name:SetText(guild_Roster_Filtered[idx+index].name);


            local lvl = _G[memberFrame:GetName() .. "_Level_Text"];
            lvl:SetText(guild_Roster_Filtered[idx+index].lvl);

            if(guild_Roster_Filtered[idx+index].spec.main) then
                _G[memberFrame:GetName() .. "_MainSpec_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster_Filtered[idx+index].spec.main .. guild_Roster_Filtered[idx+index].class);
            end

            if(guild_Roster_Filtered[idx+index].spec.off) then
                _G[memberFrame:GetName() .. "_OffSpec_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster_Filtered[idx+index].spec.off .. guild_Roster_Filtered[idx+index].class);
            end
            
            if(guild_Roster_Filtered[idx+index].prof.main) then
                _G[memberFrame:GetName() .. "_MainProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster_Filtered[idx+index].prof.main);
            end

            if(guild_Roster_Filtered[idx+index].prof.off) then
                _G[memberFrame:GetName() .. "_OffProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster_Filtered[idx+index].prof.off);
            end

            local zone = _G[memberFrame:GetName() .. "_Zone_Text"];
            zone:SetText(guild_Roster_Filtered[idx+index].zone);

            if section == 'offline' then
                    name:SetTextColor(0.5, 0.5, 0.5);
                    lvl:SetTextColor(0.5, 0.5, 0.5);
                    zone:SetTextColor(0.5, 0.5, 0.5);
            else
                    name:SetTextColor(1, 1, 0);
                    lvl:SetTextColor(1, 1, 0);
                    zone:SetTextColor(1, 1, 0);
            end

            local rank = _G[memberFrame:GetName() .. "_Rank"];
            _G[memberFrame:GetName() .. "_Rank_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\rank_]] .. ToLowerCase(Trim(guild_Roster_Filtered[idx+index].rank)));

            if(guild_Roster_Filtered[idx+index].altOf) then
                rank:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP");
                    GameTooltip:SetText(ToUpperCase(guild_Roster_Filtered[idx+index].altOf), 1, 1, 1, true);
                    GameTooltip:Show();
                end)
        
                rank:SetScript("OnLeave", function()
                    GameTooltip:Hide();
                end)
            end
        end
    end
end

function LaFratellanza_MemberListInit()
    for idx = 1, 13 do
        local item = CreateFrame("Frame", "LaFratellanza_Member" .. idx, membersFrame, "LaFratellanza_Member_Template");

        if idx == 1 then
            item:SetPoint("TOP", 0, -60);
        else
            item:SetPoint("TOP", _G["LaFratellanza_Member" .. idx-1], "BOTTOM", 0, 0);
        end
    end
    isFirstOpen = false;
    LaFratellanza_MemberListUpdate(0);
end


function LaFratellanza_ScrollBarInit()
    scrollFrame = CreateFrame("ScrollFrame", "LaFratellanza_Main_Frame_Members_ScrollFrame", membersFrame, "UIPanelScrollFrameTemplate");
    slider = CreateFrame("Slider", "LaFratellanza_Main_Frame_Members_Slider", scrollFrame, "OptionsSliderTemplate");
    scrollChild = CreateFrame("Frame", "LaFratellanza_Main_Frame_Members_ScrollChild", scrollFrame);
    membersFrame.scrollFrame = scrollFrame;
    membersFrame.slider = slider;
    scrollFrame:SetPoint("CENTER", membersFrame, "CENTER", -26, -10);
    scrollFrame:SetSize(655, 430);
    scrollFrame:EnableMouseWheel(true);

    slider:SetSize(25, 445);
    slider:SetPoint("LEFT", membersFrame, "RIGHT", -82, -10);
    slider:SetBackdrop({
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 },
    });
    _G[slider:GetName() .. 'Low']:SetText('');
    _G[slider:GetName() .. 'High']:SetText('');
end

function LaFratellanza_ScrollBarUpdate()
    local minValue = 1;
    local addValue = 0
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

function LaFratellanza_GuildRosterFiltered()

    guild_Roster_Filtered = {}

    if(profFilter ~= "All professions" or specFilter ~= "All specs") then

        if(specFilter ~= "All specs") then
            print("specFilter" .. specFilter)
            for _, member in ipairs(guild_Roster[section]) do
                if (member.spec.main == specFilter or member.spec.off == specFilter) then
                    table.insert(guild_Roster_Filtered, member)
                end
            end
        end

        if(profFilter ~= "All professions") then
            for _, member in ipairs(guild_Roster[section]) do
                if (member.prof.main == profFilter or member.prof.off == profFilter) then
                    table.insert(guild_Roster_Filtered, member)
                end
            end
        end

    else
        guild_Roster_Filtered = guild_Roster[section]
    end

end


function LaFratellanza_MembersFrameInit()

    LaFratellanza_GuildRosterFiltered()

    listLength = #guild_Roster_Filtered;
    membersFrame:Show();

    if(isFirstOpen) then
        LaFratellanza_ScrollBarInit()
    end

    LaFratellanza_ScrollBarUpdate()

    if(isFirstOpen) then   
        LaFratellanza_MemberListInit();
    else
        LaFratellanza_MemberListUpdate(0);
    end
    
end

function LaFratellanza_BuildArrayOfName(maxMembers)
    for i = 1, maxMembers do
        local name = GetGuildRosterInfo(i);
        if name ~= nil then
            guild_Roster_Names[string.lower(name)] = true
        end
    end
end

function LaFratellanza_RosterInit()
    local CVarValue = GetCVar("guildShowOffline")
    -- set a true della variabile config guildShowOffline (se è disattivata, getNumGuildMembers torna solo il numero di player online)
     SetCVar("guildShowOffline", 1);
     GuildRoster();
     guild_Roster["online"] = {};
     guild_Roster["offline"] = {};
     local maxMembers = GetNumGuildMembers();
     membersFrame = _G["LaFratellanza_Main_Frame_Members"];

     maxMembers = GetNumGuildMembers();
     if maxMembers ~= nil then
        LaFratellanza_BuildArrayOfName(maxMembers)
         for i = 1, maxMembers do
             local name, rank, _, lvl, cl, zone, note, offNote, online, status, class = GetGuildRosterInfo(i);
             if name ~= nil then
                if online == 1 then
                    table.insert(guild_Roster["online"], LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class));
                else
                    table.insert(guild_Roster["offline"], LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class));
                end
             end
         end
         _G["LaFratellanza_Main_Frame_Members_RosterStatus"]:SetText("Online: " .. #guild_Roster["online"] .. "/" .. #guild_Roster["online"]+#guild_Roster["offline"]);
         LaFratellanza_MembersFrameInit();
     end
     SetCVar("guildShowOffline", CVarValue);
 end

function LaFratellanza_CloseMainFrame()
    _G["LaFratellanza_Main_Frame"]:Hide();
    membersFrame = nil
    isMainFrameOpended = false;
end

function LaFratellanza_ShowMainFrame()
    _G["LaFratellanza_Main_Frame"]:Show();
    isMainFrameOpended = true;
end

function LaFratellanza_MenuButton_OnClick(self)
    local buttonName = self:GetName();
    if buttonName == "LaFratellanza_Button1" then
        LaFratellanza_ShowMembersFrame();
    elseif buttonName == "LaFratellanza_Button2" then
        LaFratellanza_ShowRulesFrame();
    elseif buttonName == "LaFratellanza_Button3" then
        LaFratellanza_ShowChatFrame();
    elseif buttonName == "LaFratellanza_Button4" then
        LaFratellanza_ShowStatsFrame();
    end
end

mainButton:SetScript("OnClick", function()
    if isMainFrameOpended == false then
        LaFratellanza_ShowMainFrame();
        LaFratellanza_RosterInit();
    else
        LaFratellanza_CloseMainFrame();
    end
end)


local previousSelection = "Online";
local previousSpecFilter = "All specs";

function LaFratellanza_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = LaFratellanza_DropDownOnClick;

    if level == 1 then
        info.text = "Online";
        info.value = "Online";
        UIDropDownMenu_AddButton(info);

        info.text = "Offline";
        info.value = "Offline";
        UIDropDownMenu_AddButton(info);
    end
end

function LaFratellanza_DropDownOnClick(self, arg1, arg2, checked)
    if self.value ~= previousSelection then
        previousSelection = self.value;

        local dropDownButton = _G["LaFratellanza_DropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);

        section = ToLowerCase(self.value);
        LaFratellanza_MembersFrameInit();
    end

end

function LaFratellanza_InitSpecsDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = LaFratellanza_SpecsDropDownOnClick;

    if level == 1 then
        info.text = "All specs";
        info.value = "All specs";
        UIDropDownMenu_AddButton(info)

        info.text = "Frost";
        info.value = "Frost";
        UIDropDownMenu_AddButton(info)

        info.text = "Restoration";
        info.value = "Restoration";
        UIDropDownMenu_AddButton(info)

        info.text = "Feral";
        info.value = "Feral";
        UIDropDownMenu_AddButton(info)

        info.text = "Balance";
        info.value = "Balance";
        UIDropDownMenu_AddButton(info)

        info.text = "Guardian";
        info.value = "Guardian";
        UIDropDownMenu_AddButton(info)

        info.text = "BeastMastery";
        info.value = "BeastMastery";
        UIDropDownMenu_AddButton(info)

        info.text = "Marksmanship";
        info.value = "Marksmanship";
        UIDropDownMenu_AddButton(info)

        info.text = "Survival";
        info.value = "Survival";
        UIDropDownMenu_AddButton(info)

        info.text = "Affliction";
        info.value = "Affliction";
        UIDropDownMenu_AddButton(info)

        info.text = "Destruction";
        info.value = "Destruction";
        UIDropDownMenu_AddButton(info)

        info.text = "Demonology";
        info.value = "Demonology";
        UIDropDownMenu_AddButton(info)

        info.text = "Shadow";
        info.value = "Shadow";
        UIDropDownMenu_AddButton(info)

        info.text = "Discipline";
        info.value = "Discipline";
        UIDropDownMenu_AddButton(info)

        info.text = "Holy";
        info.value = "Holy";
        UIDropDownMenu_AddButton(info)

        info.text = "Fire";
        info.value = "Fire";
        UIDropDownMenu_AddButton(info)

        info.text = "Arcane";
        info.value = "Arcane";
        UIDropDownMenu_AddButton(info)

        info.text = "Protection";
        info.value = "Protection";
        UIDropDownMenu_AddButton(info)

        info.text = "Fury";
        info.value = "Fury";
        UIDropDownMenu_AddButton(info)

        info.text = "Arms";
        info.value = "Arms";
        UIDropDownMenu_AddButton(info)

        info.text = "Retribution";
        info.value = "Retribution";
        UIDropDownMenu_AddButton(info)

        info.text = "Combat";
        info.value = "Combat";
        UIDropDownMenu_AddButton(info)

        info.text = "Assassination";
        info.value = "Assassination";
        UIDropDownMenu_AddButton(info)

        info.text = "Subtlety";
        info.value = "Subtlety";
        UIDropDownMenu_AddButton(info)

        info.text = "Elemental";
        info.value = "Elemental";
        UIDropDownMenu_AddButton(info)

        info.text = "Enhancement";
        info.value = "Enhancement";
        UIDropDownMenu_AddButton(info)

    end
end

function LaFratellanza_SpecsDropDownOnClick(self, arg1, arg2, checked)
    if self.value ~= previousSpecFilter then
        previousSpecFilter = self.value;

        print(self.value)

        local dropDownButton2 = _G["LaFratellanza_DropDownButton2"];
        UIDropDownMenu_SetText(dropDownButton2, self.value);

        specFilter = self.value;
        LaFratellanza_MembersFrameInit();
    end

end




LaFratellanza:RegisterEvent("GUILD_ROSTER_UPDATE");
LaFratellanza:RegisterEvent("PLAYER_ENTERING_WORLD");

LaFratellanza:SetScript("OnEvent", function(self, event, ...)
    if event == "GUILD_ROSTER_UPDATE" then

    end

    if event == "PLAYER_ENTERING_WORLD" then

    end
end)



