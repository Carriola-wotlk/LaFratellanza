local navBar = {"membri", "regolamento", "chat", "stats"}
local isMainFrameOpended = false
local LaFratellanza = CreateFrame("Frame")
local guild_Roster = {
    online = {},
    offline = {},
}
local section = "online"

-- MEMBERS
local listLength = 0
local membersFrame

local profTable = {
    ski = "Skinning",
    alc = "Alchemy",
    alk = "Alchemy",
    ak = "Alchemy",
    bla = "Blacksmithing",
    bs = "Blacksmithing",
    enc = "Enchanting",
    eng = "Engineering",
    her = "Herbalism",
    erb = "Herbalism",
    ins = "Inscription",
    jew = "Jewelcrafting",
    jc = "Jewelcrafting",
    jw = "Jewelcrafting",
    let = "Leatherworking",
    lw = "Leatherworking",
    min = "Mining",
    tai = "Tailoring",
    fis = "Fishing",
    coo = "Cooking",
}

local specTable = {
    unh = "Unholy",
    fro = "Frost",
    blo = "Blood",

    res = "Restoration",
    fer = "Feral",
    bal = "Balance",

    bea = "BeastMastery",
    bm = "BeastMastery",
    mar = "Marksmanship",
    mm = "Marksmanship",
    sur = "Survival",

    aff = "Affliction",
    des = "Destruction",
    dem = "Demonology",

    sha = "Shadow",
    dis = "Discipline",
    hol = "Holy",

    fir ="Fire",
    arc = "Arcane",

    pro = "Protection",
    fur = "Fury",
    arm = "Arms",

    ret = "Retribution",

    com = "Combat",
    ass = "Assassination",
    sub = "Subtlety",

    ele = "Elemental",
    enh = "Enhancement",
    ena = "Enhancement",
}

local mainButton = CreateFrame("Button", "LaFratellanzaInitialButton", UIParent, "UIPanelButtonTemplate")
mainButton:SetPoint("LEFT", 0, 0)
mainButton:SetSize(100, 30)
mainButton:SetMovable(true)
mainButton:SetText("La Fratellanza")



-- UTILS ----------------------------------------------
function Trim(s)
    return s:match'^%s*(.*%S)' or ''
end

function ToLowerCase(s)
    return s:lower()
end

function ToUpperCase(s)
    return s:upper()
end

----------------------------------------------------------------

function LaFratellanza_OnLoad(self)
    self.items = {}
    for idx, value in ipairs(navBar) do
        local item = CreateFrame("Button", "LaFratellanza_Button" .. idx, self, "LaFratellanzaMenuButtonTemplate")
        self.items[idx] = item
        _G["LaFratellanza_Button" .. idx .. "_Voice"]:SetText(value)
        _G["LaFratellanza_Button" .. idx .. "_IconTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. value .. "_icon")

        if idx == 1 then
            item:SetPoint("LEFT", 30, 20)
            _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]])
        else
            item:SetPoint("TOPLEFT", self.items[idx-1], "BOTTOMLEFT", 0, -12) 
        end
    end

end

function LaFratellanza_ShowMembersFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]])
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_Button3_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_Button4_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\members-bottom-right]])
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\members-top-right]])
    _G["LaFratellanza_Main_Frame_Members"]:Show()
end

function LaFratellanza_ShowRulesFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]])
    _G["LaFratellanza_Button3_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_Button4_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\regolamento-bottom-right]])
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\regolamento-top-right]])
    _G["LaFratellanza_Main_Frame_Members"]:Hide()
end

function LaFratellanza_ShowChatFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_Button3_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]])
    _G["LaFratellanza_Button4_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]])
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\chat-bottom-right]])
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\chat-top-right]])
    _G["LaFratellanza_Main_Frame_Members"]:Hide()
end

function LaFratellanza_ShowStatsFrame()
    --_G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\regolamento-bottom-right]])
    --_G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\regolamento-top-right]])
end

function LaFratellanza_CloseMainFrame()
    _G["LaFratellanza_Main_Frame"]:Hide()
    isMainFrameOpended = false
end

