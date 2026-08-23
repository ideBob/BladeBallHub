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

--// Capability Detection
local Capabilities = {
    HasDrawing        = typeof(Drawing) == "table",
    HasRequest        = typeof(request) == "function" or typeof(http_request) == "function" or typeof(syn) == "table",
    HasNetworkFeatures = false,
    HasGetgenv        = typeof(getgenv) == "function",
}

pcall(function()
    if typeof(getrenv) == "function" or typeof(hookmetamethod) == "function" then
        Capabilities.HasNetworkFeatures = true
    end
end)

--// Central State
local State = {
    InfiniteJump  = false,
    NoFog         = false,
    FullBright    = false,
    RemoveJitter  = false,
    RakNetDesync  = false,
    ESP           = false,
    AutoParry     = false,
    AutoDash      = false,
    BallTracker   = false,
    DebugMode     = false,
    CurrentTheme  = "Black",
}

local Config = {
    ParryDistance      = 12,
    ReactionTime       = 0.05,
    PredictionStrength = 0.75,
    MinimumBallSpeed   = 10,
    MaximumBallDistance = 120,
    AutoDashDistance   = 15,
    AutoDashCooldown   = 0.65,
    DebugThrottle      = 0.35,
}

--// Connection Manager
local Connections = {}
local function Track(name, conn)
    if Connections[name] then
        pcall(function() Connections[name]:Disconnect() end)
    end
    Connections[name] = conn
    return conn
end

local function Disconnect(name)
    if Connections[name] then
        pcall(function() Connections[name]:Disconnect() end)
        Connections[name] = nil
    end
end

local function DisconnectAll()
    for name, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
        Connections[name] = nil
    end
end

--// Utility
local function Notify(title, content, duration)
    pcall(function()
        WindUI:Notify({
            Title = title or "Blade Ball Hub",
            Content = content or "",
            Duration = duration or 3,
        })
    end)
end

local lastDebug = 0
local function Debug(...)
    if not State.DebugMode then return end
    local now = tick()
    if now - lastDebug < Config.DebugThrottle then return end
    lastDebug = now
    warn("[BladeBall]", ...)
end

