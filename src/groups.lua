---@type Packer
local Packer = select(2, ...)

---@class Groups : Frame
local Groups = Packer:NewModule("Groups", CreateFrame("Frame"))


function Groups:OnInit()
    self:EnableMouse(true)
    self:SetSize(500, 500)

    ---@type FontString
    self.hint = self:CreateFontString(nil, nil, "GameFontNormalMed3")
    self.hint:SetPoint("CENTER")
    self.hint:SetText("Create a group")

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
            -- TODO: add item to group
        elseif pressedButton == 'RightButton' then
            self.GroupMenu:Toggle(scrollFrameButton, scrollFrameButton)
        end
    end

    scrollFrame.createButton = function(parent)
        ---@type Button
        local button = CreateFrame("Button", nil, parent)

        button:SetPoint("RIGHT", -2, 0)
        button:SetScript("OnClick", scrollFrameButton_OnClick)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetPushedTextOffset(0, 0)

        button.label = button:CreateFontString()
        button.label:SetJustifyH("LEFT")
        button.label:SetFontObject(GameFontNormal)
        button.label:SetPoint("LEFT", 11, 0)

        local left = button:CreateTexture(nil, "BACKGROUND")
        left:SetPoint("LEFT")
        left:SetSize(76, 16)
        left:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        left:SetTexCoord(0.17578125, 0.47265625, 0.29687500, 0.54687500)

        local right = button:CreateTexture(nil, "BACKGROUND")
        right:SetPoint("RIGHT")
        right:SetSize(76, 16)
        right:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        right:SetTexCoord(0.17578125, 0.47265625, 0.01562500, 0.26562500)

        local middle = button:CreateTexture(nil, "BACKGROUND")
        middle:SetPoint("LEFT", left, "RIGHT", -20, 0)
        middle:SetPoint("RIGHT", right, "LEFT", 20, 0)
        middle:SetHeight(16)
        middle:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        middle:SetTexCoord(0.48046875, 0.98046875, 0.01562500, 0.26562500)

        return button
    end

    scrollFrame.updateButton = function(button, index)
        button.index = index
        button.group = Packer:GetGroup(index)
        button:EnableDrawLayer("BACKGROUND")
        button:SetHighlightTexture(nil)
        button.label:SetText(button.group.name)
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
