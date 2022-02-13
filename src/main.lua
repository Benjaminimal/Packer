local _, core = ...

local Packer = LibStub("AceAddon-3.0"):NewAddon("Packer")

function Packer:OnInitialize()
    --- Init code
    core.DB:Init()

    for i, group in ipairs(core.DB.storage.profile.groups) do
        print(i, group.name)
    end

    SLASH_PACKER1 = "/packer"
    SLASH_PACKER2 = "/pc"
    SlashCmdList.PACKER = function(msg, editBox)
        core.UI.Toggle()
    end
end

function Packer:OnEnable()
    --- Enable code
end

function Packer:OnDisable()
    --- Disable code
end
