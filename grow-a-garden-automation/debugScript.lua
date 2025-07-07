-- Debug Script for Grow a Garden Automation
-- This script helps identify and fix initialization issues

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

print("🔍 Starting Debug Script...")

-- Check if game is properly loaded
if not game:IsLoaded() then
    print("⏳ Waiting for game to load...")
    game.Loaded:Wait()
end

print("✅ Game loaded")

-- Check essential game services
local function CheckGameServices()
    print("🔍 Checking game services...")
    
    if ReplicatedStorage:FindFirstChild("Modules") then
        print("✅ ReplicatedStorage.Modules found")
        
        if ReplicatedStorage.Modules:FindFirstChild("DataService") then
            print("✅ DataService found")
        else
            warn("❌ DataService not found")
        end
        
        if ReplicatedStorage.Modules:FindFirstChild("Remotes") then
            print("✅ Remotes found")
        else
            warn("❌ Remotes not found")
        end
        
        if ReplicatedStorage.Modules:FindFirstChild("PetServices") then
            print("✅ PetServices found")
        else
            warn("❌ PetServices not found")
        end
    else
        warn("❌ ReplicatedStorage.Modules not found")
    end
    
    if ReplicatedStorage:FindFirstChild("GameEvents") then
        print("✅ GameEvents found")
    else
        warn("❌ GameEvents not found")
    end
    
    if ReplicatedStorage:FindFirstChild("Data") then
        print("✅ Data folder found")
    else
        warn("❌ Data folder not found")
    end
end

-- Test basic automation config initialization
local function TestConfigInitialization()
    print("🔍 Testing configuration initialization...")
    
    local testConfig = {
        -- Master Settings
        Enabled = false,
        WebhookURL = "",
        LogLevel = "INFO",
        
        -- Auto Buy Settings
        AutoBuySeeds = {
            Enabled = false,
            SelectedSeeds = {"Carrot", "Strawberry"},
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
            SelectedSeeds = {"Carrot", "Strawberry"},
            SeedPriority = {"Carrot", "Strawberry"},
            PlantInterval = 2,
            UseWateringCan = true,
            MaxPlantsPerType = 50,
            AutoReplant = true,
            OnlyPlantSelected = true,
        },
        
        AutoCollect = {
            Enabled = false,
            CollectInterval = 1,
            CollectRadius = 100,
            PrioritizeRareItems = true,
            AutoSell = false,
            SellThreshold = 100,
        },
        
        -- Pet Management
        PetManagement = {
            Enabled = false,
            AutoEquip = true,
            AutoUnequip = true,
            AutoFeed = true,
            FeedThreshold = 500,
            AutoHatchEggs = true,
            HatchInterval = 10,
            PreferredPets = {},
            AutoUnequipWeak = true,
            FeedAllPets = true,
            EquipBestPets = true,
            AutoLevelPets = true,
            PetEquipSlots = 3,
        },
        
        -- Events & Quests
        AutoEvents = {
            Enabled = false,
            DailyQuests = true,
            SummerHarvest = true,
            BloodMoon = true,
            BeeSwarm = true,
            NightQuests = true,
            AutoClaim = true,
            AutoParticipate = true,
        },
        
        -- Trading
        AutoTrade = {
            Enabled = false,
            AutoAcceptTrades = false,
            AutoTradeFruits = false,
            AutoTradePets = false,
            MinPetValue = 1000,
            MinFruitValue = 100,
            MaxPetValue = 100000,
            MaxFruitValue = 10000,
            BlacklistedItems = {},
            WhitelistedItems = {},
            AutoOffer = false,
            MaxTradesPerDay = 10,
            TradeOnlyDuplicates = true,
            RequireValueMatch = true,
            -- Target Player Trading
            TargetPlayerEnabled = false,
            TargetPlayerName = "",
            AutoTeleportToTarget = true,
            TradeAllFruitsToTarget = false,
            TradeAllPetsToTarget = false,
            RequestInterval = 30,
            MaxRequestAttempts = 5,
            OnlyTradeWhenTargetOnline = true,
        },
        
        -- Misc Features
        MiscFeatures = {
            AutoOpenPacks = false,
            SelectedPacks = {"Normal Seed Pack", "Exotic Seed Pack"},
            PackOpenInterval = 5,
            AutoUseGear = true,
            AutoExpand = false,
            AutoTeleport = false,
            AutoCraftRecipes = false,
        },
        
        -- Performance
        Performance = {
            ReduceGraphics = false,
            DisableAnimations = false,
            MaxFPS = 60,
            LowMemoryMode = false,
            OptimizeRendering = true,
            DisableParticles = false,
        },
    }
    
    -- Test config access
    local success, error = pcall(function()
        local test1 = testConfig.AutoPlant.Enabled
        local test2 = testConfig.PetManagement.AutoEquip
        local test3 = testConfig.AutoTrade.TargetPlayerName
        local test4 = testConfig.Performance.ReduceGraphics
        
        print("✅ Configuration structure is valid")
        print("  AutoPlant.Enabled:", test1)
        print("  PetManagement.AutoEquip:", test2)
        print("  AutoTrade.TargetPlayerName:", test3)
        print("  Performance.ReduceGraphics:", test4)
    end)
    
    if not success then
        warn("❌ Configuration structure invalid:", error)
        return false
    end
    
    return testConfig
end

-- Test module loading
local function TestModuleLoading()
    print("🔍 Testing module loading...")
    
    local success, error = pcall(function()
        if ReplicatedStorage:FindFirstChild("Modules") then
            local DataService = require(ReplicatedStorage.Modules.DataService)
            print("✅ DataService loaded successfully")
            
            local Remotes = require(ReplicatedStorage.Modules.Remotes)
            print("✅ Remotes loaded successfully")
            
            if ReplicatedStorage.Modules:FindFirstChild("PetServices") then
                local PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService)
                print("✅ PetsService loaded successfully")
            end
        end
        
        if ReplicatedStorage:FindFirstChild("Data") then
            local SeedData = require(ReplicatedStorage.Data.SeedData)
            print("✅ SeedData loaded successfully")
            
            local GearData = require(ReplicatedStorage.Data.GearData)
            print("✅ GearData loaded successfully")
        end
    end)
    
    if not success then
        warn("❌ Module loading failed:", error)
        return false
    end
    
    return true
end

-- Main debug execution
local function RunDebug()
    wait(3) -- Wait for game to stabilize
    
    CheckGameServices()
    
    local configTest = TestConfigInitialization()
    if configTest then
        print("✅ Configuration test passed")
        
        -- Store test config globally
        _G.AutomationSystem = _G.AutomationSystem or {}
        _G.AutomationSystem.Config = configTest
        print("✅ Test configuration stored in _G.AutomationSystem.Config")
    end
    
    if TestModuleLoading() then
        print("✅ Module loading test passed")
    end
    
    print("🎉 Debug completed successfully!")
    print("💡 You can now load the automation system with:")
    print("   loadstring(game:HttpGet('https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/mainLoader.lua'))()")
end

-- Run debug
RunDebug()

return {
    CheckGameServices = CheckGameServices,
    TestConfigInitialization = TestConfigInitialization,
    TestModuleLoading = TestModuleLoading
}