local Debug = {}

--[[
    Color codes for ESO chat messages.
    ESO uses |cRRGGBB to start a color (hex), and |r to reset.
    We'll use different colors for info, warnings, and errors.
]]
local COLORS = {
    INFO = "FFFFFF",  -- White for normal info messages
    WARN = "FFFF00",  -- Yellow for warnings
    ERROR = "FF0000", -- Red for errors
}

--[[
    Helper function to wrap a message in ESO's color codes.
    msg:   The message string to colorize
    color: The hex color code (e.g., "FF0000" for red)
    Returns the colorized string for ESO chat output.
]]
local function colorize(msg, color)
    return string.format("|c%s%s|r", color, tostring(msg))
end

--[[
    Log a normal info message to the chat.
    Usage: Debug.log("something happened")
]]
function Debug.log(msg)
    d(colorize("[TSC] " .. msg, COLORS.INFO))
end

--[[
    Log a warning message to the chat (yellow).
    Usage: Debug.warn("this might be a problem")
]]
function Debug.warn(msg)
    d(colorize("[TSC][WARN] " .. msg, COLORS.WARN))
end

--[[
    Log an error message to the chat (red).
    Usage: Debug.error("this is definitely a problem")
]]
function Debug.error(msg)
    d(colorize("[TSC][ERROR] " .. msg, COLORS.ERROR))
end

--[[
    Return the Debug table so other files can use these functions.
    Example: local Debug = require("modules/core/debug")
]]
return Debug
