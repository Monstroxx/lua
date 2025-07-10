-- Complete Automation System for Grow a Garden
-- Backend implementation with all features

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)

-- Safe module loading function
local function SafeRequire(modulePath, moduleName)
    local success, result = pcall(function()
        return require(modulePath)
    end)
    
    if success then
        print("✅ " .. moduleName .. " loaded successfully")
        return result
    else
        warn("❌ " .. moduleName .. " failed to load: " .. tostring(result))
        return nil
    end
end

-- Import game modules safely
local DataService = SafeRequire(ReplicatedStorage.Modules.DataService, "DataService")
local Remotes = SafeRequire(ReplicatedStorage.Modules.Remotes, "Remotes")
local PetsService = SafeRequire(ReplicatedStorage.Modules.PetServices.PetsService, "PetsService")
local CollectController = SafeRequire(ReplicatedStorage.Modules.CollectController, "CollectController")
local MarketController = SafeRequire(ReplicatedStorage.Modules.MarketController, "MarketController")

-- Data imports safely
local SeedData = SafeRequire(ReplicatedStorage.Data.SeedData, "SeedData")
local GearData = SafeRequire(ReplicatedStorage.Data.GearData, "GearData")
local PetList = SafeRequire(ReplicatedStorage.Data.PetRegistry.PetList, "PetList")
local PetEggData = SafeRequire(ReplicatedStorage.Data.PetEggData, "PetEggData")
local SeedPackData = SafeRequire(ReplicatedStorage.Data.SeedPackData, "SeedPackData")

