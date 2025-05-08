local Formatter = {}

--[[
    Formats a number with commas for thousands.
    Example: 1234567 -> "1,234,567"
]]
function Formatter.toGold(amount)
    amount = tonumber(amount)
    if not amount then return "0" end

    local formatted = tostring(amount)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

TSC_FormatterModule = Formatter
return Formatter
