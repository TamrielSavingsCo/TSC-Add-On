-- main.lua
local TSCPriceFetcher = {
    name = "TSCPriceFetcher",
    version = "0.0.1",
    modules = {} -- Container for our modules
}

-- Make it globally accessible (needed for ESO addon structure)
_G.TSCPriceFetcher = TSCPriceFetcher

-- Load order matters, so we load core first
TSCPriceFetcher.modules.debug = TSC_DebugModule
TSCPriceFetcher.modules.init = TSC_InitModule
TSCPriceFetcher.modules.events = TSC_EventsModule
d("DEBUG: events module is " .. tostring(TSCPriceFetcher.modules.events))
TSCPriceFetcher.modules.events.registerAll()

-- Then business logic
TSCPriceFetcher.modules.lookup = TSC_LookupModule



return TSCPriceFetcher
