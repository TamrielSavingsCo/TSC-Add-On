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

    -- Add to the left tooltip
    local leftTooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_LEFT_TOOLTIP
    if leftTooltip and leftTooltip.AddLine then
        leftTooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        leftTooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to leftTooltip")
    else
        d("No AddLine method found on leftTooltip")
    end

    -- Add to the movable tooltip
    local movableTooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_MOVABLE_TOOLTIP
    if movableTooltip and movableTooltip.AddLine then
        movableTooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        leftTooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to movableTooltip")
    else
        d("No AddLine method found on movableTooltip")
    end

    -- Add to the quad3 tooltip
    local quad3Tooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_QUAD_TOOLTIP
    if quad3Tooltip and quad3Tooltip.AddLine then
        quad3Tooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        quad3Tooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to quad3Tooltip")
    else
        d("No AddLine method found on quad3Tooltip")
    end

    -- Add to the right tooltip
    local rightTooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_RIGHT_TOOLTIP
    if rightTooltip and rightTooltip.AddLine then
        rightTooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        rightTooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to rightTooltip")
    else
        d("No AddLine method found on rightTooltip")
    end

    -- Add to the quad23 tooltip
    local quad23Tooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_QUAD_2_3_TOOLTIP
    if quad23Tooltip and quad23Tooltip.AddLine then
        quad23Tooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        quad23Tooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to quad23Tooltip")
    else
        d("No AddLine method found on quad23Tooltip")
    end

    -- Add to the left dialog tooltip
    local leftDialogTooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_LEFT_DIALOG_TOOLTIP
    if leftDialogTooltip and leftDialogTooltip.AddLine then
        leftDialogTooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        leftDialogTooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to leftDialogTooltip")
    else
        d("No AddLine method found on leftDialogTooltip")
    end

    -- Add to the quad1 tooltip
    local quad1Tooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_QUAD1_TOOLTIP
    if quad1Tooltip and quad1Tooltip.AddLine then
        quad1Tooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        quad1Tooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to quad1Tooltip")
    else
        d("No AddLine method found on quad1Tooltip")
    end

    -- Add to the quad2 tooltip
    local quad2Tooltip = tooltipControl.tooltips and tooltipControl.tooltips.GAMEPAD_QUAD2_TOOLTIP
    if quad2Tooltip and quad2Tooltip.AddLine then
        quad2Tooltip:AddLine("|cFFFF00Avg Price:|r " .. priceString .. " gold")
        quad2Tooltip:AddLine("|cFF00FFTEST LINE: If you see this, AddLine works!|r")
        d("Added price line and TEST LINE to quad2Tooltip")
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