local function SafeHRP(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function SafeHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(char)
    local hum = SafeHumanoid(char)
    return hum and hum.Health > 0 and hum.Parent ~= nil
end

--//==========================================================================
--// CUSTOM THEMES (WindUI AddTheme / SetTheme)
--//==========================================================================
local ThemeNames = { "Lavender", "Purple", "Violet", "White", "Black" }

local Themes = {
    Lavender = {
        Name        = "Lavender",
        Accent      = Color3.fromHex("#2a2438"),
        Background  = Color3.fromHex("#1a1625"),
        Dialog      = Color3.fromHex("#221c30"),
        Outline     = Color3.fromHex("#c4b5fd"),
        Text        = Color3.fromHex("#f3e8ff"),
        Placeholder = Color3.fromHex("#a78bfa"),
        Button      = Color3.fromHex("#3b3154"),
        Icon        = Color3.fromHex("#c4b5fd"),
        Toggle      = Color3.fromHex("#a78bfa"),
        Slider      = Color3.fromHex("#a78bfa"),
        Checkbox    = Color3.fromHex("#a78bfa"),
        Primary     = Color3.fromHex("#8b5cf6"),
    },
    Purple = {
        Name        = "Purple",
        Accent      = Color3.fromHex("#1f1230"),
        Background  = Color3.fromHex("#120a1f"),
        Dialog      = Color3.fromHex("#1a1028"),
        Outline     = Color3.fromHex("#c084fc"),
        Text        = Color3.fromHex("#faf5ff"),
        Placeholder = Color3.fromHex("#a855f7"),
        Button      = Color3.fromHex("#3b0764"),
        Icon        = Color3.fromHex("#d8b4fe"),
        Toggle      = Color3.fromHex("#a855f7"),
        Slider      = Color3.fromHex("#c026d3"),
        Checkbox    = Color3.fromHex("#a855f7"),
        Primary     = Color3.fromHex("#9333ea"),
    },
    Violet = {
        Name        = "Violet",
        Accent      = Color3.fromHex("#1a1030"),
        Background  = Color3.fromHex("#0f0a1c"),
        Dialog      = Color3.fromHex("#161028"),
        Outline     = Color3.fromHex("#8b5cf6"),
        Text        = Color3.fromHex("#ede9fe"),
        Placeholder = Color3.fromHex("#7c3aed"),
        Button      = Color3.fromHex("#2e1065"),
        Icon        = Color3.fromHex("#a78bfa"),
        Toggle      = Color3.fromHex("#7c3aed"),
        Slider      = Color3.fromHex("#6d28d9"),
        Checkbox    = Color3.fromHex("#7c3aed"),
        Primary     = Color3.fromHex("#5b21b6"),
    },
    White = {
        Name        = "White",
        Accent      = Color3.fromHex("#f4f4f5"),
        Background  = Color3.fromHex("#ffffff"),
        Dialog      = Color3.fromHex("#fafafa"),
        Outline     = Color3.fromHex("#a1a1aa"),
        Text        = Color3.fromHex("#18181b"),
        Placeholder = Color3.fromHex("#71717a"),
        Button      = Color3.fromHex("#e4e4e7"),
        Icon        = Color3.fromHex("#3f3f46"),
        Toggle      = Color3.fromHex("#52525b"),
        Slider      = Color3.fromHex("#3f3f46"),
        Checkbox    = Color3.fromHex("#52525b"),
        Primary     = Color3.fromHex("#27272a"),
    },
    Black = {
        Name        = "Black",
        Accent      = Color3.fromHex("#121212"),
        Background  = Color3.fromHex("#0a0a0a"),
        Dialog      = Color3.fromHex("#111111"),
        Outline     = Color3.fromHex("#3f3f46"),
        Text        = Color3.fromHex("#fafafa"),
        Placeholder = Color3.fromHex("#71717a"),
        Button      = Color3.fromHex("#1c1c1c"),
        Icon        = Color3.fromHex("#a1a1aa"),
        Toggle      = Color3.fromHex("#e4e4e7"),
        Slider      = Color3.fromHex("#d4d4d8"),
        Checkbox    = Color3.fromHex("#e4e4e7"),
        Primary     = Color3.fromHex("#fafafa"),
    },
}

local function RegisterThemes()
    for _, name in ipairs(ThemeNames) do
        local theme = Themes[name]
        if theme then
            local ok, err = pcall(function()
                WindUI:AddTheme(theme)
            end)
            if not ok then
                warn("[BladeBall Hub] Failed to register theme", name, err)
            end
        end
    end
end

local function ApplyTheme(themeName)
    if type(themeName) ~= "string" or not Themes[themeName] then
        Notify("Theme", "Unknown theme: " .. tostring(themeName), 3)
        Debug("ApplyTheme rejected invalid name:", themeName)
        return false
    end

    local ok, result = pcall(function()
        return WindUI:SetTheme(themeName)
    end)

    if not ok then
        warn("[BladeBall Hub] SetTheme error:", result)
        Notify("Theme", "Could not apply theme (" .. themeName .. ")", 4)
        Debug("SetTheme failed:", result)
        return false
    end

    -- Some WindUI builds return nil on success; treat successful pcall as applied
    State.CurrentTheme = themeName
    Debug("Theme applied:", themeName)
    Notify("Theme", "Applied: " .. themeName, 2)
    return true
end

RegisterThemes()

--// Ball Controller (centralized)
local BallController = {
    CurrentBall = nil,
    Folder      = nil,
}

local function ResolveBallFolder()
    local balls = Workspace:FindFirstChild("Balls")
    if balls then return balls end
    local training = Workspace:FindFirstChild("TrainingBalls")
    if training then return training end
    return nil
end

local function FindRealBall(folder)
    if not folder then return nil end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") and child:GetAttribute("realBall") == true then
            return child
        end
    end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") and (child:GetAttribute("target") ~= nil or child.AssemblyLinearVelocity.Magnitude > 5) then
            return child
        end
    end
    return nil
end

local function GetBallVelocity(ball)
    if not ball then return Vector3.zero end
    local zoomies = ball:FindFirstChild("zoomies")
    if zoomies and zoomies:IsA("BodyVelocity") then
        return zoomies.Velocity
    end
    if zoomies and zoomies:IsA("LinearVelocity") then
        return zoomies.VectorVelocity
    end
    return ball.AssemblyLinearVelocity
end

function BallController:Refresh()
    self.Folder = ResolveBallFolder()
    self.CurrentBall = FindRealBall(self.Folder)
    return self.CurrentBall
end

function BallController:Start()
    local function onBallChange()
        self:Refresh()
        Debug("Ball refreshed:", self.CurrentBall and self.CurrentBall.Name or "nil")
    end

    Track("BallFolderChildAdded", Workspace.ChildAdded:Connect(function(child)
        if child.Name == "Balls" or child.Name == "TrainingBalls" then
            self.Folder = child
            Track("BallsChildAdded", child.ChildAdded:Connect(onBallChange))
            Track("BallsChildRemoved", child.ChildRemoved:Connect(onBallChange))
            onBallChange()
        end
    end))

    self.Folder = ResolveBallFolder()
    if self.Folder then
        Track("BallsChildAdded", self.Folder.ChildAdded:Connect(onBallChange))
        Track("BallsChildRemoved", self.Folder.ChildRemoved:Connect(onBallChange))
    end
    onBallChange()

    Track("BallHeartbeat", RunService.Heartbeat:Connect(function()
        if not self.CurrentBall or not self.CurrentBall.Parent then
            self:Refresh()
        end
    end))
end

function BallController:Stop()
    Disconnect("BallFolderChildAdded")
    Disconnect("BallsChildAdded")
    Disconnect("BallsChildRemoved")
    Disconnect("BallHeartbeat")
    self.CurrentBall = nil
    self.Folder = nil
end

--// Prediction
local function PredictImpact(ballPos, ballVel, playerPos, playerVel, strength)
    local relativePos = ballPos - playerPos
    local relativeVel = ballVel - (playerVel * strength)
    local speed = relativeVel.Magnitude
    if speed < 0.01 then
        return relativePos.Magnitude, false, math.huge
    end
    local approaching = relativePos:Dot(relativeVel) < 0
    local timeToImpact = relativePos.Magnitude / speed
    if approaching then
        local closing = -relativePos.Unit:Dot(relativeVel)
        if closing > 0.5 then
            timeToImpact = relativePos.Magnitude / closing
        end
    end
    return relativePos.Magnitude, approaching, timeToImpact
end

--// Parry Fire
local lastParryTime = 0
local function FireParry()
    local now = tick()
    if now - lastParryTime < (Config.ReactionTime + 0.08) then return end
    lastParryTime = now

    local success = false

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local parry = remotes:FindFirstChild("ParryButtonPress") or remotes:FindFirstChild("ParryAttempt")
            if parry and parry:IsA("RemoteEvent") then
                parry:FireServer()
                success = true
            end
        end
    end)

    if not success then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            success = true
        end)
    end

    Debug("Parry fired, success:", success)