-- Automation Configuration (MUST BE DEFINED FIRST!)
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
        SelectedGear = {"Watering Can", "Trowel", "Basic Sprinkler"},
        MaxSpend = 500000,
        KeepMinimum = 100000,
        CheckInterval = 60,
        MinStock = 5,
        BuyUpTo = 20,
    },
    
    AutoBuyEggs = {
        Enabled = false,
        SelectedEggs = {"Common Egg", "Mythical Egg"},
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
        SeedPriority = {"Carrot", "Strawberry", "Blueberry"},
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
        AutoAcceptGifts = false,
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

-- Initialize global automation state IMMEDIATELY after config definition
_G.AutomationSystem = _G.AutomationSystem or {}
_G.AutomationSystem.Config = AutomationConfig
_G.AutomationSystem.Functions = {}

-- Create config sync system
_G.AutomationSystem.SyncConfig = function(newConfig)
    if newConfig then
        -- Merge new config with existing config
        for key, value in pairs(newConfig) do
            if AutomationConfig[key] then
                if type(value) == "table" and type(AutomationConfig[key]) == "table" then
                    -- Deep merge for nested tables
                    for subKey, subValue in pairs(value) do
                        AutomationConfig[key][subKey] = subValue
                    end
                else
                    AutomationConfig[key] = value
                end
            end
        end
        _G.AutomationSystem.Config = AutomationConfig
        print("🔄 Config synced from UI")
    end
    return AutomationConfig
end

print("✅ AutomationConfig initialized and stored in _G.AutomationSystem.Config")

-- DO NOT LOAD UI HERE - The mainLoader will handle UI loading separately
-- This prevents the circular loading issue
print("📡 Backend ready for UI connection")

-- Webhook System
local WebhookManager = {}
WebhookManager.__index = WebhookManager

function WebhookManager.new(url)
    local self = setmetatable({}, WebhookManager)
    self.url = url
    self.queue = {}
    self.lastSent = 0
    self.rateLimit = 2 -- 2 seconds between messages
    return self
end

function WebhookManager:Log(level, message, data)
    if not AutomationConfig or not AutomationConfig.WebhookURL or AutomationConfig.WebhookURL == "" then return end
    
    local config = AutomationConfig
    if not config.LogLevel then config.LogLevel = "INFO" end
    if config.LogLevel == "ERROR" and level ~= "ERROR" then return end
    if config.LogLevel == "WARN" and level == "INFO" then return end
    
    local embed = {
        title = "🌱 Garden Automation - " .. level,
        description = message,
        color = level == "ERROR" and 16711680 or level == "WARN" and 16776960 or 65280,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        fields = {}
    }
    
    if data then
        for key, value in pairs(data) do
            table.insert(embed.fields, {
                name = key,
                value = tostring(value),
                inline = true
            })
        end
    end
    
    table.insert(self.queue, {
        content = "",
        embeds = {embed}
    })
    
    self:ProcessQueue()
end

function WebhookManager:ProcessQueue()
    if #self.queue == 0 then return end
    if tick() - self.lastSent < self.rateLimit then return end
    
    local message = table.remove(self.queue, 1)
    self.lastSent = tick()
    
    local success, error = pcall(function()
        local jsonData = HttpService:JSONEncode(message)
        HttpService:PostAsync(self.url, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("Webhook failed:", error)
    end
end

local webhook = WebhookManager.new(AutomationConfig.WebhookURL)

-- Performance Optimization
-- delete textures, meshes, and other assets that are not needed
local PerformanceManager = {}

function PerformanceManager.OptimizeGraphics()
    if not AutomationConfig or not AutomationConfig.Performance or not AutomationConfig.Performance.ReduceGraphics then return end
    
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 100
    lighting.ShadowSoftness = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            if AutomationConfig.Performance.DisableParticles then
                obj.Enabled = false
            end
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
        end
    end
end

function PerformanceManager.DisableAnimations()
    if not AutomationConfig or not AutomationConfig.Performance or not AutomationConfig.Performance.DisableAnimations then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Animation") then
            obj.AnimationId = ""
        end
    end
end

-- Data Management
local DataManager = {}

function DataManager.GetPlayerData()
    if not DataService then
        warn("❌ DataService not available")
        return {}
    end
    
    local success, data = pcall(function()
        return DataService:GetData()
    end)
    
    if success and data then
        return data
    else
        warn("❌ Failed to get player data:", data)
        return {}
    end
end

function DataManager.GetBackpack()
    local data = DataManager.GetPlayerData()
    return data.Backpack or {}
end

function DataManager.GetSheckles()
    local data = DataManager.GetPlayerData()
    return data.Sheckles or 0
end

function DataManager.GetPetData()
    local data = DataManager.GetPlayerData()
    return data.PetsData or {}
end

function DataManager.GetEquippedPets()
    local petData = DataManager.GetPetData()
    return petData.EquippedPets or {}
end

function DataManager.GetPlantedObjects()
    local data = DataManager.GetPlayerData()
    return data.PlantedObjects or {}
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
    
    -- Find planting spots in farm
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
            if distance <= (AutomationConfig and AutomationConfig.AutoCollect and AutomationConfig.AutoCollect.CollectRadius or 100) then
                table.insert(plants, obj)
            end
        end
    end
    
    return plants
end

function FarmingManager.PlantSeed(seedType, spot)
    if not AutomationConfig or not AutomationConfig.AutoPlant then
        return false
    end
    
    if not AutomationConfig.AutoPlant.OnlyPlantSelected then
        return false
    end
    
    if not table.find(AutomationConfig.AutoPlant.SelectedSeeds or {}, seedType) then
        return false
    end
    
    local backpack = DataManager.GetBackpack()
    local seedName = seedType .. " Seed"
    local seedCount = backpack[seedName] or 0
    
    if seedCount <= 0 then
        webhook:Log("INFO", "No seeds available", {SeedType = seedType})
        return false
    end
    
    local success, error = pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Move to planting spot
            character.HumanoidRootPart.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
            wait(0.5)
            
            -- Method 1: Try to find and equip the seed first
            local seedTool = character:FindFirstChild(seedName) or LocalPlayer.Backpack:FindFirstChild(seedName)
            if seedTool and seedTool:IsA("Tool") then
                seedTool.Parent = character
                wait(0.2)
                
                -- Click on the planting spot
                local clickDetector = spot:FindFirstChild("ClickDetector") or spot:FindFirstChild("ProximityPrompt")
                if clickDetector then
                    if clickDetector:IsA("ClickDetector") then
                        fireclickdetector(clickDetector)
                    elseif clickDetector:IsA("ProximityPrompt") then
                        fireproximityprompt(clickDetector)
                    end
                end
                
                wait(0.2)
                seedTool.Parent = LocalPlayer.Backpack
            else
                -- Method 2: Use TrowelRemote if seed tool not found
                local TrowelRemote = ReplicatedStorage.GameEvents.TrowelRemote
                if TrowelRemote then
                    TrowelRemote:FireServer(seedType, spot.Position)
                end
            end
        end
    end)
    
    if success then
        webhook:Log("INFO", "Planted seed", {SeedType = seedType, Position = tostring(spot.Position)})
        return true
    else
        webhook:Log("ERROR", "Failed to plant seed", {Error = error})
        return false
    end
end

function FarmingManager.CollectPlants()
    local plants = FarmingManager.GetHarvestablePlants()
    if #plants == 0 then return end
    
    local collected = 0
    
    -- Sort by priority if enabled
    if AutomationConfig and AutomationConfig.AutoCollect and AutomationConfig.AutoCollect.PrioritizeRareItems then
        table.sort(plants, function(a, b)
            return (a:GetAttribute("Rarity") or 0) > (b:GetAttribute("Rarity") or 0)
        end)
    end
    
    for _, plant in pairs(plants) do
        local success, error = pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Move to plant
                character.HumanoidRootPart.CFrame = plant.CFrame + Vector3.new(0, 5, 0)
                wait(0.3)
                
                -- Method 1: Try proximity prompt
                local proximityPrompt = plant:FindFirstChild("ProximityPrompt") or plant:FindFirstChild("CollectPrompt")
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                    wait(0.5)
                else
                    -- Method 2: Try click detector
                    local clickDetector = plant:FindFirstChild("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                        wait(0.5)
                    else
                        -- Method 3: Use ByteNet remote
                        Remotes.Crops.Collect.send({plant})
                    end
                end
            end
        end)
        
        if success then
            collected = collected + 1
        else
            webhook:Log("ERROR", "Failed to collect plant", {Error = error})
        end
        
        wait(AutomationConfig and AutomationConfig.AutoCollect and AutomationConfig.AutoCollect.CollectInterval or 1)
    end
    
    if collected > 0 then
        webhook:Log("INFO", "Collected plants", {Count = collected})
    end
end

-- there is no ui for this feature ad this settings to advanceAutomationUI.lua
function FarmingManager.UseWateringCan()
    if not AutomationConfig or not AutomationConfig.AutoPlant or not AutomationConfig.AutoPlant.UseWateringCan then return end
    
    local backpack = DataManager.GetBackpack()
    local wateringCan = backpack["Watering Can"]
    
    if wateringCan and wateringCan > 0 then
        local plantedObjects = DataManager.GetPlantedObjects()
        for _, plantData in pairs(plantedObjects) do
            local plant = workspace:FindFirstChild(plantData.ObjectId)
            if plant and not plant:GetAttribute("Watered") then
                local success, error = pcall(function()
                    -- Use watering can on plant
                    local character = LocalPlayer.Character
                    if character then
                        local tool = character:FindFirstChild("Watering Can") or LocalPlayer.Backpack:FindFirstChild("Watering Can")
                        if tool then
                            character.HumanoidRootPart.CFrame = plant.CFrame + Vector3.new(0, 5, 0)
                            tool.Parent = character
                            tool:Activate()
                            wait(0.5)
                            tool.Parent = LocalPlayer.Backpack
                        end
                    end
                end)
                
                if not success then
                    webhook:Log("ERROR", "Failed to water plant", {Error = error})
                end
                
                wait(1)
            end
        end
    end
end

-- Shop Management
local ShopManager = {}

-- UI Navigation Functions
function ShopManager.OpenShop()
    local success, error = pcall(function()
        -- Find and click shop button in UI
        local shopButton = PlayerGui:FindFirstChild("ShopButton", true) or PlayerGui:FindFirstChild("Shop", true)
        if shopButton and shopButton:IsA("GuiButton") then
            shopButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        -- Try to find shop NPC and teleport to it
        local shopNPC = workspace:FindFirstChild("ShopNPC") or workspace:FindFirstChild("Shop")
        if shopNPC then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = shopNPC.CFrame + Vector3.new(0, 5, 5)
                wait(1)
                
                -- Try to activate proximity prompt
                local proximityPrompt = shopNPC:FindFirstChild("ProximityPrompt", true)
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                end
            end
        end
    end)
    
    return success
end

function ShopManager.NavigateToSeedShop()
    local success, error = pcall(function()
        -- Look for seed shop tab or button
        local seedShopButton = PlayerGui:FindFirstChild("SeedShop", true) or PlayerGui:FindFirstChild("Seeds", true)
        if seedShopButton and seedShopButton:IsA("GuiButton") then
            seedShopButton.MouseButton1Click:Fire()
            wait(0.5)
        end
    end)
    
    return success
end

function ShopManager.BuySeeds()
    local success, error = pcall(function()
        if not AutomationConfig or not AutomationConfig.AutoBuySeeds or not AutomationConfig.AutoBuySeeds.Enabled then 
            print("❌ BuySeeds: Not enabled or config missing")
            return 
        end
    
    print("🌱 BuySeeds: Starting seed purchase check...")
    
    -- Check if DataManager functions exist
    print("🔍 Debug: DataManager exists:", DataManager ~= nil)
    print("🔍 Debug: DataManager.GetBackpack exists:", DataManager.GetBackpack ~= nil)
    print("🔍 Debug: DataManager.GetSheckles exists:", DataManager.GetSheckles ~= nil)
    
    local backpack, sheckles
    
    -- Safely get backpack
    local success1, result1 = pcall(function()
        return DataManager.GetBackpack()
    end)
    
    if success1 then
        backpack = result1
        print("🔍 Debug: Backpack retrieved successfully")
    else
        print("❌ Debug: Failed to get backpack:", result1)
        return
    end
    
    -- Safely get sheckles
    local success2, result2 = pcall(function()
        return DataManager.GetSheckles()
    end)
    
    if success2 then
        sheckles = result2
        print("💰 Current Sheckles:", sheckles)
    else
        print("❌ Debug: Failed to get sheckles:", result2)
        return
    end
    
    print("🔍 Debug: Backpack data:", backpack ~= nil)
    if backpack then
        print("🔍 Debug: Backpack type:", type(backpack))
    end
    
    print("🔍 Debug: AutoBuySeeds config:", AutomationConfig.AutoBuySeeds)
    print("🔍 Debug: KeepMinimum:", AutomationConfig.AutoBuySeeds.KeepMinimum or 100000)
    print("🔍 Debug: SelectedSeeds:", AutomationConfig.AutoBuySeeds.SelectedSeeds)
    
    if sheckles < (AutomationConfig.AutoBuySeeds.KeepMinimum or 100000) then
        webhook:Log("WARN", "Not enough money to buy seeds safely")
        return
    end
    
    local selectedSeeds = AutomationConfig.AutoBuySeeds.SelectedSeeds or {}
    print("🔍 Debug: Processing seeds:", #selectedSeeds, "seeds")
    
    for _, seedType in pairs(selectedSeeds) do
        print("🔍 Debug: Checking seed type:", seedType)
        -- Use real game SeedData
        print("🔍 Debug: SeedData exists:", SeedData ~= nil)
        local seedInfo = SeedData and SeedData[seedType]
        print("🔍 Debug: SeedInfo for", seedType, ":", seedInfo ~= nil)
        if seedInfo then
            print("🔍 Debug: DisplayInShop:", seedInfo.DisplayInShop)
        end
        
        if not seedInfo or not seedInfo.DisplayInShop then
            webhook:Log("WARN", "Seed not available in shop", {SeedType = seedType})
            continue
        end
        
        local seedName = seedInfo.SeedName
        local currentStock = backpack[seedName] or 0
        
        if currentStock < (AutomationConfig.AutoBuySeeds.MinStock or 10) then
            
            if seedInfo and sheckles >= seedInfo.Price + AutomationConfig.AutoBuySeeds.KeepMinimum then
                local buyAmount = math.min(AutomationConfig.AutoBuySeeds.BuyUpTo - currentStock, 
                                         math.floor((sheckles - AutomationConfig.AutoBuySeeds.KeepMinimum) / seedInfo.Price))
                
                if buyAmount > 0 then
                    for i = 1, buyAmount do
                        local success, error = pcall(function()
                            -- Use GameEvents for in-game currency purchases (much cheaper!)
                            if game.ReplicatedStorage.GameEvents.BuySeedStock then
                                game.ReplicatedStorage.GameEvents.BuySeedStock:FireServer(seedType)
                            else
                                error("GameEvents.BuySeedStock not available")
                            end
                        end)
                        
                        if success then
                            webhook:Log("INFO", "Purchased seed", {SeedType = seedType, Price = seedInfo.Price})
                            sheckles = sheckles - seedInfo.Price
                            wait(1)
                        else
                            webhook:Log("ERROR", "Failed to buy seed", {Error = error})
                            break
                        end
                        
                        if sheckles < seedInfo.Price + AutomationConfig.AutoBuySeeds.KeepMinimum then
                            break
                        end
                    end
                end
            end
        end
    end
    end)
    
    if not success then
        print("❌ BuySeeds ERROR:", error)
        webhook:Log("ERROR", "BuySeeds function failed", {Error = error})
    end
end

-- not working maby check first what gear are in stock
function ShopManager.BuyGear()
    if not AutomationConfig or not AutomationConfig.AutoBuyGear or not AutomationConfig.AutoBuyGear.Enabled then 
        print("❌ BuyGear: Not enabled or config missing")
        return 
    end
    
    print("🔧 BuyGear: Starting gear purchase check...")
    local backpack = DataManager.GetBackpack()
    local sheckles = DataManager.GetSheckles()
    print("💰 Current Sheckles:", sheckles)
    
    if sheckles < AutomationConfig.AutoBuyGear.KeepMinimum then return end
    
    for _, gearType in pairs(AutomationConfig.AutoBuyGear.SelectedGear) do
        local currentStock = backpack[gearType] or 0
        
        if currentStock < AutomationConfig.AutoBuyGear.MinStock then
            -- Find gear info from real game GearData
            local gearInfo = nil
            if GearData and GearData[gearType] then
                local gearData = GearData[gearType]
                gearInfo = {
                    name = gearType,
                    price = gearData.Price,
                    id = gearData.PurchaseID
                }
            end
            
            if gearInfo and sheckles >= gearInfo.price + AutomationConfig.AutoBuyGear.KeepMinimum then
                local buyAmount = math.min(AutomationConfig.AutoBuyGear.BuyUpTo - currentStock,
                                         math.floor((sheckles - AutomationConfig.AutoBuyGear.KeepMinimum) / gearInfo.price))
                
                if buyAmount > 0 then
                    for i = 1, buyAmount do
                        local success, error = pcall(function()
                            -- Use GameEvents for in-game currency purchases (much cheaper!)
                            if game.ReplicatedStorage.GameEvents.BuyGearStock then
                                game.ReplicatedStorage.GameEvents.BuyGearStock:FireServer(gearType)
                            else
                                error("GameEvents.BuyGearStock not available")
                            end
                        end)
                        
                        if success then
                            webhook:Log("INFO", "Purchased gear", {GearType = gearType, Price = gearInfo.price})
                            sheckles = sheckles - gearInfo.price
                            wait(1)
                        else
                            webhook:Log("ERROR", "Failed to buy gear", {Error = error})
                            break
                        end
                        
                        if sheckles < gearInfo.price + AutomationConfig.AutoBuyGear.KeepMinimum then
                            break
                        end
                    end
                end
            end
        end
    end
end

-- not working maby check first what egg are in stock
function ShopManager.BuyEggs()
    if not AutomationConfig or not AutomationConfig.AutoBuyEggs or not AutomationConfig.AutoBuyEggs.Enabled then 
        print("❌ BuyEggs: Not enabled or config missing")
        return 
    end
    
    print("🥚 BuyEggs: Starting egg purchase check...")
    local sheckles = DataManager.GetSheckles()
    print("💰 Current Sheckles:", sheckles)
    
    if sheckles < AutomationConfig.AutoBuyEggs.KeepMinimum then return end
    
    for _, eggType in pairs(AutomationConfig.AutoBuyEggs.SelectedEggs) do
        -- Find egg info from real game PetEggData
        local eggInfo = nil
        if PetEggData and PetEggData[eggType] then
            local eggData = PetEggData[eggType]
            eggInfo = {
                name = eggType,
                price = eggData.Price,
                id = eggData.PurchaseID
            }
        end
        
        if eggInfo and sheckles >= eggInfo.price + AutomationConfig.AutoBuyEggs.KeepMinimum then
            local buyAmount = math.min(AutomationConfig.AutoBuyEggs.BuyUpTo, 
                                     math.floor((sheckles - AutomationConfig.AutoBuyEggs.KeepMinimum) / eggInfo.price))
            
            if buyAmount > 0 then
                for i = 1, buyAmount do
                    local success, error = pcall(function()
                        -- Use GameEvents for in-game currency purchases (much cheaper!)
                        -- Note: BuyPetEgg requires egg index, not name
                        local eggIndex = nil
                        if PetEggData then
                            local index = 1
                            for eggName, _ in pairs(PetEggData) do
                                if eggName == eggType then
                                    eggIndex = index
                                    break
                                end
                                index = index + 1
                            end
                        end
                        
                        if game.ReplicatedStorage.GameEvents.BuyPetEgg and eggIndex then
                            game.ReplicatedStorage.GameEvents.BuyPetEgg:FireServer(eggIndex)
                        else
                            error("GameEvents.BuyPetEgg not available or egg index not found")
                        end
                    end)
                    
                    if success then
                        webhook:Log("INFO", "Purchased egg", {EggType = eggType, Price = eggInfo.price})
                        sheckles = sheckles - eggInfo.price
                        wait(2)
                    else
                        webhook:Log("ERROR", "Failed to buy egg", {Error = error})
                        break
                    end
                    
                    if sheckles < eggInfo.price + AutomationConfig.AutoBuyEggs.KeepMinimum then
                        break
                    end
                end
            end
        end
    end
end

-- Pet Management System
local PetManager = {}

-- UI Navigation for Pet Management
function PetManager.OpenPetUI()
    local success, error = pcall(function()
        -- Look for pet management UI button (arrow on left side)
        local petButton = PlayerGui:FindFirstChild("PetButton", true) or PlayerGui:FindFirstChild("Pets", true)
        if petButton and petButton:IsA("GuiButton") then
            petButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        -- Look for arrow button to expand pet menu
        local arrowButton = PlayerGui:FindFirstChild("Arrow", true) or PlayerGui:FindFirstChild("Expand", true)
        if arrowButton and arrowButton:IsA("GuiButton") then
            arrowButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        -- Try keyboard shortcut if available
        UserInputService:GetService("UserInputService"):GetKeysPressed()
        
        return false
    end)
    
    return success
end

function PetManager.NavigateToPetInventory()
    local success, error = pcall(function()
        local inventoryTab = PlayerGui:FindFirstChild("PetInventory", true) or PlayerGui:FindFirstChild("Inventory", true)
        if inventoryTab and inventoryTab:IsA("GuiButton") then
            inventoryTab.MouseButton1Click:Fire()
            wait(0.5)
        end
    end)
    
    return success
end

function PetManager.EquipBestPets()
    if not AutomationConfig or not AutomationConfig.PetManagement or not AutomationConfig.PetManagement.AutoEquip or not AutomationConfig.PetManagement.EquipBestPets then
        return
    end
    
    local petData = DataManager.GetPetData()
    local inventory = petData.PetInventory and petData.PetInventory.Data or {}
    local equipped = DataManager.GetEquippedPets()
    
    -- Find best pets to equip
    local bestPets = {}
    for petId, pet in pairs(inventory) do
        if pet and PetList[pet.PetType] then
            local rarity = PetList[pet.PetType].Rarity or "Common"
            local level = pet.Level or 1
            local value = (level * 100) + (RarityValues[rarity] or 0)
            
            table.insert(bestPets, {
                id = petId,
                data = pet,
                rarity = rarity,
                level = level,
                value = value
            })
        end
    end
    
    -- Sort by value (level + rarity)
    table.sort(bestPets, function(a, b)
        return a.value > b.value
    end)
    
    -- Equip best pets up to slot limit
    local maxSlots = (AutomationConfig.PetManagement and AutomationConfig.PetManagement.PetEquipSlots) or 3
    for i = 1, math.min(#bestPets, maxSlots) do
        local pet = bestPets[i]
        if not equipped[tostring(i)] or equipped[tostring(i)] ~= pet.id then
            local success, error = pcall(function()
                PetsService:EquipPet(pet.id, i)
            end)
            
            if success then
                webhook:Log("INFO", "Equipped pet", {
                    PetType = pet.data.PetType,
                    Slot = i,
                    Level = pet.level
                })
                wait(0.5)
            else
                webhook:Log("ERROR", "Failed to equip pet", {Error = error})
            end
        end
    end
end

function PetManager.UnequipWeakPets()
    if not AutomationConfig or not AutomationConfig.PetManagement or not AutomationConfig.PetManagement.AutoUnequip or not AutomationConfig.PetManagement.AutoUnequipWeak then
        return
    end
    
    local equipped = DataManager.GetEquippedPets()
    local petData = DataManager.GetPetData()
    local inventory = petData.PetInventory and petData.PetInventory.Data or {}
    
    for slot, petId in pairs(equipped) do
        local pet = inventory[petId]
        if pet and pet.Level and pet.Level < 5 then -- Unequip pets below level 5
            local success, error = pcall(function()
                PetsService:UnequipPet(petId)
            end)
            
            if success then
                webhook:Log("INFO", "Unequipped weak pet", {
                    PetType = pet.PetType,
                    Level = pet.Level
                })
                wait(0.5)
            else
                webhook:Log("ERROR", "Failed to unequip pet", {Error = error})
            end
        end
    end
end

function PetManager.FeedPets()
    if not AutomationConfig or not AutomationConfig.PetManagement or not AutomationConfig.PetManagement.AutoFeed then return end
    
    local petData = DataManager.GetPetData()
    local inventory = petData.PetInventory and petData.PetInventory.Data or {}
    local backpack = DataManager.GetBackpack()
    
    -- Get pets to feed
    local petsToFeed = {}
    if AutomationConfig.PetManagement.FeedAllPets then
        petsToFeed = inventory
    else
        local equipped = DataManager.GetEquippedPets()
        for _, petId in pairs(equipped) do
            if inventory[petId] then
                petsToFeed[petId] = inventory[petId]
            end
        end
    end
    
    for petId, pet in pairs(petsToFeed) do
        if pet.Hunger and pet.Hunger < AutomationConfig.PetManagement.FeedThreshold then
            -- Find suitable food in inventory
            for itemName, amount in pairs(backpack) do
                if amount > 0 and PetManager.IsPetFood(itemName) then
                    local success, error = pcall(function()
                        -- Pet feeding logic would go here
                        -- This depends on the game's pet feeding system
                        local PetFeedingService = ReplicatedStorage:FindFirstChild("PetFeedingService")
                        if PetFeedingService then
                            PetFeedingService:FireServer("FeedPet", petId, itemName)
                        end
                    end)
                    
                    if success then
                        webhook:Log("INFO", "Fed pet", {
                            PetId = petId,
                            Food = itemName
                        })
                        break
                    else
                        webhook:Log("ERROR", "Failed to feed pet", {Error = error})
                    end
                end
            end
        end
    end
end

function PetManager.IsPetFood(itemName)
    -- Check if item is pet food (fruits, etc.)
    local foodKeywords = {"Fruit", "Berry", "Apple", "Carrot", "Tomato", "Banana"}
    for _, keyword in pairs(foodKeywords) do
        if itemName:find(keyword) then
            return true
        end
    end
    return false
end

function PetManager.HatchEggs()
    if not AutomationConfig or not AutomationConfig.PetManagement or not AutomationConfig.PetManagement.AutoHatchEggs then return end
    
    local backpack = DataManager.GetBackpack()
    
    for eggName, amount in pairs(backpack) do
        if amount > 0 and eggName:find("Egg") then
            local success, error = pcall(function()
                -- Egg hatching logic
                local EggHatchingService = ReplicatedStorage:FindFirstChild("EggHatchingService")
                if EggHatchingService then
                    EggHatchingService:FireServer("HatchEgg", eggName)
                end
            end)
            
            if success then
                webhook:Log("INFO", "Hatched egg", {EggType = eggName})
                wait(AutomationConfig.PetManagement.HatchInterval)
            else
                webhook:Log("ERROR", "Failed to hatch egg", {Error = error})
            end
        end
    end
end

-- Event Management
local EventManager = {}

function EventManager.HandleEvents()
    if not AutomationConfig or not AutomationConfig.AutoEvents or not AutomationConfig.AutoEvents.Enabled then return end
    
    if AutomationConfig.AutoEvents.DailyQuests then
        EventManager.ClaimDailyQuests()
    end
    
    if AutomationConfig.AutoEvents.SummerHarvest then
        EventManager.HandleSummerHarvest()
    end
    
    if AutomationConfig.AutoEvents.AutoClaim then
        EventManager.ClaimEventRewards()
    end
end

function EventManager.ClaimDailyQuests()
    local success, error = pcall(function()
        -- Use correct ByteNet remote from game analysis
        Remotes.DailyQuests.Claim.send()
    end)
    
    if success then
        webhook:Log("INFO", "Claimed daily quest reward")
    else
        webhook:Log("ERROR", "Failed to claim daily quest", {Error = error})
    end
end

function EventManager.HandleSummerHarvest()
    local data = DataManager.GetPlayerData()
    if data and data.SummerHarvest then
        local success, error = pcall(function()
            -- Submit plants for summer harvest
            local SummerHarvestService = ReplicatedStorage:FindFirstChild("SummerHarvestRemoteEvent")
            if SummerHarvestService then
                SummerHarvestService:FireServer("SubmitHeldPlant")
            end
        end)
        
        if success then
            webhook:Log("INFO", "Participated in summer harvest")
        else
            webhook:Log("ERROR", "Failed summer harvest", {Error = error})
        end
    end
end

function EventManager.ClaimEventRewards()
    -- Claim various event rewards
    local success, error = pcall(function()
        -- Check for claimable event rewards
        local data = DataManager.GetPlayerData()
        if data and data.Events then
            for eventName, eventData in pairs(data.Events) do
                if eventData.Claimable then
                    local EventService = ReplicatedStorage:FindFirstChild(eventName .. "Service")
                    if EventService then
                        EventService:FireServer("ClaimReward")
                    end
                end
            end
        end
    end)
end

-- where is dino event functions?

-- Pack Management
local PackManager = {}

function PackManager.OpenPacks()
    if not AutomationConfig or not AutomationConfig.MiscFeatures or not AutomationConfig.MiscFeatures.AutoOpenPacks then return end
    
    local backpack = DataManager.GetBackpack()
    
    for _, packType in pairs(AutomationConfig.MiscFeatures.SelectedPacks) do
        local packCount = backpack[packType] or 0
        
        if packCount > 0 then
            local success, error = pcall(function()
                if packType:find("Seed Pack") then
                    Remotes.SeedPack.Open:fire(packType)
                elseif packType:find("Infinite Pack") then
                    Remotes.InfinitePack.Claim:fire()
                end
            end)
            
            if success then
                webhook:Log("INFO", "Opened pack", {PackType = packType})
                wait(AutomationConfig.MiscFeatures.PackOpenInterval)
            else
                webhook:Log("ERROR", "Failed to open pack", {Error = error})
            end
        end
    end
end

-- add auto skip (via ui controller) for pack opening

-- Trading System
local TradingManager = {}
local lastTradeAttempt = 0
local tradeAttemptCount = 0

-- Enhanced Trading Functions
function TradingManager.EquipItemForTrading(itemName, itemType)
    local success, error = pcall(function()
        local character = LocalPlayer.Character
        if not character then return false end
        
        if itemType == "fruit" then
            -- Find fruit in backpack and equip it
            local backpack = DataManager.GetBackpack()
            if backpack[itemName] and backpack[itemName] > 0 then
                -- Look for fruit tool in backpack
                local fruitTool = LocalPlayer.Backpack:FindFirstChild(itemName)
                if fruitTool and fruitTool:IsA("Tool") then
                    fruitTool.Parent = character
                    wait(0.5)
                    return true
                end
            end
        elseif itemType == "pet" then
            -- For pets, we need to equip them first
            local petData = DataManager.GetPetData()
            local inventory = petData.PetInventory and petData.PetInventory.Data or {}
            
            for petId, pet in pairs(inventory) do
                if pet.PetType == itemName then
                    PetsService:EquipPet(petId, 1)
                    wait(1)
                    return true
                end
            end
        end
        
        return false
    end)
    
    return success
end

function TradingManager.FindAndActivateGiftPrompt(targetPlayer)
    local success, error = pcall(function()
        if not targetPlayer or not targetPlayer.Character then return false end
        
        -- Look for gift/trade proximity prompt near target player
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Get close to target player
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(2, 0, 2))
            wait(1)
            
            -- Look for proximity prompts around the target player
            local prompts = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Parent then
                    local distance = (obj.Parent.Position - targetPosition).Magnitude
                    if distance <= 10 then
                        table.insert(prompts, obj)
                    end
                end
            end
            
            -- Try to activate gift/trade prompts
            for _, prompt in pairs(prompts) do
                if prompt.ObjectText:lower():find("gift") or prompt.ObjectText:lower():find("trade") or prompt.ObjectText:lower():find("give") then
                    fireproximityprompt(prompt)
                    wait(2)
                    return true
                end
            end
            
            -- Try to activate any prompt near the player
            for _, prompt in pairs(prompts) do
                fireproximityprompt(prompt)
                wait(2)
                return true
            end
        end
        
        return false
    end)
    
    return success
end

function TradingManager.AcceptIncomingTrade()
    local success, error = pcall(function()
        -- Look for accept button in trade UI
        local acceptButton = PlayerGui:FindFirstChild("Accept", true) or PlayerGui:FindFirstChild("AcceptTrade", true)
        if acceptButton and acceptButton:IsA("GuiButton") and acceptButton.Visible then
            acceptButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        -- Look for trade notification popup
        local tradeNotification = PlayerGui:FindFirstChild("TradeNotification", true) or PlayerGui:FindFirstChild("TradeRequest", true)
        if tradeNotification then
            local acceptBtn = tradeNotification:FindFirstChild("Accept", true)
            if acceptBtn and acceptBtn:IsA("GuiButton") then
                acceptBtn.MouseButton1Click:Fire()
                wait(1)
                return true
            end
        end
        
        return false
    end)
    
    return success
end

function TradingManager.HandleTrades()
    if not AutomationConfig or not AutomationConfig.AutoTrade or not AutomationConfig.AutoTrade.Enabled then return end
    
    -- Auto accept incoming gifts
    if AutomationConfig.AutoTrade.AutoAcceptGifts then
        TradingManager.AutoAcceptGifts()
    end
    
    -- Auto accept incoming trades
    if AutomationConfig.AutoTrade.AutoAcceptTrades then
        TradingManager.AutoAcceptTrades()
    end
    
    -- Send general trade offers
    if AutomationConfig.AutoTrade.AutoOffer then
        TradingManager.SendTradeOffers()
    end
    
    -- Handle target player trading (teleport + equip + gift)
    if AutomationConfig.AutoTrade.TargetPlayerEnabled then
        TradingManager.HandleTargetPlayerTrading()
    end
end

function TradingManager.FindTargetPlayer()
    if not AutomationConfig or not AutomationConfig.AutoTrade then return nil end
    local targetName = AutomationConfig.AutoTrade.TargetPlayerName or ""
    if targetName == "" then return nil end
    
    -- Find target player in current game
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == targetName:lower() or player.DisplayName:lower() == targetName:lower() then
            return player
        end
    end
    
    return nil
end

-- list current player in lobby
-- add function to refresh player list (refresh button needs to add in ui advancedAutomationUI.lua)
function TradingManager.TeleportToPlayer(targetPlayer)
    if not AutomationConfig or not AutomationConfig.AutoTrade or not AutomationConfig.AutoTrade.AutoTeleportToTarget then return false end
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local success, error = pcall(function()
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(5, 0, 5))
    end)
    
    if success then
        webhook:Log("INFO", "Teleported to target player", {TargetPlayer = targetPlayer.Name})
        return true
    else
        webhook:Log("ERROR", "Failed to teleport to player", {Error = error})
        return false
    end
end

function TradingManager.GetTradableItems()
    local backpack = DataManager.GetBackpack()
    local tradableItems = {}
    
    -- Get fruits to trade
    if AutomationConfig and AutomationConfig.AutoTrade and AutomationConfig.AutoTrade.TradeAllFruitsToTarget then
        for itemName, amount in pairs(backpack) do
            if TradingManager.IsFruit(itemName) and amount > 0 then
                table.insert(tradableItems, {
                    name = itemName,
                    amount = amount,
                    type = "fruit"
                })
            end
        end
    end
    
    -- Get pets to trade
    if AutomationConfig and AutomationConfig.AutoTrade and AutomationConfig.AutoTrade.TradeAllPetsToTarget then
        local petData = DataManager.GetPetData()
        local inventory = petData.PetInventory and petData.PetInventory.Data or {}
        
        for petId, pet in pairs(inventory) do
            if pet and not TradingManager.IsPetEquipped(petId) then
                table.insert(tradableItems, {
                    name = pet.PetType,
                    id = petId,
                    amount = 1,
                    type = "pet",
                    level = pet.Level or 1
                })
            end
        end
    end
    
    return tradableItems
end

function TradingManager.IsFruit(itemName)
    local fruitKeywords = {"Fruit", "Berry", "Apple", "Orange", "Banana", "Grape", "Mango", "Kiwi", "Pineapple"}
    for _, keyword in pairs(fruitKeywords) do
        if itemName:find(keyword) then
            return true
        end
    end
    return false
end

function TradingManager.IsPetEquipped(petId)
    local equipped = DataManager.GetEquippedPets()
    for _, equippedId in pairs(equipped) do
        if equippedId == petId then
            return true
        end
    end
    return false
end

function TradingManager.SendTradeRequest(targetPlayer, items)
    local success, error = pcall(function()
        -- Use ByteNet Gift system for trading/gifting
        if Remotes and Remotes.Gift and Remotes.Gift.SendGiftTo then
            -- For each item, send as a gift
            for _, item in pairs(items) do
                if item.type == "fruit" and item.productId then
                    Remotes.Gift.SendGiftTo.send({
                        productId = item.productId,
                        targetUserId = targetPlayer.UserId
                    })
                    wait(1) -- Rate limit
                end
            end
        else
            error("Gift system not available")
        end
    end)
    
    if success then
        webhook:Log("INFO", "Sent gifts to player", {
            TargetPlayer = targetPlayer.Name,
            ItemCount = #items
        })
        return true
    else
        webhook:Log("ERROR", "Failed to send gifts", {Error = error})
        return false
    end
end

-- Auto Accept Gift UI Navigation
function TradingManager.AutoAcceptGifts()
    if not AutomationConfig.AutoTrade.AutoAcceptTrades then return end
    
    local success, error = pcall(function()
        -- Look for gift notification UIs based on real game structure
        local giftNotification = PlayerGui:FindFirstChild("Gift_Notification", true)
        if giftNotification then
            -- Check if the gift notification has the proper structure
            local holder = giftNotification:FindFirstChild("Holder")
            if holder then
                local frame = holder:FindFirstChild("Frame")
                if frame then
                    local acceptButton = frame:FindFirstChild("Accept")
                    if acceptButton and acceptButton:IsA("TextButton") and acceptButton.Visible then
                        -- Click the accept button
                        acceptButton.MouseButton1Click:Fire()
                        webhook:Log("INFO", "Auto-accepted gift via Gift_Notification")
                        wait(1)
                        return true
                    end
                end
            end
        end
        
        -- Look for friend notification UIs
        local friendNotification = PlayerGui:FindFirstChild("Friend_Notification", true)
        if friendNotification then
            local acceptButton = friendNotification:FindFirstChild("Accept", true) or friendNotification:FindFirstChild("AcceptButton", true)
            if acceptButton and acceptButton:IsA("GuiButton") and acceptButton.Visible then
                acceptButton.MouseButton1Click:Fire()
                webhook:Log("INFO", "Auto-accepted friend request")
                wait(1)
                return true
            end
        end
        
        -- Look for trade notification UIs
        local tradeNotification = PlayerGui:FindFirstChild("Trade_Notification", true)
        if tradeNotification then
            local acceptButton = tradeNotification:FindFirstChild("Accept", true) or tradeNotification:FindFirstChild("AcceptButton", true)
            if acceptButton and acceptButton:IsA("GuiButton") and acceptButton.Visible then
                acceptButton.MouseButton1Click:Fire()
                webhook:Log("INFO", "Auto-accepted trade request")
                wait(1)
                return true
            end
        end
        
        -- Look for any accept buttons in specific UI patterns
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Visible and gui.Name == "Accept" then
                local parent = gui.Parent
                if parent and parent.Parent and parent.Parent.Name == "Holder" then
                    -- This matches the Gift_Notification structure
                    gui.MouseButton1Click:Fire()
                    webhook:Log("INFO", "Auto-accepted notification", {ParentName = parent.Parent.Parent.Name})
                    wait(1)
                    return true
                end
            end
        end
        
        -- Fallback: Look for any accept buttons in notification-like UIs
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Visible then
                local text = gui.Text:lower()
                if text:find("accept") or text:find("yes") or text:find("confirm") then
                    local parent = gui.Parent
                    if parent and (parent.Name:lower():find("gift") or parent.Name:lower():find("trade") or parent.Name:lower():find("friend") or parent.Name:lower():find("notification")) then
                        gui.MouseButton1Click:Fire()
                        webhook:Log("INFO", "Auto-accepted UI prompt", {ButtonText = gui.Text, ParentName = parent.Name})
                        wait(1)
                        return true
                    end
                end
            end
        end
    end)
    
    if not success then
        webhook:Log("ERROR", "AutoAcceptGifts failed", {Error = error})
    end
end

-- Equip Item for Trading
function TradingManager.EquipItemForTrading(itemName, itemType)
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character then return false end
        
        if itemType == "fruit" then
            -- Find fruit in backpack and equip it as a tool
            local backpack = DataManager.GetBackpack()
            if backpack[itemName] and backpack[itemName] > 0 then
                -- Look for fruit tool in backpack
                local fruitTool = LocalPlayer.Backpack:FindFirstChild(itemName)
                if fruitTool and fruitTool:IsA("Tool") then
                    fruitTool.Parent = character
                    wait(0.5)
                    return true
                end
                
                -- Alternative: Try to find via tool's actual name pattern
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find(itemName) then
                        tool.Parent = character
                        wait(0.5)
                        return true
                    end
                end
                
                -- Try to equip via inventory UI
                local inventoryUI = PlayerGui:FindFirstChild("InventoryGui", true) or PlayerGui:FindFirstChild("Inventory", true)
                if inventoryUI then
                    local itemButton = inventoryUI:FindFirstChild(itemName, true)
                    if itemButton and itemButton:IsA("GuiButton") then
                        itemButton.MouseButton1Click:Fire()
                        wait(0.5)
                        return true
                    end
                end
            end
        elseif itemType == "pet" then
            -- Equip pet for trading using the real PetsService
            if PetsService then
                local petData = DataManager.GetPetData()
                local inventory = petData.PetInventory and petData.PetInventory.Data or {}
                
                -- Find the pet by name and equip it
                for petId, pet in pairs(inventory) do
                    if pet.PetType == itemName then
                        PetsService:EquipPet(petId, 1) -- Equip to slot 1
                        wait(1)
                        return true
                    end
                end
            end
        end
        return false
    end)
    
    if success and result then
        webhook:Log("INFO", "Equipped item for trading", {Item = itemName, Type = itemType})
        return true
    else
        webhook:Log("ERROR", "Failed to equip item", {Item = itemName, Type = itemType, Error = result})
        return false
    end
end

-- Find and Activate Gift Proximity Prompt
function TradingManager.FindAndActivateGiftPrompt(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
        
        local targetCharacter = targetPlayer.Character
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter:FindFirstChild("Torso") or targetCharacter:FindFirstChild("UpperTorso")
        if not targetHRP then return false end
        
        -- First, make sure we're close enough and have the right item equipped
        local distance = (targetHRP.Position - character.HumanoidRootPart.Position).Magnitude
        if distance > 15 then
            -- Move closer to the target player
            character.HumanoidRootPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
            wait(1)
        end
        
        -- Check if we have a fruit tool equipped (needed for fruit gifting)
        local equippedTool = character:FindFirstChildWhichIsA("Tool")
        if equippedTool and equippedTool:FindFirstChild("Weight") then
            -- We have a fruit tool equipped, now look for proximity prompts
            
            -- Look for proximity prompts on the target player's HumanoidRootPart
            for _, child in pairs(targetHRP:GetChildren()) do
                if child:IsA("ProximityPrompt") and child.Enabled then
                    local actionText = child.ActionText:lower()
                    if actionText:find("gift") or actionText:find("give") or actionText:find("trade") then
                        -- Activate the proximity prompt
                        fireproximityprompt(child)
                        webhook:Log("INFO", "Activated gift prompt", {
                            TargetPlayer = targetPlayer.Name,
                            PromptText = child.ActionText,
                            EquippedTool = equippedTool.Name
                        })
                        return true
                    end
                end
            end
            
            -- If no specific gift prompt found, try any enabled prompt
            for _, child in pairs(targetHRP:GetChildren()) do
                if child:IsA("ProximityPrompt") and child.Enabled then
                    fireproximityprompt(child)
                    webhook:Log("INFO", "Activated proximity prompt", {
                        TargetPlayer = targetPlayer.Name,
                        PromptText = child.ActionText,
                        EquippedTool = equippedTool.Name
                    })
                    return true
                end
            end
        end
        
        -- Also check if we have a pet equipped for pet gifting
        local equippedPet = character:FindFirstChildWhichIsA("Tool")
        if equippedPet and equippedPet:GetAttribute("PET_UUID") then
            -- We have a pet equipped, look for pet gifting prompts
            for _, child in pairs(targetHRP:GetChildren()) do
                if child:IsA("ProximityPrompt") and child.Enabled then
                    local actionText = child.ActionText:lower()
                    if actionText:find("gift") or actionText:find("pet") or actionText:find("give") then
                        fireproximityprompt(child)
                        webhook:Log("INFO", "Activated pet gift prompt", {
                            TargetPlayer = targetPlayer.Name,
                            PromptText = child.ActionText,
                            EquippedPet = equippedPet.Name
                        })
                        return true
                    end
                end
            end
        end
        
        return false
    end)
    
    if success and result then
        return true
    else
        webhook:Log("ERROR", "Failed to activate gift prompt", {Error = result})
        return false
    end
end

function TradingManager.HandleTargetPlayerTrading()
    local currentTime = tick()
    
    -- Check if enough time has passed since last attempt
    if currentTime - lastTradeAttempt < AutomationConfig.AutoTrade.RequestInterval then
        return
    end
    
    -- Check if we've exceeded max attempts
    if tradeAttemptCount >= AutomationConfig.AutoTrade.MaxRequestAttempts then
        webhook:Log("WARN", "Max trade attempts reached for this session")
        return
    end
    
    -- Find target player
    local targetPlayer = TradingManager.FindTargetPlayer()
    if not targetPlayer then
        if AutomationConfig.AutoTrade.OnlyTradeWhenTargetOnline then
            webhook:Log("INFO", "Target player not found or offline", {
                TargetName = AutomationConfig.AutoTrade.TargetPlayerName
            })
            return
        end
    end
    
    -- Get items to trade
    local tradableItems = TradingManager.GetTradableItems()
    if #tradableItems == 0 then
        webhook:Log("INFO", "No items available to trade")
        return
    end
    
    -- Teleport to target player if enabled
    if targetPlayer and AutomationConfig.AutoTrade.AutoTeleportToTarget then
        if not TradingManager.TeleportToPlayer(targetPlayer) then
            return -- Failed to teleport
        end
        wait(2) -- Wait for teleport to complete
    end
    
    -- Execute the complete trading workflow
    if targetPlayer then
        -- Go through each item and try to gift it
        for _, item in pairs(tradableItems) do
            webhook:Log("INFO", "Attempting to gift item", {
                TargetPlayer = targetPlayer.Name,
                ItemName = item.name,
                ItemType = item.type
            })
            
            -- Equip the item for trading
            if TradingManager.EquipItemForTrading(item.name, item.type) then
                wait(1) -- Wait for item to be equipped
                
                -- Try to activate gift prompt
                if TradingManager.FindAndActivateGiftPrompt(targetPlayer) then
                    webhook:Log("INFO", "Successfully gifted item", {
                        TargetPlayer = targetPlayer.Name,
                        ItemName = item.name,
                        ItemType = item.type
                    })
                    
                    wait(3) -- Wait for gift animation/confirmation
                    
                    -- Check if we should continue with more items
                    if not AutomationConfig.AutoTrade.TradeAllFruitsToTarget and item.type == "fruit" then
                        break -- Only trade one fruit
                    end
                    if not AutomationConfig.AutoTrade.TradeAllPetsToTarget and item.type == "pet" then
                        break -- Only trade one pet
                    end
                else
                    webhook:Log("WARN", "Failed to activate gift prompt", {
                        TargetPlayer = targetPlayer.Name,
                        ItemName = item.name
                    })
                end
            else
                webhook:Log("WARN", "Failed to equip item for trading", {
                    TargetPlayer = targetPlayer.Name,
                    ItemName = item.name,
                    ItemType = item.type
                })
            end
            
            wait(1) -- Small delay between items
        end
        
        -- Update tracking
        tradeAttemptCount = tradeAttemptCount + 1
        lastTradeAttempt = currentTime
        
        webhook:Log("INFO", "Target player trading session completed", {
            TargetPlayer = targetPlayer.Name,
            ItemsAttempted = #tradableItems,
            Attempt = tradeAttemptCount
        })
    end
end

function TradingManager.AutoAcceptTrades()
    -- Auto accept incoming trades based on criteria
    local success, error = pcall(function()
        -- Check for incoming trades and evaluate them
        local TradeService = ReplicatedStorage:FindFirstChild("TradeService")
        if TradeService then
            -- This would need to hook into the game's trade acceptance system
            -- Implementation depends on game's specific trading mechanics
        end
    end)
end

function TradingManager.SendTradeOffers()
    -- Send general trade offers to other players
    local success, error = pcall(function()
        -- Find suitable trading partners and send offers
        local tradableItems = TradingManager.GetTradableItems()
        
        if #tradableItems > 0 then
            -- Look for other players to trade with
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Send trade offer based on configured parameters
                    local itemsToOffer = {}
                    for i = 1, math.min(3, #tradableItems) do
                        table.insert(itemsToOffer, tradableItems[i])
                    end
                    
                    if #itemsToOffer > 0 then
                        TradingManager.SendTradeRequest(player, itemsToOffer)
                        break -- Only send one offer at a time
                    end
                end
            end
        end
    end)
end

function TradingManager.ResetTradeAttempts()
    tradeAttemptCount = 0
    lastTradeAttempt = 0
    webhook:Log("INFO", "Trade attempts reset")
end

-- Main Automation Loop
local lastTasks = {
    buySeeds = 0,
    buyGear = 0,
    buyEggs = 0,
    plantSeeds = 0,
    collectPlants = 0,
    managePets = 0,
    handleEvents = 0,
    openPacks = 0,
    handleTrades = 0,
    useWateringCan = 0,
}

local function MainLoop()
    local currentTime = tick()
    
    while true do
        if AutomationConfig and AutomationConfig.Enabled then
            -- Shopping (with intervals) - Check both master and individual enables
            if AutomationConfig.AutoBuySeeds and AutomationConfig.AutoBuySeeds.Enabled and 
               currentTime - lastTasks.buySeeds >= (AutomationConfig.AutoBuySeeds.CheckInterval or 30) then
                print("🛒 Attempting to buy seeds...")
                pcall(ShopManager.BuySeeds)
                lastTasks.buySeeds = currentTime
            end
            
            if AutomationConfig.AutoBuyGear and AutomationConfig.AutoBuyGear.Enabled and
               currentTime - lastTasks.buyGear >= (AutomationConfig.AutoBuyGear.CheckInterval or 60) then
                print("🔧 Attempting to buy gear...")
                pcall(ShopManager.BuyGear)
                lastTasks.buyGear = currentTime
            end
            
            if AutomationConfig.AutoBuyEggs and AutomationConfig.AutoBuyEggs.Enabled and
               currentTime - lastTasks.buyEggs >= (AutomationConfig.AutoBuyEggs.CheckInterval or 45) then
                print("🥚 Attempting to buy eggs...")
                pcall(ShopManager.BuyEggs)
                lastTasks.buyEggs = currentTime
            end
            
            -- Farming (more frequent)
            if AutomationConfig.AutoCollect and AutomationConfig.AutoCollect.Enabled and currentTime - lastTasks.collectPlants >= (AutomationConfig.AutoCollect.CollectInterval or 1) then
                pcall(FarmingManager.CollectPlants)
                lastTasks.collectPlants = currentTime
            end
            
            if AutomationConfig.AutoPlant and AutomationConfig.AutoPlant.Enabled and currentTime - lastTasks.plantSeeds >= (AutomationConfig.AutoPlant.PlantInterval or 2) then
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
            
            if AutomationConfig.AutoPlant and AutomationConfig.AutoPlant.UseWateringCan and currentTime - lastTasks.useWateringCan >= 30 then
                pcall(FarmingManager.UseWateringCan)
                lastTasks.useWateringCan = currentTime
            end
            
            -- Pet Management
            if AutomationConfig.PetManagement and AutomationConfig.PetManagement.Enabled and currentTime - lastTasks.managePets >= 10 then
                pcall(PetManager.EquipBestPets)
                pcall(PetManager.UnequipWeakPets)
                pcall(PetManager.FeedPets)
                pcall(PetManager.HatchEggs)
                lastTasks.managePets = currentTime
            end
            
            -- Events (every 60 seconds)
            if AutomationConfig.AutoEvents and AutomationConfig.AutoEvents.Enabled and currentTime - lastTasks.handleEvents >= 60 then
                pcall(EventManager.HandleEvents)
                lastTasks.handleEvents = currentTime
            end
            
            -- Packs (every 30 seconds)
            if AutomationConfig.MiscFeatures and AutomationConfig.MiscFeatures.AutoOpenPacks and currentTime - lastTasks.openPacks >= 30 then
                pcall(PackManager.OpenPacks)
                lastTasks.openPacks = currentTime
            end
            
            -- Trading (every 120 seconds)
            if AutomationConfig.AutoTrade and AutomationConfig.AutoTrade.Enabled and currentTime - lastTasks.handleTrades >= 120 then
                pcall(TradingManager.HandleTrades)
                lastTasks.handleTrades = currentTime
            end
            
            -- Process webhook queue
            pcall(function() webhook:ProcessQueue() end)
        end
        
        -- Update current time
        currentTime = tick()
        
        -- Main loop delay
        wait(1)
    end
end

-- Rarity Values for pet sorting
local RarityValues = {
    Common = 100,
    Uncommon = 200,
    Rare = 400,
    Legendary = 800,
    Mythical = 1600,
    Divine = 3200,
    Prismatic = 6400,
}

-- Initialize System
local function Initialize()
    -- Ensure AutomationConfig is available
    if not AutomationConfig then
        warn("AutomationConfig not available, initialization delayed")
        return
    end
    
    webhook:Log("INFO", "Complete Automation System initialized")
    
    -- Apply performance optimizations
    PerformanceManager.OptimizeGraphics()
    PerformanceManager.DisableAnimations()
    
    -- Sync webhook URL
    webhook.url = AutomationConfig.WebhookURL or ""
    
    -- Start main loop
    spawn(MainLoop)
    
    print("🌱 Complete Automation System loaded and running!")
end

-- Connect to UI updates
local function SyncWithUI()
    -- This would sync configuration changes from the UI
    -- Implementation depends on how the UI communicates config changes

    -- mb use config file/ read write file
    -- or use RemoteEvents to sync config changes
    -- you decide how to implement this, but it have to work with UI
end

-- Error handling wrapper
local function SafeCall(func, name)
    local success, error = pcall(func)
    if not success then
        webhook:Log("ERROR", "Function failed: " .. name, {Error = error})
        warn("Automation Error in " .. name .. ":", error)
    end
end

-- Wait for everything to load then initialize
wait(3)

-- Ensure AutomationConfig is properly available
if not AutomationConfig then
    warn("Critical Error: AutomationConfig not initialized!")
    return
end

Initialize()

-- Export for UI integration
local AutomationSystemAPI = {
    Config = AutomationConfig,
    Webhook = webhook,
    DataManager = DataManager,
    FarmingManager = FarmingManager,
    ShopManager = ShopManager,
    PetManager = PetManager,
    EventManager = EventManager,
    PackManager = PackManager,
    TradingManager = TradingManager,
    
    -- UI Communication Functions
    UpdateConfig = function(newConfig)
        for key, value in pairs(newConfig) do
            if type(value) == "table" and type(AutomationConfig[key]) == "table" then
                -- Deep merge for nested tables
                for subKey, subValue in pairs(value) do
                    AutomationConfig[key][subKey] = subValue
                end
            else
                AutomationConfig[key] = value
            end
        end
        webhook:Log("INFO", "Configuration updated from UI")
    end,
    
    GetStatus = function()
        return {
            Enabled = AutomationConfig.Enabled,
            Sheckles = DataManager.GetSheckles(),
            Backpack = DataManager.GetBackpack(),
            PetData = DataManager.GetPetData(),
            PlantedObjects = DataManager.GetPlantedObjects()
        }
    end,
    
    ManualTrigger = function(action, ...)
        local args = {...}
        if action == "buySeeds" then
            ShopManager.BuySeeds()
        elseif action == "plantSeeds" then
            local spots = FarmingManager.GetPlantableSpots()
            for _, spot in pairs(spots) do
                for _, seedType in pairs(AutomationConfig.AutoPlant.SelectedSeeds) do
                    if FarmingManager.PlantSeed(seedType, spot) then
                        break
                    end
                end
            end
        elseif action == "collectPlants" then
            FarmingManager.CollectPlants()
        elseif action == "managePets" then
            PetManager.OpenPetUI()
            PetManager.EquipBestPets()
        elseif action == "acceptTrade" then
            TradingManager.AcceptIncomingTrade()
        elseif action == "tradeWithPlayer" then
            local playerName = args[1]
            if playerName then
                local targetPlayer = TradingManager.FindTargetPlayer()
                if targetPlayer then
                    TradingManager.TeleportToPlayer(targetPlayer)
                    TradingManager.HandleTargetPlayerTrading()
                end
            end
        end
    end
}

-- Make system available globally for UI integration
_G.AutomationSystem = AutomationSystemAPI
print("🔗 AutomationSystem exported to _G for UI integration")

-- ========================================
-- ADVANCED UI SYSTEM INTEGRATION
-- ========================================

-- UI Configuration
local UIConfig = {
    Colors = {
        Primary = Color3.fromRGB(120, 119, 255),        -- Bright Purple
        Secondary = Color3.fromRGB(175, 82, 222),       -- Purple-Pink
        Accent = Color3.fromRGB(255, 105, 180),         -- Hot Pink
        Background = Color3.fromRGB(13, 13, 13),        -- Deep Black
        Surface = Color3.fromRGB(28, 28, 30),           -- Dark Grey
        SurfaceLight = Color3.fromRGB(44, 44, 46),      -- Light Grey
        SurfaceHover = Color3.fromRGB(58, 58, 62),      -- Hover Grey
        Text = Color3.fromRGB(255, 255, 255),           -- White
        TextSecondary = Color3.fromRGB(152, 152, 157),  -- Light Grey
        TextDim = Color3.fromRGB(99, 99, 102),          -- Dim Grey
        Success = Color3.fromRGB(52, 199, 89),          -- Green
        Warning = Color3.fromRGB(255, 204, 0),          -- Yellow
        Error = Color3.fromRGB(255, 69, 58),            -- Red
        Border = Color3.fromRGB(56, 56, 58),            -- Border Grey
    },
    Sizes = {
        MainFrame = UDim2.new(0, 900, 0, 600),
        CategoryWidth = 220,
        ContentWidth = 660,
        HeaderHeight = 70,
        CornerRadius = UDim.new(0, 16),
        FloatingButtonSize = 60,
    },
    Fonts = {
        Header = Enum.Font.GothamBold,
        Title = Enum.Font.GothamSemibold,
        Body = Enum.Font.Gotham,
        Button = Enum.Font.GothamMedium,
        Mono = Enum.Font.RobotoMono,
    }
}

-- UI Categories
local Categories = {
    {Name = "Dashboard", Icon = "📊", Color = UIConfig.Colors.Primary},
    {Name = "Auto Buy", Icon = "🛒", Color = UIConfig.Colors.Success},
    {Name = "Farming", Icon = "🌱", Color = UIConfig.Colors.Success},
    {Name = "Pets", Icon = "🐕", Color = UIConfig.Colors.Warning},
    {Name = "Events", Icon = "🎉", Color = UIConfig.Colors.Accent},
    {Name = "Trading", Icon = "🤝", Color = UIConfig.Colors.Secondary},
    {Name = "Misc", Icon = "⚙️", Color = UIConfig.Colors.TextSecondary},
    {Name = "Performance", Icon = "⚡", Color = UIConfig.Colors.Error},
    {Name = "Settings", Icon = "🔧", Color = UIConfig.Colors.TextDim},
}

-- Current state
local CurrentCategory = 1
local UIElements = {}

-- Game Items Database
-- Function to get real game items data
local function GetAvailableSeeds()
    local seeds = {}
    if SeedData then
        for seedName, seedData in pairs(SeedData) do
            if seedData.DisplayInShop then
                table.insert(seeds, {
                    name = seedName,
                    rarity = seedData.SeedRarity,
                    price = seedData.Price,
                    id = seedData.PurchaseID
                })
            end
        end
    end
    -- Sort by price
    table.sort(seeds, function(a, b) return a.price < b.price end)
    return seeds
end

local function GetAvailableGear()
    local gear = {}
    if GearData then
        for gearName, gearData in pairs(GearData) do
            if gearData.DisplayInShop then
                table.insert(gear, {
                    name = gearName,
                    rarity = gearData.GearRarity,
                    price = gearData.Price,
                    id = gearData.PurchaseID
                })
            end
        end
    end
    -- Sort by price
    table.sort(gear, function(a, b) return a.price < b.price end)
    return gear
end

local function GetAvailableEggs()
    local eggs = {}
    if PetEggData then
        for eggName, eggData in pairs(PetEggData) do
            table.insert(eggs, {
                name = eggName,
                rarity = eggData.EggRarity,
                price = eggData.Price,
                id = eggData.PurchaseID
            })
        end
    end
    -- Sort by price
    table.sort(eggs, function(a, b) return a.price < b.price end)
    return eggs
end

-- Game Items using real data
local GameItems = {
    Seeds = GetAvailableSeeds(),
    Gear = GetAvailableGear(),
    Eggs = GetAvailableEggs()
}

-- Rarity Colors
local RarityColors = {
    Common = Color3.fromRGB(155, 155, 155),      -- Grey
    Uncommon = Color3.fromRGB(30, 255, 0),       -- Green
    Rare = Color3.fromRGB(0, 112, 221),          -- Blue
    Legendary = Color3.fromRGB(163, 53, 238),    -- Purple
    Mythical = Color3.fromRGB(255, 128, 0),      -- Orange
    Divine = Color3.fromRGB(255, 215, 0),        -- Gold
    Prismatic = Color3.fromRGB(255, 20, 147),    -- Pink
}

-- Utility Functions
local function FormatNumber(num)
    if num >= 1000000000 then
        return string.format("%.1fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

local function GetRarityColor(rarity)
    return RarityColors[rarity] or UIConfig.Colors.Text
end

-- Create Floating Toggle Button
local function CreateFloatingButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloatingToggle"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 200
    
    -- Main floating button
    local floatingButton = Instance.new("TextButton")
    floatingButton.Name = "FloatingButton"
    floatingButton.Size = UDim2.new(0, UIConfig.Sizes.FloatingButtonSize, 0, UIConfig.Sizes.FloatingButtonSize)
    floatingButton.Position = UDim2.new(1, -80, 0, 100)
    floatingButton.BackgroundColor3 = UIConfig.Colors.Primary
    floatingButton.BorderSizePixel = 0
    floatingButton.Text = ""
    floatingButton.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = floatingButton
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⏸️"
    icon.TextColor3 = UIConfig.Colors.Text
    icon.TextScaled = true
    icon.Font = UIConfig.Fonts.Header
    icon.Parent = floatingButton
    
    -- Status dot
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 15, 0, 15)
    statusDot.Position = UDim2.new(1, -20, 0, 5)
    statusDot.BackgroundColor3 = UIConfig.Colors.Error
    statusDot.BorderSizePixel = 0
    statusDot.Parent = floatingButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 7.5)
    dotCorner.Parent = statusDot
    
    -- Hover effects
    floatingButton.MouseEnter:Connect(function()
        TweenService:Create(floatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)}):Play()
    end)
    
    floatingButton.MouseLeave:Connect(function()
        TweenService:Create(floatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    end)
    
    -- Click handler
    floatingButton.MouseButton1Click:Connect(function()
        ToggleMainUI()
    end)
    
    -- Update status function
    local function updateStatus(enabled)
        statusDot.BackgroundColor3 = enabled and UIConfig.Colors.Success or UIConfig.Colors.Error
        icon.Text = enabled and "⚡" or "⏸️"
    end
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = floatingButton.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            floatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UIElements.FloatingButton = floatingButton
    UIElements.StatusDot = statusDot
    UIElements.UpdateStatus = updateStatus
    
    return screenGui
end

-- Toggle main UI
function ToggleMainUI()
    local mainFrame = UIElements.MainFrame
    local blur = UIElements.BlurBackground
    if not mainFrame or not blur then return end
    
    if mainFrame.Visible then
        -- Hide UI
        blur.Visible = false
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        wait(0.3)
        mainFrame.Visible = false
        mainFrame.Size = UIConfig.Sizes.MainFrame
        mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    else
        -- Show UI
        blur.Visible = true
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UIConfig.Sizes.MainFrame,
            Position = UDim2.new(0.5, -450, 0.5, -300)
        }):Play()
    end
