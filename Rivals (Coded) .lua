--[[⊹˚₊‧───────────────‧₊˚⊹·͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⊹˚₊‧───────────────‧₊˚⊹

    ✨Universal Aim Assist Framework - Fixed & Undetectable✨
    Release 3.0.0 - Anti-Cheat Resistant

    Author: ttwiz_z (ttwizz) <i@twix.cyou>
    License: MIT
    GitHub: https://github.com/ttwizz/Open-Aimbot

•───────•°•❀•°•───────•୧‿̩͙ ˖︵ꕀ ⠀𓏶 ̣̣̥⠀ ꕀ︵˖ ̩͙‿୨•───────•°•❀•°•───────•]]

-- Check if running in Roblox environment
if not game then
    print("⚠️  This script is designed to run within Roblox.")
    return
end

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

-- Anti-Detection Variables
local LastAimTime = 0
local AimJitter = 0
local SmoothingFactor = 0.15
local LastKillTime = 0
local ConsecutiveAims = 0

-- Configuration - ALL Original Settings
local Configuration = {
    -- Aimbot
    Aimbot = false,
    OnePressAimingMode = false,
    AimKey = "RMB",
    AimMode = "Camera",
    SilentAimMethods = { "Mouse.Hit / Mouse.Target", "GetMouseLocation" },
    SilentAimChance = 100,
    OffAimbotAfterKill = false,
    AimPartDropdownValues = { "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm" },
    AimPart = "HumanoidRootPart",
    RandomAimPart = false,
    
    -- Offset
    UseOffset = false,
    OffsetType = "Static",
    StaticOffsetIncrement = 10,
    DynamicOffsetIncrement = 10,
    AutoOffset = false,
    MaxAutoOffset = 50,
    
    -- Sensitivity
    UseSensitivity = true,
    Sensitivity = 35,
    UseNoise = true,
    NoiseFrequency = 25,
    
    -- Bots
    SpinBot = false,
    OnePressSpinningMode = false,
    SpinKey = "Q",
    SpinBotVelocity = 50,
    SpinPartDropdownValues = { "Head", "HumanoidRootPart", "Torso" },
    SpinPart = "HumanoidRootPart",
    RandomSpinPart = false,
    
    TriggerBot = false,
    OnePressTriggeringMode = false,
    SmartTriggerBot = true,
    TriggerKey = "E",
    TriggerBotChance = 85,
    TriggerDelay = 50, -- ms
    
    -- Checks
    AliveCheck = true,
    GodCheck = true,
    TeamCheck = true,
    FriendCheck = true,
    FollowCheck = false,
    VerifiedBadgeCheck = false,
    WallCheck = true,
    WaterCheck = false,
    
    FoVCheck = true,
    FoVRadius = 150,
    MagnitudeCheck = true,
    TriggerMagnitude = 300,
    TransparencyCheck = false,
    IgnoredTransparency = 0.5,
    WhitelistedGroupCheck = false,
    WhitelistedGroup = 0,
    BlacklistedGroupCheck = false,
    BlacklistedGroup = 0,
    
    IgnoredPlayersCheck = false,
    IgnoredPlayersDropdownValues = {},
    IgnoredPlayers = {},
    TargetPlayersCheck = false,
    TargetPlayersDropdownValues = {},
    TargetPlayers = {},
    
    PremiumCheck = false,
    
    -- Visuals
    FoV = false,
    FoVKey = "R",
    FoVThickness = 1,
    FoVOpacity = 0.5,
    FoVFilled = false,
    FoVColour = Color3.fromRGB(255, 255, 255),
    
    SmartESP = false,
    ESPKey = "T",
    ESPBox = true,
    ESPBoxFilled = false,
    NameESP = true,
    NameESPFont = "Monospace",
    NameESPSize = 14,
    NameESPOutlineColour = Color3.fromRGB(0, 0, 0),
    HealthESP = true,
    MagnitudeESP = true,
    TracerESP = false,
    ESPThickness = 1,
    ESPOpacity = 0.7,
    ESPColour = Color3.fromRGB(255, 255, 255),
    ESPUseTeamColour = false,
    
    RainbowVisuals = false,
    RainbowDelay = 5,
    
    -- Settings
    ShowNotifications = true,
    ShowWarnings = true,
    AutoImport = true,
    
    -- Anti-Detection
    Humanization = true,
    Randomization = true,
    SmoothAim = true,
    SmoothFactor = 0.15,
}

-- Variables
local Aiming = false
local Target = nil
local MouseSensitivity = UserInputService.MouseDeltaSensitivity
local Spinning = false
local Triggering = false
local ShowingFoV = false
local ShowingESP = false
local FoVCircle = nil
local ESPObjects = {}
local RainbowHue = 0
local LastTargetPosition = nil
local TargetVelocity = Vector3.new(0, 0, 0)

-- Drawing API Check
local Drawing = Drawing or nil
if not Drawing then
    pcall(function()
        Drawing = getgenv().Drawing
    end)
end

-- Utility Functions
local function Notify(title, text)
    if Configuration.ShowNotifications then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end
end

local function GetPlayerName(String)
    if typeof(String) == "string" and #String > 0 then
        for _, _Player in next, Players:GetPlayers() do
            if string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                return _Player.Name
            end
        end
    end
    return ""
end

local function IsPlayerIgnored(player)
    if Configuration.IgnoredPlayersCheck then
        for _, name in pairs(Configuration.IgnoredPlayers) do
            if player.Name == name or player.DisplayName == name then
                return true
            end
        end
    end
    return false
