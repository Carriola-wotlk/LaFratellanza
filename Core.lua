LaFratellanza = CreateFrame("Frame");
LaFratellanza_main_button = CreateFrame("Button", "LaFratellanzaInitialButton", UIParent, "UIPanelButtonTemplate");
LaFratellanza_main_button:SetPoint("LEFT", 0, 0);
LaFratellanza_main_button:SetSize(100, 30);
LaFratellanza_main_button:SetText("La Fratellanza");
LaFratellanza_main_button:SetMovable(true);
LaFratellanza_main_button:RegisterForDrag("LeftButton");
LaFratellanza_main_button:SetScript("OnDragStart", LaFratellanza_main_button.StartMoving);
LaFratellanza_main_button:SetScript("OnDragStop", LaFratellanza_main_button.StopMovingOrSizing);
local playerName = UnitName("player");
local messages = {};



function LaFratellanza_CloseCustomChat()
    for idx = 1, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(idx);
        if name == "LaFratellanzaProfessioni" then
            FCF_Close(_G["ChatFrame" .. idx])
        end
    end
end

function LaFratellanza_CloseMainFrame()
    LaFratellanza_ShowMembersFrame();
    _G["LaFratellanza_Main_Frame"]:Hide();
    LaFratellanza_guild_roster = {
        online = {},
        offline = {},
    };
end

function LaFratellanza_ShowMainFrame()
    _G["LaFratellanza_Main_Frame"]:Show();
    LaFratellanza_RefreshMembers();
end

function LaFratellanza_MainFrameToggle()
   if _G["LaFratellanza_Main_Frame"]:IsShown() then
        LaFratellanza_CloseMainFrame();
    else
        LaFratellanza_ShowMainFrame();
    end
end

function LaFratellanza_MenuButton_OnClick(self)
    local buttonName = self:GetName();
    if buttonName == "LaFratellanza_Button1" then
        LaFratellanza_navBar_current_button = "membri";
        LaFratellanza_ShowMembersFrame();
    elseif buttonName == "LaFratellanza_Button2" then
        LaFratellanza_navBar_current_button = "regolamento";
        LaFratellanza_ShowRulesFrame();
    end
end


LaFratellanza_main_button:SetScript("OnClick", function()
    LaFratellanza_MainFrameToggle();
end)

LaFratellanza:RegisterEvent("GUILD_ROSTER_UPDATE");
LaFratellanza:RegisterEvent("CHAT_MSG_ADDON");
LaFratellanza:RegisterEvent("PLAYER_LOGOUT");
LaFratellanza:RegisterEvent("PLAYER_LOGIN");

