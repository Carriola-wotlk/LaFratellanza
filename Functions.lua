function LaFratellanza_Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function LaFratellanza_ToLowerCase(s)
    return s:lower();
end

function LaFratellanza_ToUpperCase(s)
    return s:upper();
end

function LaFratellanza_OnLoad(self)
    self.items = {};
    for idx, value in ipairs(LaFratellanza_navBar) do
        local item = CreateFrame("Button", "LaFratellanza_Button" .. idx, self, "LaFratellanzaMenuButtonTemplate");
        self.items[idx] = item;
        _G["LaFratellanza_Button" .. idx .. "_Voice"]:SetText(value);
        _G["LaFratellanza_Button" .. idx .. "_Voice"]:SetTextColor(0.2, 0.2, 0.2);
        _G["LaFratellanza_Button" .. idx .. "_IconTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\icons\]] .. value .. "_icon");

        if idx == 1 then
            item:SetPoint("LEFT", 23, -40);
            _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]]);
        else
            item:SetPoint("TOPLEFT", self.items[idx-1], "BOTTOMLEFT", 0, -8);
        end
    end
end

function LaFratellanza_ShowMembersFrame()
    _G["LaFratellanza_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-press]]);
    _G["LaFratellanza_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\buttons\button-normal]]);
    _G["LaFratellanza_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\main-bottom-right]]);
    _G["LaFratellanza_main_texture_top_right"]:SetTexture([[Interface\AddOns\LaFratellanza\texture\frames\main-top-right]]);
    _G["LaFratellanza_Main_Frame_Rules"]:Hide();
    _G["LaFratellanza_Main_Frame_Members"]:Show();
end

