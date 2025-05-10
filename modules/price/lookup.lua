local data = TSCPriceNameData
local info = TSCPriceNameDataInfo

local Lookup = {}

--[[
    Gets the price for a given item name, formatted with commas for thousands.
    If the item is not found, returns a default string ("No price data").
    @param itemName (string) - The name of the item to look up.
    @return (string) - The formatted price as a string (e.g., "1,234"), or the default string if not found.

    Usage:
        local formatted = Lookup.getFormattedPrice("Acai Berry")
        -- formatted will be "1,234" or "No price data"
]]
function Lookup.getFormattedPrice(itemName)
    TSCPriceFetcher.modules.debug.log("Lookup: Looking up price for itemName='" .. tostring(itemName) .. "'")
    local price = data[itemName]
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

--[[
    Gets the raw price number for a given item name.
    @param itemName (string) - The name of the item to look up.
    @return (number|nil) - The price as a number, or nil if not found.

    Usage:
        local price = Lookup.getPrice("Acai Berry")
        if price then
            -- Use the price number
        else
            -- Handle missing price
        end
]]
function Lookup.getPrice(itemName)
    return data[itemName]
end

TSC_LookupModule = Lookup
return Lookup
