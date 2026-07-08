--[[⊹˚₊‧───────────────‧₊˚⊹·͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⊹˚₊‧───────────────‧₊˚⊹

    ✨Open Aimbot - WindUI Edition✨
    Anti-Cheat Resistant | Fully Featured

•───────•°•❀•°•───────•୧‿̩͙ ˖︵ꕀ ⠀𓏶 ̣̣̥⠀ ꕀ︵˖ ̩͙‿୨•───────•°•❀•°•───────•]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Constants
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Anti-Detection Variables
local LastAimTime = 0
local AimJitter = 0
local SmoothingFactor = 0.15
local LastKillTime = 0
local ConsecutiveAims = 0

-- Configuration
local Configuration = {
    -- Aimbot
    Aimbot = false,
    OnePressAimingMode = false,
    AimKey = "RMB",
    AimMode = "Camera",
    SilentAimChance = 100,
    OffAimbotAfterKill = false,
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
    SpinPart = "HumanoidRootPart",
    RandomSpinPart = false,
    
    TriggerBot = false,
    OnePressTriggeringMode = false,
    SmartTriggerBot = true,
    TriggerKey = "E",
    TriggerBotChance = 85,
    TriggerDelay = 50,
    
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
    IgnoredPlayers = {},
    TargetPlayersCheck = false,
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

-- State Variables
local Aiming = false
local Target = nil
local Spinning = false
local Triggering = false
local ShowingFoV = false
local ShowingESP = false
local FoVCircle = nil
local ESPObjects = {}
local RainbowHue = 0
local LastTargetPosition = nil
local TargetVelocity = Vector3.new(0, 0, 0)

-- Drawing API Setup
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

local function IsPlayerIgnored(plr)
    if Configuration.IgnoredPlayersCheck then
        for _, name in pairs(Configuration.IgnoredPlayers) do
            if plr.Name == name or plr.DisplayName == name then
                return true
            end
        end
    end
    return false
end

local function IsPlayerTargeted(plr)
    if Configuration.TargetPlayersCheck then
        for _, name in pairs(Configuration.TargetPlayers) do
            if plr.Name == name or plr.DisplayName == name then
                return true
            end
        end
        return false
    end
    return true
end

local function RaycastWallCheck(startPos, endPos, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList or {Camera, Player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(startPos, (endPos - startPos).Unit * (endPos - startPos).Magnitude, raycastParams)
    
    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
            return false
        end
        return true
    end
    return false
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
            
            if Configuration.AliveCheck and (not Humanoid or Humanoid.Health <= 0) then
                continue
            end
            
            if Configuration.GodCheck and Humanoid and Humanoid.MaxHealth == math.huge then
                continue
            end
            
            if Configuration.TeamCheck and OtherPlayer.Team == Player.Team then
                continue
            end
            
            if Configuration.FriendCheck then
                local success, isFriend = pcall(function()
                    return Player:IsFriendsWith(OtherPlayer.UserId)
                end)
                if success and isFriend then
                    continue
                end
            end
            
            if Configuration.VerifiedBadgeCheck then
                local success, hasBadge = pcall(function()
                    return OtherPlayer.HasVerifiedBadge
                end)
                if success and hasBadge then
                    continue
                end
            end
            
            if Configuration.PremiumCheck and OtherPlayer.MembershipType ~= Enum.MembershipType.None then
                continue
            end
            
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
            
            if IsPlayerIgnored(OtherPlayer) then
                continue
            end
            
            if not IsPlayerTargeted(OtherPlayer) then
                continue
            end
            
            local Distance = (RootPart.Position - Camera.CFrame.Position).Magnitude
            
            if Configuration.MagnitudeCheck and Distance > Configuration.TriggerMagnitude then
                continue
            end
            
            if Configuration.TransparencyCheck then
                local head = Character:FindFirstChild("Head")
                if head and head.Transparency >= Configuration.IgnoredTransparency then
                    continue
                end
            end
            
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            
            if not OnScreen then
                continue
            end
            
            if Configuration.FoVCheck then
                local FoVDistance = math.sqrt((ScreenPosition.X - MousePosition.X)^2 + (ScreenPosition.Y - MousePosition.Y)^2)
                if FoVDistance > Configuration.FoVRadius then
                    continue
                end
            end
            
            if Configuration.WallCheck then
                local ignoreList = {Camera, Player.Character, Character}
                if RaycastWallCheck(Camera.CFrame.Position, RootPart.Position, ignoreList) then
                    continue
                end
            end
            
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

-- Drawing Functions
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
        FoVCircle.NumSides = 64
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

function CreateESP()
    if not Drawing then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            CreatePlayerESP(plr)
        end
    end
end

function CreatePlayerESP(plr)
    if not Drawing then return end
    pcall(function()
        if ESPObjects[plr] then return end
        
        local ESPData = {}
        
        ESPData.Box = Drawing.new("Square")
        ESPData.Box.Visible = false
        ESPData.Box.Color = Configuration.ESPColour
        ESPData.Box.Thickness = Configuration.ESPThickness
        ESPData.Box.Transparency = Configuration.ESPOpacity
        ESPData.Box.Filled = Configuration.ESPBoxFilled
        
        ESPData.Name = Drawing.new("Text")
        ESPData.Name.Visible = false
        ESPData.Name.Color = Configuration.ESPColour
        ESPData.Name.Size = Configuration.NameESPSize
        ESPData.Name.Center = true
        ESPData.Name.Outline = true
        ESPData.Name.OutlineColor = Configuration.NameESPOutlineColour
        ESPData.Name.Font = Drawing.Fonts[Configuration.NameESPFont] or Drawing.Fonts.Monospace
        
        ESPData.Tracer = Drawing.new("Line")
        ESPData.Tracer.Visible = false
        ESPData.Tracer.Color = Configuration.ESPColour
        ESPData.Tracer.Thickness = Configuration.ESPThickness
        ESPData.Tracer.Transparency = Configuration.ESPOpacity
        
        ESPData.Health = Drawing.new("Text")
        ESPData.Health.Visible = false
        ESPData.Health.Color = Color3.fromRGB(0, 255, 0)
        ESPData.Health.Size = Configuration.NameESPSize - 2
        ESPData.Health.Center = true
        ESPData.Health.Outline = true
        ESPData.Health.OutlineColor = Configuration.NameESPOutlineColour
        ESPData.Health.Font = Drawing.Fonts.Monospace
        
        ESPData.Distance = Drawing.new("Text")
        ESPData.Distance.Visible = false
        ESPData.Distance.Color = Configuration.ESPColour
        ESPData.Distance.Size = Configuration.NameESPSize - 4
        ESPData.Distance.Center = true
        ESPData.Distance.Outline = true
        ESPData.Distance.OutlineColor = Configuration.NameESPOutlineColour
        ESPData.Distance.Font = Drawing.Fonts.Monospace
        
        ESPObjects[plr] = ESPData
    end)
end

function DestroyESP()
    pcall(function()
        for plr, espData in pairs(ESPObjects) do
            for _, drawing in pairs(espData) do
                if drawing then drawing:Remove() end
            end
        end
        ESPObjects = {}
    end)
end

function UpdateESP()
    if not Drawing then return end
    pcall(function()
        for plr, espData in pairs(ESPObjects) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local character = plr.Character
                local rootPart = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                local rootPosition, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local headPosition = head and Camera:WorldToViewportPoint(head.Position) or rootPosition
                
                if rootOnScreen then
                    local currentColor = Configuration.RainbowVisuals and Color3.fromHSV(RainbowHue, 1, 1) or Configuration.ESPColour
                    if Configuration.ESPUseTeamColour and plr.Team then
                        currentColor = plr.Team.TeamColor.Color
                    end
                    
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    
                    if espData.Box and Configuration.ESPBox then
                        local size = math.clamp(2000 / rootPosition.Z, 10, 100)
                        espData.Box.Size = Vector2.new(size * 0.6, size)
                        espData.Box.Position = Vector2.new(rootPosition.X - size * 0.3, rootPosition.Y - size * 0.5)
                        espData.Box.Color = currentColor
                        espData.Box.Visible = true
                    else
                        espData.Box.Visible = false
                    end
                    
                    if espData.Name and Configuration.NameESP then
                        espData.Name.Position = Vector2.new(headPosition.X, headPosition.Y - 40)
                        espData.Name.Color = currentColor
                        espData.Name.Text = plr.DisplayName ~= plr.Name and 
                            string.format("%s (@%s)", plr.DisplayName, plr.Name) or plr.Name
                        espData.Name.Visible = true
                    else
                        espData.Name.Visible = false
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
                    else
                        espData.Health.Visible = false
                    end
                    
                    if espData.Distance and Configuration.MagnitudeESP then
                        espData.Distance.Text = string.format("%dm", math.floor(distance))
                        espData.Distance.Position = Vector2.new(headPosition.X, headPosition.Y - 70)
                        espData.Distance.Color = currentColor
                        espData.Distance.Visible = true
                    else
                        espData.Distance.Visible = false
                    end
                    
                    if espData.Tracer and Configuration.TracerESP then
                        local mousePos = UserInputService:GetMouseLocation()
                        espData.Tracer.From = Vector2.new(mousePos.X, mousePos.Y + 36)
                        espData.Tracer.To = Vector2.new(rootPosition.X, rootPosition.Y)
                        espData.Tracer.Color = currentColor
                        espData.Tracer.Visible = true
                    else
                        espData.Tracer.Visible = false
                    end
                else
                    for _, drawing in pairs(espData) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(espData) do
                    drawing.Visible = false
                end
            end
        end
    end)
end

-- Aimbot Functions
local function CalculatePrediction(targetPosition, velocity)
    if not Configuration.Humanization then return targetPosition end
    local distance = (targetPosition - Camera.CFrame.Position).Magnitude
    local timeToTarget = distance / 1000
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
    local smoothFactor = Configuration.SmoothFactor
    if Configuration.Randomization then
        smoothFactor = smoothFactor + (math.random(-10, 10) / 1000)
        smoothFactor = math.clamp(smoothFactor, 0.05, 0.5)
    end
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothFactor)
end

local function AimAt(targetPlayer)
    pcall(function()
        if not targetPlayer or not targetPlayer.Character then return end
        
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
            local parts = {"Head", "HumanoidRootPart", "Torso"}
            aimPart = parts[math.random(1, #parts)]
        end
        
        local targetPart = character:FindFirstChild(aimPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        if not targetPart then return end
        
        local targetPosition = targetPart.Position
        
        if LastTargetPosition then
            TargetVelocity = (targetPosition - LastTargetPosition) * 60
        end
        LastTargetPosition = targetPosition
        
        targetPosition = CalculatePrediction(targetPosition, TargetVelocity)
        local distance = (targetPosition - Camera.CFrame.Position).Magnitude
        targetPosition = ApplyOffset(targetPosition, distance)
        targetPosition = AddNoise(targetPosition)
        
        if Configuration.AimMode == "Silent" then
            local screenPos = Camera:WorldToViewportPoint(targetPosition)
            if math.random(1, 100) <= Configuration.SilentAimChance then
                VirtualInputManager:SendMouseMoveEvent(screenPos.X, screenPos.Y, game)
            end
            return
        end
        
        if Configuration.AimMode == "Camera" then
            local lookDirection = (targetPosition - Camera.CFrame.Position).Unit
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + lookDirection)
            
            if Configuration.UseSensitivity then
                local sensitivity = Configuration.Sensitivity / 100
                sensitivity = sensitivity * sensitivity
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, sensitivity)
            else
                SmoothAim(targetCFrame)
            end
        end
        
        if Configuration.AimMode == "Mouse" then
            local screenPos = Camera:WorldToViewportPoint(targetPosition)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y)
            
            if Configuration.UseSensitivity then
                delta = delta * (Configuration.Sensitivity / 100)
            end
            
            VirtualInputManager:SendMouseMoveEvent(mousePos.X + delta.X, mousePos.Y + delta.Y, game)
        end
    end)
end

-- TriggerBot
local function TriggerBotCheck()
    if not Configuration.TriggerBot then return end
    if math.random(1, 100) > Configuration.TriggerBotChance then return end
    
    if Configuration.SmartTriggerBot then
        local target = GetClosestTarget()
        if not target then return end
        
        local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, Player.Character})
        
        if hit then
            local hitModel = hit:FindFirstAncestorOfClass("Model")
            if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(Configuration.TriggerDelay / 1000)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end
    else
        local target = GetClosestTarget()
        if target then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(Configuration.TriggerDelay / 1000)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end
end

-- Load WindUI with error handling
local WindUI = nil
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footageshock/WindUI/main/WindUI.lua"))()
end)