end

-- Create header
function CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, UIConfig.Sizes.HeaderHeight)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = UIConfig.Colors.Surface
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UIConfig.Sizes.CornerRadius
    headerCorner.Parent = header
    
    -- Hide bottom corners
    local headerBg = Instance.new("Frame")
    headerBg.Size = UDim2.new(1, 0, 0, 35)
    headerBg.Position = UDim2.new(0, 0, 1, -35)
    headerBg.BackgroundColor3 = UIConfig.Colors.Surface
    headerBg.BorderSizePixel = 0
    headerBg.Parent = header
    
    -- Logo/Icon
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 50, 0, 50)
    logo.Position = UDim2.new(0, 20, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Text = "🌱"
    logo.TextColor3 = UIConfig.Colors.Primary
    logo.TextScaled = true
    logo.Font = UIConfig.Fonts.Header
    logo.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 350, 0, 35)
    title.Position = UDim2.new(0, 80, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Complete Automation Suite"
    title.TextColor3 = UIConfig.Colors.Text
    title.TextSize = 22
    title.Font = UIConfig.Fonts.Title
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(0, 350, 0, 20)
    subtitle.Position = UDim2.new(0, 80, 0, 40)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Grow a Garden Automation System"
    subtitle.TextColor3 = UIConfig.Colors.TextSecondary
    subtitle.TextSize = 12
    subtitle.Font = UIConfig.Fonts.Body
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    -- Status card
    local statusCard = Instance.new("Frame")
    statusCard.Name = "StatusCard"
    statusCard.Size = UDim2.new(0, 140, 0, 40)
    statusCard.Position = UDim2.new(1, -160, 0, 15)
    statusCard.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    statusCard.BorderSizePixel = 0
    statusCard.Parent = header
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 20)
    statusCorner.Parent = statusCard
    
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(0, 15, 0, 15)
    statusDot.BackgroundColor3 = UIConfig.Colors.Error
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusCard
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 5)
    dotCorner.Parent = statusDot
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -35, 1, 0)
    statusText.Position = UDim2.new(0, 30, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Disabled"
    statusText.TextColor3 = UIConfig.Colors.TextSecondary
    statusText.TextSize = 14
    statusText.Font = UIConfig.Fonts.Body
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusCard
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -55, 0, 17.5)
    closeButton.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = UIConfig.Colors.TextSecondary
    closeButton.TextSize = 16
    closeButton.Font = UIConfig.Fonts.Button
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 17.5)
    closeCorner.Parent = closeButton
    
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Error}):Play()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.Text}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.SurfaceLight}):Play()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.TextSecondary}):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        ToggleMainUI()
    end)
    
    -- Store status elements for updates
    UIElements.MainStatusDot = statusDot
    UIElements.MainStatusText = statusText
