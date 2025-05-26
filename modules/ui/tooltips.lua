--[[
    modules/ui/tooltips.lua
    Handles adding price information to gamepad tooltips in ESO.
    All helper functions are local; only AddPriceToGamepadTooltip is exposed.
]]
local Tooltips = {}

-- Constants
local COLORS = {
    TSC_GREEN = "009449"
}

--[[
    Checks if the tooltip already contains a price line from this addon.
    Prevents duplicate price info from being added.
    @param tooltip (table): The tooltip object to check.
    @return (boolean): true if price info is present, false otherwise.
]]
local function TooltipHasPriceLine(tooltip)
    TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine called")
    if not tooltip then
        TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine: tooltip is nil")
        return false
    end

    -- Check scrollTooltip.contents (classic way)
    if tooltip.scrollTooltip and tooltip.scrollTooltip.contents and tooltip.scrollTooltip.contents.GetNumChildren then
        TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine: using scrollTooltip.contents")
        local content = tooltip.scrollTooltip.contents
        local numChildren = content:GetNumChildren()
        for i = 1, numChildren do
            local child = content:GetChild(i)
            if child then
                local text = child.GetText and child:GetText() or "<no GetText>"
                TSCPriceFetcher.modules.debug.log("scrollTooltip child " ..
                    i .. ": " .. tostring(child) .. " | Text: " .. tostring(text))
            end
            if child and child.GetText then
                local text = child:GetText()
                if text and text:find("Average Price: ") then
                    TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine: found price line in scrollTooltip.contents")
                    return true
                end
            end
        end
    end

    -- Check direct children (for tooltips without scrollTooltip)
    if tooltip.GetNumChildren then
        TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine: using direct children")
        local numChildren = tooltip:GetNumChildren()
        for i = 1, numChildren do
            local child = tooltip:GetChild(i)
            if child then
                local text = child.GetText and child:GetText() or "<no GetText>"
                TSCPriceFetcher.modules.debug.log("direct child " ..
                    i .. ": " .. tostring(child) .. " | Text: " .. tostring(text))
            end
            if child and child.GetText then
                local text = child:GetText()
                if text and text:find("Average Price: ") then
                    TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine: found price line in direct children")
                    return true
                end
            end
        end
    end

    TSCPriceFetcher.modules.debug.log("TooltipHasPriceLine: price line not found")
    return false
end

local function colorize(msg, color)
    return string.format("|c%s%s|r", color, tostring(msg))
end

--[[
    Adds a formatted price section to the tooltip.
    @param tooltip (table): The tooltip object to modify.
    @param itemName (string): The item name for price lookup.
    @param itemLink (string): The item link string.
]]
local function AddPriceSection(tooltip, itemName, itemLink)
    local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
    TSCPriceFetcher.modules.debug.log("AddPriceSection called for: " ..
        tostring(itemName) .. " (cleaned: " .. tostring(cleanName) .. ")")

    local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
    priceSection:AddLine(colorize("Tamriel Savings Co", COLORS.TSC_GREEN), tooltip:GetStyle("bodyDescription"))

    -- Always show average price (handles "no price data" internally)
    local formattedPrice = TSCPriceFetcher.modules.dataAdapter.getFormattedAvgPrice(itemName, itemLink)
    priceSection:AddLine("Average Price: " .. formattedPrice, tooltip:GetStyle("bodyDescription"))

    -- Show additional info if available
    local priceRange = TSCPriceFetcher.modules.dataAdapter.getFormattedPriceRange(itemName, itemLink)
    if priceRange then
        priceSection:AddLine("Range: " .. priceRange, tooltip:GetStyle("bodyDescription"))
    end

    local salesCount = TSCPriceFetcher.modules.dataAdapter.getSalesCount(itemName, itemLink)
    if salesCount then
        priceSection:AddLine("Sales: " .. tostring(salesCount), tooltip:GetStyle("bodyDescription"))
    end

    tooltip:AddSection(priceSection)
end

--[[
    Determines if the tooltip context and item link are valid for price display.
    @param tooltipType (number): The tooltip type (e.g., GAMEPAD_LEFT_TOOLTIP).
    @param tooltipObject (table): The tooltip object.
    @param itemLink (string): The item link string.
    @return (boolean): true if valid, false otherwise.
]]
local function ShouldAddPriceToTooltip(tooltipType, tooltipObject, itemLink)
    -- Must have valid tooltip and tooltip type
    if not tooltipType or not tooltipObject then return false end

    -- Must be a valid item link
    if type(itemLink) ~= "string" or not itemLink:find("^|H%d:item:") then return false end

    -- Must have a valid item name
    local itemName = GetItemLinkName(itemLink)
    if not itemName or itemName == "" then return false end

    -- Must have a valid item type
    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_NONE then return false end

    return true
end

--[[
    Adds price info to a gamepad tooltip if the item is valid and price not already present.
    @param tooltipObject (table): The GAMEPAD_TOOLTIPS object.
    @param tooltipType (number): The tooltip type (e.g., GAMEPAD_LEFT_TOOLTIP).
    @param itemLink (string): The item link string.
]]
function Tooltips.AddPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    if not ShouldAddPriceToTooltip(tooltipType, tooltipObject, itemLink) then return end

    local tooltip = tooltipObject:GetTooltip(tooltipType)
    if not tooltip then return end

    if TooltipHasPriceLine(tooltip) then return end

    local itemName = GetItemLinkName(itemLink)
    if not itemName then return end

    local success, result = pcall(function()
        AddPriceSection(tooltip, itemName, itemLink)
        return true
    end)

    if not success and TSCPriceFetcher and TSCPriceFetcher.modules and TSCPriceFetcher.modules.debug then
        TSCPriceFetcher.modules.debug.error("Failed to add price to tooltip: " .. tostring(result))
    end
end

TSC_TooltipsModule = Tooltips
return Tooltips
