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
    d("OnTooltipShown called: " ..
        tostring(tooltipControl) .. ", " .. tostring(itemLink) .. ", " .. tostring(bagId) .. ", " .. tostring(slotIndex))

    -- Try to get itemLink if not provided
    if not itemLink and bagId and slotIndex then
        itemLink = GetItemLink(bagId, slotIndex)
    end

    if not itemLink or not tooltipControl then
        d("Tooltips: Missing itemLink or tooltipControl")
        return
    end

    local itemName = GetItemLinkName(itemLink)
    if not itemName then
        d("Tooltips: Could not get item name from itemLink: " .. tostring(itemLink))
        return
    end

    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)

    -- Try to add to the left tooltip
    local leftTooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_LEFT_TOOLTIP
    if leftTooltip and leftTooltip.AddLine then
        leftTooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        leftTooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to leftTooltip")
    else
        d("No AddLine method found on leftTooltip")
    end

    -- Debug: log all keys in tooltips
    if type(tooltipControl.tooltips) == "table" then
        for k, v in pairs(tooltipControl.tooltips) do
            d("tooltips key: " .. tostring(k) .. ", type: " .. type(v))
            if type(v) == "userdata" and v.AddLine then
                d("tooltips[" .. tostring(k) .. "] has AddLine")
            end
        end
    end
end

TSC_TooltipsModule = {
    OnTooltipShown = OnTooltipShown
}
return TSC_TooltipsModule
