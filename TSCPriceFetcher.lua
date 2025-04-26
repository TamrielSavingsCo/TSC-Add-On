-- TSCPriceFetcher
-- A price lookup addon for ESO
-- Author: @besidemyself

-- Create the addon namespace
local TSCPriceFetcher = {}

-- Constants and cached values
TSCPriceFetcher.name = "TSCPriceFetcher"
TSCPriceFetcher.version = "0.0.1"

-- Default settings - no longer using saved variables
TSCPriceFetcher.settings = {
    showTooltips = true,
    showInInventory = true,
    debugMode = true,
}

-- Forward declare functions
local OnAddOnLoaded
local InitializeAddon
local LookupPrice
local FormatPrice

-- Debug logging function
local function DebugLog(message)
    -- Only log if debug is enabled
    if TSCPriceFetcher.settings.debugMode then
        d("|c88FFFF[TSCPriceFetcher DEBUG]|r " .. tostring(message))
    end
end

-------------------------------
-- Main Addon Functions
-------------------------------

-- Function to look up a price based on itemId
function LookupPrice(itemId, itemLink)
    DebugLog("LookupPrice: " .. tostring(itemId) .. " " .. tostring(itemLink))
    -- Direct ID lookup for most items
    if TSCPriceData[itemId] then
        DebugLog("LookupPrice: Found price for itemId " .. tostring(itemId))
        return TSCPriceData[itemId].price
    end

    -- Only check type if we need to
    local itemType = GetItemLinkItemType(itemLink or
        ("|H1:item:" .. itemId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
    DebugLog("LookupPrice: Item type: " .. tostring(itemType))
    -- Name lookup only for gear items
    ---@diagnostic disable-next-line: undefined-global
    if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_JEWELRY then
        local itemName = GetItemLinkName(itemLink or
            ("|H1:item:" .. itemId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
        DebugLog("LookupPrice: Item name: " .. tostring(itemName))
        if itemName and TSCPriceNameData[itemName] then
            DebugLog("LookupPrice: Found price for itemName " .. tostring(itemName))
            return TSCPriceNameData[itemName].price
        end
    end
    DebugLog("LookupPrice: No price found, returning 0")
    return 0
end

-- Function to format price with commas
function FormatPrice(price)
    DebugLog("FormatPrice: " .. tostring(price))
    local formatted = tostring(price)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    DebugLog("FormatPrice: Formatted price: " .. tostring(formatted))
    return formatted
end

-- Hook into item tooltips for bag items (inventory, bank, etc.)
function SetupBagItemTooltipHook()
    DebugLog("SetupBagItemTooltipHook: Setting up bag item tooltip hook")
    ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "SetBagItem", function(self, bagId, slotIndex)
        DebugLog("SetupBagItemTooltipHook: Bag ID: " .. tostring(bagId) .. " Slot Index: " .. tostring(slotIndex))
        if not TSCPriceFetcher.settings.showTooltips then
            DebugLog("SetupBagItemTooltipHook: Exiting early - tooltips disabled")
            return false
        end

        local itemId = GetItemId(bagId, slotIndex)
        DebugLog("SetupBagItemTooltipHook: Item ID: " .. tostring(itemId))
        if itemId and itemId > 0 then
            local price = LookupPrice(itemId)
            DebugLog("SetupBagItemTooltipHook: Price: " .. tostring(price))
            if price and price > 0 then
                self:AddLine(zo_strformat("TSC Price: <<1>>g", FormatPrice(price)))
            end
        end
        return false
    end)
    DebugLog("SetupBagItemTooltipHook: Bag item tooltip hook set up")
end

-- Hook into item tooltips for item links (chat, quest rewards, etc.)
function SetupItemLinkTooltipHook()
    DebugLog("SetupItemLinkTooltipHook: Setting up item link tooltip hook")
    ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "SetLink", function(self, itemLink)
        DebugLog("SetupItemLinkTooltipHook: Item Link: " .. tostring(itemLink))
        if not TSCPriceFetcher.settings.showTooltips then
            DebugLog("SetupItemLinkTooltipHook: Exiting early - tooltips disabled")
            return false
        end

        local itemId = GetItemLinkItemId(itemLink)
        DebugLog("SetupItemLinkTooltipHook: Item ID: " .. tostring(itemId))
        if itemId and itemId > 0 then
            local price = LookupPrice(itemId, itemLink)
            DebugLog("SetupItemLinkTooltipHook: Price: " .. tostring(price))
            if price and price > 0 then
                self:AddLine(zo_strformat("TSC Price: <<1>>g", FormatPrice(price)))
            end
        end
        return false
    end)
    DebugLog("SetupItemLinkTooltipHook: Item link tooltip hook set up")
end

-- Master function to setup all tooltip hooks
function SetupAllHooks()
    DebugLog("SetupAllHooks: Setting up all hooks")
    SetupBagItemTooltipHook()
    SetupItemLinkTooltipHook()
    SetupInventoryHooks()
    DebugLog("SetupAllHooks: All hooks set up")
end

-- Hook into inventory item display to show prices
function SetupInventoryHooks()
    DebugLog("SetupInventoryHooks: Setting up inventory hook")
    if not TSCPriceFetcher.settings.showInInventory then
        DebugLog("SetupInventoryHooks: Exiting early - inventory not shown")
        return
    end

    -- Only implement the gamepad inventory hook
    ---@diagnostic disable-next-line: param-type-mismatch
    ZO_PreHook("ZO_GamepadInventoryList_SetupItemRow", function(control, data)
        DebugLog("SetupInventoryHooks: Gamepad inventory hook triggered " .. tostring(control) .. " " .. tostring(data))
        if not control or not data or not data.data then return false end

        local bagId, slotIndex = data.data.bagId, data.data.slotIndex
        DebugLog("SetupInventoryHooks: Bag ID: " .. tostring(bagId) .. " Slot Index: " .. tostring(slotIndex))
        if not bagId or not slotIndex then return false end

        local itemId = GetItemId(bagId, slotIndex)
        DebugLog("SetupInventoryHooks: Item ID: " .. tostring(itemId))
        if not itemId or itemId <= 0 then return false end

        local price = LookupPrice(itemId)
        DebugLog("SetupInventoryHooks: Price: " .. tostring(price))
        if price and price > 0 then
            -- Find the label in gamepad UI
            local nameControl = control:GetNamedChild("Name")
            DebugLog("SetupInventoryHooks: Name Control: " .. tostring(nameControl))
            if nameControl then
                local originalName = nameControl:GetText()
                DebugLog("SetupInventoryHooks: Original Name: " .. tostring(originalName))
                local priceText = " - " .. FormatPrice(price) .. "g"
                DebugLog("SetupInventoryHooks: Price Text: " .. tostring(priceText))
                nameControl:SetText(originalName .. priceText)
                DebugLog("SetupInventoryHooks: Set Text: " .. tostring(originalName) .. tostring(priceText))
            end
        end

        return false
    end)
    DebugLog("SetupInventoryHooks: Inventory hook set up")
end

-- Function to convert date string to timestamp - optimized for console
local function dateToTimestamp(dateStr)
    DebugLog("dateToTimestamp: " .. tostring(dateStr))
    -- Simple conversion from YYYY-MM-DD to timestamp
    local year, month, day = dateStr:match("(%d+)-(%d+)-(%d+)")
    if year and month and day then
        year, month, day = tonumber(year), tonumber(month), tonumber(day)
        DebugLog("dateToTimestamp: Year: " ..
            tostring(year) .. " Month: " .. tostring(month) .. " Day: " .. tostring(day))
        -- Basic validation to avoid crashes
        if not year or year < 2020 or year > 2050 or
            not month or month < 1 or month > 12 or
            not day or day < 1 or day > 31 then
            -- Fall back to a reasonable default if data is corrupt
            DebugLog("dateToTimestamp: Data is corrupt, returning 30 days ago")
            return GetTimeStamp() - 2592000 -- 30 days ago
        end

        -- Force UTC time (more consistent across consoles)
        -- Set time to noon to avoid day boundary issues
        local t = os.time({
            year = year,
            month = month,
            day = day,
            hour = 12,
            min = 0,
            sec = 0,
            isdst = false -- Disable DST considerations
        })
        DebugLog("dateToTimestamp: Timestamp: " .. tostring(t))
        return t
    end

    -- If parsing fails, use a reasonable fallback
    DebugLog("dateToTimestamp: Parsing failed, returning 30 days ago")
    return GetTimeStamp() - 2592000 -- 30 days ago
end

-- Check if price data is current with flexibility - console optimized
function CheckPriceDataVersion()
    -- Use a pcall to prevent any possible errors from crashing the addon
    local success, result = pcall(function()
        local currentDate = GetTimeStamp() -- Gets current timestamp in seconds
        DebugLog("CheckPriceDataVersion: Current date: " .. tostring(currentDate))
        -- Check main price data
        if not TSCPriceDataInfo then
            -- Missing metadata is critical but shouldn't crash
            return false, "Price data information is missing. Please reinstall the addon."
        end

        -- Make sure the date format is valid before proceeding
        if not TSCPriceDataInfo.expiryDate or
            not TSCPriceDataInfo.expiryDate:match("^%d%d%d%d%-%d%d%-%d%d$") then
            -- Invalid date format
            return false, "Price data format is invalid. Please reinstall the addon."
        end

        local expiryTimestamp = dateToTimestamp(TSCPriceDataInfo.expiryDate)

        -- Standard grace period - 8 days
        local standardGracePeriod = 691200 -- 8 days in seconds

        -- Calculate how out of date the data is
        local daysPastExpiry = (currentDate - expiryTimestamp) / 86400 -- Convert to days

        -- Data is extremely outdated (30+ days) - show stronger alert
        if daysPastExpiry >= 30 then
            DebugLog("CheckPriceDataVersion: Data is extremely outdated")
            return false, "Your price data is critically outdated. Prices are likely inaccurate."
            -- Data is moderately outdated (8+ days) - show standard alert
        elseif daysPastExpiry >= 8 then
            DebugLog("CheckPriceDataVersion: Data is moderately outdated")
            return false, "Your price data is outdated. Consider updating soon."
            -- Data is current or within grace period - no alert needed
        else
            DebugLog("CheckPriceDataVersion: Data is current")
            return true, ""
        end
    end)

    -- Default for crash cases
    if not success then
        DebugLog("CheckPriceDataVersion: Error checking data version")
        d("|cFF0000TSCPriceFetcher: Error checking data version. The addon will continue to work.|r")
        return true -- Don't bother users with errors, just keep working
    end

    local dataIsCurrent, warningMessage = result, ""
    if type(result) == "table" then
        dataIsCurrent, warningMessage = result[1], result[2]
    end

    -- If there's a warning, display it to the user
    if warningMessage and warningMessage ~= "" then
        -- Display message in a way that's clearly visible to console users
        -- Red text for expired, brighter red for critically outdated
        local messageColor = "FF0000" -- Default red

        -- If checking result directly mentioned "critically" - use brighter color
        if warningMessage:find("critically") then
            messageColor = "FF3333" -- Brighter red for critical

            -- Make the alert more prominent for critical outdated data
            ---@diagnostic disable-next-line: param-type-mismatch
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR,
                "TSCPriceFetcher: " .. warningMessage)
        end

        -- Always show chat message
        d("|c" .. messageColor .. "TSCPriceFetcher: " .. warningMessage .. "|r")
    end

    return dataIsCurrent
end

-- Check if data file is loaded correctly
function ValidatePriceData()
    if not TSCPriceData then
        d("|cFF0000TSCPriceFetcher: ERROR - Price data not found! Please reinstall the addon.|r")
        DebugLog("ValidatePriceData: TSCPriceData not found")
        return false
    end

    local entryCount = 0
    for _ in pairs(TSCPriceData) do
        entryCount = entryCount + 1
        if entryCount > 1000 then break end -- Just count a sample for performance
    end

    DebugLog("ValidatePriceData: Found " .. entryCount .. " price entries")

    if entryCount < 10 then
        d("|cFF0000TSCPriceFetcher: WARNING - Price data seems incomplete! Only " .. entryCount .. " entries found.|r")
        DebugLog("ValidatePriceData: Price data seems incomplete")
        return false
    end

    return true
end

-- Initialize the addon
function InitializeAddon()
    -- Only validate data in debug mode
    if TSCPriceFetcher.settings.debugMode then
        DebugLog("InitializeAddon: Validating price data")
        ValidatePriceData()
        DebugLog("InitializeAddon: Price data validated")
    end

    -- Check data versions when ready
    -- TODO: RE-ENABLE AFTER TESTING BASIC FUNCTIONALITY
    -- local dataIsCurrent = CheckPriceDataVersion()

    -- Continue with initialization
    SetupAllHooks()

    -- Log successful initialization
    DebugLog("InitializeAddon: Successfully initialized")
    d("|c88FFFFTSCP|r|cFFDDAArice|r|c88FFFFetcher|r v" .. TSCPriceFetcher.version .. " initialized")

    -- Add this after SetupAllHooks()
    if TSCPriceFetcher.settings.debugMode then
        zo_callLater(function() TestSuite() end, 5000)
    end
end

-- Event handler for when the addon loads
function OnAddOnLoaded(event, addonName)
    -- Only initialize our addon
    DebugLog("OnAddOnLoaded: Event: " .. tostring(event) .. " Addon Name: " .. tostring(addonName))
    if addonName ~= TSCPriceFetcher.name then return end

    -- Unregister the event to avoid unnecessary checks
    ---@diagnostic disable-next-line: param-type-mismatch
    EVENT_MANAGER:UnregisterForEvent(TSCPriceFetcher.name, EVENT_ADD_ON_LOADED)

    -- Initialize the addon
    DebugLog("OnAddOnLoaded: Initializing addon")
    InitializeAddon()
end

-- Register for the addon loaded event
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(TSCPriceFetcher.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- TESTING UTILITY FUNCTIONS
-----------------------------------------------------------------

-- Tests basic price data lookup by ID
function TestPriceDataLookup()
    DebugLog("TestPriceDataLookup: Testing item ID lookup")

    -- Test specific item by ID
    local testItemId = 34349 -- Acai Berry

    -- Look up the price directly
    local price = LookupPrice(testItemId)
    DebugLog("TestPriceDataLookup: Price lookup for Acai Berry (ID: " .. testItemId .. "): " .. tostring(price))
    d("|c88FFFFPrice Test:|r Acai Berry (ID: " .. testItemId .. ") price: " .. tostring(price or "not found"))

    -- If price data is missing, add it for testing
    if not price or price <= 0 then
        if not TSCPriceData then TSCPriceData = {} end
        TSCPriceData[testItemId] = { price = 123 }
        d("|cFFFF88Note:|r Created test price 123 for Acai Berry (ID: " .. testItemId .. ")")

        -- Test lookup again
        price = LookupPrice(testItemId)
        d("|c88FFFFPrice Test:|r After adding data - Acai Berry price: " .. tostring(price or "still not found"))
    end

    return price and price > 0
end

-- Tests name-based price data lookup
function TestPriceNameDataLookup()
    DebugLog("TestPriceNameDataLookup: Testing item name lookup")

    -- Test specific named item
    local namedItemLink = "|H1:item:123456:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Abyssal Brace Gauntlets]|h"
    local itemName = "Abyssal Brace Gauntlets"

    -- Test if TSCPriceNameData exists
    if not TSCPriceNameData then
        d("|cFF8888Price Test:|r TSCPriceNameData table missing")
        DebugLog("TestPriceNameDataLookup: TSCPriceNameData table not found")
        TSCPriceNameData = {}
    end

    -- Add the test item to the name data
    TSCPriceNameData[itemName] = { price = 10000 }
    d("|cFFFF88Note:|r Added test price 10000 for " .. itemName)

    -- Test name lookup through the regular function
    local mockedItemLink = namedItemLink
    local namePrice = LookupPrice(123456, mockedItemLink)
    d("|c88FFFFPrice Test:|r " .. itemName .. " price: " .. tostring(namePrice or "not found"))
    DebugLog("TestPriceNameDataLookup: Price lookup for " .. itemName .. ": " .. tostring(namePrice))

    return namePrice and namePrice > 0
end

-- Tests price data structure integrity
function TestDataStructures()
    DebugLog("TestDataStructures: Checking data structures")

    -- Check internal data structures
    DebugLog("TestDataStructures: TSCPriceData exists: " .. tostring(TSCPriceData ~= nil))
    DebugLog("TestDataStructures: TSCPriceNameData exists: " .. tostring(TSCPriceNameData ~= nil))

    -- Display data structure details
    local idCount = 0
    if TSCPriceData then
        for _ in pairs(TSCPriceData) do idCount = idCount + 1 end
    end

    local nameCount = 0
    if TSCPriceNameData then
        for _ in pairs(TSCPriceNameData) do nameCount = nameCount + 1 end
    end

    d("|c88FFFFData Summary:|r ID entries: " .. idCount .. ", Name entries: " .. nameCount)

    return TSCPriceData ~= nil and idCount > 0
end

-- Tests gamepad UI availability
function TestGamepadUI()
    DebugLog("TestGamepadUI: Checking UI state")

    -- Check if we're in gamepad mode
    local isGamepadMode = IsInGamepadPreferredMode()
    DebugLog("TestGamepadUI: IsInGamepadPreferredMode(): " .. tostring(isGamepadMode))
    d("|c88FFFFGamepad Mode:|r " .. tostring(isGamepadMode))

    -- Then check if the global objects exist
    local tooltipsExist = GAMEPAD_TOOLTIPS ~= nil
    d("|c88FFFFGamepad Test:|r GAMEPAD_TOOLTIPS exists: " .. tostring(tooltipsExist))
    DebugLog("TestGamepadUI: GAMEPAD_TOOLTIPS exists: " .. tostring(tooltipsExist))

    -- Report more detailed info if tooltips exist
    if tooltipsExist then
        d("|c88FFFFGamepad Test:|r Tooltip object type: " .. type(GAMEPAD_TOOLTIPS))
        d("|c88FFFFGamepad Test:|r GetTooltip method exists: " ..
            tostring(type(GAMEPAD_TOOLTIPS.GetTooltip) == "function"))
    end

    return isGamepadMode and tooltipsExist
end

-- Master testing function that runs all tests
function TestSuite()
    DebugLog("TestSuite: Beginning all tests")
    d("|c88FFFF==== TSCPriceFetcher TEST SUITE ====|r")

    -- Run each test and collect results
    local results = {
        priceData = TestPriceDataLookup(),
        nameData = TestPriceNameDataLookup(),
        dataStructures = TestDataStructures(),
        gamepadUI = TestGamepadUI()
    }

    -- Display summary
    d("|c88FFFF==== TEST RESULTS ====|r")
    d("|c" .. (results.priceData and "88FF88" or "FF8888") .. "Price Data Lookup:|r " .. tostring(results.priceData))
    d("|c" .. (results.nameData and "88FF88" or "FF8888") .. "Name Data Lookup:|r " .. tostring(results.nameData))
    d("|c" ..
        (results.dataStructures and "88FF88" or "FF8888") .. "Data Structures:|r " .. tostring(results.dataStructures))
    d("|c" .. (results.gamepadUI and "88FF88" or "FF8888") .. "Gamepad UI Available:|r " .. tostring(results.gamepadUI))

    local allPassed = results.priceData and results.nameData and results.dataStructures
    local uiWarning = not results.gamepadUI and "WARNING: Gamepad UI not available - tooltips will not work!" or ""

    d("|c" .. (allPassed and "88FF88" or "FF8888") .. "Overall Result:|r " .. (allPassed and "PASS" or "FAIL") ..
        (uiWarning ~= "" and " - " .. uiWarning or ""))

    DebugLog("TestSuite: Tests completed")
    return results
end