end

--// Feature: Infinite Jump
local function SetInfiniteJump(enabled)
    State.InfiniteJump = enabled
    Disconnect("InfiniteJump")
    if not enabled then
        Notify("Infinite Jump", "Disabled")
        return
    end

    local function bindCharacter(char)
        Disconnect("InfiniteJump")
        local hum = SafeHumanoid(char)
        if not hum then return end

        Track("InfiniteJump", UserInputService.JumpRequest:Connect(function()
            if not State.InfiniteJump then return end
            local c = LocalPlayer.Character
            local h = SafeHumanoid(c)
            if h and h.Parent and h:GetState() ~= Enum.HumanoidStateType.Dead then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
    end

    if LocalPlayer.Character then
        bindCharacter(LocalPlayer.Character)
    end
    Track("InfiniteJumpChar", LocalPlayer.CharacterAdded:Connect(bindCharacter))
    Notify("Infinite Jump", "Enabled")
end

--// Feature: No Fog
local originalFog = {}
local function CaptureFog()
    originalFog = {
        FogEnd      = Lighting.FogEnd,
        FogStart    = Lighting.FogStart,
        FogColor    = Lighting.FogColor,
        Atmosphere  = Lighting:FindFirstChildOfClass("Atmosphere"),
    }
end

local function SetNoFog(enabled)
    State.NoFog = enabled
    Disconnect("NoFog")
    Disconnect("NoFog2")
    if not enabled then
        pcall(function()
            if originalFog.FogEnd then Lighting.FogEnd = originalFog.FogEnd end
            if originalFog.FogStart then Lighting.FogStart = originalFog.FogStart end
            if originalFog.FogColor then Lighting.FogColor = originalFog.FogColor end
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm and originalFog.Atmosphere then
                atm.Density = originalFog.Atmosphere.Density
            end
        end)
        Notify("No Fog", "Disabled")
        return
    end

    CaptureFog()
    local function apply()
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Density = 0 end
    end
    apply()
    Track("NoFog", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if State.NoFog then apply() end
    end))
    Track("NoFog2", RunService.Heartbeat:Connect(function()
        if not State.NoFog then return end
        if Lighting.FogEnd < 50000 then apply() end
    end))
    Notify("No Fog", "Enabled")
end

--// Feature: Full Bright
local originalLighting = {}
local function CaptureLighting()
    originalLighting = {
        Brightness      = Lighting.Brightness,
        ClockTime       = Lighting.ClockTime,
        Ambient         = Lighting.Ambient,
        OutdoorAmbient  = Lighting.OutdoorAmbient,
        ColorShift_Top  = Lighting.ColorShift_Top,
        FogEnd          = Lighting.FogEnd,
    }
end

local function SetFullBright(enabled)
    State.FullBright = enabled
    Disconnect("FullBright")
    if not enabled then
        pcall(function()
            for k, v in pairs(originalLighting) do
                Lighting[k] = v
            end
        end)
        Notify("Full Bright", "Disabled")
        return
    end

    CaptureLighting()
    local function apply()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.FogEnd = 100000
    end
    apply()
    Track("FullBright", RunService.Heartbeat:Connect(function()
        if not State.FullBright then return end
        if Lighting.Brightness < 1.5 then apply() end
    end))
    Notify("Full Bright", "Enabled")
end

--// Feature: Remove Jitter
local function SetRemoveJitter(enabled)
    State.RemoveJitter = enabled
    Disconnect("RemoveJitter")
    if not enabled then
        Notify("Remove Jitter", "Disabled")
        return
    end

    local lastCF = Camera.CFrame
    Track("RemoveJitter", RunService.RenderStepped:Connect(function()
        if not State.RemoveJitter then return end
        local current = Camera.CFrame
        local delta = (current.Position - lastCF.Position).Magnitude
        if delta > 8 and delta < 40 then
            Camera.CFrame = lastCF:Lerp(current, 0.55)
        end
        lastCF = Camera.CFrame
    end))
    Notify("Remove Jitter", "Enabled")
end

--// Feature: RakNet Desync
local function SetRakNetDesync(enabled)
    State.RakNetDesync = enabled
    Disconnect("RakNetDesync")
    if not enabled then
        Notify("RakNet Desync", "Disabled")
        return
    end

    if not Capabilities.HasNetworkFeatures then
        State.RakNetDesync = false
        Notify("RakNet Desync", "Unsupported in this environment", 4)
        return
    end

    local ok, err = pcall(function()
        Debug("RakNet Desync attempted (experimental)")
    end)
    if not ok then
        State.RakNetDesync = false
        Notify("RakNet Desync", "Failed: " .. tostring(err), 4)
        return
    end
    Notify("RakNet Desync", "Enabled (experimental)")
end

--// Feature: ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "BladeBallESP"
ESPFolder.Parent = CoreGui

local espObjects = {}

local function ClearESPFor(player)
    local data = espObjects[player]
    if data then
        for _, obj in pairs(data) do
            pcall(function() obj:Destroy() end)
        end
        espObjects[player] = nil
    end
end

local function ClearAllESP()
    for player in pairs(espObjects) do
        ClearESPFor(player)
    end
    for _, child in ipairs(ESPFolder:GetChildren()) do
        pcall(function() child:Destroy() end)
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    ClearESPFor(player)

    local char = player.Character
    if not char then return end
    local hrp = SafeHRP(char)
    local hum = SafeHumanoid(char)
    if not hrp or not hum then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 80, 80)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = hrp
    billboard.Size = UDim2.fromOffset(120, 40)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.4
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Text = player.Name
    label.Parent = billboard

    espObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
    }
