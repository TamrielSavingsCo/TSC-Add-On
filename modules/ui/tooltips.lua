-- modules/ui/tooltips.lua
local Tooltips = {}

function Tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    if tooltipType ~= GAMEPAD_LEFT_TOOLTIP then return end

    -- Looser item link check: match any |H#:item: link
    if type(itemLink) ~= "string" or not itemLink:find("^|H%d:item:") then return end

    local itemName = GetItemLinkName(itemLink)
    if not itemName or itemName == "" then return end

    -- Only skip if item type is ITEMTYPE_NONE (most non-items)
    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_NONE then return end

    local tooltip = tooltipObject:GetTooltip(tooltipType)
    if not tooltip then return end

    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)
    if not priceString then return end

    local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
    priceSection:AddLine("Tamriel Savings Co: " .. priceString, tooltip:GetStyle("bodyDescription"))
    tooltip:AddSection(priceSection)
end

TSC_TooltipsModule = Tooltips
return Tooltips
