-- Backend Only Automation for Grow a Garden
-- Minimal version without UI that focuses on core functionality

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)

print("🌱 Backend Only Automation starting...")

-- Safe module loading with error handling
local function SafeRequire(module, name)
    local success, result = pcall(function()
        return require(module)
    end)
    
    if success then
        print("✅", name, "loaded successfully")
        return result
    else
        warn("❌", name, "failed to load:", result)
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

-- Simplified configuration
local AutomationConfig = {
    -- Master Settings
    Enabled = false,
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
    
    -- Trading
    AutoTrade = {
        Enabled = false,
        AutoAcceptTrades = false,
        TargetPlayerName = "",
        RequestInterval = 30,
        MaxRequestAttempts = 5,
    },
}

-- Initialize global state
_G.AutomationSystem = _G.AutomationSystem or {}
_G.AutomationSystem.Config = AutomationConfig
_G.AutomationSystem.Functions = {}

print("✅ Configuration initialized")

-- Simple logging without webhooks
local function Log(level, message, data)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = string.format("[%s] %s: %s", timestamp, level, message)
    
    if data then
        logMessage = logMessage .. " | " .. HttpService:JSONEncode(data)
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
    if not DataService then return {} end
    local success, data = pcall(function()
        return DataService:GetData()
    end)
    return success and data or {}
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
    local collectRadius = AutomationConfig.AutoCollect.CollectRadius or 100
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:HasTag("Harvestable") or (obj.Name:find("Plant") and obj:GetAttribute("Grown")) then
            local distance = (obj.Position - playerPos).Magnitude
            if distance <= collectRadius then
                table.insert(plants, obj)
            end
        end
    end
    
    return plants
end

function FarmingManager.PlantSeed(seedType, spot)
    if not AutomationConfig.AutoPlant.OnlyPlantSelected then return false end
    if not table.find(AutomationConfig.AutoPlant.SelectedSeeds or {}, seedType) then return false end
    
    local backpack = DataManager.GetBackpack()
    local seedName = seedType .. " Seed"
    local seedCount = backpack[seedName] or 0
    
    if seedCount <= 0 then
        Log("INFO", "No seeds available", {SeedType = seedType})
        return false
    end
    
    local success, error = pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
            wait(0.5)
            
            -- Try proximity prompt first
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
            if ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("TrowelRemote") then
                ReplicatedStorage.GameEvents.TrowelRemote:FireServer(seedType, spot.Position)
            end
        end
    end)
    
    if success then
        Log("INFO", "Planted seed", {SeedType = seedType})
        return true
    else
        Log("ERROR", "Failed to plant seed", {Error = error})
        return false
    end
end

function FarmingManager.CollectPlants()
    local plants = FarmingManager.GetHarvestablePlants()
    if #plants == 0 then return end
    
    local collected = 0
    
    for _, plant in pairs(plants) do
        local success, error = pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = plant.CFrame + Vector3.new(0, 5, 0)
                wait(0.3)
                
                -- Try proximity prompt
                local proximityPrompt = plant:FindFirstChild("ProximityPrompt") or plant:FindFirstChild("CollectPrompt")
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                    wait(0.5)
                    return
                end
                
                -- Try click detector
                local clickDetector = plant:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    wait(0.5)
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
        else
            Log("ERROR", "Failed to collect plant", {Error = error})
        end
        
        wait(AutomationConfig.AutoCollect.CollectInterval or 1)
    end
    
    if collected > 0 then
        Log("INFO", "Collected plants", {Count = collected})
    end
end

-- Shop Management
local ShopManager = {}

