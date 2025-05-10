-- modules/ui/tooltips.lua
local Tooltips = {}

function Tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    -- Debug the call
    TSCPriceFetcher.modules.debug.log("AddPriceToGamepadTooltip called: tooltipType=" ..
    tostring(tooltipType) .. ", itemLink=" .. tostring(itemLink))

    -- Only proceed if we're dealing with the left tooltip
    if tooltipType ~= GAMEPAD_LEFT_TOOLTIP then
        TSCPriceFetcher.modules.debug.log("Not left tooltip, returning")
        return
    end

    -- Only proceed if itemLink is a valid item link
    if type(itemLink) ~= "string" or not itemLink:find("^|H%d:item:") then
        TSCPriceFetcher.modules.debug.log("Invalid item link, returning")
        return
    end

    local itemName = GetItemLinkName(itemLink)
    if not itemName or itemName == "" then
        TSCPriceFetcher.modules.debug.log("No item name, returning")
        return
    end

    -- Check if item type is valid (not ITEMTYPE_NONE which most non-items use)
    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_NONE then
        TSCPriceFetcher.modules.debug.log("Item type is NONE, returning")
        return
    end

    -- Get the tooltip object - this is safe based on the ESO code you shared
    local tooltip = tooltipObject:GetTooltip(tooltipType)
    if not tooltip then
        TSCPriceFetcher.modules.debug.log("No tooltip object, returning")
        return
    end

    -- Look up the price
    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)
    if not priceString then
        TSCPriceFetcher.modules.debug.log("No price found for item, returning")
        return
    end

    -- Add the price to the tooltip
    TSCPriceFetcher.modules.debug.log("Adding price to tooltip: " .. priceString)

    -- Use a try/catch approach to avoid errors if methods don't exist
    local success, result = pcall(function()
        local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
        priceSection:AddLine("Tamriel Savings Co: " .. priceString, tooltip:GetStyle("bodyDescription"))
        tooltip:AddSection(priceSection)
        return true
    end)

    if not success then
        TSCPriceFetcher.modules.debug.error("Failed to add price to tooltip: " .. tostring(result))
    end
end

TSC_TooltipsModule = Tooltips
return Tooltips