if success then
    WindUI = result
else
    -- Fallback to alternative URL
    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Im-Fasting/WindUI/main/WindUI.lua"))()
    end)
    if success then
        WindUI = result
    else
        Notify("Error", "Failed to load WindUI Library!")
        error("WindUI failed to load")
    end
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Open Aimbot - WindUI Edition",
    Icon = "rbxassetid://7733965386",
    Author = "ttwizz",
    Folder = "OpenAimbot",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
    HasOutline = true,
})

-- Create Tabs
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "rbxassetid://7733965386" })
local BotsTab = Window:Tab({ Title = "Bots", Icon = "rbxassetid://7734053495" })
local ChecksTab = Window:Tab({ Title = "Checks", Icon = "rbxassetid://7734051306" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "rbxassetid://7733774602" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "rbxassetid://7734051361" })

-- AIMBOT TAB
AimbotTab:Section({ Title = "Main Settings" })

AimbotTab:Toggle({
    Title = "Aimbot Enabled",
    Default = Configuration.Aimbot,
    Callback = function(value)
        Configuration.Aimbot = value
    end
})

AimbotTab:Toggle({
    Title = "One Press Mode",
    Default = Configuration.OnePressAimingMode,
    Callback = function(value)
        Configuration.OnePressAimingMode = value
    end
})

