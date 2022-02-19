---@type Packer
local Packer = select(2, ...)

---@class Groups : Frame
local Groups = Packer:NewModule("Groups", CreateFrame("Frame"))

---@class GroupContainer : Frame
local GroupContainer

---@class GroupHeader : Button
local GroupHeader

---@class GroupBody : Frame
local GroupBody

---@class GroupBodyItem : Frame
local GroupBodyItem


--------------------------------------------------------------------------------
--- Groups
--------------------------------------------------------------------------------
function Groups:OnInit()
    self.scrollFrame = self:CreateScrollFrame()
    self.contextMenu = self:CreateContextMenu()
    self.addButton = self:CreateAddButton()

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

    scrollFrame.createButton = function(parent)
        return GroupContainer:New(parent)
    end

    scrollFrame.updateButton = function(groupContainer, index)
        groupContainer:SetGroup(index)
    end

    scrollFrame:CreateButtons()

    return scrollFrame
end


function Groups:CreateContextMenu()
    local contextMenu = Packer:CreateDropdown("Menu")
    contextMenu.initialize = function(menu)
        local button = UIDROPDOWNMENU_MENU_VALUE
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Delete"
        info.func = function(info, groupIndex)
            Packer:DeleteGroup(groupIndex)
            self:Render()
        end
        info.arg1 = button.index
        info.notCheckable = true
        menu:AddButton(info)
    end

    return contextMenu
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
    self.scrollFrame:update()
end


--------------------------------------------------------------------------------
--- GroupContainer
--------------------------------------------------------------------------------
GroupContainer = {}
function GroupContainer:New(parent)
    ---@type GroupContainer
    local obj = CreateFrame("Frame", nil, parent)
    Packer:SetSuperClass(self, obj)

    obj:SetPoint("RIGHT", -2, 0)
    obj.header = GroupHeader:New(obj)
    obj.body = GroupBody:New(obj)

    return obj
end

function GroupContainer:SetGroup(index)
    self.index = index
    self.group = Packer:GetGroup(index)
    self.header:SetName(self.group.name)

    self.body:SetGroup(self.group)
    self:UpdateHeight()
end

function GroupContainer:Toggle()
    self.body:SetShown(not self.body:IsShown())
    self:Update()
end

function GroupContainer:Update()
    self.body:SetGroup(self.group)
    self:UpdateHeight()
end

function GroupContainer:UpdateHeight()
    local height = self.header:GetHeight()
    if self.body:IsShown() then
        local itemCount = Packer:ItemCount(self.group)
        if itemCount == 0 then
            height = height + 40
        else
            height = height + self.body:GetHeight()
        end
    end
    self:SetHeight(height)
end


--------------------------------------------------------------------------------
--- GroupHeader
--------------------------------------------------------------------------------
GroupHeader = {}
function GroupHeader:New(parent)
    ---@type GroupHeader
    local obj = CreateFrame("Button", nil, parent)
    Packer:SetSuperClass(self, obj)

    obj:SetHeight(18)
    obj:SetPoint("TOPLEFT")
    obj:SetPoint("RIGHT")
    obj:SetScript("OnClick", obj.OnClick)
    obj:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    obj.label = obj:CreateFontString()
    obj.label:SetJustifyH("LEFT")
    obj.label:SetFontObject(GameFontNormal)
    obj.label:SetPoint("LEFT", 6, 0)

    local left = obj:CreateTexture(nil, "BACKGROUND")
    left:SetPoint("LEFT")
    left:SetSize(76, 16)
    left:SetTexture([[Interface\Buttons\CollapsibleHeader]])
    left:SetTexCoord(0.17578125, 0.47265625, 0.29687500, 0.54687500)

    local right = obj:CreateTexture(nil, "BACKGROUND")
    right:SetPoint("RIGHT")
    right:SetSize(76, 16)
    right:SetTexture([[Interface\Buttons\CollapsibleHeader]])
    right:SetTexCoord(0.17578125, 0.47265625, 0.01562500, 0.26562500)

    local middle = obj:CreateTexture(nil, "BACKGROUND")
    middle:SetPoint("LEFT", left, "RIGHT", -20, 0)
    middle:SetPoint("RIGHT", right, "LEFT", 20, 0)
    middle:SetHeight(16)
    middle:SetTexture([[Interface\Buttons\CollapsibleHeader]])
    middle:SetTexCoord(0.48046875, 0.98046875, 0.01562500, 0.26562500)

    return obj
