local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

WindUI:AddTheme({
    Name = "Dark",
    Accent = "#18181b",
    Dialog = "#18181b", 
    Outline = "#FFFFFF",
    Text = "#FFFFFF",
    Placeholder = "#999999",
    Background = "#0e0e10",
    Button = "#52525b",
    Icon = "#a1a1aa",
})

WindUI:SetTheme("Dark")
WindUI:SetNotificationLower(true)

if not getgenv().TransparencyEnabled then
    getgenv().TransparencyEnabled = false
end

-- ==========================================
-- 100 DAYS AT SEA: MASTER ARRAYS
-- ==========================================

local seaMaterials = {
    "Wood", "Broken Crates", "Planks", "Logs", "Twigs", "Faggots", "Sawdust", "Wood Waste", 
    "Thatch", "Cloth", "Rope", "Scraps", "Nails", "Metal Scrap", "Rusty Anchor", "Barbed Wire"
}
local seaOresAndFuels = {
    "Iron Ore", "Iron Bars", "Titanium Ore", "Titanium Bars", "Ice Chunks", "Packed Ice", 
    "Sulphur", "Copper Ore", "Charcoal", "Coal", "Gas", "Oil", "Biofuel", "Car Battery", "Engine Battery"
}
local seaFoodAndWater = {
    "Raw Fish", "Cooked Fish", "Shark Meat", "Deer Meat", "Venison", "Cooked Meat", 
    "Crab Sticks", "Potato", "Orange", "Green Coconuts", "Brown Coconuts", "Breadfruit", 
    "Jungle Berries", "Eggs", "Stew", "Chowder", "Sushi", "Canned Beans", "Crackers", 
    "Freshwater", "Purified Water"
}
local seaValuables = {"Coins", "Pearls", "Level 3 Flute", "Airdrop Supplies", "Chest", "Crate", "Floating Chest"}
local seaHostiles = {"Shark", "Seagull", "Pirate"}
local seaNPCs = {"Madeline", "Erik", "dr.Stephen"}

-- Active Selection Tables
local selectedMaterialItems = {}
local selectedFoodItems = {}
local selectedEspTargets = {}
local selectedHostileEsp = {}

local allEspItems = {}
for _, v in ipairs(seaMaterials) do table.insert(allEspItems, v) end
for _, v in ipairs(seaOresAndFuels) do table.insert(allEspItems, v) end
for _, v in ipairs(seaFoodAndWater) do table.insert(allEspItems, v) end
for _, v in ipairs(seaValuables) do table.insert(allEspItems, v) end

-- ==========================================
-- CORE FUNCTIONS & AUTOMATION
-- ==========================================

local function getClosest(targetName)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local closest, maxDist = nil, 9999
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == targetName and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
            local dist = (hrp.Position - pos).Magnitude
            if dist < maxDist then
                maxDist = dist
                closest = obj
            end
        end
    end
    return closest
end

-- Safely fires all proximity prompts within a specific object 
local function fireAllPrompts(obj)
    for _, prompt in ipairs(obj:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local originalLOS = prompt.RequiresLineOfSight
            local originalDist = prompt.MaxActivationDistance
            
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 99999
            
            fireproximityprompt(prompt, 1, true)
            
            task.delay(0.1, function()
                prompt.RequiresLineOfSight = originalLOS
                prompt.MaxActivationDistance = originalDist
            end)
        end
    end
end

-- ==========================================
-- UI INITIALIZATION
-- ==========================================

local Window = WindUI:CreateWindow({
    Title = "100 Days At Sea | BORUTODEV",
    Icon = "rbxassetid://72462144048455", 
    Author = "BORUTODEV",
    Folder = "BorutoDEV_SeaHub",
    Size = UDim2.fromOffset(600, 450),
    Transparent = getgenv().TransparencyEnabled,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 170,
    BackgroundImageTransparency = 0.8,
    HideSearchBar = false,
    ScrollBarEnabled = true
})

Window:SetToggleKey(Enum.KeyCode.V)

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "home" }),
    AutoFarm = Window:Tab({ Title = "Auto Farm", Icon = "tractor" }),
    Base = Window:Tab({ Title = "Base Auto", Icon = "hammer" }),
    Combat = Window:Tab({ Title = "Combat", Icon = "swords" }),
    Bring = Window:Tab({ Title = "Auto Collect", Icon = "package" }),
    Esp = Window:Tab({ Title = "Visuals", Icon = "eye" }),
    Player = Window:Tab({ Title = "Player", Icon = "user" })
}

