-- modules/core/events.lua
local TSCPriceFetcher = _G.TSCPriceFetcher

local Events = {
    -- Store registered events for cleanup
    registered = {},
    --- Queue for events that should be registered after initialization
    --- @type table<number, {event: number, callback: function}>
    initQueue = {},
    --- Whether the events system has been initialized
    --- @type boolean
    isInitialized = false
}

-- Private functions
local function cleanupEventsInternal()
    TSCPriceFetcher.modules.debug.trace("Events: Cleaning up registered events")
    for event, callback in pairs(Events.registered) do
        EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, event)
    end
    Events.registered = {}
end

--- Handles the addon loaded event
--- @param eventCode number The event code
--- @param addonName string Name of the addon that loaded
local function onLoaded(eventCode, addonName)
    if addonName ~= TSCPriceFetcher.name then return end

    TSCPriceFetcher.modules.debug.log("Events: Addon loaded")
    EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, EVENT_ADD_ON_LOADED)

    -- Initialize the addon through init module
    TSCPriceFetcher.modules.init.initialize()
    Events.markInitialized()
end

-- Public functions
--- Cleans up all registered events
--- @description Use when needing to reset addon state or during shutdown
function Events.cleanup()
    cleanupEventsInternal()
end

--- Registers an event handler
--- @param event number The event to register for
--- @param callback function The callback function
function Events.register(event, callback)
    if type(callback) ~= "function" then
        TSCPriceFetcher.modules.debug.error("Events: Invalid callback for event " .. tostring(event))
        return
    end

    TSCPriceFetcher.modules.debug.trace(zo_strformat("Events: Registering for event <<1>>", event))
    EVENT_MANAGER:RegisterForEvent(TSCPriceFetcher.name, event, callback)
    Events.registered[event] = callback
end

--- Unregisters an event handler
--- @param event number The event to unregister
function Events.unregister(event)
    TSCPriceFetcher.modules.debug.trace(zo_strformat("Events: Unregistering event <<1>>", event))
    EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, event)
    Events.registered[event] = nil
end

--- Registers an event handler with optional filter
--- @param event number The event to register for
--- @param callback function The callback function
--- @param filterType number Optional filter type
--- @param filterValue any Optional filter value
function Events.registerFiltered(event, callback, filterType, filterValue)
    if filterType and filterValue == nil then
        TSCPriceFetcher.modules.debug.error("Events: Filter type provided without value for event " .. tostring(event))
        return
    end
    Events.register(event, callback)
    if filterType then
        EVENT_MANAGER:AddFilterForEvent(TSCPriceFetcher.name, event, filterType, filterValue)
    end
end

--- Checks if an event is registered
--- @param event number The event to check
--- @return boolean Whether the event is registered
function Events.isRegistered(event)
    return Events.registered[event] ~= nil
end

--- Queues an event registration for after initialization
--- @param event number The event to register
--- @param callback function The callback function
--- @description Use this when you need to ensure the addon is fully initialized before registering
function Events.queueForInit(event, callback)
    if Events.isInitialized then
        Events.register(event, callback)
    else
        table.insert(Events.initQueue, { event = event, callback = callback })
    end
end

--- Marks the events system as initialized and processes queued events
function Events.markInitialized()
    Events.isInitialized = true
    -- Process queued events
    for _, queuedEvent in ipairs(Events.initQueue) do
        Events.register(queuedEvent.event, queuedEvent.callback)
    end
    Events.initQueue = {} -- Clear the queue
    TSCPriceFetcher.modules.debug.log("Events: Initialization complete, processed queued events")
end

--- Removes a filter from an event
--- @param event number The event to remove filter from
--- @param filterType number The filter type to remove
function Events.removeFilter(event, filterType)
    if Events.isRegistered(event) then
        EVENT_MANAGER:RemoveFilterForEvent(TSCPriceFetcher.name, event, filterType)
        TSCPriceFetcher.modules.debug.trace(zo_strformat("Events: Removed filter <<1>> from event <<2>>", filterType,
            event))
    end
end

--- Temporarily suspends event handling
function Events.suspend()
    for event in pairs(Events.registered) do
        EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, event)
    end
    TSCPriceFetcher.modules.debug.log("Events: Suspended event handling")
end

--- Resumes event handling
function Events.resume()
    for event, callback in pairs(Events.registered) do
        EVENT_MANAGER:RegisterForEvent(TSCPriceFetcher.name, event, callback)
    end
    TSCPriceFetcher.modules.debug.log("Events: Resumed event handling")
end

-- Register for initial load event
Events.register(EVENT_ADD_ON_LOADED, onLoaded)

-- Register for player activated (after load screen)
Events.register(EVENT_PLAYER_ACTIVATED, function()
    TSCPriceFetcher.modules.debug.log("Events: Player activated")
end)

-- Register for player deactivated/logout
Events.register(EVENT_PLAYER_DEACTIVATED, function()
    TSCPriceFetcher.modules.debug.log("Events: Player deactivated")
    Events.cleanup()
end)

return Events
