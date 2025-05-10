--[[
       modules/price/lookup.lua
       Provides price lookup and formatting for item names.
       Exposes: getFormattedPrice, getPrice
]]

local priceData = TSCPriceNameData

local Lookup = {}

--[[
    Gets the price for a given item name, formatted with commas for thousands.
    If the item is not found, returns a default string ("No price data").
    @param itemName (string) - The name of the item to look up.
    @return (string) - The formatted price as a string (e.g., "1,234"), or the default string if not found.

    Usage:
        local formatted = Lookup.getFormattedPrice("Acai Berry")
        -- formatted will be "1,234" or "no price data"
]]
function Lookup.getFormattedPrice(itemName)
    TSCPriceFetcher.modules.debug.log("Lookup: Looking up price for itemName='" .. tostring(itemName) .. "'")
    local price = Lookup.getPrice(itemName)
    if price then
        TSCPriceFetcher.modules.debug.log("Lookup: Found price='" .. tostring(price) .. "'")
        if TSC_FormatterModule then
            return TSC_FormatterModule.toGold(price) .. " gold"
        else
            return tostring(price) .. " gold"
        end
    end

    TSCPriceFetcher.modules.debug.warn("Lookup: No price data for itemName='" .. tostring(itemName) .. "'")
    return "no price data"
end

local function IsValidItemName(itemName)
    return type(itemName) == "string" and itemName ~= ""
end

function Lookup.getPrice(itemName)
    if not IsValidItemName(itemName) then
        return nil
    end
    return priceData[string.lower(itemName)]
end

TSC_LookupModule = Lookup
return Lookup