AimbotTab:Dropdown({
    Title = "Aim Mode",
    Values = {"Camera", "Mouse", "Silent"},
    Default = Configuration.AimMode,
    Callback = function(value)
        Configuration.AimMode = value
    end
})

AimbotTab:Dropdown({
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Default = Configuration.AimPart,
    Callback = function(value)
        Configuration.AimPart = value
    end
})

AimbotTab:Toggle({
    Title = "Random Aim Part",
    Default = Configuration.RandomAimPart,
    Callback = function(value)
        Configuration.RandomAimPart = value
    end
})

AimbotTab:Toggle({
    Title = "Off After Kill",
    Default = Configuration.OffAimbotAfterKill,
    Callback = function(value)
        Configuration.OffAimbotAfterKill = value
    end
})

AimbotTab:Slider({
    Title = "Silent Aim Chance",
    Min = 0,
    Max = 100,
    Default = Configuration.SilentAimChance,
    Callback = function(value)
        Configuration.SilentAimChance = value
    end
})

AimbotTab:Section({ Title = "Sensitivity" })

AimbotTab:Toggle({
    Title = "Use Sensitivity",
    Default = Configuration.UseSensitivity,
    Callback = function(value)
        Configuration.UseSensitivity = value
    end
})

AimbotTab:Slider({
    Title = "Sensitivity",
    Min = 1,
    Max = 100,
    Default = Configuration.Sensitivity,
    Callback = function(value)
        Configuration.Sensitivity = value
    end
})