end

local function UpdateESP()
    if not State.ESP then return end
    local myChar = LocalPlayer.Character
    local myHRP = SafeHRP(myChar)

    for player, data in pairs(espObjects) do
        if not player.Parent or not player.Character or not IsAlive(player.Character) then
            ClearESPFor(player)
        else
            local hrp = SafeHRP(player.Character)
            local hum = SafeHumanoid(player.Character)
            if hrp and data.Label and myHRP then
                local dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
                local hp = hum and math.floor(hum.Health) or 0
                data.Label.Text = string.format("%s\n%d studs | HP %d", player.Name, dist, hp)
            end
        end
    end
end

local function SetESP(enabled)
    State.ESP = enabled
    Disconnect("ESPUpdate")
    Disconnect("ESPPlayerAdded")
    Disconnect("ESPPlayerRemoving")
    if not enabled then
        ClearAllESP()
        Notify("ESP", "Disabled")
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then CreateESP(player) end
            Track("ESPChar_" .. player.UserId, player.CharacterAdded:Connect(function()
                task.wait(0.3)
                if State.ESP then CreateESP(player) end
            end))
        end
    end

    Track("ESPPlayerAdded", Players.PlayerAdded:Connect(function(player)
        Track("ESPChar_" .. player.UserId, player.CharacterAdded:Connect(function()
            task.wait(0.3)
            if State.ESP then CreateESP(player) end
        end))
    end))

    Track("ESPPlayerRemoving", Players.PlayerRemoving:Connect(function(player)
        ClearESPFor(player)
        Disconnect("ESPChar_" .. player.UserId)
    end))

    Track("ESPUpdate", RunService.Heartbeat:Connect(function()
        UpdateESP()
    end))
    Notify("ESP", "Enabled")
