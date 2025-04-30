-- modules/core/init.lua
local TSCPriceFetcher = _G.TSCPriceFetcher

-- Default settings
local defaultSettings = {
    showTooltips = true,
    showInInventory = true,
    debugMode = true,
    throttleTime = 1000, -- ms between same debug messages
    version = "1.0.0"    -- Add version tracking
}

-- Setting types for validation
local settingTypes = {
    showTooltips = "boolean",
    showInInventory = "boolean",
    debugMode = "boolean",
    throttleTime = "number",
    version = "string"
}

local MODULE_VERSION = "1.0.0"
local SAVED_VARS_VERSION = 1
local savedVariableTable = "TSCPriceFetcherSavedVars"
local SETTINGS_CHANGED_EVENT = "TSCPriceFetcher_SettingChanged"
local REQUIRED_MODULES = {
    "debug",
    -- Add other required modules here
}

-- Add at top with other constants
local SETTING_CONSTRAINTS = {
    throttleTime = { min = 100, max = 10000 }, -- milliseconds
    version = { pattern = "^%d+%.%d+%.%d+$" }  -- semver format
}

local Init = {
    --- Current addon settings
    --- @type table
    settings = {},
    --- Whether the addon has been initialized
    --- @type boolean
    isInitialized = false,
    --- Event handlers
    --- @type table
    eventHandlers = {},
    --- Module version
    --- @type string
    version = MODULE_VERSION
}

-- Move KEYS inside Init table definition or after it
Init.KEYS = {
    SHOW_TOOLTIPS = "showTooltips",
    SHOW_INVENTORY = "showInInventory",
    DEBUG_MODE = "debugMode",
    THROTTLE_TIME = "throttleTime",
    VERSION = "version"
}

-- Private functions
local function initializeSettings()
    -- Start with defaults
    Init.settings = ZO_ShallowTableCopy(defaultSettings)
    TSCPriceFetcher.modules.debug.log("Init: Settings initialized with defaults")
end

local function initializeModules()
    local success = pcall(function()
        -- Set debug mode from settings
        TSCPriceFetcher.modules.debug.setEnabled(Init.settings.debugMode)
        TSCPriceFetcher.modules.debug.log("Init: Debug mode " .. (Init.settings.debugMode and "enabled" or "disabled"))

        -- Set throttle time from settings
        TSCPriceFetcher.modules.debug.throttleTime = Init.settings.throttleTime
    end)

    if not success then
        TSCPriceFetcher.modules.debug.error("Init: Failed to initialize modules")
        return false
    end
    return true
end

local function loadSavedVariables()
    -- Load saved variables or use defaults
    local success, result = pcall(function()
        return ZO_SavedVars:NewAccountWide(savedVariableTable, SAVED_VARS_VERSION, nil, defaultSettings)
    end)

    if not success then
        TSCPriceFetcher.modules.debug.error("Init: Failed to load saved variables - " .. tostring(result))
        return false
    end

    Init.settings = result
    TSCPriceFetcher.modules.debug.log("Init: Loaded saved variables")
    return true
end

local function checkVersion()
    local currentVersion = TSCPriceFetcher.version
    local savedVersion = Init.settings.lastVersion

    if savedVersion ~= currentVersion then
        TSCPriceFetcher.modules.debug.log(zo_strformat("Init: Version changed from <<1>> to <<2>>",
            savedVersion or "none", currentVersion))
        Init.settings.lastVersion = currentVersion
        return false
    end
    return true
end

local function validateSettings()
    local valid = true
    for key, defaultValue in pairs(defaultSettings) do
        -- Check existence and type in one go
        local isValid, error = validateSettingType(key, Init.settings[key])
        if Init.settings[key] == nil or not isValid then
            Init.settings[key] = defaultValue
            valid = false
            TSCPriceFetcher.modules.debug.warn(zo_strformat(
                "Init: Invalid or missing setting <<1>>: <<2>>, using default",
                key,
                error or "missing value"
            ))
        end
    end
    return valid
end

local function saveSettings()
    if not Init.isInitialized then return false end

    local success, result = pcall(function()
        return ZO_SavedVars:NewAccountWide(savedVariableTable, SAVED_VARS_VERSION, nil, Init.settings)
    end)

    if not success then
        TSCPriceFetcher.modules.debug.error("Init: Failed to save settings - " .. tostring(result))
        return false
    end

    Init.settings = result
    TSCPriceFetcher.modules.debug.log("Init: Settings saved")
    return true
