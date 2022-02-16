---@type Packer
local Packer = select(2, ...)

---@class Groups : Frame
local Groups = Packer:NewModule("Groups", CreateFrame("Frame"))


function Groups:OnInit()
    self.ScrollFrame = self:CreateScrollFrame()
    self.GroupMenu = self:CreateGroupMenu()
    self.AddButton = self:CreateAddButton()

    self:Render()
end


function Groups:CreateScrollFrame()
    local scrollFrame = Packer:CreateScrollFrame("Hybrid", self)
    scrollFrame:SetPoint("TOPLEFT", self.Inset, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMRIGHT", -24, 4)

    scrollFrame:SetButtonHeight(18)
    scrollFrame.initialOffsetX = 2
    scrollFrame.initialOffsetY = -1
    scrollFrame.offsetY = -2
    scrollFrame.getNumItems = function()
        return Packer:GroupCount()
    end

    local function scrollFrameButton_OnClick(scrollFrameButton, pressedButton)
        if pressedButton == 'LeftButton' then
            local parent = scrollFrameButton:GetParent()
            local height = scrollFrameButton:GetHeight() + (not parent.body:IsShown() and 40 or 0)
            parent:SetHeight(height)
            parent.body:SetShown(not parent.body:IsShown())
        elseif pressedButton == 'RightButton' then
            self.GroupMenu:Toggle(scrollFrameButton, scrollFrameButton)
        end
    end

    scrollFrame.createButton = function(parent)
        ---@type Frame
        local groupContainer = CreateFrame("Button", nil, parent)
        groupContainer:SetPoint("RIGHT", -2, 0)

        ---@type Button
        local header = CreateFrame("Button", nil, groupContainer)

        header:SetHeight(18)
        header:SetPoint("TOPLEFT")
        header:SetPoint("RIGHT")
        header:SetScript("OnClick", scrollFrameButton_OnClick)
        header:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        header.label = header:CreateFontString()
        header.label:SetJustifyH("LEFT")
        header.label:SetFontObject(GameFontNormal)
        header.label:SetPoint("LEFT", 11, 0)

        local left = header:CreateTexture(nil, "BACKGROUND")
        left:SetPoint("LEFT")
        left:SetSize(76, 16)
        left:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        left:SetTexCoord(0.17578125, 0.47265625, 0.29687500, 0.54687500)

        local right = header:CreateTexture(nil, "BACKGROUND")
        right:SetPoint("RIGHT")
        right:SetSize(76, 16)
        right:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        right:SetTexCoord(0.17578125, 0.47265625, 0.01562500, 0.26562500)

        local middle = header:CreateTexture(nil, "BACKGROUND")
        middle:SetPoint("LEFT", left, "RIGHT", -20, 0)
        middle:SetPoint("RIGHT", right, "LEFT", 20, 0)
        middle:SetHeight(16)
        middle:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        middle:SetTexCoord(0.48046875, 0.98046875, 0.01562500, 0.26562500)

        ---@type Frame
        local body = CreateFrame("Frame", nil, groupContainer)
        body:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
        body:SetPoint("BOTTOM")
        -- TODO: set dynamic height
        body:SetHeight(40)
        body:Hide()

        body.bg = Packer:DebugBackground(body)

        ---@type FontString
        body.hint = body:CreateFontString(nil, nil, "GameFontNormalMed3")
        body.hint:SetText("Drag an item here to add it")
        body.hint:SetPoint("CENTER")

        groupContainer.header = header
        groupContainer.body = body

        return groupContainer
    end

    scrollFrame.updateButton = function(groupContainer, index)
        groupContainer.index = index
        groupContainer.group = Packer:GetGroup(index)
        groupContainer.header.label:SetText(groupContainer.group.name)
    end

    scrollFrame:CreateButtons()

    return scrollFrame
end


function Groups:CreateGroupMenu()
    local groupMenu = Packer:CreateDropdown("Menu")
    groupMenu.initialize = function(menu)
        local button = UIDROPDOWNMENU_MENU_VALUE
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Delete"
        info.func = function(info, groupIndex)
            Packer:DeleteGroup(groupIndex)
            self:Render()
        end
        info.arg1 = button.index
        menu:AddButton(info)
    end

    return groupMenu
end


function Groups:CreateAddButton()
    ---@type Button
    local addButton = Packer:CreateButton(self)
    addButton:SetWidth(80)
    addButton:SetPoint("TOPLEFT", 16, -32)
    addButton:SetText("Add Group")
    addButton:SetScript("OnClick", function(...)
        local groupNum = Packer:GroupCount() + 1
        Packer:NewGroup("Group "..groupNum)
        self:Render()
    end)
end


function Groups:Render()
    self.ScrollFrame:update()
end
