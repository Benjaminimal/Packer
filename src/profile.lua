local _, Packer = ...

---@type Frame
local Profile = Packer:NewModule("Profile", CreateFrame("Frame"))

function Profile:OnInit()
    self.hint = self:CreateFontString(nil, nil, "GameFontNormalMed3")
    self.hint:SetPoint("CENTER")
    self.hint:SetText("self management")
end
