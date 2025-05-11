local Formatter = {}

--[[
    Formats a number with commas for thousands.
    Example: 1234567 -> "1,234,567"
]]
function Formatter.toGold(amount)
    amount = tonumber(amount)
    if not amount then return "0" end
    return ZO_CommaDelimitNumber(amount)
end

TSC_FormatterModule = Formatter
return Formatter
