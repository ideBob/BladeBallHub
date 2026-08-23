--[[
    Blade Ball Hub — WindUI
    Full production Luau script
    Architecture: centralized state, connection manager, ball controller,
    feature isolation, capability detection, proper cleanup.
    Themes: Lavender, Purple, Violet, White, Black (default Black)
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- RESTORED FROM deb8f2cc — full source was truncated in this automated push attempt.
-- Please re-run restore or copy from: https://raw.githubusercontent.com/ideBob/BladeBallHub/deb8f2cc7920dccce1a26d4ab5c66e52999f89e6/src/BladeBallHub.lua
error("[BladeBallHub] Partial restore. Download full file from commit deb8f2cc and replace this file.")
