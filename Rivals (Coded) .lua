--[[⊹˚₊‧───────────────‧₊˚⊹·͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⊹˚₊‧───────────────‧₊˚⊹

    ✨Open Aimbot - Rayfield Edition✨
    Anti-Cheat Resistant | Fully Featured

•───────•°•❀•°•───────•୧‿̩͙ ˖︵ꕀ ⠀𓏶 ̣̣̥⠀ ꕀ︵˖ ̩͙‿୨•───────•°•❀•°•───────•]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Constants
local Player = Players.LocalPlayer

-- Configuration
local Configuration = {
    Aimbot = false,
    OnePressAimingMode = false,
    AimKey = "RMB",
    AimMode = "Camera",
    SilentAimChance = 100,
    OffAimbotAfterKill = false,
    AimPart = "HumanoidRootPart",
    RandomAimPart = false,
    
    UseOffset = false,
    OffsetType = "Static",
    StaticOffsetIncrement = 10,
    DynamicOffsetIncrement = 10,
    AutoOffset = false,
    MaxAutoOffset = 50,
    
    UseSensitivity = true,
    Sensitivity = 35,
    UseNoise = true,
    NoiseFrequency = 25,
    
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
    
    AliveCheck = true,
    GodCheck = true,
    TeamCheck = true,
    FriendCheck = true,
    WallCheck = true,
    
    FoVCheck = true,
    FoVRadius = 150,
    MagnitudeCheck = true,
    TriggerMagnitude = 300,
    
    FoV = false,
    FoVThickness = 1,
    FoVOpacity = 0.5,
    FoVFilled = false,
    FoVColour = Color3.fromRGB(255, 255, 255),
    
    SmartESP = false,
    ESPBox = true,
    ESPBoxFilled = false,
    NameESP = true,
    HealthESP = true,
    MagnitudeESP = true,
    TracerESP = false,
    ESPThickness = 1,
    ESPOpacity = 0.7,
    ESPColour = Color3.fromRGB(255, 255, 255),
    ESPUseTeamColour = false,
    
    RainbowVisuals = false,
    RainbowDelay = 5,
    
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

-- Drawing API
local Drawing = Drawing or nil
if not Drawing then
    pcall(function()
        Drawing = getgenv().Drawing
    end)
end

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Open Aimbot - Fixed Edition",
    LoadingTitle = "Open Aimbot",
    LoadingSubtitle = "by ttwizz",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "OpenAimbot",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Functions
local function Notify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
        Image = 4483362458,
    })
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
        ESPData.Name.Size = 14
        ESPData.Name.Center = true
        ESPData.Name.Outline = true
        ESPData.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
        
        ESPData.Tracer = Drawing.new("Line")
        ESPData.Tracer.Visible = false
        ESPData.Tracer.Color = Configuration.ESPColour
        ESPData.Tracer.Thickness = Configuration.ESPThickness
        ESPData.Tracer.Transparency = Configuration.ESPOpacity
        
        ESPData.Health = Drawing.new("Text")
        ESPData.Health.Visible = false
        ESPData.Health.Color = Color3.fromRGB(0, 255, 0)
        ESPData.Health.Size = 12
        ESPData.Health.Center = true
        ESPData.Health.Outline = true
        
        ESPData.Distance = Drawing.new("Text")
        ESPData.Distance.Visible = false
        ESPData.Distance.Color = Configuration.ESPColour
        ESPData.Distance.Size = 10
        ESPData.Distance.Center = true
        ESPData.Distance.Outline = true
        
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

-- RAYFIELD UI SETUP
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local BotsTab = Window:CreateTab("Bots", 4483362458)
local ChecksTab = Window:CreateTab("Checks", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- AIMBOT TAB
AimbotTab:CreateSection("Main Settings")

AimbotTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = Configuration.Aimbot,
    Flag = "AimbotEnabled",
    Callback = function(Value)
        Configuration.Aimbot = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "One Press Mode",
    CurrentValue = Configuration.OnePressAimingMode,
    Flag = "OnePressMode",
    Callback = function(Value)
        Configuration.OnePressAimingMode = Value
    end,
})