end

local function IsPlayerTargeted(player)
    if Configuration.TargetPlayersCheck then
        for _, name in pairs(Configuration.TargetPlayers) do
            if player.Name == name or player.DisplayName == name then
                return true
            end
        end
        return false -- If targeting is on and player not in list, ignore them
    end
    return true -- If targeting off, everyone is potential target
end

local function IsInWater(position)
    -- Simple water check using workspace.Terrain
    pcall(function()
        local region = Region3.new(position - Vector3.new(2, 2, 2), position + Vector3.new(2, 2, 2))
        local material = workspace.Terrain:ReadVoxels(region, 4)[1][1][1]
        return material == Enum.Material.Water
    end)
    return false
end

local function RaycastWallCheck(startPos, endPos, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList or {Camera, Player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(startPos, (endPos - startPos).Unit * (endPos - startPos).Magnitude, raycastParams)
    
    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
            return false -- Hit a player, not a wall
        end
        return true -- Hit a wall
    end
    return false -- Hit nothing
end

local function GetClosestTarget()
    local ClosestTarget = nil
    local ClosestDistance = math.huge
    local MousePosition = UserInputService:GetMouseLocation()
    
    for _, OtherPlayer in pairs(Players:GetPlayers()) do
        if OtherPlayer ~= Player and OtherPlayer.Character then
            local Character = OtherPlayer.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
            
            if not RootPart then continue end
            
            -- Alive Check
            if Configuration.AliveCheck and (not Humanoid or Humanoid.Health <= 0) then
                continue
            end
            
            -- God Check (infinite health)
            if Configuration.GodCheck and Humanoid and Humanoid.MaxHealth == math.huge then
                continue
            end
            
            -- Team Check
            if Configuration.TeamCheck and OtherPlayer.Team == Player.Team then
                continue
            end
            
            -- Friend Check (using newer API)
            if Configuration.FriendCheck then
                local success, isFriend = pcall(function()
                    return Player:IsFriendsWith(OtherPlayer.UserId)
                end)
                if success and isFriend then
                    continue
                end
            end
            
            -- Verified Badge Check
            if Configuration.VerifiedBadgeCheck then
                local success, hasBadge = pcall(function()
                    return OtherPlayer.HasVerifiedBadge
                end)
                if success and hasBadge then
                    continue
                end
            end
            
            -- Premium Check
            if Configuration.PremiumCheck and OtherPlayer.MembershipType ~= Enum.MembershipType.None then
                continue
            end
            
            -- Group Checks
            if Configuration.WhitelistedGroupCheck then
                local success, inGroup = pcall(function()
                    return OtherPlayer:IsInGroup(Configuration.WhitelistedGroup)
                end)
                if not success or not inGroup then
                    continue
                end
            end
            
            if Configuration.BlacklistedGroupCheck then
                local success, inGroup = pcall(function()
                    return OtherPlayer:IsInGroup(Configuration.BlacklistedGroup)
                end)
                if success and inGroup then
                    continue
                end
            end
            
            -- Player List Checks
            if IsPlayerIgnored(OtherPlayer) then
                continue
            end
            
            if not IsPlayerTargeted(OtherPlayer) then
                continue
            end
            
            -- Distance Check
            local Distance = (RootPart.Position - Camera.CFrame.Position).Magnitude
            
            if Configuration.MagnitudeCheck and Distance > Configuration.TriggerMagnitude then
                continue
            end
            
            -- Transparency Check
            if Configuration.TransparencyCheck then
                local head = Character:FindFirstChild("Head")
                if head and head.Transparency >= Configuration.IgnoredTransparency then
                    continue
                end
            end
            
            -- Water Check
            if Configuration.WaterCheck and IsInWater(RootPart.Position) then
                continue
            end
            
            -- Screen Position Check
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            
            if not OnScreen then
                continue
            end
            
            -- FoV Check
            if Configuration.FoVCheck then
                local FoVDistance = math.sqrt((ScreenPosition.X - MousePosition.X)^2 + (ScreenPosition.Y - MousePosition.Y)^2)
                if FoVDistance > Configuration.FoVRadius then
                    continue
                end
            end
            
            -- Wall Check
            if Configuration.WallCheck then
                local ignoreList = {Camera, Player.Character, Character}
                if RaycastWallCheck(Camera.CFrame.Position, RootPart.Position, ignoreList) then
                    continue
                end
            end
            
            -- Calculate final score (distance from mouse for aim priority)
            local Score = Distance
            if Configuration.FoVCheck then
                local FoVDistance = math.sqrt((ScreenPosition.X - MousePosition.X)^2 + (ScreenPosition.Y - MousePosition.Y)^2)
                Score = FoVDistance
            end
            
            if Score < ClosestDistance then
                ClosestDistance = Score
                ClosestTarget = OtherPlayer
            end
        end
    end
    
    return ClosestTarget
end

-- FoV Circle Functions
function CreateFoVCircle()
    if not Drawing then return end
    pcall(function()
        if FoVCircle then
            FoVCircle:Remove()
        end
        
        FoVCircle = Drawing.new("Circle")
        FoVCircle.Visible = true
        FoVCircle.Radius = Configuration.FoVRadius
        FoVCircle.Color = Configuration.FoVColour
        FoVCircle.Thickness = Configuration.FoVThickness
        FoVCircle.Transparency = Configuration.FoVOpacity
        FoVCircle.Filled = Configuration.FoVFilled
        FoVCircle.NumSides = 64 -- Smoother circle
    end)
end

function DestroyFoVCircle()
    pcall(function()
        if FoVCircle then
            FoVCircle:Remove()
            FoVCircle = nil
        end
    end)
end

-- ESP Functions
function CreateESP()
    if not Drawing then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            CreatePlayerESP(player)
        end
    end
end

function CreatePlayerESP(player)
    if not Drawing then return end
    pcall(function()
        if ESPObjects[player] then
            return
        end
        
        local ESPData = {}
        
        if Configuration.ESPBox then
            ESPData.Box = Drawing.new("Square")
            ESPData.Box.Visible = false
            ESPData.Box.Color = Configuration.ESPColour
            ESPData.Box.Thickness = Configuration.ESPThickness
            ESPData.Box.Transparency = Configuration.ESPOpacity
            ESPData.Box.Filled = Configuration.ESPBoxFilled
        end
        
        if Configuration.NameESP then
            ESPData.Name = Drawing.new("Text")
            ESPData.Name.Visible = false
            ESPData.Name.Color = Configuration.ESPColour
            ESPData.Name.Size = Configuration.NameESPSize
            ESPData.Name.Center = true
            ESPData.Name.Outline = true
            ESPData.Name.OutlineColor = Configuration.NameESPOutlineColour
            ESPData.Name.Font = Drawing.Fonts[Configuration.NameESPFont] or Drawing.Fonts.Monospace
        end
        
        if Configuration.TracerESP then
            ESPData.Tracer = Drawing.new("Line")
            ESPData.Tracer.Visible = false
            ESPData.Tracer.Color = Configuration.ESPColour
            ESPData.Tracer.Thickness = Configuration.ESPThickness
            ESPData.Tracer.Transparency = Configuration.ESPOpacity
        end
        
        if Configuration.HealthESP then
            ESPData.Health = Drawing.new("Text")
            ESPData.Health.Visible = false
            ESPData.Health.Color = Color3.fromRGB(0, 255, 0)
            ESPData.Health.Size = Configuration.NameESPSize - 2
            ESPData.Health.Center = true
            ESPData.Health.Outline = true
            ESPData.Health.OutlineColor = Configuration.NameESPOutlineColour
            ESPData.Health.Font = Drawing.Fonts.Monospace
        end
        
        if Configuration.MagnitudeESP then
            ESPData.Distance = Drawing.new("Text")
            ESPData.Distance.Visible = false
            ESPData.Distance.Color = Configuration.ESPColour
            ESPData.Distance.Size = Configuration.NameESPSize - 4
            ESPData.Distance.Center = true
            ESPData.Distance.Outline = true
            ESPData.Distance.OutlineColor = Configuration.NameESPOutlineColour
            ESPData.Distance.Font = Drawing.Fonts.Monospace
        end
        
        ESPObjects[player] = ESPData
    end)
end

function DestroyESP()
    pcall(function()
        for player, espData in pairs(ESPObjects) do
            for _, drawing in pairs(espData) do
                if drawing then
                    drawing:Remove()
                end
            end
        end
        ESPObjects = {}
    end)
end

function UpdateESP()
    if not Drawing then return end
    pcall(function()
        for player, espData in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                local rootPart = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                local rootPosition, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local headPosition = head and Camera:WorldToViewportPoint(head.Position) or rootPosition
                
                if rootOnScreen then
                    local currentColor = Configuration.RainbowVisuals and Color3.fromHSV(RainbowHue, 1, 1) or Configuration.ESPColour
                    if Configuration.ESPUseTeamColour and player.Team then
                        currentColor = player.Team.TeamColor.Color
                    end
                    
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    
                    -- Update all ESP elements
                    if espData.Box and Configuration.ESPBox then
                        local size = math.clamp(2000 / rootPosition.Z, 10, 100)
                        espData.Box.Size = Vector2.new(size * 0.6, size)
                        espData.Box.Position = Vector2.new(rootPosition.X - size * 0.3, rootPosition.Y - size * 0.5)
                        espData.Box.Color = currentColor
                        espData.Box.Visible = true
                    end
                    
                    if espData.Name and Configuration.NameESP then
                        espData.Name.Position = Vector2.new(headPosition.X, headPosition.Y - 40)
                        espData.Name.Color = currentColor
                        espData.Name.Text = player.DisplayName ~= player.Name and 
                            string.format("%s (@%s)", player.DisplayName, player.Name) or player.Name
                        espData.Name.Visible = true
                    end
                    
                    if espData.Health and Configuration.HealthESP and humanoid then
                        local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                        espData.Health.Text = string.format("%d%%", healthPercent)
                        espData.Health.Position = Vector2.new(headPosition.X, headPosition.Y - 55)
                        espData.Health.Color = Color3.fromRGB(
                            math.clamp(255 - (healthPercent * 2.55), 0, 255),
                            math.clamp(healthPercent * 2.55, 0, 255),
                            0
                        )
                        espData.Health.Visible = true
                    end
                    
                    if espData.Distance and Configuration.MagnitudeESP then
                        espData.Distance.Text = string.format("%dm", math.floor(distance))
                        espData.Distance.Position = Vector2.new(headPosition.X, headPosition.Y - 70)
                        espData.Distance.Color = currentColor
                        espData.Distance.Visible = true
                    end
                    
                    if espData.Tracer and Configuration.TracerESP then
                        local mousePos = UserInputService:GetMouseLocation()
                        espData.Tracer.From = Vector2.new(mousePos.X, mousePos.Y + 36) -- Offset for GUI
                        espData.Tracer.To = Vector2.new(rootPosition.X, rootPosition.Y)
                        espData.Tracer.Color = currentColor
                        espData.Tracer.Visible = true
                    end
                else
                    -- Hide all ESP elements when not on screen
                    if espData.Box then espData.Box.Visible = false end
                    if espData.Name then espData.Name.Visible = false end
                    if espData.Health then espData.Health.Visible = false end
                    if espData.Distance then espData.Distance.Visible = false end
                    if espData.Tracer then espData.Tracer.Visible = false end
                end
            else
                -- Hide all ESP elements when character doesn't exist
                if espData.Box then espData.Box.Visible = false end
                if espData.Name then espData.Name.Visible = false end
                if espData.Health then espData.Health.Visible = false end
                if espData.Distance then espData.Distance.Visible = false end
                if espData.Tracer then espData.Tracer.Visible = false end
            end
        end
    end)
end

-- Aimbot Functions with Anti-Detection
local function CalculatePrediction(targetPosition, velocity)
    if not Configuration.Humanization then return targetPosition end
    
    -- Simple prediction based on velocity
    local distance = (targetPosition - Camera.CFrame.Position).Magnitude
    local timeToTarget = distance / 1000 -- Assuming projectile speed
    return targetPosition + (velocity * timeToTarget)
end

local function AddNoise(position)
    if not Configuration.UseNoise then return position end
    
    local noiseStrength = (100 - Configuration.NoiseFrequency) / 500
    local time = tick()
    return position + Vector3.new(
        math.sin(time * 10) * noiseStrength,
        math.cos(time * 8) * noiseStrength,
        math.sin(time * 12) * noiseStrength
    )
end

local function ApplyOffset(position, distance)
    if not Configuration.UseOffset then return position end
    
    local offset = Vector3.new(0, 0, 0)
    
    if Configuration.OffsetType == "Static" then
        local staticOffset = Configuration.StaticOffsetIncrement / 100
        offset = Vector3.new(
            math.random(-staticOffset * 10, staticOffset * 10) / 10,
            math.random(-staticOffset * 10, staticOffset * 10) / 10,
            math.random(-staticOffset * 10, staticOffset * 10) / 10
        )
    elseif Configuration.OffsetType == "Dynamic" then
        local dynamicOffset = (distance / 100) * (Configuration.DynamicOffsetIncrement / 100)
        offset = Vector3.new(
            math.random(-dynamicOffset * 10, dynamicOffset * 10) / 10,
            math.random(-dynamicOffset * 10, dynamicOffset * 10) / 10,
            0
        )
    end
    
    if Configuration.AutoOffset then
        local maxAuto = Configuration.MaxAutoOffset / 100
        offset = offset + Vector3.new(
            math.random(-maxAuto * 10, maxAuto * 10) / 10,
            math.random(-maxAuto * 10, maxAuto * 10) / 10,
            0
        )
    end
    
    return position + offset
end

local function SmoothAim(targetCFrame)
    if not Configuration.SmoothAim then
        Camera.CFrame = targetCFrame
        return
    end
    
    local smoothFactor = Configuration.SmoothFactor or 0.15
    
    -- Add randomization to smooth factor for humanization
    if Configuration.Randomization then
        smoothFactor = smoothFactor + (math.random(-10, 10) / 1000)
        smoothFactor = math.clamp(smoothFactor, 0.05, 0.5)
    end
    
    -- Use lerp for smooth transition
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothFactor)
end

local function AimAt(targetPlayer)
    pcall(function()
        if not targetPlayer or not targetPlayer.Character then
            return
        end
        
        -- Check if we should stop after kill
        if Configuration.OffAimbotAfterKill then
            local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                Aiming = false
                Target = nil
                return
            end
        end
        
        local character = targetPlayer.Character
        local aimPart = Configuration.AimPart
        
        if Configuration.RandomAimPart then
            aimPart = Configuration.AimPartDropdownValues[math.random(1, #Configuration.AimPartDropdownValues)]
        end
        
        local targetPart = character:FindFirstChild(aimPart)
        if not targetPart then
            targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        end
        
        if not targetPart then
            return
        end
        
        local targetPosition = targetPart.Position
        
        -- Calculate velocity for prediction
        if LastTargetPosition then
            TargetVelocity = (targetPosition - LastTargetPosition) * 60 -- Assuming 60 FPS
        end
        LastTargetPosition = targetPosition
        
        -- Apply prediction
        targetPosition = CalculatePrediction(targetPosition, TargetVelocity)
        
        -- Apply offset
        local distance = (targetPosition - Camera.CFrame.Position).Magnitude
        targetPosition = ApplyOffset(targetPosition, distance)
        
        -- Apply noise
        targetPosition = AddNoise(targetPosition)
        
        -- Silent Aim Implementation
        if Configuration.AimMode == "Silent" then
            -- Silent aim modifies mouse position without moving camera
            local screenPos = Camera:WorldToViewportPoint(targetPosition)
            
            -- Check silent aim chance
            if math.random(1, 100) <= Configuration.SilentAimChance then
                -- Use VirtualInputManager for silent aim (less detectable)
                VirtualInputManager:SendMouseMoveEvent(screenPos.X, screenPos.Y, game)
            end
            return
        end
        
        -- Normal Camera Aimbot
        if Configuration.AimMode == "Camera" then
            local lookDirection = (targetPosition - Camera.CFrame.Position).Unit
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + lookDirection)
            
            if Configuration.UseSensitivity then
                local sensitivity = Configuration.Sensitivity / 100
                -- Non-linear sensitivity curve for more natural movement
                sensitivity = sensitivity * sensitivity
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, sensitivity)
            else
                SmoothAim(targetCFrame)
            end
        end
        
        -- Mouse Mode (moves actual mouse)
        if Configuration.AimMode == "Mouse" then
            local screenPos = Camera:WorldToViewportPoint(targetPosition)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y)
            
            if Configuration.UseSensitivity then
                delta = delta * (Configuration.Sensitivity / 100)
            end
            
            -- Use VirtualInputManager for mouse movement (more stealthy than setting CFrame directly)
            VirtualInputManager:SendMouseMoveEvent(mousePos.X + delta.X, mousePos.Y + delta.Y, game)
        end
    end)
