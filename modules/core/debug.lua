-- modules/core/debug.lua
local TSCPriceFetcher = _G.TSCPriceFetcher

-- Debug level constants
local DEBUG_LEVELS = {
    TRACE = 0, -- Most verbose level
    DEBUG = 1,
    WARNING = 2,
    ERROR = 3
}

local DEBUG_COLORS = {
    [DEBUG_LEVELS.TRACE] = "666666", -- Grey for trace
    [DEBUG_LEVELS.DEBUG] = "88FFFF",
    [DEBUG_LEVELS.WARNING] = "FFFF00",
    [DEBUG_LEVELS.ERROR] = "FF0000"
}

local DEBUG_LABELS = {
    [DEBUG_LEVELS.TRACE] = "TRACE",
    [DEBUG_LEVELS.DEBUG] = "DEBUG",
    [DEBUG_LEVELS.WARNING] = "WARNING",
    [DEBUG_LEVELS.ERROR] = "ERROR"
}

local Debug = {
    -- Will be set from init settings later
    enabled = true,
    LEVELS = DEBUG_LEVELS, -- Expose levels publicly
    -- Throttling settings
    lastMessage = {},
    throttleTime = 1000, -- ms between same messages
}

-- Private functions
local function validateMessage(message)
    if message == nil then
        return "nil"
    end
    return message
end

--- Formats a debug message with color and prefix
--- @param message any The message to format
--- @param level number The debug level (from DEBUG_LEVELS)
--- @return string The formatted message
local function formatMessage(message, level)
    if not DEBUG_COLORS[level] then
        level = DEBUG_LEVELS.DEBUG
    end
    return zo_strformat("|c<<1>>[TSCPriceFetcher <<2>>]|r <<3>>",
        DEBUG_COLORS[level],
        DEBUG_LABELS[level],
        tostring(validateMessage(message)))
end

local function isThrottled(message, level)
    local now = GetGameTimeMilliseconds()
    local key = tostring(message) .. tostring(level)
    local lastTime = Debug.lastMessage[key]

    if lastTime and (now - lastTime) < Debug.throttleTime then
        return true
    end

    Debug.lastMessage[key] = now
    return false
end

-- Public functions
--- Logs a trace message if debug is enabled (most verbose level)
--- @param message any The message to log
function Debug.trace(message)
    if not Debug.enabled then return end
    if isThrottled(message, DEBUG_LEVELS.TRACE) then return end
    d(formatMessage(message, DEBUG_LEVELS.TRACE))
end

--- Logs a debug message if debug is enabled
--- @param message any The message to log
function Debug.log(message)
    if not Debug.enabled then return end
    if isThrottled(message, DEBUG_LEVELS.DEBUG) then return end
    d(formatMessage(message, DEBUG_LEVELS.DEBUG))
end

--- Logs a warning message if debug is enabled
--- @param message any The message to log
--- @description Use for important but non-critical issues
function Debug.warn(message)
    if not Debug.enabled then return end
    if isThrottled(message, DEBUG_LEVELS.WARNING) then return end
    d(formatMessage(message, DEBUG_LEVELS.WARNING))
end

--- Logs an error message (always enabled) with optional stack trace
--- @param message any The message to log
--- @description Use for critical issues that need immediate attention
function Debug.error(message)
    -- Errors bypass throttling - always show them
    d(formatMessage(message, DEBUG_LEVELS.ERROR))
    -- Add stack trace in debug mode
    if Debug.enabled then
        d(debug.traceback("Stack trace:", 2))
    end
end

--- Enable/disable debug logging
--- @param enabled boolean Whether to enable debug logging
function Debug.setEnabled(enabled)
    Debug.enabled = enabled
    Debug.log(zo_strformat("Debug logging <<1>>", enabled and "enabled" or "disabled"))
end

return Debug