end

local function onAddonLoaded(event, addonName)
    if addonName ~= TSCPriceFetcher.name then return end
    EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, EVENT_ADD_ON_LOADED)
    Init.initialize()
end

local function registerEvents()
    -- Register for addon loaded event
    Init.eventHandlers.addonLoaded = EVENT_MANAGER:RegisterForEvent(TSCPriceFetcher.name, EVENT_ADD_ON_LOADED,
        onAddonLoaded)

    -- Register for player activated (after loading screen)
    Init.eventHandlers.playerActivated = {
        name = EVENT_PLAYER_ACTIVATED,
        callback = function()
            TSCPriceFetcher.modules.debug.log("Init: Player activated")
        end
    }

    EVENT_MANAGER:RegisterForEvent(TSCPriceFetcher.name,
        Init.eventHandlers.playerActivated.name,
        Init.eventHandlers.playerActivated.callback)
end

--- Validates a setting value against its expected type and constraints
--- @param key string The setting key to validate
--- @param value any The value to validate
--- @return boolean isValid True if value matches expected type and constraints
--- @return string|nil error Error message if validation failed
local function validateSettingType(key, value)
    local expectedType = settingTypes[key]
    if not expectedType then
        return false, "No type definition found"
    end

    local actualType = type(value)
    if actualType ~= expectedType then
        return false, string.format("Expected type %s, got %s", expectedType, actualType)
    end

    -- Additional type-specific validation
    if expectedType == "number" then
        local constraints = SETTING_CONSTRAINTS[key]
        if constraints then
            if value < constraints.min or value > constraints.max then
                return false, string.format("Value must be between %d and %d", constraints.min, constraints.max)
            end
        end
    elseif expectedType == "string" and SETTING_CONSTRAINTS[key] then
        if not string.match(value, SETTING_CONSTRAINTS[key].pattern) then
            return false, "String format is invalid"
        end
    end

    return true, nil
end

-- Public functions
--- Initializes the addon
--- @return boolean Success
function Init.initialize()
    if Init.isInitialized then
        TSCPriceFetcher.modules.debug.warn("Init: Addon already initialized")
        return false
    end

    -- Check for required modules
    for _, moduleName in ipairs(REQUIRED_MODULES) do
        if not TSCPriceFetcher.modules[moduleName] then
            -- Can't use debug module here since it might not exist
            d("Init: Required module not found: " .. moduleName)
            return false
        end
    end

    TSCPriceFetcher.modules.debug.log("Init: Starting initialization")

    -- Initialize in order with error handling
    local success, error = pcall(function()
        initializeSettings()
        if not loadSavedVariables() then return false end
        if not validateSettings() then return false end
        if not checkVersion() then
            TSCPriceFetcher.modules.debug.warn("Init: Version mismatch detected")
        end
        if not initializeModules() then return false end
        return true
    end)

    if not success then
        TSCPriceFetcher.modules.debug.error("Init: Failed to initialize - " .. tostring(error))
        return false
    end

    Init.isInitialized = true
    TSCPriceFetcher.modules.debug.log("Init: Initialization complete")
    return true
end

--- Gets a setting value
--- @param key string The setting key
--- @return any|nil The setting value or nil if not found/initialized
function Init.getSetting(key)
    if not Init.isInitialized then
        TSCPriceFetcher.modules.debug.warn("Init: Attempted to get setting before initialization")
        return nil
    end

    if not Init.hasSetting(key) then
        TSCPriceFetcher.modules.debug.warn("Init: Attempted to get invalid setting: " .. tostring(key))
        return nil
    end
    return Init.settings[key]
end

--- Sets a setting value
--- @param key string The setting key to change
--- @param value any The new value to set
--- @return boolean Success Whether the setting was changed and saved successfully
function Init.setSetting(key, value)
    if not Init.isInitialized then
        TSCPriceFetcher.modules.debug.error("Init: Attempted to set setting before initialization")
        return false
    end

    if defaultSettings[key] == nil then
        TSCPriceFetcher.modules.debug.error("Init: Attempted to set invalid setting: " .. tostring(key))
        return false
    end

    local isValid, error = validateSettingType(key, value)
    if not isValid then
        TSCPriceFetcher.modules.debug.error(zo_strformat("Init: Invalid type for setting <<1>>: <<2>>", key, error))
        return false
    end

    local oldValue = Init.settings[key]
    Init.settings[key] = value

    -- Fire settings changed event
    CALLBACK_MANAGER:FireCallbacks(SETTINGS_CHANGED_EVENT, key, value, oldValue)

    TSCPriceFetcher.modules.debug.log(zo_strformat("Init: Setting <<1>> changed to <<2>>", key, tostring(value)))
    return saveSettings()
