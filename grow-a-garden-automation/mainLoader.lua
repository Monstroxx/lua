-- Final Automation Loader for Grow a Garden
-- ONE FILE SOLUTION - No UI loading issues, no sync problems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

print("🌱 Final Automation Loader starting...")

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)

-- Clear any existing automation
_G.AutomationSystem = nil

-- Safe module loading function
local function SafeRequire(modulePath, moduleName)
    local success, result = pcall(function()
        return require(modulePath)
    end)
    
    if success then
        print("✅ " .. moduleName .. " loaded")
        return result
    else
        warn("❌ " .. moduleName .. " failed:", result)
        return nil
    end
end

-- Import game modules safely
local DataService = SafeRequire(ReplicatedStorage.Modules.DataService, "DataService")
local Remotes = SafeRequire(ReplicatedStorage.Modules.Remotes, "Remotes")
local PetsService = SafeRequire(ReplicatedStorage.Modules.PetServices.PetsService, "PetsService")

-- Data imports
local SeedData = SafeRequire(ReplicatedStorage.Data.SeedData, "SeedData")
local GearData = SafeRequire(ReplicatedStorage.Data.GearData, "GearData")

-- Configuration
local AutomationConfig = {
    -- Master Settings
    Enabled = false,
    WebhookURL = "",
    LogLevel = "INFO",
    
    -- Auto Buy Settings
    AutoBuySeeds = {
        Enabled = false,
        SelectedSeeds = {"Carrot", "Strawberry", "Blueberry"},
        MaxSpend = 1000000,
        KeepMinimum = 100000,
        CheckInterval = 30,
        MinStock = 10,
        BuyUpTo = 50,
    },
    
    AutoBuyGear = {
        Enabled = false,
        SelectedGear = {"Watering Can", "Trowel"},
        MaxSpend = 500000,
        KeepMinimum = 100000,
        CheckInterval = 60,
        MinStock = 5,
        BuyUpTo = 20,
    },
    
    AutoBuyEggs = {
        Enabled = false,
        SelectedEggs = {"Common Egg"},
        MaxSpend = 2000000,
        KeepMinimum = 500000,
        CheckInterval = 45,
        MinStock = 1,
        BuyUpTo = 10,
    },
    
    -- Farming Settings
    AutoPlant = {
        Enabled = false,
        SelectedSeeds = {"Carrot", "Strawberry", "Blueberry"},
        PlantInterval = 2,
        UseWateringCan = true,
        OnlyPlantSelected = true,
    },
    
    AutoCollect = {
        Enabled = false,
        CollectInterval = 1,
        CollectRadius = 100,
        PrioritizeRareItems = true,
    },
    
    -- Pet Management
    PetManagement = {
        Enabled = false,
        AutoEquip = true,
        AutoFeed = true,
        AutoHatchEggs = true,
        PetEquipSlots = 3,
    },
    
    -- Events & Quests
    AutoEvents = {
        Enabled = false,
        DailyQuests = true,
        AutoClaim = true,
    },
    
    -- Trading
    AutoTrade = {
        Enabled = false,
        AutoAcceptTrades = false,
        TargetPlayerName = "",
        RequestInterval = 30,
        MaxRequestAttempts = 5,
    },
    
    -- Performance
    Performance = {
        ReduceGraphics = false,
        DisableAnimations = false,
    },
}

-- Initialize global state
_G.AutomationSystem = {
    Config = AutomationConfig,
    Functions = {},
    Loaded = true
}

print("✅ Configuration initialized")

-- Simple logging
local function Log(level, message, data)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = string.format("[%s] %s: %s", timestamp, level, message)
    
    if data then
        for key, value in pairs(data) do
            logMessage = logMessage .. " | " .. key .. ":" .. tostring(value)
        end
    end
    
    if level == "ERROR" then
        warn(logMessage)
    else
        print(logMessage)
    end
end

-- Data Management
local DataManager = {}

function DataManager.GetPlayerData()
    if not DataService then
        return {}
    end
    
    local success, data = pcall(function()
        return DataService:GetData()
    end)
    
    return (success and data) and data or {}
end

function DataManager.GetBackpack()
    local data = DataManager.GetPlayerData()
    return data.Backpack or {}
end

function DataManager.GetSheckles()
    local data = DataManager.GetPlayerData()
    return data.Sheckles or 0
end

-- Farming System
local FarmingManager = {}

function FarmingManager.GetPlantableSpots()
    local spots = {}
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return spots
    end
    
    local playerPos = character.HumanoidRootPart.Position
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "PlantingSpot" and obj:IsA("Part") then
            local distance = (obj.Position - playerPos).Magnitude
            if distance <= 200 and not obj:FindFirstChild("Plant") then
                table.insert(spots, obj)
            end
        end
    end
    
    return spots
end