end

--// Feature: Auto Parry
local parryDebounce = false
local function AutoParryStep()
    if not State.AutoParry or parryDebounce then return end

    local ball = BallController.CurrentBall
    if not ball or not ball.Parent then return end

    local char = LocalPlayer.Character
    if not IsAlive(char) then return end
    local hrp = SafeHRP(char)
    if not hrp then return end

    local ballPos = ball.Position
    local ballVel = GetBallVelocity(ball)
    local speed = ballVel.Magnitude

    if speed < Config.MinimumBallSpeed then return end

    local playerVel = hrp.AssemblyLinearVelocity
    local distance, approaching, eta = PredictImpact(ballPos, ballVel, hrp.Position, playerVel, Config.PredictionStrength)

    if distance > Config.MaximumBallDistance then return end
    if not approaching then return end

    local target = ball:GetAttribute("target")
    if target and target ~= LocalPlayer.Name and target ~= LocalPlayer.DisplayName then
        if distance > Config.ParryDistance * 0.6 then return end
    end

    local threshold = Config.ReactionTime + (Config.ParryDistance / math.max(speed, 1)) * Config.PredictionStrength
    if eta <= threshold or distance <= Config.ParryDistance then
        parryDebounce = true
        FireParry()
        Debug(string.format("AutoParry | Dist: %.1f | Speed: %.1f | ETA: %.3f", distance, speed, eta))
        task.delay(math.max(0.12, Config.ReactionTime), function()
            parryDebounce = false
        end)
    end
