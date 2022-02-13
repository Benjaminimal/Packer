local _, core = ...
core.DB = {}

local DB = core.DB

-- TODO: not working with defaults, add AddGroup button
local defaults = {
    profile = {
        groups = {
            {
                name = "Hyjal Tank",
                items = {},
            },
            {
                name = "Kara GDKP",
                items = {},
            },
            {
                name = "Threat Set",
                items = {},
            },
        }
    }
}

function DB:Init()
    self.storage = LibStub("AceDB-3.0"):New("PackerDB", defaults)
end