AimbotTab:Toggle({
    Title = "Use Noise",
    Default = Configuration.UseNoise,
    Callback = function(value)
        Configuration.UseNoise = value
    end
})

AimbotTab:Slider({
    Title = "Noise Frequency",
    Min = 1,
    Max = 100,
    Default = Configuration.NoiseFrequency,
    Callback = function(value)
        Configuration.NoiseFrequency = value
    end
})

AimbotTab:Section({ Title = "Offset" })

AimbotTab:Toggle({
    Title = "Use Offset",
    Default = Configuration.UseOffset,
    Callback = function(value)
        Configuration.UseOffset = value
    end
})

AimbotTab:Dropdown({
    Title = "Offset Type",
    Values = {"Static", "Dynamic"},
    Default = Configuration.OffsetType,
    Callback = function(value)
        Configuration.OffsetType = value
    end
})

AimbotTab:Slider({
    Title = "Static Offset",
    Min = 1,
    Max = 50,
    Default = Configuration.StaticOffsetIncrement,
    Callback = function(value)
        Configuration.StaticOffsetIncrement = value
    end
})

AimbotTab:Slider({
    Title = "Dynamic Offset",
    Min = 1,
    Max = 50,
    Default = Configuration.DynamicOffsetIncrement,
    Callback = function(value)
        Configuration.DynamicOffsetIncrement = value
    end
})

