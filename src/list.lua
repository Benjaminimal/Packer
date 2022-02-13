local _, Packer = ...

---@type Frame
local List = Packer:NewModule("List", CreateFrame("Frame"))

List.hint = List:CreateFontString(nil, nil, "GameFontNormalMed3")
List.hint:SetPoint("CENTER")
List.hint:SetText("List of items missing in your bag and where to get them")