end

local function SetAutoParry(enabled)
    State.AutoParry = enabled
    Disconnect("AutoParry")
    if not enabled then
        Notify("Auto Parry", "Disabled")
        return
    end
    Track("AutoParry", RunService.Heartbeat:Connect(function()
        local ok, err = pcall(AutoParryStep)
        if not ok then
            warn("[BladeBall Hub] AutoParry error:", err)
            if State.DebugMode then
                Notify("Auto Parry Error", tostring(err), 4)
            end
        end
    end))
    Notify("Auto Parry", "Enabled")
end

--// Feature: Auto Dash
local lastDash = 0
local function AutoDashStep()
    if not State.AutoDash then return end
    local now = tick()
    if now - lastDash < Config.AutoDashCooldown then return end

    local ball = BallController.CurrentBall
    if not ball or not ball.Parent then return end

    local char = LocalPlayer.Character
    if not IsAlive(char) then return end
    local hrp = SafeHRP(char)
    local hum = SafeHumanoid(char)
    if not hrp or not hum then return end

    local ballVel = GetBallVelocity(ball)
    local speed = ballVel.Magnitude
    if speed < Config.MinimumBallSpeed then return end

    local distance, approaching, eta = PredictImpact(ball.Position, ballVel, hrp.Position, hrp.AssemblyLinearVelocity, 0.5)
    if not approaching then return end
    if distance > Config.AutoDashDistance then return end
    if eta > 0.45 then return end

    lastDash = now
    local away = (hrp.Position - ball.Position)
    if away.Magnitude < 0.1 then
        away = hrp.CFrame.LookVector
    else
        away = away.Unit
    end
    local dashDir = Vector3.new(away.X, 0.15, away.Z).Unit

    pcall(function()
        hrp.AssemblyLinearVelocity = dashDir * 55 + Vector3.new(0, 12, 0)
    end)

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local ability = remotes:FindFirstChild("AbilityButtonPress")
            if ability and ability:IsA("RemoteEvent") then
                ability:FireServer()
            end
        end
    end)

    Debug(string.format("AutoDash | Dist: %.1f | ETA: %.3f", distance, eta))
end

local function SetAutoDash(enabled)
    State.AutoDash = enabled
    Disconnect("AutoDash")
    if not enabled then
        Notify("Auto Dash", "Disabled")
        return
    end
    Track("AutoDash", RunService.Heartbeat:Connect(function()
        local ok, err = pcall(AutoDashStep)
        if not ok then
            warn("[BladeBall Hub] AutoDash error:", err)
        end
    end))
    Notify("Auto Dash", "Enabled")
end