function LaFratellanza_ProfChatFrameInit()
    local background = CreateFrame("Frame", "LaFratellanza_ChatFrame_Backgroud", LaFratellanza_main_frame);
    background:SetSize(256, 256);
    background:SetPoint("LEFT", LaFratellanza_main_frame, "TOPRIGHT", -15, -150);
    background:SetBackdrop({
        bgFile = "Interface\\AddOns\\LaFratellanza\\texture\\frames\\finestra-laterale.tga",
        tile = false,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    background:SetFrameLevel(LaFratellanza_main_frame:GetFrameLevel()-1);

    LaFratellanza_chatFrame = FCF_OpenNewWindow("LaFratellanzaProfessioni");
    LaFratellanza_chatFrameTab = _G["ChatFrame" .. LaFratellanza_chatFrame:GetID() .. "Tab"];
    LaFratellanza_chatFrameButtonFrame = _G["ChatFrame" .. LaFratellanza_chatFrame:GetID() .. "ButtonFrame"];
    LaFratellanza_chatFrameEditBox = _G["ChatFrame" .. LaFratellanza_chatFrame:GetID() .. "EditBox"];

    ChatFrame_RemoveAllMessageGroups(LaFratellanza_chatFrame);
    ChatFrame_AddMessageGroup(LaFratellanza_chatFrame, "ADDON");
    
    LaFratellanza_chatFrame:SetScript("OnEvent", function(self, event, prefix, message)
        if event == "CHAT_MSG_ADDON" and prefix == LaFratellanza_channel then
            if string.sub(message, 1, 3) == "Res" then
                self:AddMessage(string.sub(message, 5));
                table.insert(messages, string.sub(message, 5));
            end
        end
    end)
    LaFratellanza_chatFrame:RegisterEvent("CHAT_MSG_ADDON");
	CURRENT_CHAT_FRAME_ID = LaFratellanza_chatFrame:GetID();
	FCF_ToggleLock();
	LaFratellanza_chatFrame:SetParent(_G["LaFratellanza_Main_Frame"]);
    LaFratellanza_chatFrameTab:SetParent(_G["LaFratellanza_Main_Frame"]);
    LaFratellanza_chatFrameButtonFrame:SetParent(_G["LaFratellanza_Main_Frame"]);
    LaFratellanza_chatFrameEditBox:SetParent(_G["LaFratellanza_Main_Frame"]);

	LaFratellanza_chatFrame:ClearAllPoints();
	LaFratellanza_chatFrame:SetFrameLevel(_G["LaFratellanza_Main_Frame"]:GetFrameLevel()-1);
	LaFratellanza_chatFrame:SetWidth(220);
	LaFratellanza_chatFrame:SetHeight(180);
	LaFratellanza_chatFrame:SetPoint("TOPLEFT", _G["LaFratellanza_Main_Frame"],"TOPRIGHT", 10, -70);

    LaFratellanza_chatFrameButtonFrame:SetWidth(0);
	LaFratellanza_chatFrameButtonFrame:SetHeight(0);
    LaFratellanza_chatFrameButtonFrame:ClearAllPoints();
    LaFratellanza_chatFrameButtonFrame:SetPoint("TOPRIGHT", UIParent,"TOPRIGHT", 0, 0);
    LaFratellanza_chatFrameButtonFrame:SetFrameLevel(_G["LaFratellanza_Main_Frame"]:GetFrameLevel()-1);

    LaFratellanza_chatFrameEditBox:ClearAllPoints();
    LaFratellanza_chatFrameEditBox:SetWidth(20);
    LaFratellanza_chatFrameEditBox:SetHeight(20);
    LaFratellanza_chatFrameButtonFrame:SetPoint("TOPRIGHT", UIParent,"TOPRIGHT", 0, 0);

    FCF_SetLocked(LaFratellanza_chatFrame, 1);
    FCF_SetWindowAlpha(LaFratellanza_chatFrame, 0);
    LaFratellanza_chatFrame:SetMovable( false );
    LaFratellanza_chatFrame:SetResizable( false );

    for i = 1, #messages do
        LaFratellanza_chatFrame:AddMessage(message[i]);
    end

    local header = CreateFrame("Frame", "LaFratellanza_ChatFrame_Header", LaFratellanza_main_frame);
    header:SetSize(256, 64);
    header:SetPoint("LEFT", LaFratellanza_main_frame, "TOPRIGHT", -15, -55);
    header:SetBackdrop({
        bgFile = "Interface\\AddOns\\LaFratellanza\\texture\\frames\\header-finestra-laterale.tga",
        tile = false,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    header:SetFrameLevel(LaFratellanza_chatFrameTab:GetFrameLevel()+10);

    local headerTitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    headerTitle:SetPoint("TOPLEFT", header, "TOPLEFT", 30, -30);
    headerTitle:SetText("LINK PROFESSIONI");
end


LaFratellanza:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if event == "PLAYER_LOGOUT" then
        LaFratellanza_CloseCustomChat();
        for idx = 1, NUM_CHAT_WINDOWS do
            local name = GetChatWindowInfo(idx);
            if name == "LaFratellanzaProfessioni" then
                FCF_Close(_G["ChatFrame" .. idx])
            end
        end
    end

    if event == "CHAT_MSG_ADDON" and prefix == LaFratellanza_channel then
        local msgType = string.sub(message, 1, 3);
        local prof = string.sub(message, 5);
        if msgType == "Req" then
            local jewelcraftingLink = select(2,  GetSpellLink(prof));
            local msg = "Res:" .. "|cff00A2FF ------| " .. playerName .. ":|r " .. jewelcraftingLink .. "|cff00A2FF |------ |r";
            SendAddonMessage(LaFratellanza_channel, msg, "WHISPER", sender);
        end
    end

    if event == "CHAT_MSG_ADDON" and prefix == LaFratellanza_channel then
        local msgType = string.sub(message, 1, 3);
        local link = string.sub(message, 5);
        if msgType == "Res" then
           print(link);
        end
    end

    if event == "PLAYER_LOGIN" then
        LaFratellanza_CloseCustomChat();
        LaFratellanza_main_frame = _G["LaFratellanza_Main_Frame"];
        LaFratellanza_members_frame = _G["LaFratellanza_Main_Frame_Members"];
        LaFratellanza_ProfChatFrameInit();
        LaFratellanza_InitNoteFrame();
        LaFratellanza_RefreshMembers();
        LaFratellanza_RulesFrameInit()
    end

    if event == "GUILD_ROSTER_UPDATE" then
       if _G["LaFratellanza_Main_Frame"]:IsShown() then
            if(LaFratellanza_rosterInProgress == false) then
                LaFratellanza_RosterBuild();
            end
       end
    end
end)

tinsert(UISpecialFrames, "LaFratellanza_Main_Frame");