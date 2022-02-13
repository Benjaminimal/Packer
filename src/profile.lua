local _, Packer = ...

---@type Frame
local Profile = Packer:NewModule("Profile", CreateFrame("Frame"))

Profile.hint = Profile:CreateFontString(nil, nil, "GameFontNormalMed3")
Profile.hint:SetPoint("CENTER")
Profile.hint:SetText("Profile management")