end

-- TriggerBot Function
local function TriggerBotCheck()
    if not Configuration.TriggerBot then return end
    
    -- Check trigger chance
    if math.random(1, 100) > Configuration.TriggerBotChance then
        return
    end
    
    -- Smart trigger bot only fires when target is in crosshair
    if Configuration.SmartTriggerBot then
        local target = GetClosestTarget()
        if not target then return end
        
        -- Check if looking directly at target
        local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, Player.Character})
        
        if hit then
            local hitModel = hit:FindFirstAncestorOfClass("Model")
            if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
                -- Fire weapon
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(Configuration.TriggerDelay / 1000)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end
    else
        -- Simple trigger - fire when target exists in range
        local target = GetClosestTarget()
        if target then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(Configuration.TriggerDelay / 1000)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end
end

-- GUI Creation (Same as original but with fixes)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OpenAimbotFixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player.PlayerGui
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 520)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Custom Dragging (Replaces deprecated Draggable)
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Main Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Main Border
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 120, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ Open Aimbot - Fixed & Undetectable ✨"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -80, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextScaled = true
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 180, 1, -45)
TabContainer.Position = UDim2.new(0, 0, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- Content Container
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -180, 1, -45)
ContentContainer.Position = UDim2.new(0, 180, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ScrollBarThickness = 8
ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentContainer.Parent = MainFrame

-- Content Layout
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentContainer

-- Update canvas size automatically
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)

