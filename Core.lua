local addonName, IVSP = ...

local currentSpecID
-----------------------------------------------
-- frame (button)
-----------------------------------------------
local frame = CreateFrame("Button", "IcyVeinsStatPriorityFrame", CharacterFrame)
frame:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", 0, 1)
frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
frame:SetPushedTextOffset(0, -1)

-- text
CreateFont("IVSP_FONT")
IVSP_FONT:SetShadowColor(0, 0, 0)
IVSP_FONT:SetShadowOffset(1, -1)
IVSP_FONT:SetJustifyH("CENTER")
IVSP_FONT:SetJustifyV("MIDDLE")

-- function
local function SetFrame(bgColor, borderColor, fontColor, fontSize, show)
    IVSP_FONT:SetFont(GameFontNormal:GetFont(), fontSize)
    IVSP_FONT:SetTextColor(unpack(fontColor))
    
    frame:SetNormalFontObject(IVSP_FONT)

    frame:SetBackdropColor(unpack(bgColor))
    frame:SetBackdropBorderColor(unpack(borderColor))
    frame:SetHeight(fontSize + 7)

    if show then
        frame:Show()
    else
        frame:Hide()
    end
end

local function SetText(text)
    if not text then return end
    frame:SetText(text)
    frame:SetWidth(frame:GetFontString():GetStringWidth() + 20)
end

-----------------------------------------------
-- frame (help)
-----------------------------------------------
local helpFrame = CreateFrame("Frame", "IcyVeinsStatPriorityHelpFrame", frame)
helpFrame:Hide()
helpFrame:SetSize(220, 80)
helpFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)
helpFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})

local helpFrameText = helpFrame:CreateFontString(nil, "OVERLAY", "IVSP_FONT")
helpFrameText:SetPoint("TOPLEFT", 5, -5)
helpFrameText:SetPoint("BOTTOMRIGHT", -5, 5)
helpFrameText:SetSpacing(5)

local function SetHelpFrame(bgColor, borderColor)
    helpFrame:SetBackdropColor(unpack(bgColor))
    helpFrame:SetBackdropBorderColor(unpack(borderColor))
    helpFrameText:SetText("<- Click on IVSP to change its color.\nIVSP List will show up ATST if there're multiple stat priorities for your current spec. ")
    helpFrame:Show()
end

helpFrame:SetScript("OnShow", function()
    if IVSP_Config["helpViewed"] then
        helpFrame:Hide()
    end
    IVSP_Config["helpViewed"] = true
end)

-----------------------------------------------
-- color picker -- https://wow.gamepedia.com/Using_the_ColorPickerFrame
-----------------------------------------------
local items = {}
local colorPicker
local function IVSPColorCallback(restore)
    local newR, newG, newB, newA
    if restore then -- canceled
        newR, newG, newB, newA = unpack(restore)
    else
        newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
    end
    
    colorPicker:SetBackdropColor(newR, newG, newB, newA)
    if colorPicker:GetName() == "IcyVeinsBGColorPicker" then
        IVSP_Config["bgColor"] = {newR, newG, newB, newA}
        frame:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        for _, i in pairs(items) do
            i:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        end
    elseif colorPicker:GetName() == "IcyVeinsBorderColorPicker" then
        IVSP_Config["borderColor"] = {newR, newG, newB, newA}
        frame:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
        for _, i in pairs(items) do
            i:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
        end
    elseif colorPicker:GetName() == "IcyVeinsFontColorPicker" then
        IVSP_Config["fontColor"] = {newR, newG, newB, newA}
        IVSP_FONT:SetTextColor(unpack(IVSP_Config["fontColor"]))
    end
end

local function ShowColorPicker(colorTable, changedCallback)
    local r, g, b, a = unpack(colorTable)
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
    ColorPickerFrame.previousValues = {r, g, b, a}
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 
        changedCallback, changedCallback, changedCallback
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Hide() -- Need to run the OnShow handler.
    ColorPickerFrame:Show()
end

