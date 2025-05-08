---@diagnostic disable: undefined-global
local Events = {}

-- Table to keep track of registered events and their handlers
Events.registered = {}

-- Register an event with a handler
function Events.register(event, callback)
    TSCPriceFetcher.modules.debug.log("Events: Registering event " .. tostring(event))
    EVENT_MANAGER:RegisterForEvent(TSCPriceFetcher.name, event, callback)
    Events.registered[event] = callback
end

-- Unregister an event
function Events.unregister(event)
    TSCPriceFetcher.modules.debug.log("Events: Unregistering event " .. tostring(event))
    EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, event)
    Events.registered[event] = nil
end

local function registerPreHooks()
    if TSC_TooltipsModule and ZO_ItemTooltip_SetBagItem then
        ZO_PreHook(ZO_ItemTooltip_SetBagItem, function(tooltipControl, bagId, slotIndex)
            TSC_TooltipsModule.OnTooltipShown(nil, tooltipControl, nil, bagId, slotIndex)
            return false
        end)
        TSCPriceFetcher.modules.debug.log("Events: PreHooks registered")
    else
        TSCPriceFetcher.modules.debug.warn(
            "Events: Could not register PreHooks (missing TooltipsModule or ZO_ItemTooltip_SetBagItem)")
    end
end

-- Register all events needed for your addon
function Events.registerAll()
    Events.register(EVENT_ADD_ON_LOADED, function(event, addonName)
        if addonName == TSCPriceFetcher.name then
            TSCPriceFetcher.modules.init.initialize()
            registerPreHooks()
            Events.unregister(EVENT_ADD_ON_LOADED)
        end
    end)

    TSCPriceFetcher.modules.debug.log("Events: All events registered")
end

TSC_EventsModule = Events
return Events