function ShopManager.BuySeeds()
    if not AutomationConfig.AutoBuySeeds.Enabled then return end
    
    local backpack = DataManager.GetBackpack()
    local sheckles = DataManager.GetSheckles()
    
    if sheckles < (AutomationConfig.AutoBuySeeds.KeepMinimum or 100000) then
        Log("WARN", "Not enough money to buy seeds safely")
        return
    end
    
    for _, seedType in pairs(AutomationConfig.AutoBuySeeds.SelectedSeeds or {}) do
        local seedName = seedType .. " Seed"
        local currentStock = backpack[seedName] or 0
        
        if currentStock < (AutomationConfig.AutoBuySeeds.MinStock or 10) then
            local success, error = pcall(function()
                if ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("BuySeedStock") then
                    ReplicatedStorage.GameEvents.BuySeedStock:FireServer(seedType)
                end
            end)
            
            if success then
                Log("INFO", "Purchased seed", {SeedType = seedType})
                wait(1)
            else
                Log("ERROR", "Failed to buy seed", {Error = error})
            end
        end
    end
end

-- Main automation loop
local lastTasks = {
    buySeeds = 0,
    plantSeeds = 0,
    collectPlants = 0,
}

local function MainLoop()
    while true do
        if AutomationConfig.Enabled then
            local currentTime = tick()
            
            -- Shopping
            if currentTime - lastTasks.buySeeds >= (AutomationConfig.AutoBuySeeds.CheckInterval or 30) then
                pcall(ShopManager.BuySeeds)
                lastTasks.buySeeds = currentTime
            end
            
            -- Collecting
            if AutomationConfig.AutoCollect.Enabled and currentTime - lastTasks.collectPlants >= (AutomationConfig.AutoCollect.CollectInterval or 1) then
                pcall(FarmingManager.CollectPlants)
                lastTasks.collectPlants = currentTime
            end
            
            -- Planting
            if AutomationConfig.AutoPlant.Enabled and currentTime - lastTasks.plantSeeds >= (AutomationConfig.AutoPlant.PlantInterval or 2) then
                pcall(function()
                    local spots = FarmingManager.GetPlantableSpots()
                    for _, spot in pairs(spots) do
                        for _, seedType in pairs(AutomationConfig.AutoPlant.SelectedSeeds or {}) do
                            if FarmingManager.PlantSeed(seedType, spot) then
                                break
                            end
                        end
                    end
                end)
                lastTasks.plantSeeds = currentTime
            end
        end
        
        wait(1)
    end
end

-- Chat commands
local function OnChatted(message)
    local command = message:lower()
    
    if command == "/start" then
        AutomationConfig.Enabled = true
        Log("INFO", "Automation started")
    elseif command == "/stop" then
        AutomationConfig.Enabled = false
        Log("INFO", "Automation stopped")
    elseif command == "/collect" then
        FarmingManager.CollectPlants()
    elseif command == "/plant" then
        local spots = FarmingManager.GetPlantableSpots()
        for _, spot in pairs(spots) do
            for _, seedType in pairs(AutomationConfig.AutoPlant.SelectedSeeds or {}) do
                if FarmingManager.PlantSeed(seedType, spot) then
                    break
                end
            end
        end
    elseif command == "/buy" then
        ShopManager.BuySeeds()
    elseif command == "/status" then
        local backpack = DataManager.GetBackpack()
        local sheckles = DataManager.GetSheckles()
        local itemCount = 0
        for _ in pairs(backpack) do
            itemCount = itemCount + 1
        end
        
        Log("INFO", "Status", {
            Enabled = AutomationConfig.Enabled,
            Sheckles = sheckles,
            BackpackItems = itemCount
        })
    elseif command == "/help" then
        print("🌱 Backend Automation Commands:")
        print("  /start - Start automation")
        print("  /stop - Stop automation")
        print("  /collect - Manual collect")
        print("  /plant - Manual plant")
        print("  /buy - Manual buy seeds")
        print("  /status - Show status")
        print("  /help - Show this help")
    end
end

LocalPlayer.Chatted:Connect(OnChatted)

-- Store functions globally
_G.AutomationSystem.Functions = {
    DataManager = DataManager,
    FarmingManager = FarmingManager,
    ShopManager = ShopManager,
    Config = AutomationConfig,
    Log = Log
}

-- Start automation
spawn(MainLoop)

Log("INFO", "Backend Only Automation System loaded successfully!")
print("💬 Use /help for available commands")
print("💬 Use /start to begin automation")

return _G.AutomationSystem