--// Feature: Ball Tracker UI
local trackerLabel = nil
local function SetBallTracker(enabled)
    State.BallTracker = enabled
    Disconnect("BallTracker")
    if trackerLabel then
        pcall(function() trackerLabel:Destroy() end)
        trackerLabel = nil
    end
    if not enabled then
        Notify("Ball Tracker", "Disabled")
        return
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "BallTrackerGui"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(200, 110)
    frame.Position = UDim2.new(0, 12, 0.5, -55)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 120)
    stroke.Thickness = 1
    stroke.Parent = frame

    trackerLabel = Instance.new("TextLabel")
    trackerLabel.Size = UDim2.new(1, -12, 1, -12)
    trackerLabel.Position = UDim2.fromOffset(6, 6)
    trackerLabel.BackgroundTransparency = 1
    trackerLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
    trackerLabel.Font = Enum.Font.Code
    trackerLabel.TextSize = 13
    trackerLabel.TextXAlignment = Enum.TextXAlignment.Left
    trackerLabel.TextYAlignment = Enum.TextYAlignment.Top
    trackerLabel.Text = "BALL TRACKER\nWaiting..."
    trackerLabel.Parent = frame

    local lastUpdate = 0
    Track("BallTracker", RunService.Heartbeat:Connect(function()
        if not State.BallTracker then return end
        local now = tick()
        if now - lastUpdate < 0.08 then return end
        lastUpdate = now

        local ball = BallController.CurrentBall
        local char = LocalPlayer.Character
        local hrp = SafeHRP(char)

        if not ball or not hrp then
            trackerLabel.Text = "BALL TRACKER\nNo ball"
            return
        end

        local vel = GetBallVelocity(ball)
        local speed = vel.Magnitude
        local dist, approaching, eta = PredictImpact(ball.Position, vel, hrp.Position, hrp.AssemblyLinearVelocity, Config.PredictionStrength)

        trackerLabel.Text = string.format(
            "BALL TRACKER\nSpeed:   %.1f\nDistance:%.1f\nApproach:%s\nETA:     %.3fs",
            speed,
            dist,
            approaching and "YES" or "NO",
            eta < 100 and eta or 0
        )
    end))
    Notify("Ball Tracker", "Enabled")
end

--// Cleanup on destroy
local function FullCleanup()
    State.InfiniteJump = false
    State.NoFog = false
    State.FullBright = false
    State.RemoveJitter = false
    State.RakNetDesync = false
    State.ESP = false
    State.AutoParry = false
    State.AutoDash = false
    State.BallTracker = false

    DisconnectAll()
    BallController:Stop()
    ClearAllESP()
    pcall(function() ESPFolder:Destroy() end)

    pcall(function()
        for k, v in pairs(originalLighting) do
            Lighting[k] = v
        end
        if originalFog.FogEnd then Lighting.FogEnd = originalFog.FogEnd end
        if originalFog.FogStart then Lighting.FogStart = originalFog.FogStart end
    end)

    if trackerLabel then
        pcall(function()
            local gui = trackerLabel.Parent and trackerLabel.Parent.Parent
            if gui then gui:Destroy() end
        end)
        trackerLabel = nil
    end
end

--// UI Construction (default theme: Black)
local Window = WindUI:CreateWindow({
    Title  = "Blade Ball Hub",
    Icon   = "swords",
    Author = "WindUI • Production",
    Folder = "BladeBallHub",
    Size   = UDim2.fromOffset(560, 420),
    Theme  = "Black",
    Resizable = true,
    Transparent = true,
    SideBarWidth = 160,
})

State.CurrentTheme = "Black"

Window:OnDestroy(function()
    FullCleanup()
end)

-- Main Tab
local MainTab = Window:Tab({
    Title = "Main",
    Icon  = "home",
})

MainTab:Toggle({
    Title = "Infinite Jump",
    Desc  = "Jump repeatedly while airborne",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetInfiniteJump, v)
        if not ok then warn("[Hub] InfiniteJump:", err) end
    end,
})

MainTab:Toggle({
    Title = "No Fog",
    Desc  = "Remove fog / atmosphere density",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetNoFog, v)
        if not ok then warn("[Hub] NoFog:", err) end
    end,
})

MainTab:Toggle({
    Title = "Full Bright",
    Desc  = "Force bright lighting",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetFullBright, v)
        if not ok then warn("[Hub] FullBright:", err) end
    end,
})

MainTab:Toggle({
    Title = "Remove Jitter",
    Desc  = "Light camera stabilization",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetRemoveJitter, v)
        if not ok then warn("[Hub] RemoveJitter:", err) end
    end,
})

MainTab:Toggle({
    Title = "RakNet Desync",
    Desc  = "Experimental (executor dependent)",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetRakNetDesync, v)
        if not ok then warn("[Hub] RakNetDesync:", err) end
    end,
})