end

-- Update Dashboard Stats
local function UpdateDashboardStats()
    -- Update Sheckles
    if UIElements.ShecklesValue then
        local sheckles = DataManager.GetSheckles() or 0
        UIElements.ShecklesValue.Text = FormatNumber(sheckles)
    end
    
    -- Update Plants count
    if UIElements.PlantsValue then
        local plantedObjects = DataManager.GetPlantedObjects() or {}
        local plantCount = 0
        for _ in pairs(plantedObjects) do
            plantCount = plantCount + 1
        end
        UIElements.PlantsValue.Text = FormatNumber(plantCount)
    end
    
    -- Update Pets count
    if UIElements.PetsValue then
        local petData = DataManager.GetPetData() or {}
        local petInventory = petData.PetInventory and petData.PetInventory.Data or {}
        local petCount = 0
        for _ in pairs(petInventory) do
            petCount = petCount + 1
        end
        UIElements.PetsValue.Text = FormatNumber(petCount)
    end
end

-- Update status display
local function UpdateUIStatus()
    if UIElements.UpdateStatus then
        UIElements.UpdateStatus(AutomationConfig.Enabled)
    end
    
    if UIElements.MainStatusDot and UIElements.MainStatusText then
        UIElements.MainStatusDot.BackgroundColor3 = AutomationConfig.Enabled and UIConfig.Colors.Success or UIConfig.Colors.Error
        UIElements.MainStatusText.Text = AutomationConfig.Enabled and "Active" or "Disabled"
        UIElements.MainStatusText.TextColor3 = AutomationConfig.Enabled and UIConfig.Colors.Success or UIConfig.Colors.TextSecondary
    end
    
    -- Update Dashboard stats
    UpdateDashboardStats()