Window:SelectTab(1)

-- ==========================================
-- MAIN TAB
-- ==========================================
Tabs.Main:Section({ Title = "Core Automation", Icon = "cpu" })

local instantInteractEnabled = false
Tabs.Main:Toggle({
    Title = "Instant Interact (No Hold)", Value = false,
    Callback = function(state)
        instantInteractEnabled = state
        if state then
            task.spawn(function()
                while instantInteractEnabled do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

local autoEatDrink = false
Tabs.Main:Toggle({
    Title = "Auto Eat & Drink (Keeps Bars Full)", Value = false,
    Callback = function(state)
        autoEatDrink = state
        if state then
            task.spawn(function()
                while autoEatDrink do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        local backpack = LocalPlayer.Backpack
                        for _, item in ipairs(backpack:GetChildren()) do
                            if table.find(seaFoodAndWater, item.Name) then
                                item.Parent = char
                                item:Activate()
                                task.wait(0.5)
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

local autoRescue = false
Tabs.Main:Toggle({
    Title = "Auto-Rescue Survivors", Value = false,
    Callback = function(state)
        autoRescue = state
        if state then
            task.spawn(function()
                while autoRescue do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if table.find(seaNPCs, obj.Name) then
                            fireAllPrompts(obj)
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

-- ==========================================
-- AUTO FARM TAB
-- ==========================================
Tabs.AutoFarm:Section({ Title = "Resource Gathering", Icon = "anchor" })

local autoScrapDedicated = false
Tabs.AutoFarm:Toggle({
    Title = "Auto-Scrap (Loot All Floating Scrap)", Value = false,
    Callback = function(state)
        autoScrapDedicated = state
        if state then
            task.spawn(function()
                while autoScrapDedicated do
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name == "Scraps" or obj.Name == "Metal Scrap" or obj.Name == "Scrap" then
                            -- Floating Check
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and not part.Anchored then
                                fireAllPrompts(obj)
                            end
                        end
                    end
                    task.wait(1.5) 
                end
            end)
        end
    end
})

local autoChest = false
Tabs.AutoFarm:Toggle({
    Title = "Auto-Collect Chests & Crates", Value = false,
    Callback = function(state)
        autoChest = state
        if state then
            task.spawn(function()
                while autoChest do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Chest" or obj.Name == "Crate" or obj.Name == "Floating Chest" or obj.Name == "Airdrop Supplies" then
                            fireAllPrompts(obj)
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

local autoHarpoon = false
Tabs.AutoFarm:Toggle({
    Title = "Auto-Harpoon Debris", Value = false,
    Callback = function(state)
        autoHarpoon = state
        if state then
            task.spawn(function()
                while autoHarpoon do
                    local tool = LocalPlayer.Character:FindFirstChild("Harpoon") or LocalPlayer.Backpack:FindFirstChild("Harpoon")
                    if tool then
                        tool.Parent = LocalPlayer.Character
                        local target = getClosest("Wood") or getClosest("Plastic") or getClosest("Scraps")
                        if target then tool:Activate() end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

local autoFish = false
Tabs.AutoFarm:Toggle({
    Title = "Auto-Fish", Value = false,
    Callback = function(state)
        autoFish = state
        if state then
            task.spawn(function()
                while autoFish do
                    local rod = LocalPlayer.Character:FindFirstChild("Fishing Rod") or LocalPlayer.Backpack:FindFirstChild("Fishing Rod")
                    if rod then
                        rod.Parent = LocalPlayer.Character
                        rod:Activate()
                        task.wait(3) 
                        VirtualUser:ClickButton1(Vector2.new(0,0)) 
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

local autoMine = false
Tabs.AutoFarm:Toggle({
    Title = "Auto-Mine Ores (Iron/Titanium)", Value = false,
    Callback = function(state)
        autoMine = state
        if state then
            task.spawn(function()
                while autoMine do
                    local ore = getClosest("Iron Ore") or getClosest("Titanium Ore")
                    if ore then fireAllPrompts(ore) end
                    task.wait(1)
                end
            end)
        end
    end
})

-- ==========================================
-- BASE AUTO TAB
-- ==========================================
Tabs.Base:Section({ Title = "Machinery Management", Icon = "settings" })

local autoPurify = false
Tabs.Base:Toggle({
    Title = "Auto-Refill/Collect Purifiers", Value = false,
    Callback = function(state)
        autoPurify = state
        if state then
            task.spawn(function()
                while autoPurify do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Small Purifier" or obj.Name == "Large Purifier" then
                            fireAllPrompts(obj)
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

local autoCookSmelt = false
Tabs.Base:Toggle({
    Title = "Auto Cook/Smelt (Bonfire/Smelter)", Value = false,
    Callback = function(state)
        autoCookSmelt = state
        if state then
            task.spawn(function()
                while autoCookSmelt do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Bonfire" or obj.Name == "Smelter" or obj.Name == "Cooking Pots" then
                            fireAllPrompts(obj)
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

local autoCrab = false
Tabs.Base:Toggle({
    Title = "Auto-Loot Crab Traps", Value = false,
    Callback = function(state)
        autoCrab = state
        if state then
            task.spawn(function()
                while autoCrab do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Crab Traps" then
                            fireAllPrompts(obj)
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

-- ==========================================
-- COMBAT TAB
-- ==========================================
Tabs.Combat:Section({ Title = "Anti-Hostile Area of Effect", Icon = "shield" })

local killAura = false
local auraRadius = 25

Tabs.Combat:Slider({
    Title = "Aura Radius (Studs)",
    Value = { Min = 10, Max = 100, Default = 25 },
    Callback = function(v) auraRadius = v end
})

Tabs.Combat:Toggle({
    Title = "Enable AoE Kill Aura", Value = false,
    Callback = function(state)
        killAura = state
        if state then
            task.spawn(function()
                while killAura do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local weapon = char:FindFirstChildOfClass("Tool")
                        
                        if weapon and weapon:FindFirstChild("Handle") then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if table.find(seaHostiles, obj.Name) and obj:FindFirstChild("HumanoidRootPart") then
                                    local enemyHrp = obj.HumanoidRootPart
                                    local dist = (hrp.Position - enemyHrp.Position).Magnitude
                                    
                                    if dist <= auraRadius then
                                        weapon:Activate()
                                        pcall(function()
                                            weapon.Handle.CFrame = enemyHrp.CFrame
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1) 
                end
            end)
        end
    end
})

Tabs.Combat:Toggle({
    Title = "God Mode / Anti-Damage", Value = false,
    Callback = function(state)
        task.spawn(function()
            while state and task.wait(1) do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end
        end)
    end
})

-- ==========================================
-- AUTO COLLECT TAB (FLOATING ONLY)
-- ==========================================
local function remoteCollectItems(itemNames, stopFlag)
    for _, itemName in ipairs(itemNames) do
        if stopFlag and not stopFlag() then break end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if stopFlag and not stopFlag() then break end
            
            if string.match(string.lower(obj.Name), string.lower(itemName)) then
                -- Floating Check: Ensure it's not anchored (prevents grabbing base parts)
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part and not part.Anchored then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        local originalLOS = prompt.RequiresLineOfSight
                        local originalDist = prompt.MaxActivationDistance
                        
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = 99999
                        
                        fireproximityprompt(prompt, 1, true)
                        
                        task.delay(0.1, function()
                            prompt.RequiresLineOfSight = originalLOS
                            prompt.MaxActivationDistance = originalDist
                        end)
                        task.wait(0.05) 
                    end
                end
            end
        end
    end
end

Tabs.Bring:Section({ Title = "Remote Collect (Floating Items Only)", Icon = "download" })

local allMatsAndOres = {}
for _, v in ipairs(seaMaterials) do table.insert(allMatsAndOres, v) end
for _, v in ipairs(seaOresAndFuels) do table.insert(allMatsAndOres, v) end

Tabs.Bring:Dropdown({ 
    Title = "Materials & Ores", 
    Values = allMatsAndOres, Multi = true, AllowNone = true, 
    Callback = function(options) selectedMaterialItems = options end 
})

Tabs.Bring:Dropdown({ 
    Title = "Food & Valuables", 
    Values = seaFoodAndWater, Multi = true, AllowNone = true, 
    Callback = function(options) selectedFoodItems = options end 
})

local loopCollect = false
Tabs.Bring:Toggle({
    Title = "Loop Collect Selected Items", Default = false,
    Callback = function(state)
        loopCollect = state
        if state then
            task.spawn(function()
                while loopCollect do
                    local combined = {}
                    for _, v in ipairs(selectedMaterialItems) do table.insert(combined, v) end
                    for _, v in ipairs(selectedFoodItems) do table.insert(combined, v) end
                    
                    if #combined > 0 then 
                        remoteCollectItems(combined, function() return loopCollect end) 
                    end
                    task.wait(1.5)
                end
            end)
        end
    end
})

-- ==========================================
-- ESP TAB
-- ==========================================
local espEnabled = false
Tabs.Esp:Section({ Title = "Visuals", Icon = "eye" })
Tabs.Esp:Dropdown({ Title = "Select ESP Targets", Values = allEspItems, Multi = true, AllowNone = true, Callback = function(options) selectedEspTargets = options end })
Tabs.Esp:Dropdown({ Title = "Hostile ESP", Values = seaHostiles, Multi = true, AllowNone = true, Callback = function(options) selectedHostileEsp = options end })

local function createESP(part, text, color)
    if part:FindFirstChild("BorutoESP") then return end
    local esp = Instance.new("BillboardGui", part)
    esp.Name = "BorutoESP"
    esp.Size = UDim2.new(0, 100, 0, 20)
    esp.StudsOffset = Vector3.new(0, 2.5, 0)
    esp.AlwaysOnTop = true
    esp.MaxDistance = 1500
    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
end

local function clearESP()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "BorutoESP" then v:Destroy() end
    end
end

Tabs.Esp:Toggle({
    Title = "Enable ESP", Value = false,
    Callback = function(state)
        espEnabled = state
        if not state then clearESP() return end
        task.spawn(function()
            while espEnabled do
                clearESP()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if table.find(selectedEspTargets, obj.Name) then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if part then createESP(part, obj.Name, Color3.fromRGB(0, 255, 0)) end
                    end
                    if table.find(selectedHostileEsp, obj.Name) then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if part then createESP(part, obj.Name, Color3.fromRGB(255, 0, 0)) end
                    end
                end
                task.wait(2.5) 
            end
        end)
    end
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
Tabs.Player:Section({ Title = "Movement", Icon = "activity" })
local walkSpeed = 16
Tabs.Player:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 150, Default = 16 }, Callback = function(v) walkSpeed = v end })
Tabs.Player:Toggle({ 
    Title = "Enable WalkSpeed", Value = false, 
    Callback = function(state) 
        task.spawn(function()
            while state and task.wait(0.1) do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = walkSpeed end
            end
            if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end)
    end 
})

WindUI:Notify({Title = "Loaded", Content = "BORUTODEV 100 Days At Sea Maximum Version initialized.", Duration = 4})
