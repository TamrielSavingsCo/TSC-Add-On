-- main.lua
local TSCPriceFetcher = {
    name = "TSCPriceFetcher",
    version = "0.0.1",
    modules = {} -- Container for our modules
}

-- Make it globally accessible (needed for ESO addon structure)
_G.TSCPriceFetcher = TSCPriceFetcher

-- Load order matters, so we load core first
TSCPriceFetcher.modules.debug = require("modules/core/debug")
TSCPriceFetcher.modules.init = require("modules/core/init")
TSCPriceFetcher.modules.events = require("modules/core/events")
d("DEBUG: events module is " .. tostring(TSCPriceFetcher.modules.events))
TSCPriceFetcher.modules.events.registerAll()

-- Then business logic
TSCPriceFetcher.modules.lookup = require("modules/price/lookup")
-- TSCPriceFetcher.modules.format = require("modules/price/format")

-- Then UI modules
-- TSCPriceFetcher.modules.tooltips = require("modules/ui/tooltips")
-- TSCPriceFetcher.modules.inventory = require("modules/ui/inventory")
-- TSCPriceFetcher.modules.chat = require("modules/ui/chat")

-- Data handling
-- TSCPriceFetcher.modules.version = require("modules/data/version")
-- TSCPriceFetcher.modules.validate = require("modules/data/validate")

-- Tests loaded last if debug mode
-- if TSCPriceFetcher.modules.init.settings.debugMode then
--     TSCPriceFetcher.modules.test = require("modules/test/test")
--     TSCPriceFetcher.modules.mocks = require("modules/test/mocks")
-- end



return TSCPriceFetcher