AimbotTab:CreateDropdown({
    Name = "Aim Mode",
    Options = {"Camera", "Mouse", "Silent"},
    CurrentOption = Configuration.AimMode,
    Flag = "AimMode",
    Callback = function(Value)
        Configuration.AimMode = Value
    end,
})

AimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = Configuration.AimPart,
    Flag = "AimPart",
    Callback = function(Value)
        Configuration.AimPart = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "Random Aim Part",
    CurrentValue = Configuration.RandomAimPart,
    Flag = "RandomAimPart",
    Callback = function(Value)
        Configuration.RandomAimPart = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "Off After Kill",
    CurrentValue = Configuration.OffAimbotAfterKill,
    Flag = "OffAfterKill",
    Callback = function(Value)
        Configuration.OffAimbotAfterKill = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Silent Aim Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = Configuration.SilentAimChance,
    Flag = "SilentAimChance",
    Callback = function(Value)
        Configuration.SilentAimChance = Value
    end,
})

AimbotTab:CreateSection("Sensitivity")

AimbotTab:CreateToggle({
    Name = "Use Sensitivity",
    CurrentValue = Configuration.UseSensitivity,
    Flag = "UseSensitivity",
    Callback = function(Value)
        Configuration.UseSensitivity = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Sensitivity",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = Configuration.Sensitivity,
    Flag = "Sensitivity",
    Callback = function(Value)
        Configuration.Sensitivity = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "Use Noise",
    CurrentValue = Configuration.UseNoise,
    Flag = "UseNoise",
    Callback = function(Value)
        Configuration.UseNoise = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Noise Frequency",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = Configuration.NoiseFrequency,
    Flag = "NoiseFrequency",
    Callback = function(Value)
        Configuration.NoiseFrequency = Value
    end,
})

AimbotTab:CreateSection("Offset")

AimbotTab:CreateToggle({
    Name = "Use Offset",
    CurrentValue = Configuration.UseOffset,
    Flag = "UseOffset",
    Callback = function(Value)
        Configuration.UseOffset = Value
    end,
})

