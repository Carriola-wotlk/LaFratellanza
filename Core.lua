local navBar = {"membri", "regolamento", "chat", "stats"}
local isMainFrameOpended = false
local LaFratellanza = CreateFrame("Frame")
local guild_Roster = {
    online = {},
    offline = {},
}
local modeView = "online"

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

    bea = "Beast Mastery",
    bm = "Beast Mastery",
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
    ass = "Assassin",
    sub = "Subtlety",

    ele = "Elemental",
    enh = "Enhancement",
}

local mainButton = CreateFrame("Button", "LaFratellanzaInitialButton", UIParent, "UIPanelButtonTemplate")
mainButton:SetPoint("LEFT", 0, 0)
mainButton:SetSize(100, 30)
mainButton:SetMovable(true)
mainButton:SetText("La Fratellanza")

function LaFratellanza_OnLoad(self)
    self.items = {}
    for idx, value in ipairs(navBar) do
        local item = CreateFrame("Button", "LaFratellanza_Button" .. idx, self, "LaFratellanzaButtonTemplate")
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


function LaFratellanza_MembersFrameInit(section)
    local membersFrame = _G["LaFratellanza_Main_Frame_Members"]
    local listLength = #guild_Roster["online"]

    membersFrame:Show()

    if listLength > 12 then
        listLength = 12
    end

    for i, player in ipairs(guild_Roster["offline"]) do
        if(player.name == "Becchino") then
            print("EEEEEEEEEEEEEEEEEEEEEEEEE")
            print(player.prof.main)
            print(player.prof.off)
            print(player.spec.main)
            print(player.spec.off)
            print(player.altOf)
        end
    end

    for idx = 1, listLength do
        local item = CreateFrame("Frame", "LaFratellanza_Member" .. idx, membersFrame, "LaFratellanza_Member_Template")
        _G["LaFratellanza_Member" .. idx .. "_IconTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx].class)
        _G["LaFratellanza_Member" .. idx .. "_Voice"]:SetText(guild_Roster[section][idx].name)
        _G["LaFratellanza_Member" .. idx .. "_Level"]:SetText(guild_Roster[section][idx].lvl)
        _G["LaFratellanza_Member" .. idx .. "_MainSpec"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx].class)
        _G["LaFratellanza_Member" .. idx .. "_OffSpec"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx].class)
        if(guild_Roster[section][idx].prof.main) then
            _G["LaFratellanza_Member" .. idx .. "_MainProf"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx].prof.main)
        end
        if(guild_Roster[section][idx].prof.off) then
            _G["LaFratellanza_Member" .. idx .. "_OffProf"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. guild_Roster[section][idx].prof.off)
        end
        _G["LaFratellanza_Member" .. idx .. "_Zone"]:SetText(guild_Roster[section][idx].zone)
        if idx == 1 then
            item:SetPoint("TOP", 0, -90)
        else
            item:SetPoint("TOP", _G["LaFratellanza_Member" .. idx-1], "BOTTOM", 0, 0)
        end
    end
end


function LaFratellanza_RosterInit()
    -- set a true della variabile config guildShowOffline (se è disattivata, getNumGuildMembers torna solo il numero di player online)
     SetCVar("guildShowOffline", 1)
     local maxMembers = GetNumGuildMembers()
     if maxMembers == 0 then
        GuildRoster()
     end

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
         LaFratellanza_MembersFrameInit("online")
     end
     SetCVar("guildShowOffline", 0)
 end





function LaFratellanza_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    if event == "PLAYER_ENTERING_WORLD" then
        --LaFratellanza_RosterInit()
    end
end

mainButton:SetScript("OnClick", function()
    if #guild_Roster["online"] == 0 then
        GuildRoster()
        LaFratellanza_RosterInit()
    end
    if isMainFrameOpended == false then
        LaFratellanza_ShowMainFrame()
    else
        LaFratellanza_CloseMainFrame()
    end
end)

LaFratellanza:RegisterEvent("GUILD_ROSTER_UPDATE")
LaFratellanza:RegisterEvent("PLAYER_ENTERING_WORLD")
LaFratellanza:SetScript("OnEvent", LaFratellanza_OnEvent)