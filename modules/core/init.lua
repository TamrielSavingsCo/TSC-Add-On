--[[
    modules/core/init.lua
    Handles addon initialization and hooks for gamepad tooltips.
    Exposes: initialize, isReady
]]

local Init = {}

-- Flag to track if the addon is initialized
Init.isInitialized = false

local function HookGamepadTooltips()
    -- Hook inventory item tooltips - this is the most reliable hook
    SecurePostHook(ZO_GamepadInventory, "UpdateItemLeftTooltip", function(self, selectedData)
        -- Only add price data when there's a selected item
        if not selectedData then return end

        -- Check if we're really dealing with an item
        if not selectedData.bagId or not selectedData.slotIndex then return end

        -- Make sure we don't add prices for non-inventory contexts
        if selectedData.isCurrencyEntry or selectedData.isMundusEntry then return end

        -- Check if this is an actual item (has a valid name)
        local itemLink = GetItemLink(selectedData.bagId, selectedData.slotIndex)
        local itemName = GetItemLinkName(itemLink)
        if not itemName or itemName == "" then return end

        -- Get the left tooltip object that was just updated by the base function
        local tooltipObject = GAMEPAD_TOOLTIPS
        local tooltipType = GAMEPAD_LEFT_TOOLTIP

        -- Use our throttled tooltip function to add the price
        TSCPriceFetcher.modules.tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    end)
end

--- Initializes the addon (called on EVENT_ADD_ON_LOADED)
function Init.initialize()
    if Init.isInitialized then
        TSCPriceFetcher.modules.debug.log("Init: Already initialized")
        return
    end
    Init.isInitialized = true
    TSCPriceFetcher.modules.debug.success("Init: Addon initialized")
    HookGamepadTooltips()
end

--- Returns true if the addon is initialized
function Init.isReady()
    return Init.isInitialized
end

TSC_InitModule = Init
return Init