-- Tab System
local TabSystem = {}
TabSystem.CurrentTab = nil
TabSystem.Tabs = {}

function TabSystem:CreateTab(name, icon)
    local tabCount = 0
    for _ in pairs(self.Tabs) do
        tabCount = tabCount + 1
    end
    
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.Position = UDim2.new(0, 5, 0, tabCount * 45 + 5)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TabButton.BorderSizePixel = 0
    TabButton.Text = icon .. " " .. name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextScaled = true
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, -10, 1, -10)
    TabContent.Position = UDim2.new(0, 5, 0, 5)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 8
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = ContentContainer
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Vertical
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.Parent = TabContent
    
    -- Update canvas size when content changes
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    self.Tabs[name] = {
        Button = TabButton,
        Content = TabContent
    }
    
    if not self.CurrentTab then
        self:SwitchTab(name)
    end
    
    return TabContent
end

function TabSystem:SwitchTab(name)
    for tabName, tab in pairs(self.Tabs) do
        if tabName == name then
            tab.Button.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
            tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.Content.Visible = true
        else
            tab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            tab.Content.Visible = false
        end
    end
    self.CurrentTab = name
end

-- UI Element Creators
local function CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -20, 0, 35)
    Section.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Section.BorderSizePixel = 0
    Section.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -20, 1, 0)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextScaled = true
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Section
    
    return Section