end

function GroupHeader:SetName(name)
    self.label:SetText(name)
end

function GroupHeader:Toggle()
    self:GetParent():Toggle()
end

function GroupHeader:OnClick(mouseButton)
    if mouseButton == 'LeftButton' then
        self:Toggle()
    elseif mouseButton == 'RightButton' then
        Groups.contextMenu:Toggle(self, self)
    end
end


--------------------------------------------------------------------------------
--- GroupBody
--------------------------------------------------------------------------------
GroupBody = {initialHeight = 40, inset = 4}
-- TODO: add border to indicate area where items can be dropped
function GroupBody:New(parent)
    ---@type GroupBody
    local obj = CreateFrame("Frame", nil, parent)
    Packer:SetSuperClass(self, obj)

    -- TODO: replace ugly reference to parent.header
    obj:SetPoint("TOPLEFT", parent.header, "BOTTOMLEFT", self.inset, 0)
    obj:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -self.inset, 0)
    obj:SetHeight(self.initialHeight)
    obj:Hide()

    obj:EnableMouse(true)
    obj:SetScript("OnMouseUp", GroupBody.OnClick)
    obj:SetScript("OnReceiveDrag", GroupBody.OnClick)

    ---@type FontString
    obj.hint = obj:CreateFontString(nil, nil, "GameFontNormalMed3")
    obj.hint:SetText("Drag an item here to add it")
    obj.hint:SetPoint("CENTER")

    return obj
end

function GroupBody:GetGroup()
    return self:GetParent().group
end

function GroupBody:SetGroup(group)
    local itemCount = Packer:ItemCount(group)
    if itemCount > 0 then
        self.hint:Hide()
    else
        self.hint:Show()
    end

    self.items = self.items or {}
    local i = 1
    for itemId, count in pairs(group.items) do
        local item = self.items[i]

        if item == nil then
            item = GroupBodyItem:New(self)
            if i == 1 then
                item:SetPoint("TOPLEFT")
            else
                item:SetPoint("TOPLEFT", self.items[i - 1], "BOTTOMLEFT")
            end
            self.items[i] = item
        end
        item:SetItem(itemId, count)
        item:Show()

        i = i + 1
    end
    -- TODO: enable this once we can delete items from groups. maybe replace both loops with iterators?
    --for j = itemCount + 1, #self.items, 1 do
    --    if self.items[j] then
    --        self.items[j]:Hide()
    --    end
    --end
end

function GroupBody:Update()
    self:GetParent():Update()
end

function GroupBody:OnClick(mouseButton)
    if mouseButton == nil or mouseButton == 'LeftButton' then
        local cursorType, itemId, itemLink   = GetCursorInfo()
        if cursorType == "item" then
            if Packer:AddItem(self:GetGroup(), itemId, 1) then
                ClearCursor()
                self:Update()
            end
        end
    end
end

function GroupBody:GetHeight()
    local height = 0
    for i = 1, Packer:ItemCount(self:GetGroup()), 1 do
        height = height + self.items[i]:GetHeight()
    end
    return height
end


--------------------------------------------------------------------------------
--- GroupBodyEntry
--------------------------------------------------------------------------------
GroupBodyItem = {initialHeight = 14, inset = 2}
function GroupBodyItem:New(parent)
    ---@type GroupBodyEntry
    local obj = CreateFrame("Frame", nil, parent)
    Packer:SetSuperClass(self, obj)

    obj:SetPoint("RIGHT")
    obj:SetHeight(self.initialHeight)

    obj.label = obj:CreateFontString(nil, nil, "GameFontNormal")
    obj.label:SetPoint("LEFT", self.inset, 0)

    obj.count = obj:CreateFontString(nil, nil, "GameFontNormal")
    obj.count:SetPoint("RIGHT", -self.inset, 0)

    return obj
end

function GroupBodyItem:SetItem(itemId, count)
    self.label:SetText(itemId)
    self.count:SetText(count)
end