function FarmingManager.GetHarvestablePlants()
    local plants = {}
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return plants
    end
    
    local playerPos = character.HumanoidRootPart.Position
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:HasTag("Harvestable") or (obj.Name:find("Plant") and obj:GetAttribute("Grown")) then
            local distance = (obj.Position - playerPos).Magnitude
            if distance <= AutomationConfig.AutoCollect.CollectRadius then
                table.insert(plants, obj)
            end
        end
    end
    
    return plants
end

function FarmingManager.PlantSeed(seedType, spot)
    if not table.find(AutomationConfig.AutoPlant.SelectedSeeds, seedType) then
        return false
    end
    
    local backpack = DataManager.GetBackpack()
    local seedName = seedType .. " Seed"
    if (backpack[seedName] or 0) <= 0 then
        return false
    end
    
    local success = pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
            wait(0.5)
            
            -- Try proximity prompt
            local proximityPrompt = spot:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                fireproximityprompt(proximityPrompt)
                return
            end
            
            -- Try click detector
            local clickDetector = spot:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                return
            end
            
            -- Try remote event
            if ReplicatedStorage:FindFirstChild("GameEvents") then
                local trowelRemote = ReplicatedStorage.GameEvents:FindFirstChild("TrowelRemote")
                if trowelRemote then
                    trowelRemote:FireServer(seedType, spot.Position)
                end
            end
        end
    end)
    
    if success then
        Log("INFO", "Planted seed", {SeedType = seedType})
    end
    
    return success
end

function FarmingManager.CollectPlants()
    local plants = FarmingManager.GetHarvestablePlants()
    if #plants == 0 then return end
    
    local collected = 0
    
    for _, plant in pairs(plants) do
        local success = pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = plant.CFrame + Vector3.new(0, 5, 0)
                wait(0.3)
                
                -- Try proximity prompt
                local proximityPrompt = plant:FindFirstChild("ProximityPrompt") or plant:FindFirstChild("CollectPrompt")
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                    return
                end
                
                -- Try click detector
                local clickDetector = plant:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    return
                end
                
                -- Try remote
                if Remotes and Remotes.Crops and Remotes.Crops.Collect then
                    Remotes.Crops.Collect.send({plant})
                end
            end
        end)
        
        if success then
            collected = collected + 1
        end
        
        wait(AutomationConfig.AutoCollect.CollectInterval)
    end
    
    if collected > 0 then
        Log("INFO", "Collected plants", {Count = collected})
    end
end

-- Shop Management
local ShopManager = {}

function ShopManager.BuySeeds()
    if not AutomationConfig.AutoBuySeeds.Enabled then return end
    
    local sheckles = DataManager.GetSheckles()
    if sheckles < AutomationConfig.AutoBuySeeds.KeepMinimum then
        Log("WARN", "Not enough money for safe seed buying")
        return
    end
    
    local backpack = DataManager.GetBackpack()
    
    for _, seedType in pairs(AutomationConfig.AutoBuySeeds.SelectedSeeds) do
        local seedName = seedType .. " Seed"
        local currentStock = backpack[seedName] or 0
        
        if currentStock < AutomationConfig.AutoBuySeeds.MinStock then
            local success = pcall(function()
                if ReplicatedStorage:FindFirstChild("GameEvents") then
                    local buyRemote = ReplicatedStorage.GameEvents:FindFirstChild("BuySeedStock")
                    if buyRemote then
                        buyRemote:FireServer(seedType)
                    end
                end
            end)
            
            if success then
                Log("INFO", "Bought seed", {SeedType = seedType})
                wait(1)
            end
        end
    end
end

-- Pet Management
local PetManager = {}

function PetManager.EquipBestPets()
    if not AutomationConfig.PetManagement.AutoEquip then return end
    if not PetsService then return end
    
    local success = pcall(function()
        -- This would need specific implementation based on the pet system
        Log("INFO", "Pet management attempted")
    end)
end

-- Main automation loop
local lastTasks = {
    buySeeds = 0,
    plantSeeds = 0,
    collectPlants = 0,
    managePets = 0,
}

local function MainLoop()
    while true do
        if AutomationConfig.Enabled then
            local currentTime = tick()
            
            -- Shopping
            if currentTime - lastTasks.buySeeds >= AutomationConfig.AutoBuySeeds.CheckInterval then
                pcall(ShopManager.BuySeeds)
                lastTasks.buySeeds = currentTime
            end
            
            -- Collecting
            if AutomationConfig.AutoCollect.Enabled and currentTime - lastTasks.collectPlants >= AutomationConfig.AutoCollect.CollectInterval then
                pcall(FarmingManager.CollectPlants)
                lastTasks.collectPlants = currentTime
            end
            
            -- Planting
            if AutomationConfig.AutoPlant.Enabled and currentTime - lastTasks.plantSeeds >= AutomationConfig.AutoPlant.PlantInterval then
                pcall(function()
                    local spots = FarmingManager.GetPlantableSpots()
                    for _, spot in pairs(spots) do
                        for _, seedType in pairs(AutomationConfig.AutoPlant.SelectedSeeds) do
                            if FarmingManager.PlantSeed(seedType, spot) then
                                break
                            end
                        end
                    end
                end)
                lastTasks.plantSeeds = currentTime
            end
            
            -- Pet Management
            if AutomationConfig.PetManagement.Enabled and currentTime - lastTasks.managePets >= 10 then
                pcall(PetManager.EquipBestPets)
                lastTasks.managePets = currentTime
            end
        end
        
        wait(1)
    end
