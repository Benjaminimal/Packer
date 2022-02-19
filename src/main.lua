local Libra = LibStub("Libra")

---@class Packer
local Packer = Libra:NewAddon(...)
_G.Packer = Packer
Libra:EmbedWidgets(Packer)

---@type Frame
local PackerFrame = Packer:CreateUIPanel("PackerFrame")
PackerFrame:SetPoint("CENTER")
PackerFrame:SetToplevel(true)
PackerFrame:EnableMouse(true)
PackerFrame:SetTitleText("Packer")
PackerFrame:HidePortrait(PackerFrame)
PackerFrame:HideButtonBar(PackerFrame)

SLASH_PACKER1 = "/packer"
SLASH_PACKER2 = "/pc"
SlashCmdList.PACKER = function(msg)
    ToggleFrame(PackerFrame)
end

local defaults = {
    profile = {
        groups = {},
    },
}

function Packer:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PackerDB", defaults)

    for _, module in ipairs(self.modules) do
        module:OnInit()
    end

    PackerFrame:SelectTab(1)
end

---@param name string
---@param module Frame
function Packer:OnModuleCreated(name, module)
    module:SetParent(PackerFrame)
    module:SetAllPoints()
    module:Hide()
    module.name = name
    module.Inset = PackerFrame.Inset

    -- Dev helper
    module.bg = module:CreateTexture(nil, "BACKGROUND")
    module.bg:SetAllPoints()
    --module.bg:SetColorTexture(math.random(), math.random(), math.random(), .6)

    local tab = PackerFrame:CreateTab()
    tab:SetText(name)
    tab.frame = module
end

function PackerFrame:OnTabSelected(id)
    self.tabs[id].frame:Show()
end

function PackerFrame:OnTabDeselected(id)
    self.tabs[id].frame:Hide()
end

--------------------------------------------------------------------------------
--- Persistence
--------------------------------------------------------------------------------

---@param id number
function Packer:GetGroup(index)
    return self.db.profile.groups[index]
end

---@param name string
function Packer:NewGroup(name)
    self.db.profile.groups[self:GroupCount() + 1] = {
        name = name,
        itemCount = 0,
        items = {},
    }
end

function Packer:DeleteGroup(index)
    table.remove(self.db.profile.groups, index)
end

function Packer:GroupCount()
    return #(self.db.profile.groups)
end

function Packer:ItemCount(group)
    return group.itemCount
end

function Packer:AddItem(group, itemId, count)
    local added = group.items[itemId] == nil
    if added then
        group.items[itemId] = count
        group.itemCount = group.itemCount + 1
    end
    return added
end

function Packer:SetItem(group, itemId, count)
    local set = count > 0 and group.items[itemId] ~= nil
    if set then
        group.items[itemId] = count
    end
    return set
end

function Packer:DeleteItem(group, itemId)
    local deleted = group.items[itemId] ~= nil
    if deleted then
        group.items[itemId] = nil
        group.itemCount = group.itemCount - 1
    end
    return deleted
end

--------------------------------------------------------------------------------
--- Classes
--------------------------------------------------------------------------------

function Packer:SetSuperClass(subClass, superObject)
    subClass.__index = subClass
    local superClass = getmetatable(superObject)
    subClass.__super = superClass.__index
    setmetatable(subClass, superClass)
    setmetatable(superObject, subClass)
end

--------------------------------------------------------------------------------
--- Dev tools
--------------------------------------------------------------------------------

function Packer:DebugBackground(frame)
    ---@type Texture
   local background = frame:CreateTexture("BACKGROUND")
   background:SetAllPoints()
   background:SetColorTexture(math.random(), math.random(), math.random(), .6)

    return background
end