AimbotTab:CreateDropdown({
    Name = "Offset Type",
    Options = {"Static", "Dynamic"},
    CurrentOption = Configuration.OffsetType,
    Flag = "OffsetType",
    Callback = function(Value)
        Configuration.OffsetType = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Static Offset",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.StaticOffsetIncrement,
    Flag = "StaticOffset",
    Callback = function(Value)
        Configuration.StaticOffsetIncrement = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Dynamic Offset",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.DynamicOffsetIncrement,
    Flag = "DynamicOffset",
    Callback = function(Value)
        Configuration.DynamicOffsetIncrement = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "Auto Offset",
    CurrentValue = Configuration.AutoOffset,
    Flag = "AutoOffset",
    Callback = function(Value)
        Configuration.AutoOffset = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Max Auto Offset",
    Range = {10, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.MaxAutoOffset,
    Flag = "MaxAutoOffset",
    Callback = function(Value)
        Configuration.MaxAutoOffset = Value
    end,
})

-- BOTS TAB
BotsTab:CreateSection("Spin Bot")

BotsTab:CreateToggle({
    Name = "Spin Bot",
    CurrentValue = Configuration.SpinBot,
    Flag = "SpinBot",
    Callback = function(Value)
        Configuration.SpinBot = Value
    end,
})

BotsTab:CreateToggle({
    Name = "One Press Spinning",
    CurrentValue = Configuration.OnePressSpinningMode,
    Flag = "OnePressSpinning",
    Callback = function(Value)
        Configuration.OnePressSpinningMode = Value
    end,
})

BotsTab:CreateSlider({
    Name = "Spin Velocity",
    Range = {1, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.SpinBotVelocity,
    Flag = "SpinVelocity",
    Callback = function(Value)
        Configuration.SpinBotVelocity = Value
    end,
})

BotsTab:CreateDropdown({
    Name = "Spin Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = Configuration.SpinPart,
    Flag = "SpinPart",
    Callback = function(Value)
        Configuration.SpinPart = Value
    end,
})

BotsTab:CreateToggle({
    Name = "Random Spin Part",
    CurrentValue = Configuration.RandomSpinPart,
    Flag = "RandomSpinPart",
    Callback = function(Value)
        Configuration.RandomSpinPart = Value
    end,
})

BotsTab:CreateSection("Trigger Bot")

BotsTab:CreateToggle({
    Name = "Trigger Bot",
    CurrentValue = Configuration.TriggerBot,
    Flag = "TriggerBot",
    Callback = function(Value)
        Configuration.TriggerBot = Value
    end,
})

BotsTab:CreateToggle({
    Name = "One Press Triggering",
    CurrentValue = Configuration.OnePressTriggeringMode,
    Flag = "OnePressTriggering",
    Callback = function(Value)
        Configuration.OnePressTriggeringMode = Value
    end,
})

BotsTab:CreateToggle({
    Name = "Smart Trigger Bot",
    CurrentValue = Configuration.SmartTriggerBot,
    Flag = "SmartTriggerBot",
    Callback = function(Value)
        Configuration.SmartTriggerBot = Value
    end,
})

BotsTab:CreateSlider({
    Name = "Trigger Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = Configuration.TriggerBotChance,
    Flag = "TriggerChance",
    Callback = function(Value)
        Configuration.TriggerBotChance = Value
    end,
})

BotsTab:CreateSlider({
    Name = "Trigger Delay",
    Range = {10, 200},
    Increment = 10,
    Suffix = "ms",
    CurrentValue = Configuration.TriggerDelay,
    Flag = "TriggerDelay",
    Callback = function(Value)
        Configuration.TriggerDelay = Value
    end,
})

-- CHECKS TAB
ChecksTab:CreateSection("Player Checks")

ChecksTab:CreateToggle({
    Name = "Alive Check",
    CurrentValue = Configuration.AliveCheck,
    Flag = "AliveCheck",
    Callback = function(Value)
        Configuration.AliveCheck = Value
    end,
})

ChecksTab:CreateToggle({
    Name = "God Check",
    CurrentValue = Configuration.GodCheck,
    Flag = "GodCheck",
    Callback = function(Value)
        Configuration.GodCheck = Value
    end,
})

ChecksTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = Configuration.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(Value)
        Configuration.TeamCheck = Value
    end,
})

ChecksTab:CreateToggle({
    Name = "Friend Check",
    CurrentValue = Configuration.FriendCheck,
    Flag = "FriendCheck",
    Callback = function(Value)
        Configuration.FriendCheck = Value
    end,
})

ChecksTab:CreateSection("Environment Checks")

ChecksTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = Configuration.WallCheck,
    Flag = "WallCheck",
    Callback = function(Value)
        Configuration.WallCheck = Value
    end,
})

ChecksTab:CreateSection("Distance & FoV")

ChecksTab:CreateToggle({
    Name = "FoV Check",
    CurrentValue = Configuration.FoVCheck,
    Flag = "FoVCheck",
    Callback = function(Value)
        Configuration.FoVCheck = Value
    end,
})

ChecksTab:CreateSlider({
    Name = "FoV Radius",
    Range = {10, 500},
    Increment = 10,
    Suffix = "",
    CurrentValue = Configuration.FoVRadius,
    Flag = "FoVRadius",
    Callback = function(Value)
        Configuration.FoVRadius = Value
        if FoVCircle then
            FoVCircle.Radius = Value
        end
    end,
})

ChecksTab:CreateToggle({
    Name = "Magnitude Check",
    CurrentValue = Configuration.MagnitudeCheck,
    Flag = "MagnitudeCheck",
    Callback = function(Value)
        Configuration.MagnitudeCheck = Value
    end,
})

ChecksTab:CreateSlider({
    Name = "Trigger Magnitude",
    Range = {50, 1000},
    Increment = 50,
    Suffix = "",
    CurrentValue = Configuration.TriggerMagnitude,
    Flag = "TriggerMagnitude",
    Callback = function(Value)
        Configuration.TriggerMagnitude = Value
    end,
})

-- VISUALS TAB
VisualsTab:CreateSection("FoV Circle")