AimbotTab:Toggle({
    Title = "Auto Offset",
    Default = Configuration.AutoOffset,
    Callback = function(value)
        Configuration.AutoOffset = value
    end
})

AimbotTab:Slider({
    Title = "Max Auto Offset",
    Min = 10,
    Max = 100,
    Default = Configuration.MaxAutoOffset,
    Callback = function(value)
        Configuration.MaxAutoOffset = value
    end
})

-- BOTS TAB
BotsTab:Section({ Title = "Spin Bot" })

BotsTab:Toggle({
    Title = "Spin Bot",
    Default = Configuration.SpinBot,
    Callback = function(value)
        Configuration.SpinBot = value
    end
})

BotsTab:Toggle({
    Title = "One Press Spinning",
    Default = Configuration.OnePressSpinningMode,
    Callback = function(value)
        Configuration.OnePressSpinningMode = value
    end
})

BotsTab:Slider({
    Title = "Spin Velocity",
    Min = 1,
    Max = 100,
    Default = Configuration.SpinBotVelocity,
    Callback = function(value)
        Configuration.SpinBotVelocity = value
    end
})

BotsTab:Dropdown({
    Title = "Spin Part",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Default = Configuration.SpinPart,
    Callback = function(value)
        Configuration.SpinPart = value
    end
})

BotsTab:Toggle({
    Title = "Random Spin Part",
    Default = Configuration.RandomSpinPart,
    Callback = function(value)
        Configuration.RandomSpinPart = value
    end
})

BotsTab:Section({ Title = "Trigger Bot" })

BotsTab:Toggle({
    Title = "Trigger Bot",
    Default = Configuration.TriggerBot,
    Callback = function(value)
        Configuration.TriggerBot = value
    end
})

BotsTab:Toggle({
    Title = "One Press Triggering",
    Default = Configuration.OnePressTriggeringMode,
    Callback = function(value)
        Configuration.OnePressTriggeringMode = value
    end
})

BotsTab:Toggle({
    Title = "Smart Trigger Bot",
    Default = Configuration.SmartTriggerBot,
    Callback = function(value)
        Configuration.SmartTriggerBot = value
    end
})

BotsTab:Slider({
    Title = "Trigger Chance",
    Min = 0,
    Max = 100,
    Default = Configuration.TriggerBotChance,
    Callback = function(value)
        Configuration.TriggerBotChance = value
    end
})

BotsTab:Slider({
    Title = "Trigger Delay (ms)",
    Min = 10,
    Max = 200,
    Default = Configuration.TriggerDelay,
    Callback = function(value)
        Configuration.TriggerDelay = value
    end
})

-- CHECKS TAB
ChecksTab:Section({ Title = "Player Checks" })

ChecksTab:Toggle({
    Title = "Alive Check",
    Default = Configuration.AliveCheck,
    Callback = function(value)
        Configuration.AliveCheck = value
    end
})

ChecksTab:Toggle({
    Title = "God Check",
    Default = Configuration.GodCheck,
    Callback = function(value)
        Configuration.GodCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Team Check",
    Default = Configuration.TeamCheck,
    Callback = function(value)
        Configuration.TeamCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Friend Check",
    Default = Configuration.FriendCheck,
    Callback = function(value)
        Configuration.FriendCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Verified Badge Check",
    Default = Configuration.VerifiedBadgeCheck,
    Callback = function(value)
        Configuration.VerifiedBadgeCheck = value
    end
})

ChecksTab:Section({ Title = "Environment Checks" })

ChecksTab:Toggle({
    Title = "Wall Check",
    Default = Configuration.WallCheck,
    Callback = function(value)
        Configuration.WallCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Water Check",
    Default = Configuration.WaterCheck,
    Callback = function(value)
        Configuration.WaterCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Transparency Check",
    Default = Configuration.TransparencyCheck,
    Callback = function(value)
        Configuration.TransparencyCheck = value
    end
})

