-- modules/ui/tooltips.lua
local Tooltips = {}

function Tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    if tooltipType ~= GAMEPAD_LEFT_TOOLTIP then return end

    if not tooltipObject or not itemLink or itemLink == "" then return end

    local tooltip = tooltipObject:GetTooltip(tooltipType)
    if not tooltip then return end

    local itemName = GetItemLinkName(itemLink)
    if not itemName or itemName == "" then return end

    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)
    if not priceString then return end

    local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
    priceSection:AddLine("Tamriel Savings Co: " .. priceString .. " gold", tooltip:GetStyle("bodyDescription"))
    tooltip:AddSection(priceSection)
end

TSC_TooltipsModule = Tooltips
return Tooltips