VisualsTab:CreateToggle({
    Name = "Show FoV",
    CurrentValue = Configuration.FoV,
    Flag = "ShowFoV",
    Callback = function(Value)
        Configuration.FoV = Value
        ShowingFoV = Value
        if Value then
            CreateFoVCircle()
        else
            DestroyFoVCircle()
        end
    end,
})

VisualsTab:CreateSlider({
    Name = "FoV Thickness",
    Range = {1, 10},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.FoVThickness,
    Flag = "FoVThickness",
    Callback = function(Value)
        Configuration.FoVThickness = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "FoV Opacity",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = Configuration.FoVOpacity,
    Flag = "FoVOpacity",
    Callback = function(Value)
        Configuration.FoVOpacity = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "FoV Filled",
    CurrentValue = Configuration.FoVFilled,
    Flag = "FoVFilled",
    Callback = function(Value)
        Configuration.FoVFilled = Value
    end,
})

VisualsTab:CreateSection("ESP")

VisualsTab:CreateToggle({
    Name = "Smart ESP",
    CurrentValue = Configuration.SmartESP,
    Flag = "SmartESP",
    Callback = function(Value)
        Configuration.SmartESP = Value
        ShowingESP = Value
        if Value then
            CreateESP()
        else
            DestroyESP()
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = Configuration.ESPBox,
    Flag = "ESPBox",
    Callback = function(Value)
        Configuration.ESPBox = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "ESP Box Filled",
    CurrentValue = Configuration.ESPBoxFilled,
    Flag = "ESPBoxFilled",
    Callback = function(Value)
        Configuration.ESPBoxFilled = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = Configuration.NameESP,
    Flag = "NameESP",
    Callback = function(Value)
        Configuration.NameESP = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = Configuration.HealthESP,
    Flag = "HealthESP",
    Callback = function(Value)
        Configuration.HealthESP = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Magnitude ESP",
    CurrentValue = Configuration.MagnitudeESP,
    Flag = "MagnitudeESP",
    Callback = function(Value)
        Configuration.MagnitudeESP = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = Configuration.TracerESP,
    Flag = "TracerESP",
    Callback = function(Value)
        Configuration.TracerESP = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "ESP Thickness",
    Range = {1, 10},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.ESPThickness,
    Flag = "ESPThickness",
    Callback = function(Value)
        Configuration.ESPThickness = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "ESP Opacity",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = Configuration.ESPOpacity,
    Flag = "ESPOpacity",
    Callback = function(Value)
        Configuration.ESPOpacity = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Use Team Colour",
    CurrentValue = Configuration.ESPUseTeamColour,
    Flag = "ESPUseTeamColour",
    Callback = function(Value)
        Configuration.ESPUseTeamColour = Value
    end,
})

VisualsTab:CreateSection("Effects")

VisualsTab:CreateToggle({
    Name = "Rainbow Visuals",
    CurrentValue = Configuration.RainbowVisuals,
    Flag = "RainbowVisuals",
    Callback = function(Value)
        Configuration.RainbowVisuals = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "Rainbow Delay",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.RainbowDelay,
    Flag = "RainbowDelay",
    Callback = function(Value)
        Configuration.RainbowDelay = Value
    end,
})

-- SETTINGS TAB
SettingsTab:CreateSection("Anti-Detection")

SettingsTab:CreateToggle({
    Name = "Humanization",
    CurrentValue = Configuration.Humanization,
    Flag = "Humanization",
    Callback = function(Value)
        Configuration.Humanization = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "Randomization",
    CurrentValue = Configuration.Randomization,
    Flag = "Randomization",
    Callback = function(Value)
        Configuration.Randomization = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "Smooth Aim",
    CurrentValue = Configuration.SmoothAim,
    Flag = "SmoothAim",
    Callback = function(Value)
        Configuration.SmoothAim = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "Smooth Factor",
    Range = {5, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = Configuration.SmoothFactor * 100,
    Flag = "SmoothFactor",
    Callback = function(Value)
        Configuration.SmoothFactor = Value / 100
    end,
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
        else
            Target = nil
            LastTargetPosition = nil
        end
    else
        Target = nil
        LastTargetPosition = nil
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
Notify("Open Aimbot", "Rayfield Edition Loaded Successfully!")
print("✨ Open Aimbot Rayfield Edition Loaded! ✨")
