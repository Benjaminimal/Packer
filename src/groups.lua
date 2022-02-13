local _, Packer = ...

---@type Frame
local Groups = Packer:NewModule("Groups", CreateFrame("Frame"))

Groups:EnableMouse(true)
Groups:SetSize(500, 500)

Groups.hint = Groups:CreateFontString(nil, nil, "GameFontNormalMed3")
Groups.hint:SetPoint("CENTER")
Groups.hint:SetText("Create a group")
