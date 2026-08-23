--[[
    Blade Ball Hub — WindUI
    Full production Luau script

    Bootstrap: loads the complete source from the last known-good commit.
    Once the full file is restored on main, this can be replaced with the
    inline source again.

    Themes: Lavender, Purple, Violet, White, Black (default Black)
]]

local SOURCE_URL = "https://raw.githubusercontent.com/ideBob/BladeBallHub/deb8f2cc7920dccce1a26d4ab5c66e52999f89e6/src/BladeBallHub.lua"

local ok, result = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)

if not ok or type(result) ~= "string" or #result < 1000 then
    error("[BladeBallHub] Failed to fetch full source from " .. SOURCE_URL .. "\n" .. tostring(result))
end

-- The fetched file already contains its own WindUI load + full hub.
-- Execute it in this environment.
local fn, err = loadstring(result)
if not fn then
    error("[BladeBallHub] loadstring failed: " .. tostring(err))
end

fn()