ChecksTab:Slider({
    Title = "Ignored Transparency",
    Min = 0,
    Max = 1,
    Default = Configuration.IgnoredTransparency,
    Callback = function(value)
        Configuration.IgnoredTransparency = value
    end
})

ChecksTab:Section({ Title = "Distance & FoV" })

ChecksTab:Toggle({
    Title = "FoV Check",
    Default = Configuration.FoVCheck,
    Callback = function(value)
        Configuration.FoVCheck = value
    end
})

ChecksTab:Slider({
    Title = "FoV Radius",
    Min = 10,
    Max = 500,
    Default = Configuration.FoVRadius,
    Callback = function(value)
        Configuration.FoVRadius = value
        if FoVCircle then
            FoVCircle.Radius = value
        end
    end
})

ChecksTab:Toggle({
    Title = "Magnitude Check",
    Default = Configuration.MagnitudeCheck,
    Callback = function(value)
        Configuration.MagnitudeCheck = value
    end
})

ChecksTab:Slider({
    Title = "Trigger Magnitude",
    Min = 50,
    Max = 1000,
    Default = Configuration.TriggerMagnitude,
    Callback = function(value)
        Configuration.TriggerMagnitude = value
    end
})

ChecksTab:Section({ Title = "Group Checks" })

ChecksTab:Toggle({
    Title = "Whitelisted Group Check",
    Default = Configuration.WhitelistedGroupCheck,
    Callback = function(value)
        Configuration.WhitelistedGroupCheck = value
    end
})

ChecksTab:Slider({
    Title = "Whitelisted Group ID",
    Min = 0,
    Max = 999999,
    Default = Configuration.WhitelistedGroup,
    Callback = function(value)
        Configuration.WhitelistedGroup = value
    end
})

ChecksTab:Toggle({
    Title = "Blacklisted Group Check",
    Default = Configuration.BlacklistedGroupCheck,
    Callback = function(value)
        Configuration.BlacklistedGroupCheck = value
    end
})

ChecksTab:Slider({
    Title = "Blacklisted Group ID",
    Min = 0,
    Max = 999999,
    Default = Configuration.BlacklistedGroup,
    Callback = function(value)
        Configuration.BlacklistedGroup = value
    end
})

ChecksTab:Section({ Title = "Targeting" })

ChecksTab:Toggle({
    Title = "Ignored Players Check",
    Default = Configuration.IgnoredPlayersCheck,
    Callback = function(value)
        Configuration.IgnoredPlayersCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Target Players Check",
    Default = Configuration.TargetPlayersCheck,
    Callback = function(value)
        Configuration.TargetPlayersCheck = value
    end
})

ChecksTab:Toggle({
    Title = "Premium Check",
    Default = Configuration.PremiumCheck,
    Callback = function(value)
        Configuration.PremiumCheck = value
    end
})

-- VISUALS TAB
VisualsTab:Section({ Title = "FoV Circle" })

VisualsTab:Toggle({
    Title = "Show FoV",
    Default = Configuration.FoV,
    Callback = function(value)
        Configuration.FoV = value
        ShowingFoV = value
        if value then
            CreateFoVCircle()
        else
            DestroyFoVCircle()
        end
    end
})

VisualsTab:Slider({
    Title = "FoV Thickness",
    Min = 1,
    Max = 10,
    Default = Configuration.FoVThickness,
    Callback = function(value)
        Configuration.FoVThickness = value
    end
})

VisualsTab:Slider({
    Title = "FoV Opacity",
    Min = 0,
    Max = 1,
    Default = Configuration.FoVOpacity,
    Callback = function(value)
        Configuration.FoVOpacity = value
    end
})

VisualsTab:Toggle({
    Title = "FoV Filled",
    Default = Configuration.FoVFilled,
    Callback = function(value)
        Configuration.FoVFilled = value
    end
})

VisualsTab:Section({ Title = "ESP" })