local function CreateColorPicker(name, colorTable, tooltip)
    local picker = CreateFrame("Button", name, frame)
    picker:SetSize(15, 15)
    picker:Hide()
    picker:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    picker:SetBackdropBorderColor(.8, .8, .8, 1)
    picker:SetScript("OnHide", function() picker:Hide() end)
    picker:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    picker:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            colorPicker = picker
            ShowColorPicker(IVSP_Config[colorTable], IVSPColorCallback)
        elseif button == "RightButton" then
            if colorTable == "bgColor" then
                IVSP_Config["bgColor"] = {.1, .1, .1, .9}
                frame:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
                for _, i in pairs(items) do
                    i:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
                end
                picker:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
            elseif colorTable == "borderColor" then
                IVSP_Config["borderColor"] = {0, 0, 0, 1}
                frame:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
                for _, i in pairs(items) do
                    i:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
                end
                picker:SetBackdropColor(unpack(IVSP_Config["borderColor"]))
            elseif colorTable == "fontColor" then
                IVSP_Config["fontColor"] = {1, 1, 1, 1}
                IVSP_FONT:SetTextColor(unpack(IVSP_Config["fontColor"]))
                picker:SetBackdropColor(unpack(IVSP_Config["fontColor"]))
            end
        end
    end)
    
    picker:SetScript("OnEnter", function()
        GameTooltip:SetOwner(picker, "ANCHOR_TOP")
        GameTooltip:AddLine(tooltip)
        GameTooltip:AddLine("|cffffffffRight-click to reset.")
        GameTooltip:Show()
    end)
    
    picker:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return picker
end

local bgColorPicker = CreateColorPicker("IcyVeinsBGColorPicker", "bgColor", "Background Color")
bgColorPicker:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 1)

local borderColorPicker = CreateColorPicker("IcyVeinsBorderColorPicker", "borderColor", "Border Color")
borderColorPicker:SetPoint("RIGHT", bgColorPicker, "LEFT", -1, 0)

local fontColorPicker = CreateColorPicker("IcyVeinsFontColorPicker", "fontColor", "Font Color")
fontColorPicker:SetPoint("RIGHT", borderColorPicker, "LEFT", -1, 0)

-----------------------------------------------
-- list
-----------------------------------------------
local textWidth = 0
local function AddItem(text)
    local item = CreateFrame("Button", nil, frame)
    item:Hide()
    item:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    item:SetPushedTextOffset(0, -1)
    item:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
    item:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
    item:SetNormalFontObject(IVSP_FONT)
    item:SetWidth(200)
    item:SetHeight(select(2, IVSP_FONT:GetFont()) + 7)
    
    item:SetText(text)
    textWidth = max(item:GetFontString():GetStringWidth(), textWidth)

    -- highlight texture
    item.highlight = item:CreateTexture()
    item.highlight:SetColorTexture(.5, 1, 0, 1)
    item.highlight:SetSize(5, item:GetHeight() - 2)
    item.highlight:SetPoint("LEFT", 1, 0)
    item.highlight:Hide()

    table.insert(items, item)
    item.n = #items
    
    item:SetScript("OnHide", function() item:Hide() end)

    item:SetScript("OnClick", function()
        bgColorPicker:Hide()
        borderColorPicker:Hide()
        fontColorPicker:Hide()

        for _, i in pairs(items) do
            i.highlight:Hide()
            i:Hide()
        end
        item.highlight:Show()
        IVSP_Config["selected"][currentSpecID] = item.n
        SetText(IVSP:GetSPText(currentSpecID))
    end)
end

local function LoadList()
    bgColorPicker:Hide()
    borderColorPicker:Hide()
    fontColorPicker:Hide()
    
    textWidth = 0
    for _, i in pairs(items) do
        i:ClearAllPoints()
        i:Hide()
        i:SetParent(nil)
    end
    wipe(items)

    local desc = IVSP:GetSPDesc(currentSpecID)
    if not desc then return end

    for k, s in pairs(desc) do
        AddItem(s)
        if k == 1 then
            items[1]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)
        else
            items[k]:SetPoint("TOP", items[k-1], "BOTTOM", 0, -1)
        end
    end

    -- update width
    for _, i in pairs(items) do
        i:SetWidth(textWidth + 20)
    end

    if IVSP_Config["selected"][currentSpecID] then
        items[IVSP_Config["selected"][currentSpecID]].highlight:Show()
    else -- highlight first
        items[1].highlight:Show()
    end