end

-- Current Category State
local CurrentCategory = 1

-- Category buttons storage
UIElements.CategoryButtons = {}

-- Create complete main UI with category navigation
local function CreateMainUI()
    -- Destroy existing UI
    if PlayerGui:FindFirstChild("CompleteAutomationUI") then
        PlayerGui.CompleteAutomationUI:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CompleteAutomationUI"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    
    -- Background blur effect
    local blur = Instance.new("Frame")
    blur.Name = "BlurBackground"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.Position = UDim2.new(0, 0, 0, 0)
    blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blur.BackgroundTransparency = 0.3
    blur.BorderSizePixel = 0
    blur.Visible = false
    blur.Parent = screenGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UIConfig.Sizes.MainFrame
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = UIConfig.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UIConfig.Sizes.CornerRadius
    mainCorner.Parent = mainFrame
    
    -- Header
    CreateHeader(mainFrame)
    
    -- Category Sidebar
    CreateCategorySidebar(mainFrame)
    
    -- Content Area
    CreateContentArea(mainFrame)
    
    -- Store references
    UIElements.ScreenGui = screenGui
    UIElements.MainFrame = mainFrame
    UIElements.BlurBackground = blur
    
    return screenGui
end

-- Initialize UI System
local function InitializeUI()
    -- Create floating button
    CreateFloatingButton()
    
    -- Create main UI
    CreateMainUI()
    
    -- Keyboard shortcut to toggle UI (F4)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F4 then
            ToggleMainUI()
        end
    end)
    
    -- Update UI status periodically
    spawn(function()
        while true do
            UpdateUIStatus()
            wait(2)
        end
    end)
    
    print("✅ Complete UI System initialized")
    print("💡 Press F4 to toggle main UI")
    print("💡 Use floating button to access controls")
