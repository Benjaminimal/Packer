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


-- TODO: move this somewhere else
local function SetSuperClass(subClass, superObject)
    subClass.__index = subClass
    local superClass = getmetatable(superObject)
    subClass.__super = superClass.__index
    setmetatable(subClass, superClass)
    setmetatable(superObject, subClass)
end


--------------------------------------------------------------------------------
--- Groups
--------------------------------------------------------------------------------
function Groups:OnInit()
    self.scrollFrame = self:CreateScrollFrame()
    self.groupMenu = self:CreateGroupMenu()
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
    self.scrollFrame:update()
end


--------------------------------------------------------------------------------
--- GroupContainer
--------------------------------------------------------------------------------
GroupContainer = {}
function GroupContainer:New(parent)
    ---@type GroupContainer
    local obj = CreateFrame("Frame", nil, parent)
    SetSuperClass(self, obj)

    obj:SetPoint("RIGHT", -2, 0)
    obj.header = GroupHeader:New(obj)
    obj.body = GroupBody:New(obj)

    return obj
end

function GroupContainer:SetGroup(index)
    self.index = index
    self.group = Packer:GetGroup(index)
    self.header:SetName(self.group.name)

    -- TODO: fix height?
end


--------------------------------------------------------------------------------
--- GroupHeader
--------------------------------------------------------------------------------
GroupHeader = {}
function GroupHeader:New(parent)
    ---@type GroupHeader
    local obj = CreateFrame("Button", nil, parent)
    SetSuperClass(self, obj)

    obj:SetHeight(18)
    obj:SetPoint("TOPLEFT")
    obj:SetPoint("RIGHT")
    obj:SetScript("OnClick", obj.OnClick)
    obj:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    obj.label = obj:CreateFontString()
    obj.label:SetJustifyH("LEFT")
    obj.label:SetFontObject(GameFontNormal)
    obj.label:SetPoint("LEFT", 11, 0)

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

function GroupHeader:OnClick(mouseButton)
    if mouseButton == 'LeftButton' then
        local parent = self:GetParent()
        local height = self:GetHeight() + (not parent.body:IsShown() and 40 or 0)
        parent:SetHeight(height)
        parent.body:SetShown(not parent.body:IsShown())
    elseif mouseButton == 'RightButton' then
        Packer.groupMenu:Toggle(self, self)
    end
end


--------------------------------------------------------------------------------
--- GroupBody
--------------------------------------------------------------------------------
GroupBody = {}
function GroupBody:New(parent)
    ---@type GroupBody
    local obj = CreateFrame("Frame", nil, parent)
    SetSuperClass(self, obj)

    obj:SetPoint("TOPLEFT", obj:GetParent().header, "BOTTOMLEFT")
    obj:SetPoint("BOTTOM")
    -- TODO: set dynamic height
    obj:SetHeight(40)
    obj:Hide()

    obj.bg = Packer:DebugBackground(obj)

    ---@type FontString
    obj.hint = obj:CreateFontString(nil, nil, "GameFontNormalMed3")
    obj.hint:SetText("Drag an item here to add it")
    obj.hint:SetPoint("CENTER")

    return obj
end