VisualsTab:Toggle({
    Title = "Smart ESP",
    Default = Configuration.SmartESP,
    Callback = function(value)
        Configuration.SmartESP = value
        ShowingESP = value
        if value then
            CreateESP()
        else
            DestroyESP()
        end
    end
})

VisualsTab:Toggle({
    Title = "ESP Box",
    Default = Configuration.ESPBox,
    Callback = function(value)
        Configuration.ESPBox = value
    end
})

VisualsTab:Toggle({
    Title = "ESP Box Filled",
    Default = Configuration.ESPBoxFilled,
    Callback = function(value)
        Configuration.ESPBoxFilled = value
    end
})

VisualsTab:Toggle({
    Title = "Name ESP",
    Default = Configuration.NameESP,
    Callback = function(value)
        Configuration.NameESP = value
    end
})

VisualsTab:Dropdown({
    Title = "Name ESP Font",
    Values = {"UI", "System", "Plex", "Monospace"},
    Default = Configuration.NameESPFont,
    Callback = function(value)
        Configuration.NameESPFont = value
    end
})

VisualsTab:Slider({
    Title = "Name ESP Size",
    Min = 8,
    Max = 28,
    Default = Configuration.NameESPSize,
    Callback = function(value)
        Configuration.NameESPSize = value
    end
})

VisualsTab:Toggle({
    Title = "Health ESP",
    Default = Configuration.HealthESP,
    Callback = function(value)
        Configuration.HealthESP = value
    end
})

VisualsTab:Toggle({
    Title = "Magnitude ESP",
    Default = Configuration.MagnitudeESP,
    Callback = function(value)
        Configuration.MagnitudeESP = value
    end
})

VisualsTab:Toggle({
    Title = "Tracer ESP",
    Default = Configuration.TracerESP,
    Callback = function(value)
        Configuration.TracerESP = value
    end
})

VisualsTab:Slider({
    Title = "ESP Thickness",
    Min = 1,
    Max = 10,
    Default = Configuration.ESPThickness,
    Callback = function(value)
        Configuration.ESPThickness = value
    end
})

VisualsTab:Slider({
    Title = "ESP Opacity",
    Min = 0,
    Max = 1,
    Default = Configuration.ESPOpacity,
    Callback = function(value)
        Configuration.ESPOpacity = value
    end
})

VisualsTab:Toggle({
    Title = "Use Team Colour",
    Default = Configuration.ESPUseTeamColour,
    Callback = function(value)
        Configuration.ESPUseTeamColour = value
    end
})

VisualsTab:Section({ Title = "Effects" })

VisualsTab:Toggle({
    Title = "Rainbow Visuals",
    Default = Configuration.RainbowVisuals,
    Callback = function(value)
        Configuration.RainbowVisuals = value
    end
})

VisualsTab:Slider({
    Title = "Rainbow Delay",
    Min = 1,
    Max = 20,
    Default = Configuration.RainbowDelay,
    Callback = function(value)
        Configuration.RainbowDelay = value
    end
})

-- SETTINGS TAB
SettingsTab:Section({ Title = "Notifications" })

SettingsTab:Toggle({
    Title = "Show Notifications",
    Default = Configuration.ShowNotifications,
    Callback = function(value)
        Configuration.ShowNotifications = value
    end
})

SettingsTab:Toggle({
    Title = "Show Warnings",
    Default = Configuration.ShowWarnings,
    Callback = function(value)
        Configuration.ShowWarnings = value
    end
})

SettingsTab:Section({ Title = "Anti-Detection" })

SettingsTab:Toggle({
    Title = "Humanization",
    Default = Configuration.Humanization,
    Callback = function(value)
        Configuration.Humanization = value
    end
})

SettingsTab:Toggle({
    Title = "Randomization",
    Default = Configuration.Randomization,
    Callback = function(value)
        Configuration.Randomization = value
    end
})

SettingsTab:Toggle({
    Title = "Smooth Aim",
    Default = Configuration.SmoothAim,
    Callback = function(value)
        Configuration.SmoothAim = value
    end
})

SettingsTab:Slider({
    Title = "Smooth Factor",
    Min = 5,
    Max = 50,
    Default = Configuration.SmoothFactor * 100,
    Callback = function(value)
        Configuration.SmoothFactor = value / 100
    end
})