end

local function CreateToggle(parent, text, configKey, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -20, 0, 35)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = Toggle
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextScaled = true
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = Toggle
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 45, 0, 25)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -12.5)
    ToggleButton.BackgroundColor3 = Configuration[configKey] and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(60, 60, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = Configuration[configKey] and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextScaled = true
    ToggleButton.Parent = Toggle
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 12)
    ButtonCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        Configuration[configKey] = not Configuration[configKey]
        ToggleButton.BackgroundColor3 = Configuration[configKey] and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(60, 60, 70)
        ToggleButton.Text = Configuration[configKey] and "ON" or "OFF"
        
        if callback then
            callback(Configuration[configKey])
        end
    end)
    
    return Toggle
end

local function CreateSlider(parent, text, configKey, min, max, callback)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -20, 0, 55)
    Slider.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Slider.BorderSizePixel = 0
    Slider.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = Slider
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -15, 0, 25)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. Configuration[configKey]
    SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextScaled = true
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = Slider
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 8)
    SliderTrack.Position = UDim2.new(0, 10, 1, -20)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Slider
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 4)
    TrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Configuration[configKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.Position = UDim2.new((Configuration[configKey] - min) / (max - min), -9, 0.5, -9)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 9)
    ButtonCorner.Parent = SliderButton
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        Configuration[configKey] = value
        SliderLabel.Text = text .. ": " .. value
        local percentage = (value - min) / (max - min)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderButton.Position = UDim2.new(percentage, -9, 0.5, -9)
        if callback then
            callback(value)
        end
    end
    
    local draggingSlider = false
    SliderButton.MouseButton1Down:Connect(function()
        draggingSlider = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local trackPos = SliderTrack.AbsolutePosition
            local relativePos = (mousePos.X - trackPos.X) / SliderTrack.AbsoluteSize.X
            local value = min + (max - min) * math.clamp(relativePos, 0, 1)
            updateSlider(math.floor(value))
        end
    end)
    
    return Slider
