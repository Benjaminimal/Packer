local _, Packer = ...

---@type Frame
local Groups = Packer:NewModule("Groups", CreateFrame("Frame"))

function Groups:OnInit()
    self:EnableMouse(true)
    self:SetSize(500, 500)

    ---@type FontString
    self.hint = self:CreateFontString(nil, nil, "GameFontNormalMed3")
    self.hint:SetPoint("CENTER")
    self.hint:SetText("Create a group")

    ---@type ScrollFrame
    local ScrollFrame = Packer:CreateScrollFrame("Hybrid", self)
    ScrollFrame:SetPoint("TOPLEFT", self.Inset, "TOPLEFT", 4, -4)
    ScrollFrame:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMRIGHT", -24, 4)

    ScrollFrame:SetButtonHeight(18)
    ScrollFrame.initialOffsetX = 2
    ScrollFrame.initialOffsetY = -1
    ScrollFrame.offsetY = -2
    ScrollFrame.getNumItems = function()
        return Packer:GroupCount()
    end

    local GroupMenu = Packer:CreateDropdown("Menu")
    local function GroupMenu_Initialize(menu)
        local button = UIDROPDOWNMENU_MENU_VALUE
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Delete"
        info.func = function(info, groupIndex)
            Packer:DeleteGroup(groupIndex)
            self:UpdateScrollFrame()
        end
        info.arg1 = button.index
        menu:AddButton(info)
    end
    GroupMenu.initialize = GroupMenu_Initialize

    local function ScrollFrameButton_OnClick(scrollFrameButton, pressedButton)
        if pressedButton == 'LeftButton' then
            -- TODO: add item to group
        elseif pressedButton == 'RightButton' then
            GroupMenu:Toggle(scrollFrameButton, scrollFrameButton)
        end
    end

    ---@param parent Frame
    local function ScrollFrame_CreateButton(parent)
        ---@type Button
        local Button = CreateFrame("Button", nil, parent)

        Button:SetPoint("RIGHT", -5, 0)
        Button:SetScript("OnClick", ScrollFrameButton_OnClick)
        Button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        Button:SetPushedTextOffset(0, 0)

        Button.icon = Button:CreateTexture()
        Button.icon:SetPoint("LEFT", 3, 0)
        Button.icon:SetSize(16, 16)

        Button.info = Button:CreateFontString(nil, nil, "GameFontHighlightSmallRight")
        Button.info:SetPoint("RIGHT", -3, 0)

        Button.label = Button:CreateFontString()
        Button.label:SetPoint("RIGHT", Button.info, "LEFT", -4, 0)
        Button.label:SetJustifyH("LEFT")

        local left = Button:CreateTexture(nil, "BACKGROUND")
        left:SetPoint("LEFT")
        left:SetSize(76, 16)
        left:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        left:SetTexCoord(0.17578125, 0.47265625, 0.29687500, 0.54687500)

        local right = Button:CreateTexture(nil, "BACKGROUND")
        right:SetPoint("RIGHT")
        right:SetSize(76, 16)
        right:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        right:SetTexCoord(0.17578125, 0.47265625, 0.01562500, 0.26562500)

        local middle = Button:CreateTexture(nil, "BACKGROUND")
        middle:SetPoint("LEFT", left, "RIGHT", -20, 0)
        middle:SetPoint("RIGHT", right, "LEFT", 20, 0)
        middle:SetHeight(16)
        middle:SetTexture([[Interface\Buttons\CollapsibleHeader]])
        middle:SetTexCoord(0.48046875, 0.98046875, 0.01562500, 0.26562500)

        return Button
    end
    ScrollFrame.createButton = ScrollFrame_CreateButton

    ---@param button Button
    ---@param index number
    local function ScrollFrame_UpdateButton(button, index)
        button.index = index
        button.group = Packer:GetGroup(index)
        button:EnableDrawLayer("BACKGROUND")
        button:SetHighlightTexture(nil)
        button.info:SetText("")
        button.icon:SetTexture("")
        button.label:SetFontObject(GameFontNormal)
        button.label:SetPoint("LEFT", 11, 0)
        button.label:SetText(button.group.name)
    end
    ScrollFrame.updateButton = ScrollFrame_UpdateButton

    ScrollFrame:CreateButtons()
    ScrollFrame:update()

    ---@type Texture
    ScrollFrame.bg = ScrollFrame:CreateTexture(nil, "BACKGROUND")
    ScrollFrame.bg:SetAllPoints()
    ScrollFrame.bg:SetColorTexture(math.random(), math.random(), math.random(), .6)

    function self:UpdateScrollFrame()
        ScrollFrame:update()
    end

    ---@type Button
    local AddButton = Packer:CreateButton(self)
    AddButton:SetWidth(80)
    AddButton:SetPoint("TOPLEFT", 16, -32)
    AddButton:SetText("Add Group")
    AddButton:SetScript("OnClick", function(addButton, ...)
        local groupNum = Packer:GroupCount() + 1
        Packer:NewGroup("Group "..groupNum)
        self:UpdateScrollFrame()
    end)
end
