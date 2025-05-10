-- modules/ui/tooltips.lua
local Tooltips = {}

-- This function checks if a tooltip already has our price line
-- Returns true if price info already exists, false otherwise
local function TooltipHasPriceLine(tooltip)
    if not tooltip or not tooltip.scrollTooltip then return false end
    
    -- Get the content container from the scroll tooltip
    local content = tooltip.scrollTooltip.contents
    if not content or not content.GetNumChildren then return false end
    
    -- Check all child controls
    local numChildren = content:GetNumChildren()
    for i = 1, numChildren do
        local child = content:GetChild(i)
        if child and child.GetText then
            local text = child:GetText()
            if text and text:find("Tamriel Savings Co:") then
                return true
            end
        end
    end
    
    return false
end

function Tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    -- Only proceed if we're dealing with a valid tooltip
    if not tooltipType or not tooltipObject then return end
    
    -- Only proceed if itemLink is a valid item link
    if type(itemLink) ~= "string" or not itemLink:find("^|H%d:item:") then return end

    local itemName = GetItemLinkName(itemLink)
    if not itemName or itemName == "" then return end

    -- Check if item type is valid
    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_NONE then return end
    
    -- Get the tooltip object
    local tooltip = tooltipObject:GetTooltip(tooltipType)
    if not tooltip then return end
    
    -- Check if tooltip already has our price info
    if TooltipHasPriceLine(tooltip) then
        return -- Already has price info, no need to add again
    end
    
    -- Look up the price
    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(itemName)
    if not priceString then return end
    
    -- Add the price to the tooltip
    local success, result = pcall(function()
        local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
        priceSection:AddLine("Tamriel Savings Co: " .. priceString, tooltip:GetStyle("bodyDescription"))
        tooltip:AddSection(priceSection)
        return true
    end)
    
    if not success then
        if TSCPriceFetcher and TSCPriceFetcher.modules and TSCPriceFetcher.modules.debug then
            TSCPriceFetcher.modules.debug.error("Failed to add price to tooltip: " .. tostring(result))
        end
    end
end

TSC_TooltipsModule = Tooltips
return Tooltips