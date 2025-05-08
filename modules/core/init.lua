-- modules/core/init.lua

--[[
    This module handles basic addon initialization.
    It tracks whether the addon is initialized and provides an initialize() function.
    For now, it does NOT handle settings, saved variables, or versioning.
]]

local Init = {}

-- Flag to track if the addon has been initialized
Init.isInitialized = false

--[[
    Call this function to initialize the addon.
    It sets the isInitialized flag to true and logs a message.
    You should call this from your EVENT_ADD_ON_LOADED handler.
]]
function Init.initialize()
    if Init.isInitialized then
        TSCPriceFetcher.modules.debug.log("Init: Already initialized")
        return
    end
    Init.isInitialized = true
    TSCPriceFetcher.modules.debug.log("Init: Addon initialized")
end

--[[
    (Optional) Function to check if the addon is initialized.
    Returns true if initialized, false otherwise.
]]
function Init.isReady()
    return Init.isInitialized
end

-- Return the Init table so other files can use it
TSC_InitModule = Init
return Init
