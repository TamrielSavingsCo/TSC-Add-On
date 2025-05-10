-- modules/ui/tooltips.lua
local Tooltips = {}

function Tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    if tooltipType ~= GAMEPAD_LEFT_TOOLTIP then return end

    local itemName = itemLink and GetItemLinkName(itemLink)
    if not (tooltipObject and itemName and itemName ~= "") then return end


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
