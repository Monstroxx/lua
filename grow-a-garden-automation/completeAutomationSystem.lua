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

-- Import game modules
local DataService = require(ReplicatedStorage.Modules.DataService)
local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService)
local CollectController = require(ReplicatedStorage.Modules.CollectController)
local MarketController = require(ReplicatedStorage.Modules.MarketController)

-- Data imports
local SeedData = require(ReplicatedStorage.Data.SeedData)
local GearData = require(ReplicatedStorage.Data.GearData)
local PetList = require(ReplicatedStorage.Data.PetRegistry.PetList)
local PetEggData = require(ReplicatedStorage.Data.PetEggData)
local SeedPackData = require(ReplicatedStorage.Data.SeedPackData)

-- Import the UI (HTTP Request Method)
local AdvancedUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/advancedAutomationUI.lua"))()

-- Global automation state (shared between UI and backend)
_G.AutomationSystem = _G.AutomationSystem or {}
_G.AutomationSystem.Config = AutomationConfig
_G.AutomationSystem.Functions = {}

-- Automation Configuration (synced with UI)
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
    local data = DataService:GetData()
    return data or {}
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
    if not AutomationConfig or not AutomationConfig.AutoBuySeeds or not AutomationConfig.AutoBuySeeds.Enabled then return end
    
    local backpack = DataManager.GetBackpack()
    local sheckles = DataManager.GetSheckles()
    
    if sheckles < (AutomationConfig.AutoBuySeeds.KeepMinimum or 100000) then
        webhook:Log("WARN", "Not enough money to buy seeds safely")
        return
    end
    
    -- Open shop UI first
    ShopManager.OpenShop()
    ShopManager.NavigateToSeedShop()
    
    for _, seedType in pairs(AutomationConfig.AutoBuySeeds.SelectedSeeds or {}) do
        local seedName = seedType .. " Seed"
        local currentStock = backpack[seedName] or 0
        
        if currentStock < (AutomationConfig.AutoBuySeeds.MinStock or 10) then
            local seedInfo = SeedData[seedType]
            if seedInfo and sheckles >= seedInfo.Price + AutomationConfig.AutoBuySeeds.KeepMinimum then
                local buyAmount = math.min(AutomationConfig.AutoBuySeeds.BuyUpTo - currentStock, 
                                         math.floor((sheckles - AutomationConfig.AutoBuySeeds.KeepMinimum) / seedInfo.Price))
                
                if buyAmount > 0 then
                    for i = 1, buyAmount do
                        local success, error = pcall(function()
                            -- Method 1: Try to find and click buy button in UI
                            local buyButton = PlayerGui:FindFirstChild(seedType, true)
                            if buyButton then
                                local button = buyButton:FindFirstChild("Buy") or buyButton:FindFirstChild("Purchase")
                                if button and button:IsA("GuiButton") then
                                    button.MouseButton1Click:Fire()
                                    wait(0.5)
                                end
                            end
                            
                            -- Method 2: Use game remote
                            ReplicatedStorage.GameEvents.BuySeedStock:FireServer(seedType)
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
end

-- not working maby check first what gear are in stock
function ShopManager.BuyGear()
    if not AutomationConfig or not AutomationConfig.AutoBuyGear or not AutomationConfig.AutoBuyGear.Enabled then return end
    
    local backpack = DataManager.GetBackpack()
    local sheckles = DataManager.GetSheckles()
    
    if sheckles < AutomationConfig.AutoBuyGear.KeepMinimum then return end
    
    for _, gearType in pairs(AutomationConfig.AutoBuyGear.SelectedGear) do
        local currentStock = backpack[gearType] or 0
        
        if currentStock < AutomationConfig.AutoBuyGear.MinStock then
            local gearInfo = GearData[gearType]
            if gearInfo and sheckles >= gearInfo.Price + AutomationConfig.AutoBuyGear.KeepMinimum then
                local buyAmount = math.min(AutomationConfig.AutoBuyGear.BuyUpTo - currentStock,
                                         math.floor((sheckles - AutomationConfig.AutoBuyGear.KeepMinimum) / gearInfo.Price))
                
                if buyAmount > 0 then
                    for i = 1, buyAmount do
                        local success, error = pcall(function()
                            MarketController:PromptPurchase(1, gearInfo.PurchaseID)
                        end)
                        
                        if success then
                            webhook:Log("INFO", "Purchased gear", {GearType = gearType, Price = gearInfo.Price})
                            sheckles = sheckles - gearInfo.Price
                            wait(1)
                        else
                            webhook:Log("ERROR", "Failed to buy gear", {Error = error})
                            break
                        end
                        
                        if sheckles < gearInfo.Price + AutomationConfig.AutoBuyGear.KeepMinimum then
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
    if not AutomationConfig or not AutomationConfig.AutoBuyEggs or not AutomationConfig.AutoBuyEggs.Enabled then return end
    
    local sheckles = DataManager.GetSheckles()
    
    if sheckles < AutomationConfig.AutoBuyEggs.KeepMinimum then return end
    
    for _, eggType in pairs(AutomationConfig.AutoBuyEggs.SelectedEggs) do
        local eggInfo = PetEggData[eggType]
        if eggInfo and sheckles >= eggInfo.Price + AutomationConfig.AutoBuyEggs.KeepMinimum then
            local success, error = pcall(function()
                MarketController:PromptPurchase(2, eggInfo.PurchaseID)
            end)
            
            if success then
                webhook:Log("INFO", "Purchased egg", {EggType = eggType, Price = eggInfo.Price})
                sheckles = sheckles - eggInfo.Price
                wait(2)
            else
                webhook:Log("ERROR", "Failed to buy egg", {Error = error})
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
    
    if AutomationConfig.AutoTrade.AutoAcceptTrades then
        TradingManager.AutoAcceptTrades()
    end
    
    if AutomationConfig.AutoTrade.AutoOffer then
        TradingManager.SendTradeOffers()
    end
    
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
        -- Find trading system in the game
        local TradeService = ReplicatedStorage:FindFirstChild("TradeService")
        local TradingRemote = ReplicatedStorage:FindFirstChild("TradingRemote") 
        
        if TradeService then
            TradeService:FireServer("SendTradeRequest", targetPlayer.UserId, items)
        elseif TradingRemote then
            TradingRemote:FireServer("RequestTrade", targetPlayer.UserId, items)
        else
            -- Try to find any trade-related remotes
            for _, child in pairs(ReplicatedStorage:GetDescendants()) do
                if child:IsA("RemoteEvent") and child.Name:lower():find("trade") then
                    child:FireServer("Request", targetPlayer.UserId, items)
                    break
                end
            end
        end
    end)
    
    if success then
        webhook:Log("INFO", "Sent trade request", {
            TargetPlayer = targetPlayer.Name,
            ItemCount = #items
        })
        return true
    else
        webhook:Log("ERROR", "Failed to send trade request", {Error = error})
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
    
    -- Send trade request
    if targetPlayer then
        local success = TradingManager.SendTradeRequest(targetPlayer, tradableItems)
        if success then
            tradeAttemptCount = tradeAttemptCount + 1
            lastTradeAttempt = currentTime
            
            webhook:Log("INFO", "Target player trade initiated", {
                TargetPlayer = targetPlayer.Name,
                Items = #tradableItems,
                Attempt = tradeAttemptCount
            })
        end
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
            -- Shopping (with intervals)
            if currentTime - lastTasks.buySeeds >= (AutomationConfig.AutoBuySeeds and AutomationConfig.AutoBuySeeds.CheckInterval or 30) then
                pcall(ShopManager.BuySeeds)
                lastTasks.buySeeds = currentTime
            end
            
            if currentTime - lastTasks.buyGear >= (AutomationConfig.AutoBuyGear and AutomationConfig.AutoBuyGear.CheckInterval or 60) then
                pcall(ShopManager.BuyGear)
                lastTasks.buyGear = currentTime
            end
            
            if currentTime - lastTasks.buyEggs >= (AutomationConfig.AutoBuyEggs and AutomationConfig.AutoBuyEggs.CheckInterval or 45) then
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
            if AutomationConfig[key] then
                AutomationConfig[key] = value
            end
        end
        webhook:Log("INFO", "Configuration updated")
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

-- Store in global for UI access
_G.AutomationSystem.Functions = AutomationSystemAPI

return AutomationSystemAPI