end

-- Chat commands
local function onChatted(message)
    local command = message:lower()
    
    if command == "/start" then
        AutomationConfig.Enabled = true
        Log("INFO", "Automation started")
    elseif command == "/stop" then
        AutomationConfig.Enabled = false
        Log("INFO", "Automation stopped")
    elseif command == "/status" then
        local backpack = DataManager.GetBackpack()
        local sheckles = DataManager.GetSheckles()
        
        print("📊 Automation Status:")
        print("  Enabled:", AutomationConfig.Enabled)
        print("  Sheckles:", sheckles)
        print("  AutoPlant:", AutomationConfig.AutoPlant.Enabled)
        print("  AutoCollect:", AutomationConfig.AutoCollect.Enabled)
        print("  AutoBuySeeds:", AutomationConfig.AutoBuySeeds.Enabled)
        print("  PetManagement:", AutomationConfig.PetManagement.Enabled)
        
        local itemCount = 0
        for _ in pairs(backpack) do
            itemCount = itemCount + 1
        end
        print("  Backpack Items:", itemCount)
        
    elseif command == "/collect" then
        FarmingManager.CollectPlants()
    elseif command == "/plant" then
        local spots = FarmingManager.GetPlantableSpots()
        for _, spot in pairs(spots) do
            for _, seedType in pairs(AutomationConfig.AutoPlant.SelectedSeeds) do
                if FarmingManager.PlantSeed(seedType, spot) then
                    break
                end
            end
        end
    elseif command == "/buy" then
        ShopManager.BuySeeds()
    elseif command == "/enable" then
        local parts = {}
        for part in message:gmatch("%S+") do
            table.insert(parts, part)
        end
        
        if parts[2] then
            local feature = parts[2]:lower()
            if feature == "plant" then
                AutomationConfig.AutoPlant.Enabled = true
                print("✅ Auto planting enabled")
            elseif feature == "collect" then
                AutomationConfig.AutoCollect.Enabled = true
                print("✅ Auto collecting enabled")
            elseif feature == "buy" then
                AutomationConfig.AutoBuySeeds.Enabled = true
                print("✅ Auto buying enabled")
            elseif feature == "pets" then
                AutomationConfig.PetManagement.Enabled = true
                print("✅ Pet management enabled")
            end
        end
    elseif command == "/disable" then
        local parts = {}
        for part in message:gmatch("%S+") do
            table.insert(parts, part)
        end
        
        if parts[2] then
            local feature = parts[2]:lower()
            if feature == "plant" then
                AutomationConfig.AutoPlant.Enabled = false
                print("⏹️ Auto planting disabled")
            elseif feature == "collect" then
                AutomationConfig.AutoCollect.Enabled = false
                print("⏹️ Auto collecting disabled")
            elseif feature == "buy" then
                AutomationConfig.AutoBuySeeds.Enabled = false
                print("⏹️ Auto buying disabled")
            elseif feature == "pets" then
                AutomationConfig.PetManagement.Enabled = false
                print("⏹️ Pet management disabled")
            end
        end
    elseif command == "/help" then
        print("🌱 Final Automation Commands:")
        print("  /start - Start all automation")
        print("  /stop - Stop all automation")
        print("  /status - Show detailed status")
        print("  /collect - Manual collect")
        print("  /plant - Manual plant")
        print("  /buy - Manual buy seeds")
        print("  /enable [feature] - Enable specific feature (plant/collect/buy/pets)")
        print("  /disable [feature] - Disable specific feature")
        print("  /help - Show this help")
    end
end

LocalPlayer.Chatted:Connect(onChatted)

-- Store functions globally
_G.AutomationSystem.Functions = {
    DataManager = DataManager,
    FarmingManager = FarmingManager,
    ShopManager = ShopManager,
    PetManager = PetManager,
    Log = Log
}

-- Start automation loop
spawn(MainLoop)

-- Emergency stop
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        local alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
        
        if ctrl and alt then
            AutomationConfig.Enabled = false
            Log("ERROR", "EMERGENCY STOP ACTIVATED")
        end
    end
end)

Log("INFO", "Final Automation System loaded successfully!")
print("💬 Use /help for available commands")
print("💬 Use /start to begin automation")
print("🆘 Emergency stop: Ctrl+Alt+X")

return _G.AutomationSystem