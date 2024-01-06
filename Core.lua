LaFratellanza = CreateFrame("Frame");
LaFratellanza_main_button = CreateFrame("Button", "LaFratellanzaInitialButton", UIParent, "UIPanelButtonTemplate");
LaFratellanza_main_button:SetPoint("LEFT", 0, 0);
LaFratellanza_main_button:SetSize(100, 30);
LaFratellanza_main_button:SetMovable(true);
LaFratellanza_main_button:SetText("La Fratellanza");
LaFratellanza_main_button:SetMovable(true);
LaFratellanza_main_button:RegisterForDrag("LeftButton");
LaFratellanza_main_button:SetScript("OnDragStart", LaFratellanza_main_button.StartMoving);
LaFratellanza_main_button:SetScript("OnDragStop", LaFratellanza_main_button.StopMovingOrSizing);

function LaFratellanza_CloseMainFrame()
    LaFratellanza_is_open = false;
    _G["LaFratellanza_Main_Frame"]:Hide();
    GuildRoster();
end

function LaFratellanza_ShowMainFrame()
    LaFratellanza_is_open = true;
    GuildRoster();
    _G["LaFratellanza_Main_Frame"]:Show();
    LaFratellanza_RosterInit();
end

function LaFratellanza_MainFrameToggle()
    if LaFratellanza_is_open == false then
        LaFratellanza_ShowMainFrame();
    else
        LaFratellanza_CloseMainFrame();
    end
end

function LaFratellanza_MenuButton_OnClick(self)
    local buttonName = self:GetName();
    if buttonName == "LaFratellanza_Button1" then
        LaFratellanza_ShowMembersFrame();
    elseif buttonName == "LaFratellanza_Button2" then
        LaFratellanza_ShowRulesFrame();
    end
end

LaFratellanza_main_button:SetScript("OnClick", function()
    LaFratellanza_MainFrameToggle()
end)

LaFratellanza:RegisterEvent("GUILD_ROSTER_UPDATE");

