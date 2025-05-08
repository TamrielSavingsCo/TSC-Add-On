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

-- Register all events needed for your addon
function Events.registerAll()
    -- Example: Addon loaded event
    Events.register(EVENT_ADD_ON_LOADED, function(event, addonName)
        if addonName == TSCPriceFetcher.name then
            TSCPriceFetcher.modules.init.initialize()
        end
    end)

    -- **may not need this implementation**
    -- local Tooltips = require("modules/ui/tooltips")
    -- Events.register(EVENT_ITEM_TOOLTIP_SHOWN, Tooltips.OnTooltipShown)

    local Tooltips = require("modules/ui/tooltips")
    ZO_PreHook(ZO_ItemTooltip_SetBagItem, function(tooltipControl, bagId, slotIndex)
        Tooltips.OnTooltipShown(nil, tooltipControl, nil, bagId, slotIndex)
        return false
    end)

    -- Add more event registrations here as your addon grows
    TSCPriceFetcher.modules.debug.log("Events: All events registered")
end

return Events
