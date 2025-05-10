-- modules/core/init.lua

local Init = {}

-- Flag to track if the addon is initialized
Init.isInitialized = false

function Init.initialize()
    if Init.isInitialized then
        TSCPriceFetcher.modules.debug.log("Init: Already initialized")
        return
    end
    Init.isInitialized = true
    TSCPriceFetcher.modules.debug.success("Init: Addon initialized")

    local function HookGamepadTooltips()
        -- Instead of hooking the tooltip system directly, hook into 
        -- the inventory system's UpdateItemLeftTooltip function
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
            
            TSCPriceFetcher.modules.debug.log("Adding price for item: " .. itemName)
            
            -- Get the left tooltip object that was just updated by the base function
            local tooltipObject = GAMEPAD_TOOLTIPS
            local tooltip = tooltipObject:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
            
            if not tooltip then
                TSCPriceFetcher.modules.debug.error("Tooltip object not found")
                return
            end
            
            -- Look up the price
            local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)
            if not priceString then return end
            
            -- Add a slight delay to ensure we add our data after the tooltip is fully populated
            zo_callLater(function()
                local success, result = pcall(function()
                    local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
                    priceSection:AddLine("Tamriel Savings Co: " .. priceString, tooltip:GetStyle("bodyDescription"))
                    tooltip:AddSection(priceSection)
                    return true
                end)
                
                if not success then
                    TSCPriceFetcher.modules.debug.error("Failed to add price to tooltip: " .. tostring(result))
                end
            end, 50) -- 50ms delay
        end)
    end

    -- Call this once during your addon initialization
    HookGamepadTooltips()
end

function Init.isReady()
    return Init.isInitialized
end

TSC_InitModule = Init
return Init