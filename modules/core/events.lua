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
    if TSC_TooltipsModule and ItemTooltip and ItemTooltip.SetBagItem then
        TSCPriceFetcher.modules.debug.log("PreHooking ItemTooltip:SetBagItem")
        ZO_PreHook(ItemTooltip, "SetBagItem", function(tooltipControl, bagId, slotIndex)
            TSC_TooltipsModule.OnTooltipShown(nil, tooltipControl, nil, bagId, slotIndex)
            return false
        end)
        TSCPriceFetcher.modules.debug.success("Successfully PreHooked ItemTooltip:SetBagItem")
    else
        TSCPriceFetcher.modules.debug.warn(
            "Events: Could not register PreHooks")
    end
end

-- Register all events needed for your addon
function Events.registerAll()
    TSCPriceFetcher.modules.debug.log("Registering all events")

    Events.register(EVENT_ADD_ON_LOADED, function(event, addonName)
        if addonName == TSCPriceFetcher.name then
            TSCPriceFetcher.modules.init.initialize()
            Events.unregister(EVENT_ADD_ON_LOADED)
        end
    end)

    Events.register(EVENT_PLAYER_ACTIVATED, function()
        registerPreHooks()
        Events.unregister(EVENT_PLAYER_ACTIVATED)
    end)


    TSCPriceFetcher.modules.debug.success("Successfully registered all events")
end

TSC_EventsModule = Events
return Events
