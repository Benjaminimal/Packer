local Libra = LibStub("Libra")

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

function Packer:OnInitialize()
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
    module.bg:SetColorTexture(math.random(), math.random(), math.random(), .6)

    local tab = PackerFrame:CreateTab()
    tab:SetText(name)
    tab.frame = module
end

function PackerFrame:OnTabSelected(id)
    print(self.tabs[id].frame)
    self.tabs[id].frame:Show()
end

function PackerFrame:OnTabDeselected(id)
    self.tabs[id].frame:Hide()
end
