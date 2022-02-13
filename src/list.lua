local _, Packer = ...

---@type Frame
local List = Packer:NewModule("List", CreateFrame("Frame"))

function List:OnInit()
    self.hint = self:CreateFontString(nil, nil, "GameFontNormalMed3")
    self.hint:SetPoint("CENTER")
    self.hint:SetText("List of items missing in your bag and where to get them")
end