end

-- ========================================
-- EXTENDED UI COMPONENTS & HELPERS
-- ========================================

-- Helper Functions for Advanced UI
function CreateScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ContentScroll"
    scroll.Size = UDim2.new(1, -30, 1, -20)
    scroll.Position = UDim2.new(0, 15, 0, 10)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.ScrollBarImageColor3 = UIConfig.Colors.Primary
    scroll.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 20)
    layout.Parent = scroll
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    end)
    
    return scroll
end

function CreateCard(parent, title, description, layoutOrder)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("[^%w]", "")
    card.Size = UDim2.new(1, 0, 0, 100) -- Will be auto-resized based on content
    card.BackgroundColor3 = UIConfig.Colors.Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder
    card.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card
    
    -- Header section
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, description and 60 or 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Parent = card
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -30, 0, 24)
    titleLabel.Position = UDim2.new(0, 20, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = UIConfig.Colors.Text
    titleLabel.TextSize = 18
    titleLabel.Font = UIConfig.Fonts.Title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Description
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -30, 0, 16)
        descLabel.Position = UDim2.new(0, 20, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 12
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = header
    end
    
    -- Content container with automatic layout
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -40, 1, -(description and 80 or 60))
    content.Position = UDim2.new(0, 20, 0, description and 70 or 50)
    content.BackgroundTransparency = 1
    content.Parent = card
    
    -- Layout for content
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content
    
    -- Auto-resize card based on content
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local totalHeight = (description and 80 or 60) + layout.AbsoluteContentSize.Y + 20
        card.Size = UDim2.new(1, 0, 0, totalHeight)
    end)
    
    return card, content
end

function CreateToggle(parent, name, description, config, key, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. name:gsub("[^%w]", "")
    frame.Size = UDim2.new(1, 0, 0, description and 55 or 35)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Toggle switch container
    local switchContainer = Instance.new("Frame")
    switchContainer.Name = "SwitchContainer"
    switchContainer.Size = UDim2.new(0, 50, 0, 25)
    switchContainer.Position = UDim2.new(1, -50, 0, 5)
    switchContainer.BackgroundColor3 = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceHover
    switchContainer.BorderSizePixel = 0
    switchContainer.Parent = frame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 12.5)
    switchCorner.Parent = switchContainer
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = config[key] and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = UIConfig.Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = switchContainer
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 10.5)
    knobCorner.Parent = knob
    
    -- Labels
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -60, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = UIConfig.Colors.Text
    nameLabel.TextSize = 14
    nameLabel.Font = UIConfig.Fonts.Body
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, -60, 0, 25)
        descLabel.Position = UDim2.new(0, 0, 0, 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 11
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = frame
    end
    
    -- Toggle functionality
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        
        -- Sync with global config (handle nested configs)
        if _G.AutomationSystem and _G.AutomationSystem.Config then
            if config == AutomationConfig then
                -- Top-level config
                _G.AutomationSystem.Config[key] = config[key]
            else
                -- Nested config - find parent and sync
                for parentKey, parentValue in pairs(AutomationConfig) do
                    if parentValue == config then
                        if not _G.AutomationSystem.Config[parentKey] then
                            _G.AutomationSystem.Config[parentKey] = {}
                        end
                        _G.AutomationSystem.Config[parentKey][key] = config[key]
                        break
                    end
                end
            end
        end
        
        -- Animate switch
        local targetPos = config[key] and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
        local targetColor = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceHover
        
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(switchContainer, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        -- Log change
        webhook:Log("INFO", "Setting toggled", {
            Setting = name,
            Value = config[key]
        })
        
        -- Debug output
        print("🔄 Toggle:", name, "=", config[key])
    end)
    
    return frame
end

function CreateSlider(parent, name, description, config, key, minValue, maxValue, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. name:gsub("[^%w]", "")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Labels
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = UIConfig.Colors.Text
    nameLabel.TextSize = 14
    nameLabel.Font = UIConfig.Fonts.Body
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = FormatNumber(config[key])
    valueLabel.TextColor3 = UIConfig.Colors.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = UIConfig.Fonts.Mono
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, 0, 0, 14)
        descLabel.Position = UDim2.new(0, 0, 0, 20)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 11
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame
    end
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 1, -10)
    track.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    -- Slider fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((config[key] - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = UIConfig.Colors.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((config[key] - minValue) / (maxValue - minValue), -10, 0, -7)
    knob.BackgroundColor3 = UIConfig.Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 10)
    knobCorner.Parent = knob
    
    -- Slider functionality
    local dragging = false
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minValue + percentage * (maxValue - minValue))
        
        config[key] = value
        
        -- Sync with global config (handle nested configs)
        if _G.AutomationSystem and _G.AutomationSystem.Config then
            if config == AutomationConfig then
                -- Top-level config
                _G.AutomationSystem.Config[key] = value
            else
                -- Nested config - find parent and sync
                for parentKey, parentValue in pairs(AutomationConfig) do
                    if parentValue == config then
                        if not _G.AutomationSystem.Config[parentKey] then
                            _G.AutomationSystem.Config[parentKey] = {}
                        end
                        _G.AutomationSystem.Config[parentKey][key] = value
                        break
                    end
                end
            end
        end
        
        valueLabel.Text = FormatNumber(value)
        
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        knob.Position = UDim2.new(percentage, -10, 0, -7)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

function CreateTextBox(parent, name, description, config, key, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "TextBox_" .. name:gsub("[^%w]", "")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = UIConfig.Colors.Text
    nameLabel.TextSize = 14
    nameLabel.Font = UIConfig.Fonts.Body
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, 0, 0, 14)
        descLabel.Position = UDim2.new(0, 0, 0, 20)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 11
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame
    end
    
    -- Text box
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, 0, 0, 24)
    textBox.Position = UDim2.new(0, 0, 1, -26)
    textBox.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    textBox.BorderSizePixel = 0
    textBox.Text = config[key] or ""
    textBox.PlaceholderText = "Enter " .. name:lower() .. "..."
    textBox.TextColor3 = UIConfig.Colors.Text
    textBox.PlaceholderColor3 = UIConfig.Colors.TextSecondary
    textBox.TextSize = 12
    textBox.Font = UIConfig.Fonts.Body
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 6)
    textBoxCorner.Parent = textBox
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = textBox
    
    textBox.FocusLost:Connect(function()
        config[key] = textBox.Text
        webhook:Log("INFO", "Text setting changed", {
            Setting = name,
            Value = textBox.Text
        })
    end)
    
    return frame
