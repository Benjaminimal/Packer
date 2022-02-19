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
        local target = UIDROPDOWNMENU_MENU_VALUE
        for _, info in pairs(target:GetContextMenuActions()) do
            menu:AddButton(info)
        end
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
    self.header:SetName(self.group.name)
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
    obj.label:SetFontObject("GameFontNormal")
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

function GroupHeader:GetGroupIndex()
    return self:GetParent().index
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

function GroupHeader:GetContextMenuActions()
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Delete Group"
    info.arg1 = self:GetGroupIndex()
    info.func = function(info, groupIndex)
        Packer:DeleteGroup(groupIndex)
        Groups:Render()
    end
    info.notCheckable = true
    return {info}
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

    obj:SetPoint("TOPLEFT", parent.header, "BOTTOMLEFT", self.inset, 0)
    obj:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -self.inset, 0)
    obj:SetHeight(self.initialHeight)
    obj:Hide()

    obj:EnableMouse(true)
    obj:SetScript("OnMouseUp", self.OnClick)
    obj:SetScript("OnReceiveDrag", self.OnClick)

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
    for j = itemCount + 1, #self.items, 1 do
        if self.items[j] then
            self.items[j]:Hide()
        end
    end
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
--- GroupBodyItem
--------------------------------------------------------------------------------
GroupBodyItem = {initialHeight = 16, inset = 2}
function GroupBodyItem:New(parent)
    ---@type GroupBodyItem
    local obj = CreateFrame("Frame", nil, parent)
    Packer:SetSuperClass(self, obj)

    obj:SetPoint("RIGHT")
    obj:SetHeight(self.initialHeight)

    obj.label = obj:CreateFontString(nil, nil, "GameFontNormal")
    obj.label:SetPoint("LEFT", self.inset, 0)

    ---@type EditBox
    obj.countEdit = CreateFrame("EditBox", nil, obj, "InputBoxTemplate")
    obj.countEdit:SetFontObject("GameFontNormal")
    obj.countEdit:SetPoint("RIGHT")
    obj.countEdit:SetHeight(self.initialHeight - self.inset)
    obj.countEdit:SetWidth(40)
    obj.countEdit:SetMaxLetters(4)
    obj.countEdit:SetAutoFocus(false)
    obj.countEdit:SetJustifyH("RIGHT")
    obj.countEdit:SetTextInsets(0, 5, 0, 0)

    obj.countEdit.Left:Hide()
    obj.countEdit.Middle:Hide()
    obj.countEdit.Right:Hide()

    obj.countEdit:SetScript("OnEditFocusGained", function(target)
        obj:CountOnEditFocusGained(target)
    end)
    obj.countEdit:SetScript("OnEditFocusLost", function(target)
        obj:CountOnEditFocusLost(target)
    end)
    obj.countEdit:SetScript("OnEnterPressed", function(target)
        obj:CountOnEnterPressed(target)
    end)
    obj.countEdit:SetScript("OnEscapePressed", function(target)
        obj:CountOnEscapePressed(target)
    end)

    obj:SetScript("OnMouseUp", self.OnClick)
    obj:SetScript("OnReceiveDrag", parent.OnClick)

    return obj
end

function GroupBodyItem:GetGroup()
    return self:GetParent():GetGroup()
end

function GroupBodyItem:Update()
    self:GetParent():Update()
end

function GroupBodyItem:OnClick(mouseButton)
    if mouseButton == 'RightButton' then
        Groups.contextMenu:Toggle(self, self)
    else
        self:GetParent():OnClick(mouseButton)
    end
end

function GroupBodyItem:CountOnEditFocusGained(countEdit)
    countEdit.Left:Show()
    countEdit.Middle:Show()
    countEdit.Right:Show()
    countEdit:HighlightText()
end

function GroupBodyItem:CountOnEditFocusLost(countEdit)
    countEdit.Left:Hide()
    countEdit.Middle:Hide()
    countEdit.Right:Hide()
    countEdit:HighlightText(0, 0)
end

function GroupBodyItem:CountOnEnterPressed(countEdit)
    local text = countEdit:GetText()
    local count = self.count
    if not (text == "" or text:find("%D")) then
        count = tonumber(text)
    end
    self:SetCount(count)
    countEdit:ClearFocus()
end

function GroupBodyItem:CountOnEscapePressed(countEdit)
    self:SetCount(self.count)
    countEdit:ClearFocus()
end

function GroupBodyItem:GetContextMenuActions()
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Delete Item"
    info.arg1 = self:GetGroup()
    info.arg2 = self.itemId
    info.func = function(info, group, itemId)
        if Packer:DeleteItem(group, itemId) then
            self:Update()
        end
    end
    info.notCheckable = true
    return {info}
end

function GroupBodyItem:SetCount(count)
    if Packer:SetItem(self:GetGroup(), self.itemId, count) then
        self.count = count
    end
    self.countEdit:SetText(self.count)
end

function GroupBodyItem:SetItem(itemId, count)
    self.itemId = itemId
    self.count = count

    self.label:SetText(itemId)
    self.countEdit:SetText(count)
end