end

--- Resets settings to defaults
--- @return boolean Success Whether the settings were reset successfully
function Init.resetToDefaults()
    if not Init.isInitialized then
        TSCPriceFetcher.modules.debug.warn("Init: Attempted to reset settings before initialization")
        return false
    end

    Init.settings = ZO_ShallowTableCopy(defaultSettings)
    TSCPriceFetcher.modules.debug.log("Init: Settings reset to defaults")
    return saveSettings()
end

--- Cleans up the addon
--- @return boolean Success
function Init.shutdown()
    if not Init.isInitialized then return false end

    -- Save settings
    local saved = saveSettings()
    if not saved then
        TSCPriceFetcher.modules.debug.warn("Init: Failed to save settings during shutdown")
    end

    -- Unregister all events
    for name, handler in pairs(Init.eventHandlers) do
        if type(handler) == "table" then
            -- Handle structured event handlers
            EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, handler.name)
        else
            -- Handle simple event handlers
            EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, handler)
        end
    end

    Init.eventHandlers = {}
    Init.isInitialized = false
    TSCPriceFetcher.modules.debug.log("Init: Shutdown complete")
    return true
end

--- Gets all settings
--- @return table|nil settings All current settings (shallow copy) or nil if not initialized
function Init.getAllSettings()
    if not Init.isInitialized then
        TSCPriceFetcher.modules.debug.warn("Init: Attempted to get settings before initialization")
        return nil
    end
    return ZO_ShallowTableCopy(Init.settings)
end

--- Gets all default settings
--- @return table All default settings
function Init.getDefaultSettings()
    return ZO_ShallowTableCopy(defaultSettings)
end

--- Checks if a setting exists
--- @param key string The setting key to check
--- @return boolean Whether the setting exists
function Init.hasSetting(key)
    return defaultSettings[key] ~= nil
end

--- Registers a callback for when settings change
--- @param callback function The callback function to register
--- @return boolean Success Whether the callback was registered
--- @callback callback
--- @param key string The setting key that changed
--- @param newValue any The new value of the setting
--- @param oldValue any The previous value of the setting
function Init.onSettingChanged(callback)
    if type(callback) ~= "function" then
        TSCPriceFetcher.modules.debug.error("Init: Invalid callback provided to onSettingChanged")
        return false
    end
    CALLBACK_MANAGER:RegisterCallback(SETTINGS_CHANGED_EVENT, callback)
    return true
end

--- Validates all current settings
--- @return boolean isValid Whether all settings are valid
--- @return table invalidSettings Table of invalid settings with their error messages
function Init.validateAllSettings()
    if not Init.isInitialized then
        TSCPriceFetcher.modules.debug.warn("Init: Attempted to validate settings before initialization")
        return false, {}
    end

    local invalid = {}
    for key, value in pairs(Init.settings) do
        local isValid, error = validateSettingType(key, value)
        if not isValid then
            invalid[key] = error
        end
    end
    return next(invalid) == nil, invalid
end

--- Unregisters a callback for settings changes
--- @param callback function The callback to unregister
--- @return boolean Success Whether the callback was unregistered
function Init.offSettingChanged(callback)
    if type(callback) ~= "function" then
        TSCPriceFetcher.modules.debug.error("Init: Invalid callback provided to offSettingChanged")
        return false
    end
    CALLBACK_MANAGER:UnregisterCallback(SETTINGS_CHANGED_EVENT, callback)
    return true
end

--- Gets the current settings version
--- @return number version The current settings version number
function Init.getSettingsVersion()
    return SAVED_VARS_VERSION
end

--- Checks if settings need migration
--- @return boolean needsMigration True if settings version is older than current
--- @return number|nil currentVersion Current version if migration needed
--- @return number|nil savedVersion Saved version if migration needed
function Init.needsSettingsMigration()
    if not Init.isInitialized then
        TSCPriceFetcher.modules.debug.warn("Init: Attempted to check migration before initialization")
        return false, nil, nil
    end

    local savedVersion = Init.settings.lastVersion
    return savedVersion ~= MODULE_VERSION, MODULE_VERSION, savedVersion
end

-- Add at the very end before return Init
registerEvents()

return Init