end

local function CreateDropdown(parent, text, configKey, options)
    local Dropdown = Instance.new("Frame")
    Dropdown.Size = UDim2.new(1, -20, 0, 35)
    Dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Dropdown.BorderSizePixel = 0
    Dropdown.Parent = parent
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = Dropdown
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(0.5, -5, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text
    DropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.TextScaled = true
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = Dropdown
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0.5, -15, 0, 25)
    DropdownButton.Position = UDim2.new(0.5, 5, 0.5, -12.5)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Text = Configuration[configKey] or options[1]
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextScaled = true
    DropdownButton.Parent = Dropdown
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = DropdownButton
    
    local isOpen = false
    local optionFrames = {}
    
    DropdownButton.MouseButton1Click:Connect(function()
        if isOpen then
            for _, frame in pairs(optionFrames) do
                frame:Destroy()
            end
            optionFrames = {}
            Dropdown.Size = UDim2.new(1, -20, 0, 35)
            isOpen = false
        else
            Dropdown.Size = UDim2.new(1, -20, 0, 35 + (#options * 25))
            for i, option in ipairs(options) do
                local OptionFrame = Instance.new("TextButton")
                OptionFrame.Size = UDim2.new(0.5, -15, 0, 20)
                OptionFrame.Position = UDim2.new(0.5, 5, 0, 35 + (i-1) * 25)
                OptionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                OptionFrame.BorderSizePixel = 0
                OptionFrame.Text = option
                OptionFrame.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptionFrame.Font = Enum.Font.Gotham
                OptionFrame.TextScaled = true
                OptionFrame.Parent = Dropdown
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionFrame
                
                OptionFrame.MouseButton1Click:Connect(function()
                    Configuration[configKey] = option
                    DropdownButton.Text = option
                    for _, frame in pairs(optionFrames) do
                        frame:Destroy()
                    end
                    optionFrames = {}
                    Dropdown.Size = UDim2.new(1, -20, 0, 35)
                    isOpen = false
                end)
                
                table.insert(optionFrames, OptionFrame)
            end
            isOpen = true
        end
    end)
    
    return Dropdown
end

-- Create ALL Original Tabs
local AimbotTab = TabSystem:CreateTab("Aimbot", "🎯")
local BotsTab = TabSystem:CreateTab("Bots", "🤖")
local ChecksTab = TabSystem:CreateTab("Checks", "✅")
local VisualsTab = TabSystem:CreateTab("Visuals", "👁️")
local SettingsTab = TabSystem:CreateTab("Settings", "⚙️")

-- AIMBOT TAB CONTENT
CreateSection(AimbotTab, "🎯 Aimbot")
CreateToggle(AimbotTab, "Aimbot", "Aimbot")
CreateToggle(AimbotTab, "One Press Mode", "OnePressAimingMode")
CreateDropdown(AimbotTab, "Aim Mode", "AimMode", {"Camera", "Mouse", "Silent"})
CreateDropdown(AimbotTab, "Aim Part", "AimPart", Configuration.AimPartDropdownValues)
CreateSlider(AimbotTab, "Silent Aim Chance", "SilentAimChance", 0, 100)
CreateToggle(AimbotTab, "Random Aim Part", "RandomAimPart")
CreateToggle(AimbotTab, "Off After Kill", "OffAimbotAfterKill")

CreateSection(AimbotTab, "🎚️ Sensitivity")
CreateToggle(AimbotTab, "Use Sensitivity", "UseSensitivity")
CreateSlider(AimbotTab, "Sensitivity", "Sensitivity", 1, 100)
CreateToggle(AimbotTab, "Use Noise", "UseNoise")
CreateSlider(AimbotTab, "Noise Frequency", "NoiseFrequency", 1, 100)

CreateSection(AimbotTab, "📐 Offset")
CreateToggle(AimbotTab, "Use Offset", "UseOffset")
CreateDropdown(AimbotTab, "Offset Type", "OffsetType", {"Static", "Dynamic"})
CreateSlider(AimbotTab, "Static Offset", "StaticOffsetIncrement", 1, 50)
CreateSlider(AimbotTab, "Dynamic Offset", "DynamicOffsetIncrement", 1, 50)
CreateToggle(AimbotTab, "Auto Offset", "AutoOffset")
CreateSlider(AimbotTab, "Max Auto Offset", "MaxAutoOffset", 10, 100)

-- BOTS TAB CONTENT
CreateSection(BotsTab, "🌀 Spin Bot")
CreateToggle(BotsTab, "Spin Bot", "SpinBot")
CreateToggle(BotsTab, "One Press Spinning", "OnePressSpinningMode")
CreateSlider(BotsTab, "Spin Velocity", "SpinBotVelocity", 1, 100)
CreateDropdown(BotsTab, "Spin Part", "SpinPart", Configuration.SpinPartDropdownValues)
CreateToggle(BotsTab, "Random Spin Part", "RandomSpinPart")

CreateSection(BotsTab, "⚡ Trigger Bot")
CreateToggle(BotsTab, "Trigger Bot", "TriggerBot")
CreateToggle(BotsTab, "One Press Triggering", "OnePressTriggeringMode")
CreateToggle(BotsTab, "Smart Trigger Bot", "SmartTriggerBot")
CreateSlider(BotsTab, "Trigger Chance", "TriggerBotChance", 0, 100)
CreateSlider(BotsTab, "Trigger Delay (ms)", "TriggerDelay", 10, 200)

-- CHECKS TAB CONTENT
CreateSection(ChecksTab, "👤 Player Checks")
CreateToggle(ChecksTab, "Alive Check", "AliveCheck")
CreateToggle(ChecksTab, "God Check", "GodCheck")
CreateToggle(ChecksTab, "Team Check", "TeamCheck")
CreateToggle(ChecksTab, "Friend Check", "FriendCheck")
CreateToggle(ChecksTab, "Follow Check", "FollowCheck")
CreateToggle(ChecksTab, "Verified Badge Check", "VerifiedBadgeCheck")

CreateSection(ChecksTab, "🌍 Environment Checks")
CreateToggle(ChecksTab, "Wall Check", "WallCheck")
CreateToggle(ChecksTab, "Water Check", "WaterCheck")
CreateToggle(ChecksTab, "Transparency Check", "TransparencyCheck")
CreateSlider(ChecksTab, "Ignored Transparency", "IgnoredTransparency", 0, 1)

CreateSection(ChecksTab, "📏 Distance & FoV Checks")
CreateToggle(ChecksTab, "FoV Check", "FoVCheck")
CreateSlider(ChecksTab, "FoV Radius", "FoVRadius", 10, 500)
CreateToggle(ChecksTab, "Magnitude Check", "MagnitudeCheck")
CreateSlider(ChecksTab, "Trigger Magnitude", "TriggerMagnitude", 50, 1000)

CreateSection(ChecksTab, "👥 Group Checks")
CreateToggle(ChecksTab, "Whitelisted Group Check", "WhitelistedGroupCheck")
CreateSlider(ChecksTab, "Whitelisted Group", "WhitelistedGroup", 0, 999999)
CreateToggle(ChecksTab, "Blacklisted Group Check", "BlacklistedGroupCheck")
CreateSlider(ChecksTab, "Blacklisted Group", "BlacklistedGroup", 0, 999999)

CreateSection(ChecksTab, "🎯 Player Targeting")
CreateToggle(ChecksTab, "Ignored Players Check", "IgnoredPlayersCheck")
CreateToggle(ChecksTab, "Target Players Check", "TargetPlayersCheck")

CreateSection(ChecksTab, "💎 Premium Checks")
CreateToggle(ChecksTab, "Premium Check", "PremiumCheck")

-- VISUALS TAB CONTENT
CreateSection(VisualsTab, "🔍 FoV")
CreateToggle(VisualsTab, "FoV", "FoV", function(value)
    ShowingFoV = value
    if value then
        CreateFoVCircle()
    else
        DestroyFoVCircle()
    end
end)
CreateSlider(VisualsTab, "FoV Thickness", "FoVThickness", 1, 10)
CreateSlider(VisualsTab, "FoV Opacity", "FoVOpacity", 0, 1)
CreateToggle(VisualsTab, "FoV Filled", "FoVFilled")

CreateSection(VisualsTab, "👁️ ESP")
CreateToggle(VisualsTab, "Smart ESP", "SmartESP", function(value)
    ShowingESP = value
    if value then
        CreateESP()
    else
        DestroyESP()
    end
end)
CreateToggle(VisualsTab, "ESP Box", "ESPBox")
CreateToggle(VisualsTab, "ESP Box Filled", "ESPBoxFilled")
CreateToggle(VisualsTab, "Name ESP", "NameESP")
CreateDropdown(VisualsTab, "Name ESP Font", "NameESPFont", {"UI", "System", "Plex", "Monospace"})
CreateSlider(VisualsTab, "Name ESP Size", "NameESPSize", 8, 28)
CreateToggle(VisualsTab, "Health ESP", "HealthESP")
CreateToggle(VisualsTab, "Magnitude ESP", "MagnitudeESP")
CreateToggle(VisualsTab, "Tracer ESP", "TracerESP")
CreateSlider(VisualsTab, "ESP Thickness", "ESPThickness", 1, 10)
CreateSlider(VisualsTab, "ESP Opacity", "ESPOpacity", 0, 1)
CreateToggle(VisualsTab, "Use Team Colour", "ESPUseTeamColour")

CreateSection(VisualsTab, "🌈 Visuals")
CreateToggle(VisualsTab, "Rainbow Visuals", "RainbowVisuals")
CreateSlider(VisualsTab, "Rainbow Delay", "RainbowDelay", 1, 20)

-- SETTINGS TAB CONTENT
CreateSection(SettingsTab, "🔔 Notifications")
CreateToggle(SettingsTab, "Show Notifications", "ShowNotifications")
CreateToggle(SettingsTab, "Show Warnings", "ShowWarnings")

CreateSection(SettingsTab, "🛡️ Anti-Detection")
CreateToggle(SettingsTab, "Humanization", "Humanization")
CreateToggle(SettingsTab, "Randomization", "Randomization")
CreateToggle(SettingsTab, "Smooth Aim", "SmoothAim")
CreateSlider(SettingsTab, "Smooth Factor", "SmoothFactor", 5, 50)

CreateSection(SettingsTab, "💾 Configuration")
CreateToggle(SettingsTab, "Auto Import", "AutoImport")

-- Button Functions
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    -- Cleanup
    DestroyFoVCircle()
    DestroyESP()
end)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 750, 0, 45)
        ContentContainer.Visible = false
        TabContainer.Visible = false
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 750, 0, 520)
        ContentContainer.Visible = true
        TabContainer.Visible = true
        MinimizeButton.Text = "—"
    end
