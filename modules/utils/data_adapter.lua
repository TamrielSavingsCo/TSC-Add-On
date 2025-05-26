--[[
    modules/utils/data_adapter.lua
    Provides unified interface to different price data sources
    Exposes: getAvgPrice, getMinPrice, getMaxPrice, getFullData, hasFeature
]]

local goldIcon = "|t32:32:EsoUI/Art/currency/currency_gold.dds|t"

local DataAdapter = {}

-- Check what features are available based on current data source
function DataAdapter.hasFeature(feature)
    if TSCPriceFetcher.dataSource == "full" then
        return true                  -- Full data has all features
    elseif TSCPriceFetcher.dataSource == "lite" then
        return feature == "avgPrice" -- Lite only has average price
    end
    return false
end

-- Get average price (works with both data sources)
function DataAdapter.getAvgPrice(itemName, itemLink)
    if not TSCPriceFetcher.priceEnabled then
        return nil
    end

    -- Check if item is bound
    if IsItemLinkBound(itemLink) then
        return "bound item"
    end

    -- Debug data source state and access
    TSCPriceFetcher.modules.debug.log("Data source: " .. TSCPriceFetcher.dataSource)
    TSCPriceFetcher.modules.debug.log("TSCPriceDataLite exists: " .. tostring(_G.TSCPriceDataLite ~= nil))
    if _G.TSCPriceDataLite then
        TSCPriceFetcher.modules.debug.log("TSCPriceDataLite.GetAvgPrice exists: " ..
            tostring(type(_G.TSCPriceDataLite.GetAvgPrice)))
    end

    -- Try ID lookup first
    local itemId = GetItemLinkItemId(itemLink)
    TSCPriceFetcher.modules.debug.log("Trying ID lookup: " .. tostring(itemId))

    local price = nil
    if TSCPriceFetcher.dataSource == "full" then
        price = TSCPriceData:GetAvgPrice(itemId)
        TSCPriceFetcher.modules.debug.log("Full data ID lookup result: " .. tostring(price))

        if not price then
            local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
            TSCPriceFetcher.modules.debug.log("ID lookup failed, trying name: " .. tostring(cleanName))
            price = TSCPriceData:GetAvgPrice(cleanName)
            TSCPriceFetcher.modules.debug.log("Full data name lookup result: " .. tostring(price))
        end
    elseif TSCPriceFetcher.dataSource == "lite" then
        -- Try both ways of calling the function
        price = TSCPriceDataLite.GetAvgPrice(TSCPriceDataLite, itemId) -- Call as regular function
        if not price then
            price = TSCPriceDataLite:GetAvgPrice(itemId)               -- Call as method
        end
        TSCPriceFetcher.modules.debug.log("Lite data ID lookup result: " .. tostring(price))

        if not price then
            local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
            TSCPriceFetcher.modules.debug.log("ID lookup failed, trying name: " .. tostring(cleanName))
            price = TSCPriceDataLite.GetAvgPrice(TSCPriceDataLite, cleanName) -- Call as regular function
            if not price then
                price = TSCPriceDataLite:GetAvgPrice(cleanName)               -- Call as method
            end
            TSCPriceFetcher.modules.debug.log("Lite data name lookup result: " .. tostring(price))
        end
    end

    TSCPriceFetcher.modules.debug.log("Final price result: " .. tostring(price))
    return price
end

-- Get min price (only available with full data)
function DataAdapter.getCommonMinPrice(itemName, itemLink)
    if not DataAdapter.hasFeature("commonMin") then
        return nil
    end

    local itemId = GetItemLinkItemId(itemLink)
    local price = TSCPriceData:GetCommonMin(itemId)

    if not price then
        local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
        price = TSCPriceData:GetCommonMin(cleanName)
    end

    return price
end

-- Get max price (only available with full data)
function DataAdapter.getCommonMaxPrice(itemName, itemLink)
    if not DataAdapter.hasFeature("commonMax") then
        return nil
    end

    local itemId = GetItemLinkItemId(itemLink)
    local price = TSCPriceData:GetCommonMax(itemId)

    if not price then
        local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
        price = TSCPriceData:GetCommonMax(cleanName)
    end

    return price
end

-- Get min price (only available with full data)
function DataAdapter.getMinPrice(itemName, itemLink)
    if not DataAdapter.hasFeature("minPrice") then
        return nil
    end

    local itemId = GetItemLinkItemId(itemLink)
    local price = TSCPriceData:GetMinPrice(itemId)

    if not price then
        local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
        price = TSCPriceData:GetMinPrice(cleanName)
    end

    return price
end

-- Get max price (only available with full data)
function DataAdapter.getMaxPrice(itemName, itemLink)
    if not DataAdapter.hasFeature("maxPrice") then
        return nil
    end

    local itemId = GetItemLinkItemId(itemLink)
    local price = TSCPriceData:GetMaxPrice(itemId)

    if not price then
        local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
        price = TSCPriceData:GetMaxPrice(cleanName)
    end

    return price
end

-- Get sales count (only available with full data)
function DataAdapter.getSalesCount(itemName, itemLink)
    if not DataAdapter.hasFeature("salesCount") then
        return nil
    end

    local itemId = GetItemLinkItemId(itemLink)
    local count = TSCPriceData:GetSalesCount(itemId)

    if not count then
        local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
        count = TSCPriceData:GetSalesCount(cleanName)
    end

    return count
end

-- Get full data array (only available with full data)
function DataAdapter.getFullData(itemName)
    if not DataAdapter.hasFeature("fullData") then
        return nil
    end

    local cleanName = TSC_FormatterModule.StripEsoSuffix(itemName)
    return TSCPriceData:GetPrice(cleanName) -- Returns the full array
end

-- Get formatted average price with fallback
function DataAdapter.getFormattedAvgPrice(itemName, itemLink)
    local result = DataAdapter.getAvgPrice(itemName, itemLink)

    -- Handle special messages
    if result == "bound item" then
        return result
    end

    -- Handle numeric price
    if result then
        return TSC_FormatterModule.toGold(result) .. " " .. goldIcon
    end

    return "no price data"
end

-- Get formatted price range (only for full data)
function DataAdapter.getFormattedPriceRange(itemName, itemLink)
    if not DataAdapter.hasFeature("minPrice") then
        return nil
    end

    local minPrice = DataAdapter.getCommonMinPrice(itemName, itemLink)
    local maxPrice = DataAdapter.getCommonMaxPrice(itemName, itemLink)

    if minPrice and maxPrice then
        return TSC_FormatterModule.toGold(minPrice) .. " - " .. TSC_FormatterModule.toGold(maxPrice) .. " " .. goldIcon
    end

    return nil
end

TSC_DataAdapterModule = DataAdapter
return DataAdapter
