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
    -- Debug log for ItemTooltip.SetBagItem
    if ItemTooltip then
        TSCPriceFetcher.modules.debug.log("ItemTooltip exists, type: " .. type(ItemTooltip))
        if ItemTooltip.SetBagItem then
            TSCPriceFetcher.modules.debug.log("ItemTooltip.SetBagItem exists, type: " .. type(ItemTooltip.SetBagItem))
        else
            TSCPriceFetcher.modules.debug.warn("ItemTooltip.SetBagItem is nil")
        end
    else
        TSCPriceFetcher.modules.debug.warn("ItemTooltip is nil")
    end

    -- Hook ItemTooltip:SetBagItem if available
    if TSC_TooltipsModule and ItemTooltip and ItemTooltip.SetBagItem then
        ZO_PreHook(ItemTooltip, "SetBagItem", function(tooltipControl, bagId, slotIndex)
            TSC_TooltipsModule.OnTooltipShown(nil, tooltipControl, nil, bagId, slotIndex)
            return false
        end)
        TSCPriceFetcher.modules.debug.log("Events: PreHooked ItemTooltip:SetBagItem")
    else
        TSCPriceFetcher.modules.debug.warn(
            "Events: Could not register PreHooks (missing TooltipsModule or ItemTooltip.SetBagItem)")
    end
end

-- Register all events needed for your addon
function Events.registerAll()
    d("Events.registerAll called") -- Log entry into the function

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

    d("Events: All events registered (end of registerAll)")
    TSCPriceFetcher.modules.debug.log("Events: All events registered")
end

TSC_EventsModule = Events
return Events