end

function CreateItemButton(parent, item, selectedList, index)
    local isSelected = table.find(selectedList, item.name) ~= nil
    
    local button = Instance.new("TextButton")
    button.Name = "Item_" .. item.name
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = isSelected and UIConfig.Colors.Primary or UIConfig.Colors.Surface
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = index
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Rarity indicator
    local rarityBar = Instance.new("Frame")
    rarityBar.Name = "RarityBar"
    rarityBar.Size = UDim2.new(0, 4, 1, -6)
    rarityBar.Position = UDim2.new(0, 3, 0, 3)
    rarityBar.BackgroundColor3 = GetRarityColor(item.rarity)
    rarityBar.BorderSizePixel = 0
    rarityBar.Parent = button
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = rarityBar
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.6, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 15, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.name
    nameLabel.TextColor3 = isSelected and UIConfig.Colors.Text or UIConfig.Colors.Text
    nameLabel.TextSize = 12
    nameLabel.Font = UIConfig.Fonts.Body
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button
    
    -- Price label
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "PriceLabel"
    priceLabel.Size = UDim2.new(0.35, 0, 0, 14)
    priceLabel.Position = UDim2.new(0.6, 0, 0, 4)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = FormatNumber(item.price) .. " 💰"
    priceLabel.TextColor3 = isSelected and UIConfig.Colors.TextSecondary or UIConfig.Colors.TextSecondary
    priceLabel.TextSize = 10
    priceLabel.Font = UIConfig.Fonts.Mono
    priceLabel.TextXAlignment = Enum.TextXAlignment.Right
    priceLabel.Parent = button
    
    -- Rarity label
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "RarityLabel"
    rarityLabel.Size = UDim2.new(0.6, 0, 0, 14)
    rarityLabel.Position = UDim2.new(0, 15, 0, 22)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = item.rarity
    rarityLabel.TextColor3 = GetRarityColor(item.rarity)
    rarityLabel.TextSize = 10
    rarityLabel.Font = UIConfig.Fonts.Body
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = button
    
    -- Selection indicator
    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(0, 16, 0, 16)
    checkmark.Position = UDim2.new(1, -20, 0, 12)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = isSelected and "✓" or ""
    checkmark.TextColor3 = UIConfig.Colors.Text
    checkmark.TextSize = 12
    checkmark.Font = UIConfig.Fonts.Body
    checkmark.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        if not isSelected then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.SurfaceHover}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not isSelected then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Surface}):Play()
        end
    end)
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        local currentIndex = table.find(selectedList, item.name)
        
        if currentIndex then
            -- Remove from selection
            table.remove(selectedList, currentIndex)
            isSelected = false
            checkmark.Text = ""
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Surface}):Play()
        else
            -- Add to selection
            table.insert(selectedList, item.name)
            isSelected = true
            checkmark.Text = "✓"
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Primary}):Play()
        end
        
        webhook:Log("INFO", "Item selection changed", {
            Item = item.name,
            Selected = isSelected
        })
    end)
end

function CreateItemSelector(parent, title, description, items, config, key, layoutOrder)
    local card, content = CreateCard(parent, title, description, layoutOrder)
    
    -- Content area for scrollable items
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ItemSelectorContent"
    contentFrame.Size = UDim2.new(1, 0, 0, 300) -- Fixed height for scrollable content
    contentFrame.BackgroundTransparency = 1
    contentFrame.LayoutOrder = layoutOrder
    contentFrame.Parent = content
    
    -- Scroll frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ItemScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = UIConfig.Colors.Primary
    scrollFrame.Parent = contentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame
    
    -- Create item buttons
    for i, item in ipairs(items) do
        CreateItemButton(scrollFrame, item, config[key], i)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    return card
end

-- ========================================
-- CATEGORY NAVIGATION & CONTENT SECTIONS
-- ========================================

-- Create category sidebar
function CreateCategorySidebar(parent)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "CategorySidebar"
    sidebar.Size = UDim2.new(0, UIConfig.Sizes.CategoryWidth, 1, -UIConfig.Sizes.HeaderHeight)
    sidebar.Position = UDim2.new(0, 0, 0, UIConfig.Sizes.HeaderHeight)
    sidebar.BackgroundColor3 = UIConfig.Colors.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = parent
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "CategoryScroll"
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = UIConfig.Colors.Primary
    scrollFrame.Parent = sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame
    
    -- Create category buttons
    for i, category in ipairs(Categories) do
        CreateCategoryButton(scrollFrame, category, i)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
end

-- Create category button
function CreateCategoryButton(parent, category, index)
    local button = Instance.new("TextButton")
    button.Name = "CategoryButton_" .. index
    button.Size = UDim2.new(1, 0, 0, 70)
    button.BackgroundColor3 = index == CurrentCategory and UIConfig.Colors.Primary or Color3.fromRGB(0, 0, 0, 0)
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = index
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    -- Icon background
    local iconBg = Instance.new("Frame")
    iconBg.Name = "IconBg"
    iconBg.Size = UDim2.new(0, 35, 0, 35)
    iconBg.Position = UDim2.new(0, 15, 0, 8)
    iconBg.BackgroundColor3 = index == CurrentCategory and UIConfig.Colors.Text or category.Color
    iconBg.BorderSizePixel = 0
    iconBg.Parent = button
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = iconBg
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = category.Icon
    icon.TextColor3 = index == CurrentCategory and category.Color or UIConfig.Colors.Text
    icon.TextScaled = true
    icon.Font = UIConfig.Fonts.Header
    icon.Parent = iconBg
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -65, 0, 20)
    label.Position = UDim2.new(0, 60, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = category.Name
    label.TextColor3 = index == CurrentCategory and UIConfig.Colors.Text or UIConfig.Colors.TextSecondary
    label.TextSize = 14
    label.Font = UIConfig.Fonts.Title
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Name = "Desc"
    desc.Size = UDim2.new(1, -65, 0, 15)
    desc.Position = UDim2.new(0, 60, 0, 32)
    desc.BackgroundTransparency = 1
    desc.Text = GetCategoryDescription(category.Name)
    desc.TextColor3 = index == CurrentCategory and UIConfig.Colors.TextSecondary or UIConfig.Colors.TextDim
    desc.TextSize = 10
    desc.Font = UIConfig.Fonts.Body
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = button
    
    -- Store button elements
    UIElements.CategoryButtons[index] = {
        Button = button,
        IconBg = iconBg,
        Icon = icon,
        Label = label,
        Desc = desc
    }
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        SelectCategory(index)
    end)
    
    return {
        Button = button,
        IconBg = iconBg,
        Icon = icon,
        Label = label,
        Desc = desc
    }
end

function GetCategoryDescription(categoryName)
    local descriptions = {
        Dashboard = "Overview & Stats",
        ["Auto Buy"] = "Purchase automation",
        Farming = "Plant & harvest",
        Pets = "Pet management",
        Events = "Quest automation",
        Trading = "Trade system",
        Misc = "Extra features",
        Performance = "Optimization",
        Settings = "Configuration"
    }
    return descriptions[categoryName] or "Settings"
end

-- Select category
function SelectCategory(index)
    if index == CurrentCategory then return end
    
    -- Update previous category button
    local prevButton = UIElements.CategoryButtons[CurrentCategory]
    if prevButton then
        TweenService:Create(prevButton.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)}):Play()
        TweenService:Create(prevButton.IconBg, TweenInfo.new(0.2), {BackgroundColor3 = Categories[CurrentCategory].Color}):Play()
        TweenService:Create(prevButton.Icon, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.Text}):Play()
        TweenService:Create(prevButton.Label, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.TextSecondary}):Play()
        TweenService:Create(prevButton.Desc, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.TextDim}):Play()
    end
    
    -- Update new category button
    local newButton = UIElements.CategoryButtons[index]
    if newButton then
        TweenService:Create(newButton.Button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Primary}):Play()
        TweenService:Create(newButton.IconBg, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Text}):Play()
        TweenService:Create(newButton.Icon, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.Primary}):Play()
        TweenService:Create(newButton.Label, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.Text}):Play()
        TweenService:Create(newButton.Desc, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.TextSecondary}):Play()
    end
    
    CurrentCategory = index
    
    -- Update content area
    UpdateContentArea()
end

-- Create content area
function CreateContentArea(parent)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0, UIConfig.Sizes.ContentWidth, 1, -UIConfig.Sizes.HeaderHeight)
    contentArea.Position = UDim2.new(0, UIConfig.Sizes.CategoryWidth, 0, UIConfig.Sizes.HeaderHeight)
    contentArea.BackgroundColor3 = UIConfig.Colors.Background
    contentArea.BorderSizePixel = 0
    contentArea.Parent = parent
    
    -- Separator line
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(0, 2, 1, 0)
    separator.Position = UDim2.new(0, 0, 0, 0)
    separator.BackgroundColor3 = UIConfig.Colors.Border
    separator.BorderSizePixel = 0
    separator.Parent = contentArea
    
    UIElements.ContentArea = contentArea
    
    -- Load initial content
    UpdateContentArea()
end

-- Update content area
function UpdateContentArea()
    local contentArea = UIElements.ContentArea
    if not contentArea then return end
    
    -- Clear existing content
    for _, child in ipairs(contentArea:GetChildren()) do
        if child.Name ~= "Separator" then
            child:Destroy()
        end
    end
    
    -- Create new content based on category
    local categoryName = Categories[CurrentCategory].Name
    
    if categoryName == "Dashboard" then
        CreateDashboard(contentArea)
    elseif categoryName == "Auto Buy" then
        CreateAutoBuySection(contentArea)
    elseif categoryName == "Farming" then
        CreateFarmingSection(contentArea)
    elseif categoryName == "Pets" then
        CreatePetSection(contentArea)
    elseif categoryName == "Events" then
        CreateEventsSection(contentArea)
    elseif categoryName == "Trading" then
        CreateTradingSection(contentArea)
    elseif categoryName == "Misc" then
        CreateMiscSection(contentArea)
    elseif categoryName == "Performance" then
        CreatePerformanceSection(contentArea)
    elseif categoryName == "Settings" then
        CreateSettingsSection(contentArea)
    end
end