function LaFratellanza_ShowMainFrame()
    _G["LaFratellanza_Main_Frame"]:Show()
    isMainFrameOpended = true
end

function LaFratellanza_MenuButton_OnClick(self)
    local buttonName = self:GetName()
    if buttonName == "LaFratellanza_Button1" then
        LaFratellanza_ShowMembersFrame()
    elseif buttonName == "LaFratellanza_Button2" then
        LaFratellanza_ShowRulesFrame()
    elseif buttonName == "LaFratellanza_Button3" then
        LaFratellanza_ShowChatFrame()
    elseif buttonName == "LaFratellanza_Button4" then
        LaFratellanza_ShowStatsFrame()
    end
end



-------------------------------------------
--- MEMBERS FRAME
------------------------------------------
function SplitString(inputString)
    local words = {}
    for word in string.gmatch(inputString, "[^%s/-]+") do
        table.insert(words, string.lower(word))
    end
    return words
end

function LaFratellanza_DecodeNote(elements, result, name)

    local indexProf = 1
    local indexSpec = 1

    for i, element in ipairs(elements) do

        if element == "main" then
            result.isAlt = false
        elseif element == "alt" then
            result.isAlt = true
        else
            local temp = element

            if #temp > 3 then
                temp = string.sub(temp, 1, 3)
            end

            if profTable[temp] ~= nil then
                if indexProf == 1 then
                    result["prof"].main = profTable[temp]
                    indexProf = 2
                elseif indexProf == 2 then
                    result["prof"].off = profTable[temp]
                end
            elseif specTable[temp] ~= nil then
                if indexSpec == 1 then
                    result["spec"].main = specTable[temp]
                    indexSpec = 2
                elseif indexSpec == 2 then
                    result["spec"].off = specTable[temp]
                end
            elseif result.isAlt then
                result.altOf = element
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
        }

        -- ALT ha uno spazio alla fine
        -- todo: stringa da trimmare
        if rank == "ALT " then
            result.isAlt = true
        end

    local elements = SplitString(note)
    LaFratellanza_DecodeNote(elements, result, name)
    return result
end


function LaFratellanza_ClearMemberRow()
    for idx = 1, 13 do
        _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Left"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_Background_Texture_Right"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_ClassIcon_Texture"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_ClassIcon"]:SetScript("OnEnter", nil)
        _G["LaFratellanza_Member" .. idx .. "_Name_Text"]:SetText(nil)
        _G["LaFratellanza_Member" .. idx .. "_Level_Text"]:SetText(nil)
        _G["LaFratellanza_Member" .. idx .. "_MainSpec_Texture"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_OffSpec_Texture"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_MainProf_Texture"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_OffProf_Texture"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_MainSpec"]:SetScript("OnEnter", nil)
        _G["LaFratellanza_Member" .. idx .. "_OffSpec"]:SetScript("OnEnter", nil)
        _G["LaFratellanza_Member" .. idx .. "_MainProf"]:SetScript("OnEnter", nil)
        _G["LaFratellanza_Member" .. idx .. "_OffProf"]:SetScript("OnEnter", nil)
        _G["LaFratellanza_Member" .. idx .. "_Zone_Text"]:SetText(nil)
        _G["LaFratellanza_Member" .. idx .. "_Rank_Texture"]:SetTexture(nil)
        _G["LaFratellanza_Member" .. idx .. "_Rank"]:SetScript("OnEnter", nil)
    end
end