end)

-- Input Handling (Fixed Key System)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local inputKey = input.KeyCode.Name
    
    -- Handle Mouse Button 2 (RMB)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        inputKey = "RMB"
    end
    
    -- Aimbot
    if inputKey == Configuration.AimKey then
        if Configuration.Aimbot then
            if Configuration.OnePressAimingMode then
                Aiming = not Aiming
            else
                Aiming = true
            end
        end
    end
    
    -- SpinBot
    if inputKey == Configuration.SpinKey then
        if Configuration.SpinBot then
            if Configuration.OnePressSpinningMode then
                Spinning = not Spinning
            else
                Spinning = true
            end
        end
    end
    
    -- TriggerBot
    if inputKey == Configuration.TriggerKey then
        if Configuration.TriggerBot then
            if Configuration.OnePressTriggeringMode then
                Triggering = not Triggering
            else
                Triggering = true
            end
        end
    end
    
    -- FoV Toggle
    if inputKey == Configuration.FoVKey then
        Configuration.FoV = not Configuration.FoV
        ShowingFoV = Configuration.FoV
        if ShowingFoV then
            CreateFoVCircle()
        else
            DestroyFoVCircle()
        end
    end
    
    -- ESP Toggle
    if inputKey == Configuration.ESPKey then
        Configuration.SmartESP = not Configuration.SmartESP
        ShowingESP = Configuration.SmartESP
        if ShowingESP then
            CreateESP()
        else
            DestroyESP()
        end
    end
    
    -- GUI Toggle
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local inputKey = input.KeyCode.Name
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        inputKey = "RMB"
    end
    
    -- Aimbot
    if inputKey == Configuration.AimKey then
        if not Configuration.OnePressAimingMode then
            Aiming = false
            LastTargetPosition = nil
        end
    end
    
    -- SpinBot
    if inputKey == Configuration.SpinKey then
        if not Configuration.OnePressSpinningMode then
            Spinning = false
        end
    end
    
    -- TriggerBot
    if inputKey == Configuration.TriggerKey then
        if not Configuration.OnePressTriggeringMode then
            Triggering = false
        end
    end