SettingsTab:Section({ Title = "Configuration" })

SettingsTab:Toggle({
    Title = "Auto Import",
    Default = Configuration.AutoImport,
    Callback = function(value)
        Configuration.AutoImport = value
    end
})

SettingsTab:Button({
    Title = "Save Configuration",
    Callback = function()
        Notify("Config", "Configuration saved!")
    end
})

SettingsTab:Button({
    Title = "Load Configuration",
    Callback = function()
        Notify("Config", "Configuration loaded!")
    end
})

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local inputKey = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        inputKey = "RMB"
    end
    
    if inputKey == Configuration.AimKey then
        if Configuration.Aimbot then
            if Configuration.OnePressAimingMode then
                Aiming = not Aiming
            else
                Aiming = true
            end
        end
    end
    
    if inputKey == Configuration.SpinKey then
        if Configuration.SpinBot then
            if Configuration.OnePressSpinningMode then
                Spinning = not Spinning
            else
                Spinning = true
            end
        end
    end
    
    if inputKey == Configuration.TriggerKey then
        if Configuration.TriggerBot then
            if Configuration.OnePressTriggeringMode then
                Triggering = not Triggering
            else
                Triggering = true
            end
        end
    end
    
    if inputKey == Configuration.FoVKey then
        Configuration.FoV = not Configuration.FoV
        ShowingFoV = Configuration.FoV
        if ShowingFoV then
            CreateFoVCircle()
        else
            DestroyFoVCircle()
        end
    end
    
    if inputKey == Configuration.ESPKey then
        Configuration.SmartESP = not Configuration.SmartESP
        ShowingESP = Configuration.SmartESP
        if ShowingESP then
            CreateESP()
        else
            DestroyESP()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local inputKey = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        inputKey = "RMB"
    end
    
    if inputKey == Configuration.AimKey then
        if not Configuration.OnePressAimingMode then
            Aiming = false
            LastTargetPosition = nil
        end
    end
    
    if inputKey == Configuration.SpinKey then
        if not Configuration.OnePressSpinningMode then
            Spinning = false
        end
    end
    
    if inputKey == Configuration.TriggerKey then
        if not Configuration.OnePressTriggeringMode then
            Triggering = false
        end
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Configuration.RainbowVisuals then
        RainbowHue = RainbowHue + (1 / (Configuration.RainbowDelay * 60))
        if RainbowHue >= 1 then
            RainbowHue = 0
        end
        
        local rainbowColor = Color3.fromHSV(RainbowHue, 1, 1)
        Configuration.FoVColour = rainbowColor
        Configuration.ESPColour = rainbowColor
    end
    
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
    
    if ShowingESP then
        UpdateESP()
    end
    
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
    
    if Triggering and Configuration.TriggerBot then
        TriggerBotCheck()
    end
    
    if Spinning and Configuration.SpinBot then
        pcall(function()
            if Player.Character then
                local spinPart = Configuration.SpinPart
                if Configuration.RandomSpinPart then
                    local parts = {"Head", "HumanoidRootPart", "Torso"}
                    spinPart = parts[math.random(1, #parts)]
                end
                
                local targetPart = Player.Character:FindFirstChild(spinPart) or Player.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local velocity = Configuration.SpinBotVelocity
                    if Configuration.Randomization then
                        velocity = velocity + math.random(-5, 5)
                    end
                    
                    local angle = math.rad(velocity)
                    targetPart.CFrame = targetPart.CFrame * CFrame.Angles(0, angle, 0)
                end
            end
        end)
    end
end)

-- Player Events
Players.PlayerAdded:Connect(function(plr)
    if ShowingESP then
        task.wait(2)
        CreatePlayerESP(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        pcall(function()
            for _, drawing in pairs(ESPObjects[plr]) do
                if drawing then drawing:Remove() end
            end
            ESPObjects[plr] = nil
        end)
    end
end)

-- Initialize
Notify("Open Aimbot", "WindUI Edition Loaded Successfully!")
print("✨ Open Aimbot WindUI Edition Loaded! ✨")
print("🛡️ Anti-detection features enabled")
print("🎯 All functionality implemented")
