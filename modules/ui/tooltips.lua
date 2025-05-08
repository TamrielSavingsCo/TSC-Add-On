--[[
    Handler for when an item tooltip is shown.
    Handles all logic: gets item info, looks up price, adds to tooltip, logs as needed.
    @param eventCode (number|nil) - The event code (unused for prehooks)
    @param tooltipControl (userdata) - The tooltip control being shown
    @param itemLink (string|nil) - The itemLink for the item (if available)
    @param bagId (number|nil) - The bagId (if available)
    @param slotIndex (number|nil) - The slotIndex (if available)
]]
local function OnTooltipShown(eventCode, tooltipControl, itemLink, bagId, slotIndex)
    -- Try to get itemLink if not provided
    if not itemLink and bagId and slotIndex then
        itemLink = GetItemLink(bagId, slotIndex)
    end

    if not itemLink or not tooltipControl then
        if TSCPriceFetcher and TSCPriceFetcher.modules and TSCPriceFetcher.modules.debug then
            TSCPriceFetcher.modules.debug.warn("Tooltips: Missing itemLink or tooltipControl")
        end
        return
    end

    local itemName = GetItemLinkName(itemLink)
    if not itemName then
        if TSCPriceFetcher and TSCPriceFetcher.modules and TSCPriceFetcher.modules.debug then
            TSCPriceFetcher.modules.debug.warn("Tooltips: Could not get item name from itemLink: " .. tostring(itemLink))
        end
        return
    end

    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)
    if priceString then
        tooltipControl:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        if TSCPriceFetcher and TSCPriceFetcher.modules and TSCPriceFetcher.modules.debug then
            TSCPriceFetcher.modules.debug.log("Tooltips: Added price to tooltip for " .. itemName)
        end
    end
end

return {
    OnTooltipShown = OnTooltipShown
}
