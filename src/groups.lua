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

    ---@param parent Frame
    local function ScrollFrame_CreateButton(parent)
        ---@type Button
        local Button = CreateFrame("Button", nil, parent)

        Button:SetPoint("RIGHT", -5, 0)
        Button:SetScript("OnClick", onClick)
        Button:SetScript("OnEnter", onEnter)
        Button:SetScript("OnLeave", GameTooltip_Hide)
        Button:SetScript("OnReceiveDrag", dropAction)
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
        button.group = Packer.db.profile.groups[index]
        local label = button.group.name
        button:EnableDrawLayer("BACKGROUND")
        button:SetHighlightTexture(nil)
        button.info:SetText("")
        button.icon:SetTexture("")
        button.label:SetFontObject(GameFontNormal)
        button.label:SetPoint("LEFT", 11, 0)
        button.label:SetText(label)
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
