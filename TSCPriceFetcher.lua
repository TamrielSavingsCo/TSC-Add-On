-- main.lua
local TSCPriceFetcher = {
    name = "TSCPriceFetcher",
    version = "0.0.1",
    modules = {} -- Container for our modules
}

-- Make it globally accessible (needed for ESO addon structure)
_G.TSCPriceFetcher = TSCPriceFetcher

-- Load order matters, so we load core first
TSCPriceFetcher.modules.debug = DebugModule   -- defined in modules/core/debug.lua
TSCPriceFetcher.modules.init = InitModule     -- defined in modules/core/init.lua
TSCPriceFetcher.modules.events = EventsModule -- defined in modules/core/events.lua
d("DEBUG: events module is " .. tostring(TSCPriceFetcher.modules.events))
TSCPriceFetcher.modules.events.registerAll()

-- Then business logic
TSCPriceFetcher.modules.lookup = LookupModule -- defined in modules/price/lookup.lua



return TSCPriceFetcher