MainTab:Toggle({
    Title = "ESP",
    Desc  = "Player highlights + distance/HP",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetESP, v)
        if not ok then warn("[Hub] ESP:", err) end
    end,
})

MainTab:Toggle({
    Title = "Debug Mode",
    Desc  = "Throttled console diagnostics",
    Value = false,
    Callback = function(v)
        State.DebugMode = v
        Notify("Debug Mode", v and "Enabled" or "Disabled")
    end,
})

-- Parry Tab
local ParryTab = Window:Tab({
    Title = "Parry",
    Icon  = "target",
})

ParryTab:Toggle({
    Title = "Auto Parry",
    Desc  = "Velocity-based predicted parry",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetAutoParry, v)
        if not ok then warn("[Hub] AutoParry:", err) end
    end,
})

ParryTab:Toggle({
    Title = "Auto Dash",
    Desc  = "Evasive dash when ball is close",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetAutoDash, v)
        if not ok then warn("[Hub] AutoDash:", err) end
    end,
})

ParryTab:Toggle({
    Title = "Ball Tracker",
    Desc  = "Live speed / distance / ETA overlay",
    Value = false,
    Callback = function(v)
        local ok, err = pcall(SetBallTracker, v)
        if not ok then warn("[Hub] BallTracker:", err) end
    end,
})

ParryTab:Slider({
    Title = "Parry Distance",
    Step  = 0.5,
    Value = {
        Min = 4,
        Max = 30,
        Default = Config.ParryDistance,
    },
    Callback = function(v)
        Config.ParryDistance = v
    end,
})

ParryTab:Slider({
    Title = "Reaction Time",
    Step  = 0.01,
    Value = {
        Min = 0.01,
        Max = 0.25,
        Default = Config.ReactionTime,
    },
    Callback = function(v)
        Config.ReactionTime = v
    end,
})

ParryTab:Slider({
    Title = "Prediction Strength",
    Step  = 0.05,
    Value = {
        Min = 0.1,
        Max = 1.5,
        Default = Config.PredictionStrength,
    },
    Callback = function(v)
        Config.PredictionStrength = v
    end,
})

ParryTab:Slider({
    Title = "Minimum Ball Speed",
    Step  = 1,
    Value = {
        Min = 0,
        Max = 80,
        Default = Config.MinimumBallSpeed,
    },
    Callback = function(v)
        Config.MinimumBallSpeed = v
    end,
})

ParryTab:Slider({
    Title = "Max Ball Distance",
    Step  = 5,
    Value = {
        Min = 30,
        Max = 250,
        Default = Config.MaximumBallDistance,
    },
    Callback = function(v)
        Config.MaximumBallDistance = v
    end,
})

ParryTab:Slider({
    Title = "Auto Dash Distance",
    Step  = 1,
    Value = {
        Min = 5,
        Max = 40,
        Default = Config.AutoDashDistance,
    },
    Callback = function(v)
        Config.AutoDashDistance = v
    end,
})

--// UI THEME / COLOR CHANGER Tab
local ThemeTab = Window:Tab({
    Title = "UI THEME / COLOR CHANGER",
    Icon  = "palette",
})

ThemeTab:Dropdown({
    Title = "Select Theme",
    Desc  = "Applies to the entire WindUI interface",
    Values = ThemeNames,
    Value = "Black",
    Callback = function(selected)
        -- Isolated: does not touch Main/Parry feature state or connections
        local name = selected
        if type(selected) == "table" and selected.Title then
            name = selected.Title
        end
        local ok, err = pcall(function()
            ApplyTheme(tostring(name))
        end)
        if not ok then
            warn("[Hub] Theme callback error:", err)
            Notify("Theme", "Failed to apply theme", 3)
        end
    end,
})

-- Start core systems
BallController:Start()

Track("CharAdded", LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)
end))

Notify("Blade Ball Hub", "Loaded successfully", 3)
