--[[
    modules/ui/tooltips.lua
    Handles adding price information to gamepad tooltips in ESO.
    All helper functions are local; only AddPriceToGamepadTooltip is exposed.
]]
local Tooltips = {}

--[[
    Checks if the tooltip already contains a price line from this addon.
    Prevents duplicate price info from being added.
    @param tooltip (table): The tooltip object to check.
    @return (boolean): true if price info is present, false otherwise.
]]
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

--[[
    Adds a formatted price section to the tooltip.
    @param tooltip (table): The tooltip object to modify.
    @param priceString (string): The price string to display.
]]
local function AddPriceSection(tooltip, priceString)
    local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
    priceSection:AddLine("Tamriel Savings Co: " .. priceString, tooltip:GetStyle("bodyDescription"))
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

    local priceString = TSCPriceFetcher.modules.lookup.getFormattedPrice(GetItemLinkName(itemLink))
    if not priceString then return end

    local success, result = pcall(function()
        AddPriceSection(tooltip, priceString)
        return true
    end)

    if not success and TSCPriceFetcher and TSCPriceFetcher.modules and TSCPriceFetcher.modules.debug then
        TSCPriceFetcher.modules.debug.error("Failed to add price to tooltip: " .. tostring(result))
    end
end

TSC_TooltipsModule = Tooltips
return Tooltips