end

-----------------------------------------------
-- frame OnClick
-----------------------------------------------
frame:SetScript("OnClick", function()
    for _, i in pairs(items) do
        if i:IsShown() then
            i:Hide()
        else
            i:Show()
        end
    end

    if bgColorPicker:IsShown() then
        bgColorPicker:Hide()
    else
        bgColorPicker:Show()
    end

    if borderColorPicker:IsShown() then
        borderColorPicker:Hide()
    else
        borderColorPicker:Show()
    end

    if fontColorPicker:IsShown() then
        fontColorPicker:Hide()
    else
        fontColorPicker:Show()
    end

    -- hide help on click
    if helpFrame:IsShown() then
        helpFrame:Hide()
    end
end)

-----------------------------------------------
-- event
-----------------------------------------------
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function frame:ADDON_LOADED(arg1)
    if arg1 == addonName then
        if type(IVSP_Config) ~= "table" then IVSP_Config = {} end
        if type(IVSP_Config["show"]) ~= "boolean" then IVSP_Config["show"] = true end
        if type(IVSP_Config["bgColor"]) ~= "table" then IVSP_Config["bgColor"] = {.1, .1, .1, .9} end
        if type(IVSP_Config["borderColor"]) ~= "table" then IVSP_Config["borderColor"] = {0, 0, 0, 1} end
        if type(IVSP_Config["fontColor"]) ~= "table" then IVSP_Config["fontColor"] = {1, 1, 1, 1} end
        if type(IVSP_Config["fontSize"]) ~= "number" then IVSP_Config["fontSize"] = 13 end
        if type(IVSP_Config["selected"]) ~= "table" then IVSP_Config["selected"] = {} end
        if type(IVSP_Config["helpViewed"]) ~= "boolean" then IVSP_Config["helpViewed"] = false end

        SetFrame(IVSP_Config["bgColor"], IVSP_Config["borderColor"], IVSP_Config["fontColor"], IVSP_Config["fontSize"], IVSP_Config["show"])

        if not IVSP_Config["helpViewed"] then
            SetHelpFrame(IVSP_Config["bgColor"], IVSP_Config["borderColor"])
        end

        bgColorPicker:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        borderColorPicker:SetBackdropColor(unpack(IVSP_Config["borderColor"]))
        fontColorPicker:SetBackdropColor(unpack(IVSP_Config["fontColor"]))
    end
end

function frame:PLAYER_ENTERING_WORLD()
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    currentSpecID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
    SetText(IVSP:GetSPText(currentSpecID))
    LoadList()
end

function frame:ACTIVE_TALENT_GROUP_CHANGED()
    -- specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, specNum)
    local specID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
    if specID ~= currentSpecID then
        currentSpecID = specID
        SetText(IVSP:GetSPText(currentSpecID))
        LoadList()
    end
end

SLASH_ICYVEINSSTATPRIORITY1 = "/ivsp"
function SlashCmdList.ICYVEINSSTATPRIORITY(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "show" then
        frame:Show()
        IVSP_Config["show"] = true
    elseif command == "hide" then
        frame:Hide()
        IVSP_Config["show"] = false
    elseif command == "font" then
        IVSP_Config["fontSize"] = tonumber(rest) or 13
        IVSP_FONT:SetFont(GameFontNormal:GetFont(), IVSP_Config["fontSize"])
        frame:SetHeight(IVSP_Config["fontSize"] + 7)
    elseif command == "reset" then
        IVSP_Config = nil
        ReloadUI()
    else -- help
        print("|cff69CCF0Icy Veins Stat Priority help:|r")
        print("|cff69CCF0/ivsp show/hide|r: show/hide IVSP.")
        print("|cff69CCF0/ivsp font [fontSize]|r: set font size (default 13).")
        print("|cff69CCF0/ivsp reset|r: reset all settings and reload UI.")
    end
end