-- Create Dashboard
function CreateDashboard(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Status Overview Card
    local statusCard, statusContent = CreateCard(scroll, "🚀 System Status", "Current automation status and overview", 1)
    
    -- Master toggle
    CreateToggle(statusContent, "Master Automation", "Enable/disable all automation features", AutomationConfig, "Enabled", 1)
    
    -- Stats display
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, 0, 0, 60)
    statsFrame.BackgroundTransparency = 1
    statsFrame.LayoutOrder = 2
    statsFrame.Parent = statusContent
    
    local statsLayout = Instance.new("UIGridLayout")
    statsLayout.CellSize = UDim2.new(0.33, -10, 1, 0)
    statsLayout.CellPadding = UDim2.new(0, 15, 0, 0)
    statsLayout.Parent = statsFrame
    
    -- Create stat items
    local stats = {
        {name = "Sheckles", value = "0", icon = "💰", key = "ShecklesValue"},
        {name = "Plants", value = "0", icon = "🌱", key = "PlantsValue"},
        {name = "Pets", value = "0", icon = "🐕", key = "PetsValue"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Name = "Stat" .. i
        statFrame.BackgroundColor3 = UIConfig.Colors.SurfaceLight
        statFrame.BorderSizePixel = 0
        statFrame.Parent = statsFrame
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = UDim.new(0, 8)
        statCorner.Parent = statFrame
        
        local statIcon = Instance.new("TextLabel")
        statIcon.Size = UDim2.new(0, 30, 0, 30)
        statIcon.Position = UDim2.new(0, 10, 0, 5)
        statIcon.BackgroundTransparency = 1
        statIcon.Text = stat.icon
        statIcon.TextScaled = true
        statIcon.Font = UIConfig.Fonts.Header
        statIcon.Parent = statFrame
        
        local statName = Instance.new("TextLabel")
        statName.Size = UDim2.new(1, -50, 0, 15)
        statName.Position = UDim2.new(0, 45, 0, 5)
        statName.BackgroundTransparency = 1
        statName.Text = stat.name
        statName.TextColor3 = UIConfig.Colors.TextSecondary
        statName.TextSize = 10
        statName.Font = UIConfig.Fonts.Body
        statName.TextXAlignment = Enum.TextXAlignment.Left
        statName.Parent = statFrame
        
        local statValue = Instance.new("TextLabel")
        statValue.Size = UDim2.new(1, -50, 0, 20)
        statValue.Position = UDim2.new(0, 45, 0, 20)
        statValue.BackgroundTransparency = 1
        statValue.Text = FormatNumber(tonumber(stat.value))
        statValue.TextColor3 = UIConfig.Colors.Text
        statValue.TextSize = 14
        statValue.Font = UIConfig.Fonts.Mono
        statValue.TextXAlignment = Enum.TextXAlignment.Left
        statValue.Parent = statFrame
        
        -- Store reference for updates
        UIElements[stat.key] = statValue
    end
    
    -- Quick Actions Card
    local actionsCard, actionsContent = CreateCard(scroll, "⚡ Quick Actions", "Manual controls for immediate actions", 2)
    
    local actionsFrame = Instance.new("Frame")
    actionsFrame.Name = "ActionsFrame"
    actionsFrame.Size = UDim2.new(1, 0, 0, 60)
    actionsFrame.LayoutOrder = 1
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.Parent = actionsContent
    
    local actionsLayout = Instance.new("UIGridLayout")
    actionsLayout.CellSize = UDim2.new(0.25, -10, 1, 0)
    actionsLayout.CellPadding = UDim2.new(0, 10, 0, 0)
    actionsLayout.Parent = actionsFrame
    
    local quickActions = {
        {name = "🌱 Plant", action = "plantSeeds"},
        {name = "🌾 Collect", action = "collectPlants"},
        {name = "🛒 Buy", action = "buySeeds"},
        {name = "🐕 Pets", action = "managePets"}
    }
    
    for i, action in ipairs(quickActions) do
        local actionButton = Instance.new("TextButton")
        actionButton.Name = "Action" .. i
        actionButton.BackgroundColor3 = UIConfig.Colors.Primary
        actionButton.BorderSizePixel = 0
        actionButton.Text = action.name
        actionButton.TextColor3 = UIConfig.Colors.Text
        actionButton.TextSize = 12
        actionButton.Font = UIConfig.Fonts.Button
        actionButton.Parent = actionsFrame
        
        local actionCorner = Instance.new("UICorner")
        actionCorner.CornerRadius = UDim.new(0, 8)
        actionCorner.Parent = actionButton
        
        actionButton.MouseButton1Click:Connect(function()
            AutomationSystemAPI.ManualTrigger(action.action)
            
            -- Visual feedback
            actionButton.BackgroundColor3 = UIConfig.Colors.Success
            wait(0.2)
            actionButton.BackgroundColor3 = UIConfig.Colors.Primary
        end)
    end
end

-- Create Auto Buy Section
function CreateAutoBuySection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Auto Buy Seeds Card
    local seedsCard, seedsContent = CreateCard(scroll, "🌱 Auto Buy Seeds", "Automatically purchase seeds when stock is low", 1)
    
    CreateToggle(seedsContent, "Enable Auto Buy Seeds", "Automatically purchase selected seeds", AutomationConfig.AutoBuySeeds, "Enabled", 1)
    CreateSlider(seedsContent, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuySeeds, "MaxSpend", 0, 50000000, 2)
    CreateSlider(seedsContent, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuySeeds, "KeepMinimum", 0, 10000000, 3)
    CreateSlider(seedsContent, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuySeeds, "MinStock", 1, 100, 4)
    CreateSlider(seedsContent, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuySeeds, "BuyUpTo", 1, 200, 5)
    
    -- Seed selector
    CreateItemSelector(seedsContent, "Selected Seeds", "Choose which seeds to buy", GameItems.Seeds, AutomationConfig.AutoBuySeeds, "SelectedSeeds", 6)
    
    -- Auto Buy Gear Card
    local gearCard, gearContent = CreateCard(scroll, "⚒️ Auto Buy Gear", "Automatically purchase tools and gear", 2)
    
    CreateToggle(gearContent, "Enable Auto Buy Gear", "Automatically purchase selected gear", AutomationConfig.AutoBuyGear, "Enabled", 1)
    CreateSlider(gearContent, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuyGear, "MaxSpend", 0, 20000000, 2)
    CreateSlider(gearContent, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuyGear, "KeepMinimum", 0, 5000000, 3)
    CreateSlider(gearContent, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuyGear, "MinStock", 1, 50, 4)
    CreateSlider(gearContent, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuyGear, "BuyUpTo", 1, 100, 5)
    
    -- Gear selector
    CreateItemSelector(gearContent, "Selected Gear", "Choose which gear to buy", GameItems.Gear, AutomationConfig.AutoBuyGear, "SelectedGear", 6)
    
    -- Auto Buy Eggs Card
    local eggsCard, eggsContent = CreateCard(scroll, "🥚 Auto Buy Eggs", "Automatically purchase pet eggs", 3)
    
    CreateToggle(eggsContent, "Enable Auto Buy Eggs", "Automatically purchase selected eggs", AutomationConfig.AutoBuyEggs, "Enabled", 1)
    CreateSlider(eggsContent, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuyEggs, "MaxSpend", 0, 100000000, 2)
    CreateSlider(eggsContent, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuyEggs, "KeepMinimum", 0, 20000000, 3)
    CreateSlider(eggsContent, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuyEggs, "MinStock", 1, 20, 4)
    CreateSlider(eggsContent, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuyEggs, "BuyUpTo", 1, 50, 5)
    
    -- Eggs selector
    CreateItemSelector(eggsContent, "Selected Eggs", "Choose which eggs to buy", GameItems.Eggs, AutomationConfig.AutoBuyEggs, "SelectedEggs", 6)
end

-- Create Farming Section
function CreateFarmingSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Auto Plant Card
    local plantCard, plantContent = CreateCard(scroll, "🌱 Auto Plant", "Automatically plant seeds in available spots", 1)
    
    CreateToggle(plantContent, "Enable Auto Plant", "Automatically plant selected seeds", AutomationConfig.AutoPlant, "Enabled", 1)
    CreateToggle(plantContent, "Use Watering Can", "Use watering can after planting", AutomationConfig.AutoPlant, "UseWateringCan", 2)
    CreateToggle(plantContent, "Only Plant Selected", "Only plant seeds from selected list", AutomationConfig.AutoPlant, "OnlyPlantSelected", 3)
    CreateSlider(plantContent, "Plant Interval", "Seconds between planting", AutomationConfig.AutoPlant, "PlantInterval", 1, 10, 4)
    CreateSlider(plantContent, "Max Plants Per Type", "Maximum plants of each type", AutomationConfig.AutoPlant, "MaxPlantsPerType", 1, 100, 5)
    
    -- Seed selector for planting
    CreateItemSelector(plantContent, "Seeds to Plant", "Choose which seeds to plant", GameItems.Seeds, AutomationConfig.AutoPlant, "SelectedSeeds", 6)
    
    -- Auto Collect Card
    local collectCard, collectContent = CreateCard(scroll, "🌾 Auto Collect", "Automatically collect grown plants", 2)
    
    CreateToggle(collectContent, "Enable Auto Collect", "Automatically collect grown plants", AutomationConfig.AutoCollect, "Enabled", 1)
    CreateToggle(collectContent, "Prioritize Rare Items", "Collect rare items first", AutomationConfig.AutoCollect, "PrioritizeRareItems", 2)
    CreateSlider(collectContent, "Collect Interval", "Seconds between collections", AutomationConfig.AutoCollect, "CollectInterval", 0.5, 5, 3)
    CreateSlider(collectContent, "Collect Radius", "Collection radius in studs", AutomationConfig.AutoCollect, "CollectRadius", 50, 500, 4)
end

-- Create Pet Section
function CreatePetSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Pet Management Card
    local petCard, petContent = CreateCard(scroll, "🐕 Pet Management", "Automatically manage your pets", 1)
    
    CreateToggle(petContent, "Enable Pet Management", "Automatically manage pets", AutomationConfig.PetManagement, "Enabled", 1)
    CreateToggle(petContent, "Auto Equip Best", "Automatically equip best pets", AutomationConfig.PetManagement, "EquipBestPets", 2)
    CreateToggle(petContent, "Auto Feed", "Automatically feed pets", AutomationConfig.PetManagement, "AutoFeed", 3)
    CreateToggle(petContent, "Auto Hatch Eggs", "Automatically hatch eggs", AutomationConfig.PetManagement, "AutoHatchEggs", 4)
    CreateToggle(petContent, "Feed All Pets", "Feed all pets or only equipped", AutomationConfig.PetManagement, "FeedAllPets", 5)
    CreateSlider(petContent, "Pet Equip Slots", "Number of pets to equip", AutomationConfig.PetManagement, "PetEquipSlots", 1, 10, 6)
    CreateSlider(petContent, "Feed Threshold", "Feed pets below this hunger level", AutomationConfig.PetManagement, "FeedThreshold", 0, 1000, 7)
end

-- Create Events Section
function CreateEventsSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Events Card
    local eventsCard, eventsContent = CreateCard(scroll, "🎉 Events & Quests", "Automatically handle events and quests", 1)
    
    CreateToggle(eventsContent, "Enable Auto Events", "Automatically handle events", AutomationConfig.AutoEvents, "Enabled", 1)
    CreateToggle(eventsContent, "Daily Quests", "Complete daily quests", AutomationConfig.AutoEvents, "DailyQuests", 2)
    CreateToggle(eventsContent, "Summer Harvest", "Participate in summer harvest", AutomationConfig.AutoEvents, "SummerHarvest", 3)
    CreateToggle(eventsContent, "Blood Moon", "Handle blood moon events", AutomationConfig.AutoEvents, "BloodMoon", 4)
    CreateToggle(eventsContent, "Auto Claim", "Automatically claim rewards", AutomationConfig.AutoEvents, "AutoClaim", 5)
end

-- Create Trading Section
function CreateTradingSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Trading Card
    local tradingCard, tradingContent = CreateCard(scroll, "🤝 Trading System", "Automated trading features", 1)
    
    CreateToggle(tradingContent, "Enable Auto Trading", "Enable automated trading", AutomationConfig.AutoTrade, "Enabled", 1)
    CreateToggle(tradingContent, "Auto Accept Trades", "Automatically accept incoming trades", AutomationConfig.AutoTrade, "AutoAcceptTrades", 2)
    CreateToggle(tradingContent, "Target Player Trading", "Trade with specific player", AutomationConfig.AutoTrade, "TargetPlayerEnabled", 3)
    CreateToggle(tradingContent, "Trade All Fruits", "Trade all fruits to target", AutomationConfig.AutoTrade, "TradeAllFruitsToTarget", 4)
    CreateToggle(tradingContent, "Trade All Pets", "Trade all pets to target", AutomationConfig.AutoTrade, "TradeAllPetsToTarget", 5)
    
    CreateTextBox(tradingContent, "Target Player Name", "Name of player to trade with", AutomationConfig.AutoTrade, "TargetPlayerName", 6)
    CreateSlider(tradingContent, "Request Interval", "Seconds between trade requests", AutomationConfig.AutoTrade, "RequestInterval", 10, 300, 7)
    CreateSlider(tradingContent, "Max Attempts", "Maximum trade attempts per session", AutomationConfig.AutoTrade, "MaxRequestAttempts", 1, 50, 8)
end

-- Create Misc Section
function CreateMiscSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Misc Features Card
    local miscCard, miscContent = CreateCard(scroll, "⚙️ Miscellaneous Features", "Additional automation features", 1)
    
    CreateToggle(miscContent, "Auto Open Packs", "Automatically open seed packs", AutomationConfig.MiscFeatures, "AutoOpenPacks", 1)
    CreateToggle(miscContent, "Auto Use Gear", "Automatically use gear when needed", AutomationConfig.MiscFeatures, "AutoUseGear", 2)
    CreateToggle(miscContent, "Auto Teleport", "Enable teleportation features", AutomationConfig.MiscFeatures, "AutoTeleport", 3)
    CreateSlider(miscContent, "Pack Open Interval", "Seconds between pack openings", AutomationConfig.MiscFeatures, "PackOpenInterval", 1, 30, 4)
end

-- Create Performance Section
function CreatePerformanceSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Performance Card
    local perfCard, perfContent = CreateCard(scroll, "⚡ Performance Settings", "Optimize game performance", 1)
    
    CreateToggle(perfContent, "Reduce Graphics", "Lower graphics quality for better performance", AutomationConfig.Performance, "ReduceGraphics", 1)
    CreateToggle(perfContent, "Disable Animations", "Disable animations to improve FPS", AutomationConfig.Performance, "DisableAnimations", 2)
    CreateToggle(perfContent, "Disable Particles", "Disable particle effects", AutomationConfig.Performance, "DisableParticles", 3)
    CreateToggle(perfContent, "Low Memory Mode", "Optimize for low memory usage", AutomationConfig.Performance, "LowMemoryMode", 4)
    CreateSlider(perfContent, "Max FPS", "Maximum frames per second", AutomationConfig.Performance, "MaxFPS", 30, 144, 5)
end

-- Create Settings Section
function CreateSettingsSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Webhook Settings Card
    local webhookCard, webhookContent = CreateCard(scroll, "🔧 Webhook Settings", "Configure Discord webhook notifications", 1)
    
    CreateTextBox(webhookContent, "Webhook URL", "Discord webhook URL for notifications", AutomationConfig, "WebhookURL", 1)
    CreateTextBox(webhookContent, "Log Level", "Logging level (INFO, WARN, ERROR)", AutomationConfig, "LogLevel", 2)
end

-- Initialize UI after backend is ready
wait(1)
InitializeUI()

-- Store in global for UI access
_G.AutomationSystem.Functions = AutomationSystemAPI

return AutomationSystemAPI