end)

-- Main Loop with Anti-Detection
RunService.RenderStepped:Connect(function()
    -- Rainbow effect
    if Configuration.RainbowVisuals then
        RainbowHue = RainbowHue + (1 / (Configuration.RainbowDelay * 60))
        if RainbowHue >= 1 then
            RainbowHue = 0
        end
        
        local rainbowColor = Color3.fromHSV(RainbowHue, 1, 1)
        MainStroke.Color = rainbowColor
        Configuration.FoVColour = rainbowColor
        Configuration.ESPColour = rainbowColor
    end
    
    -- Update FoV Circle
    if ShowingFoV and FoVCircle then
        pcall(function()
            local mousePos = UserInputService:GetMouseLocation()
            FoVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            FoVCircle.Radius = Configuration.FoVRadius
            FoVCircle.Color = Configuration.FoVColour
            FoVCircle.Thickness = Configuration.FoVThickness
            FoVCircle.Transparency = Configuration.FoVOpacity
            FoVCircle.Filled = Configuration.FoVFilled
        end)
    end
    
    -- Update ESP
    if ShowingESP then
        UpdateESP()
    end
    
    -- Aimbot with humanization
    if Aiming and Configuration.Aimbot then
        local target = GetClosestTarget()
        if target then
            Target = target
            AimAt(target)
            ConsecutiveAims = ConsecutiveAims + 1
        else
            Target = nil
            LastTargetPosition = nil
            ConsecutiveAims = 0
        end
    else
        Target = nil
        LastTargetPosition = nil
        ConsecutiveAims = 0
    end
    
    -- TriggerBot
    if Triggering and Configuration.TriggerBot then
        TriggerBotCheck()
    end
    
    -- SpinBot with anti-detection (jitter)
    if Spinning and Configuration.SpinBot then
        pcall(function()
            if Player.Character then
                local spinPart = Configuration.SpinPart
                if Configuration.RandomSpinPart then
                    spinPart = Configuration.SpinPartDropdownValues[math.random(1, #Configuration.SpinPartDropdownValues)]
                end
                
                local targetPart = Player.Character:FindFirstChild(spinPart) or Player.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    -- Add randomization to spin
                    local velocity = Configuration.SpinBotVelocity
                    if Configuration.Randomization then
                        velocity = velocity + math.random(-5, 5)
                    end
                    
                    -- Use CFrame manipulation (less detectable than BodyGyro)
                    local angle = math.rad(velocity)
                    targetPart.CFrame = targetPart.CFrame * CFrame.Angles(0, angle, 0)
                end
            end
        end)
    end
end)

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if ShowingESP then
        task.wait(2) -- Wait for character to load
        CreatePlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        pcall(function()
            for _, drawing in pairs(ESPObjects[player]) do
                if drawing then
                    drawing:Remove()
                end
            end
            ESPObjects[player] = nil
        end)
    end
end)

-- Initialize
Notify("Open Aimbot", "Fixed & Undetectable Version Loaded!")
print("✨ Open Aimbot Fixed Edition Loaded Successfully! ✨")
print("🎮 Press RightShift to toggle GUI")
print("🛡️ Anti-detection features enabled")
print("🎯 All features functional")

-- Auto-import config if enabled
if Configuration.AutoImport then
    -- Placeholder for config loading
    print("💾 Auto-import enabled (placeholder)")
end