function LaFratellanza_MemberListUpdate(index)
    print("index ----->", index)
  
    LaFratellanza_ClearMemberRow()
    for idx = 1, 13 do
        if(guild_Roster[section][idx+index].name) then
            local memberFrame = _G["LaFratellanza_Member" .. idx]
            local memberTextureLeft = _G[memberFrame:GetName() .. "_Background_Texture_Left"]
            local memberTextureRight = _G[memberFrame:GetName() .. "_Background_Texture_Right"]
            memberTextureLeft:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-left]])
            memberTextureRight:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\member-right]])
            local background = _G[memberFrame:GetName() .. "_Background"]

            background:EnableMouse(true)

            if section == 'offline' then
                memberFrame:SetAlpha(0.6)
            else
                memberFrame:SetAlpha(1)
            end

            local classIcon = _G[memberFrame:GetName() .. "_ClassIcon"]
            local classIconTexture = _G[memberFrame:GetName() .. "_ClassIcon_Texture"]
            classIconTexture:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx+index].class)

            classIcon:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:SetText(guild_Roster[section][idx+index].class, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        
            classIcon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)


            local name = _G[memberFrame:GetName() .. "_Name_Text"]
            name:SetText(guild_Roster[section][idx+index].name)


            local lvl = _G[memberFrame:GetName() .. "_Level_Text"]
            lvl:SetText(guild_Roster[section][idx+index].lvl)

            if(guild_Roster[section][idx+index].spec.main) then
                local mainSpec = _G[memberFrame:GetName() .. "_MainSpec"]
                _G[memberFrame:GetName() .. "_MainSpec_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx+index].spec.main .. guild_Roster[section][idx+index].class)
           
                mainSpec:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:SetText(ToUpperCase(guild_Roster[section][idx+index].spec.main), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        
                mainSpec:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end

            if(guild_Roster[section][idx+index].spec.off) then
                local offSpec = _G[memberFrame:GetName() .. "_OffSpec"]
                _G[memberFrame:GetName() .. "_OffSpec_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx+index].spec.off .. guild_Roster[section][idx+index].class)
                offSpec:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:SetText(ToUpperCase(guild_Roster[section][idx+index].spec.off), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        
                offSpec:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end
            
            if(guild_Roster[section][idx+index].prof.main) then
                local mainProf = _G[memberFrame:GetName() .. "_MainProf"]
                _G[memberFrame:GetName() .. "_MainProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx+index].prof.main)
                mainProf:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:SetText(ToUpperCase(guild_Roster[section][idx+index].prof.main), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        
                mainProf:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end
            if(guild_Roster[section][idx+index].prof.off) then
                local offProf = _G[memberFrame:GetName() .. "_OffProf"]
                _G[memberFrame:GetName() .. "_OffProf_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx+index].prof.off)
                offProf:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:SetText(ToUpperCase(guild_Roster[section][idx+index].prof.off), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        
                offProf:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end

            local zone = _G[memberFrame:GetName() .. "_Zone_Text"]
            zone:SetText(guild_Roster[section][idx+index].zone)

            if section == 'offline' then
                    name:SetTextColor(0.5, 0.5, 0.5)
                    lvl:SetTextColor(0.5, 0.5, 0.5)
                    zone:SetTextColor(0.5, 0.5, 0.5)
            else
                    name:SetTextColor(1, 1, 0)
                    lvl:SetTextColor(1, 1, 0)
                    zone:SetTextColor(1, 1, 0)
            end

            local rank = _G[memberFrame:GetName() .. "_Rank"]
            _G[memberFrame:GetName() .. "_Rank_Texture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\rank_]] .. ToLowerCase(Trim(guild_Roster[section][idx+index].rank)))

            if(guild_Roster[section][idx+index].altOf) then
                rank:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:SetText(ToUpperCase(guild_Roster[section][idx+index].altOf), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        
                rank:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end
        end
    end
end

function LaFratellanza_MemberListInit()
    for idx = 1, 13 do
        local item = CreateFrame("Frame", "LaFratellanza_Member" .. idx, membersFrame, "LaFratellanza_Member_Template")
        
        if idx == 1 then
            item:SetPoint("TOP", 0, -60)
        else
            item:SetPoint("TOP", _G["LaFratellanza_Member" .. idx-1], "BOTTOM", 0, 0)
        end
    end

    LaFratellanza_MemberListUpdate(0)
end



function LaFratellanza_ScrollBarInit(listLength)
    local scrollFrame = CreateFrame("ScrollFrame", "LaFratellanza_Main_Frame_Members_ScrollFrame", membersFrame, "UIPanelScrollFrameTemplate")
    local slider = CreateFrame("Slider", "LaFratellanza_Main_Frame_Members_Slider", scrollFrame, "OptionsSliderTemplate")
    membersFrame.scrollFrame = scrollFrame
    membersFrame.slider = slider

    scrollFrame:SetPoint("CENTER", membersFrame, "CENTER", -26, -10)
    scrollFrame:SetSize(655, 430)
    scrollFrame:EnableMouseWheel(true)

    slider:SetSize(25, 445)
    slider:SetPoint("LEFT", membersFrame, "RIGHT", -82, -10)
    slider:SetBackdrop({
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 },
    })
    _G[slider:GetName() .. 'Low']:SetText('')
    _G[slider:GetName() .. 'High']:SetText('')
    local scrollChild = CreateFrame("Frame", "LaFratellanza_Main_Frame_Members_ScrollChild", scrollFrame)

    local minValue = 1
    local maxValue = (listLength*32)+160
    scrollChild:SetSize(665, maxValue)
    scrollChild:SetPoint("RIGHT", membersFrame, "LEFT", 0, 0)
    scrollFrame:SetScrollChild(scrollChild)

    local stepSize = 5 * 32

    scrollFrame:SetScript("OnVerticalScroll", function(self, value)
        local newValue = math.max(160, math.floor(value / stepSize + 0.5) * stepSize)
        newValue = math.min(maxValue, math.max(minValue, newValue))
 
        if(value == 0) then
            LaFratellanza_MemberListUpdate(0)
        else
            LaFratellanza_MemberListUpdate(newValue / 32)
        end
    end)
end


function LaFratellanza_MembersFrameInit()
    
    listLength = #guild_Roster[section]

    
    print("listLength    ->" .. listLength)

    membersFrame:Show()

    if(listLength > 13) then
        LaFratellanza_ScrollBarInit(listLength)
    end
    
    LaFratellanza_MemberListInit()

end


function LaFratellanza_RosterInit()
    local CVarValue = GetCVar("guildShowOffline")
    -- set a true della variabile config guildShowOffline (se è disattivata, getNumGuildMembers torna solo il numero di player online)
     SetCVar("guildShowOffline", 1)
     GuildRoster()
     guild_Roster["online"] = {}
     guild_Roster["offline"] = {}
     local maxMembers = GetNumGuildMembers()
     membersFrame = _G["LaFratellanza_Main_Frame_Members"]

     maxMembers = GetNumGuildMembers()
     if maxMembers ~= nil then
         for i = 1, maxMembers do
             local name, rank, _, lvl, cl, zone, note, offNote, online, status, class = GetGuildRosterInfo(i)
             if name ~= nil then
                if online == 1 then
                    table.insert(guild_Roster["online"], LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class))
                else
                    table.insert(guild_Roster["offline"], LaFratellanza_GetMemberProps(name, rank, lvl, cl, zone, note, offNote, online, status, class))
                end
             end
         end
         _G["LaFratellanza_Main_Frame_Members_RosterStatus"]:SetText("Online: " .. #guild_Roster["online"] .. "/" .. #guild_Roster["online"]+#guild_Roster["offline"])
         LaFratellanza_MembersFrameInit()
     end
     SetCVar("guildShowOffline", CVarValue)
 end


mainButton:SetScript("OnClick", function()
    if isMainFrameOpended == false then
        LaFratellanza_ShowMainFrame()
        LaFratellanza_RosterInit()
    else
        LaFratellanza_CloseMainFrame()
    end
end)


local previousSelection = "Online"

function LaFratellanza_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    info.func = LaFratellanza_DropDownOnClick

    if level == 1 then
        info.text = "Online"
        info.value = "Online"
        UIDropDownMenu_AddButton(info)

        info.text = "Offline"
        info.value = "Offline"
        UIDropDownMenu_AddButton(info)
    end
end

function LaFratellanza_DropDownOnClick(self, arg1, arg2, checked)
    if self.value ~= previousSelection then
        previousSelection = self.value

        local dropDownButton = _G["LaFratellanza_DropDownButton"]
        UIDropDownMenu_SetText(dropDownButton, self.value)

        section = ToLowerCase(self.value)
        LaFratellanza_MembersFrameInit()
    end

end



LaFratellanza:RegisterEvent("GUILD_ROSTER_UPDATE")
LaFratellanza:RegisterEvent("PLAYER_ENTERING_WORLD")