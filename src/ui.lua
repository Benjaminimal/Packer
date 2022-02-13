local _, core = ...
core.UI = {}

local UI = core.UI
local DB = core.DB
---@type Frame
local PackerFrame, ListFrame, GroupsFrame, ProfilesFrame

function UI:Toggle()
    PackerFrame = PackerFrame or UI:CreatePackerFrame()
    if PackerFrame:IsShown() then
        HideUIPanel(PackerFrame)
    else
        ShowUIPanel(PackerFrame)
    end
end

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())

    local scrollChild = self:GetParent().ScrollFrame:GetScrollChild()
    if scrollChild then
        scrollChild:Hide()
    end

    self:GetParent().ScrollFrame:SetScrollChild(self.content)
    self.content:Show()
end

local function SetTabs(frame, ...)
    frame.Tabs = {}
    local contents = {}
    local numTabs = select('#', ...)

    local nameFormat = frame:GetName() .. "Tab%d"
    for i = 1, numTabs do
        local frameLabel = select(i, ...)
        ---@type Button
        local tab = CreateFrame("Button", nameFormat.format(i), frame, "CharacterFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(frameLabel)
        tab:SetScript("OnClick", Tab_OnClick)
        table.insert(frame.Tabs, tab)

        ---@type Frame
        tab.content = UI["Create" .. frameLabel .. "Frame"](UI, frame.ScrollFrame)

        --- Dev only
        tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND")
        tab.content.bg:SetAllPoints(true)
        tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), .6)

        table.insert(contents, tab.content)

        if i == 1 then
            tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 7)
        else
             tab:SetPoint("TOPLEFT", frame.Tabs[i - 1], "TOPRIGHT", 0, 0)
        end
    end

    PanelTemplates_SetNumTabs(frame, numTabs)
    Tab_OnClick(frame.Tabs[1])

    return unpack(contents)
end

function UI:CreatePackerFrame()
    local frame = CreateFrame(
            "Frame",
            "PackerFrame",
            UIParent,
            "UIPanelDialogTemplate"
    )
    frame:SetMovable(true)
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:SetAttribute("UIPanelLayout-defined", true)
    frame:SetAttribute("UIPanelLayout-enabled", true)
    frame:SetAttribute("UIPanelLayout-area", "left")
    frame:SetAttribute("UIPanelLayout-pushable", 5)
    frame:SetAttribute("UIPanelLayout-whileDead", true)
    frame:SetSize(338, 424)

    frame.Title:SetText("Packer")
    frame.Title:SetFontObject("GameFontHighlight")
    HideUIPanel(frame)

    frame.AddGroupButton = CreateFrame("Button", nil, frame, "")

    ---@type ScrollFrame
    frame.ScrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.ScrollFrame:SetPoint("TOPLEFT", PackerFrameDialogBG, "TOPLEFT", 4, -28)
    frame.ScrollFrame:SetPoint("BOTTOMRIGHT", PackerFrameDialogBG, "BOTTOMRIGHT", -3, 4)
    --frame.ScrollFrame:SetClipsChildren(true)
    
    frame.ScrollFrame.ScrollBar:ClearAllPoints()
    frame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", frame.ScrollFrame, "TOPRIGHT", -10, -18)
    frame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", frame.ScrollFrame, "BOTTOMRIGHT", -5, 18)

    ---@type Frame
    ListFrame, GroupsFrame, ProfilesFrame = SetTabs(frame, "List", "Groups", "Profiles")

    return frame
end

--------------------------------------------------------------------------------
--- List
--------------------------------------------------------------------------------

function UI:CreateListFrame(scrollFrame)
    frame = CreateFrame("Frame", nil, scrollFrame)
    frame:SetSize(scrollFrame:GetParent():GetWidth() - 40, 500)
    frame:Hide()

    return frame
end

--------------------------------------------------------------------------------
--- Groups
--------------------------------------------------------------------------------

function UI:CreateGroupsFrame(scrollFrame)
    frame = CreateFrame("Frame", nil, scrollFrame)
    frame:SetSize(scrollFrame:GetParent():GetWidth() - 40, 500)
    frame:Hide()

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
    frame.hint:SetPoint("CENTER", parent)
    frame.hint:SetText("Drag an item here to add it")

    frame.RenderGroups = RenderGroups
    frame:RenderGroups()

    return frame
end

function RenderGroups(self)
    self.buttons = self.buttons or {}

    ---@type Button
    local button
    for i, group in ipairs(DB.storage.profile.groups) do
        button = CreateFrame("Button", nil, self, "GameMenuButtonTemplate")
        if i == 1 then
            button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
        else
            button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, 0)
        end
        button:SetSize( self:GetWidth(), 20)
        button:SetText(group.name)
        button:SetNormalFontObject("GameFontNormal")
        button:SetHighlightFontObject("GameFontHighlight")
        button:Show()

        button.group = group
        button:RegisterForClicks("LeftButtonUp")
        button:SetScript("OnClick", DragHandler)

        table.insert(self.buttons, button)
    end
end

function DragHandler(self, button, down)
    if (button == 'LeftButton' and cursorType == 'item') then
        if self.group.items[itemID] == nil then
            self.group.items[itemID] = {count = 1, link = itemLink}
        end
    end
end

--------------------------------------------------------------------------------
--- Profiles
--------------------------------------------------------------------------------

function UI:CreateProfilesFrame(scrollFrame)
    frame = CreateFrame("Frame", nil, scrollFrame)
    frame:SetSize(scrollFrame:GetParent():GetWidth() - 40, 500)
    frame:Hide()

    return frame
end
