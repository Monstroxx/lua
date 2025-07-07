-- Complete Grow a Garden Automation System
-- ALL FEATURES IN ONE FILE - Backend + Advanced UI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

print("🌱 Complete Automation System starting...")

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
local CollectController = SafeRequire(ReplicatedStorage.Modules.CollectController, "CollectController")
local MarketController = SafeRequire(ReplicatedStorage.Modules.MarketController, "MarketController")

-- Data imports
local SeedData = SafeRequire(ReplicatedStorage.Data.SeedData, "SeedData")
local GearData = SafeRequire(ReplicatedStorage.Data.GearData, "GearData")
local PetList = SafeRequire(ReplicatedStorage.Data.PetRegistry.PetList, "PetList")
local PetEggData = SafeRequire(ReplicatedStorage.Data.PetEggData, "PetEggData")
local SeedPackData = SafeRequire(ReplicatedStorage.Data.SeedPackData, "SeedPackData")

-- Complete Configuration
local AutomationConfig = {
    -- Master Settings
    Enabled = false,
    WebhookURL = "",
    LogLevel = "INFO",
    
    -- Auto Buy Settings
    AutoBuySeeds = {
        Enabled = false,
        SelectedSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Watermelon"},
        MaxSpend = 10000000,
        KeepMinimum = 1000000,
        CheckInterval = 30,
        MinStock = 10,
        BuyUpTo = 50,
    },
    
    AutoBuyGear = {
        Enabled = false,
        SelectedGear = {"Watering Can", "Trowel", "Basic Sprinkler", "Advanced Sprinkler"},
        MaxSpend = 5000000,
        KeepMinimum = 500000,
        CheckInterval = 60,
        MinStock = 5,
        BuyUpTo = 20,
    },
    
    AutoBuyEggs = {
        Enabled = false,
        SelectedEggs = {"Common Egg", "Rare Egg", "Mythical Egg"},
        MaxSpend = 20000000,
        KeepMinimum = 5000000,
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
        DinoEvents = true,
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
        SelectedPacks = {"Normal Seed Pack", "Exotic Seed Pack", "Infinite Pack"},
        PackOpenInterval = 5,
        AutoUseGear = true,
        AutoExpand = false,
        AutoTeleport = false,
        AutoCraftRecipes = false,
        AutoSkipAnimations = true,
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

-- Initialize global state
_G.AutomationSystem = {
    Config = AutomationConfig,
    Functions = {},
    UI = {},
    Loaded = true
}

print("✅ Configuration initialized")

-- Advanced Logging with Discord Webhook
local WebhookManager = {}
WebhookManager.__index = WebhookManager

function WebhookManager.new(url)
    local self = setmetatable({}, WebhookManager)
    self.url = url or ""
    self.queue = {}
    self.lastSent = 0
    self.rateLimit = 2
    return self
end

function WebhookManager:Log(level, message, data)
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
    
    -- Send to Discord if webhook URL is set
    if self.url and self.url ~= "" then
        self:SendToDiscord(level, message, data)
    end
end

function WebhookManager:SendToDiscord(level, message, data)
    if tick() - self.lastSent < self.rateLimit then return end
    
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
    
    local success = pcall(function()
        local jsonData = HttpService:JSONEncode({
            content = "",
            embeds = {embed}
        })
        HttpService:PostAsync(self.url, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if success then
        self.lastSent = tick()
    end
end

function WebhookManager:SetURL(url)
    self.url = url
end

local webhook = WebhookManager.new(AutomationConfig.WebhookURL)

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
            
            -- Try seed tool first
            local seedTool = character:FindFirstChild(seedName) or LocalPlayer.Backpack:FindFirstChild(seedName)
            if seedTool and seedTool:IsA("Tool") then
                seedTool.Parent = character
                wait(0.2)
                
                local clickDetector = spot:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                end
                
                wait(0.2)
                seedTool.Parent = LocalPlayer.Backpack
                return
            end
            
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
        webhook:Log("INFO", "Planted seed", {SeedType = seedType})
    end
    
    return success
end

function FarmingManager.CollectPlants()
    local plants = FarmingManager.GetHarvestablePlants()
    if #plants == 0 then return end
    
    local collected = 0
    
    -- Sort by rarity if enabled
    if AutomationConfig.AutoCollect.PrioritizeRareItems then
        table.sort(plants, function(a, b)
            return (a:GetAttribute("Rarity") or 0) > (b:GetAttribute("Rarity") or 0)
        end)
    end
    
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
        end
        
        wait(AutomationConfig.AutoCollect.CollectInterval)
    end
    
    if collected > 0 then
        webhook:Log("INFO", "Collected plants", {Count = collected})
    end
end

function FarmingManager.UseWateringCan()
    if not AutomationConfig.AutoPlant.UseWateringCan then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChild("Watering Can") or LocalPlayer.Backpack:FindFirstChild("Watering Can")
    if not tool then return end
    
    local plantedObjects = DataManager.GetPlantedObjects()
    for _, plantData in pairs(plantedObjects) do
        if plantData.ObjectId then
            local plant = workspace:FindFirstChild(plantData.ObjectId)
            if plant and not plant:GetAttribute("Watered") then
                local success = pcall(function()
                    character.HumanoidRootPart.CFrame = plant.CFrame + Vector3.new(0, 5, 0)
                    tool.Parent = character
                    tool:Activate()
                    wait(0.5)
                    tool.Parent = LocalPlayer.Backpack
                end)
                
                if success then
                    webhook:Log("INFO", "Watered plant")
                end
                
                wait(1)
            end
        end
    end
end

-- Shop Management
local ShopManager = {}

function ShopManager.OpenShop()
    local success = pcall(function()
        -- Try to find shop button in UI
        local shopButton = PlayerGui:FindFirstChild("ShopButton", true) or PlayerGui:FindFirstChild("Shop", true)
        if shopButton and shopButton:IsA("GuiButton") then
            shopButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        -- Try to find shop NPC
        local shopNPC = workspace:FindFirstChild("ShopNPC") or workspace:FindFirstChild("Shop")
        if shopNPC then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = shopNPC.CFrame + Vector3.new(0, 5, 5)
                wait(1)
                
                local proximityPrompt = shopNPC:FindFirstChild("ProximityPrompt", true)
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                end
            end
        end
    end)
    
    return success
end

function ShopManager.BuySeeds()
    if not AutomationConfig.AutoBuySeeds.Enabled then return end
    
    local sheckles = DataManager.GetSheckles()
    if sheckles < AutomationConfig.AutoBuySeeds.KeepMinimum then
        webhook:Log("WARN", "Not enough money for safe seed buying")
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
                webhook:Log("INFO", "Bought seed", {SeedType = seedType})
                wait(1)
            end
        end
    end
end

function ShopManager.BuyGear()
    if not AutomationConfig.AutoBuyGear.Enabled then return end
    
    local sheckles = DataManager.GetSheckles()
    if sheckles < AutomationConfig.AutoBuyGear.KeepMinimum then return end
    
    local backpack = DataManager.GetBackpack()
    
    for _, gearType in pairs(AutomationConfig.AutoBuyGear.SelectedGear) do
        local currentStock = backpack[gearType] or 0
        
        if currentStock < AutomationConfig.AutoBuyGear.MinStock then
            local success = pcall(function()
                if ReplicatedStorage:FindFirstChild("GameEvents") then
                    local buyRemote = ReplicatedStorage.GameEvents:FindFirstChild("BuyGearStock")
                    if buyRemote then
                        buyRemote:FireServer(gearType)
                    end
                end
            end)
            
            if success then
                webhook:Log("INFO", "Bought gear", {GearType = gearType})
                wait(1)
            end
        end
    end
end

function ShopManager.BuyEggs()
    if not AutomationConfig.AutoBuyEggs.Enabled then return end
    
    local sheckles = DataManager.GetSheckles()
    if sheckles < AutomationConfig.AutoBuyEggs.KeepMinimum then return end
    
    for _, eggType in pairs(AutomationConfig.AutoBuyEggs.SelectedEggs) do
        local success = pcall(function()
            if ReplicatedStorage:FindFirstChild("GameEvents") then
                local buyRemote = ReplicatedStorage.GameEvents:FindFirstChild("BuyPetEgg")
                if buyRemote then
                    buyRemote:FireServer(eggType)
                end
            end
        end)
        
        if success then
            webhook:Log("INFO", "Bought egg", {EggType = eggType})
            wait(2)
        end
    end
end

-- Pet Management
local PetManager = {}

function PetManager.OpenPetUI()
    local success = pcall(function()
        local petButton = PlayerGui:FindFirstChild("PetButton", true) or PlayerGui:FindFirstChild("Pets", true)
        if petButton and petButton:IsA("GuiButton") then
            petButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        local arrowButton = PlayerGui:FindFirstChild("Arrow", true) or PlayerGui:FindFirstChild("Expand", true)
        if arrowButton and arrowButton:IsA("GuiButton") then
            arrowButton.MouseButton1Click:Fire()
            wait(1)
            return true
        end
        
        return false
    end)
    
    return success
end

function PetManager.EquipBestPets()
    if not AutomationConfig.PetManagement.AutoEquip then return end
    if not PetsService then return end
    
    local success = pcall(function()
        local petData = DataManager.GetPetData()
        local inventory = petData.PetInventory and petData.PetInventory.Data or {}
        local equipped = DataManager.GetEquippedPets()
        
        local bestPets = {}
        for petId, pet in pairs(inventory) do
            if pet and PetList and PetList[pet.PetType] then
                local rarity = PetList[pet.PetType].Rarity or "Common"
                local level = pet.Level or 1
                local rarityValues = {Common = 100, Uncommon = 200, Rare = 400, Legendary = 800, Mythical = 1600}
                local value = (level * 100) + (rarityValues[rarity] or 0)
                
                table.insert(bestPets, {
                    id = petId,
                    data = pet,
                    rarity = rarity,
                    level = level,
                    value = value
                })
            end
        end
        
        table.sort(bestPets, function(a, b)
            return a.value > b.value
        end)
        
        local maxSlots = AutomationConfig.PetManagement.PetEquipSlots
        for i = 1, math.min(#bestPets, maxSlots) do
            local pet = bestPets[i]
            if not equipped[tostring(i)] or equipped[tostring(i)] ~= pet.id then
                PetsService:EquipPet(pet.id, i)
                webhook:Log("INFO", "Equipped pet", {PetType = pet.data.PetType, Slot = i, Level = pet.level})
                wait(0.5)
            end
        end
    end)
end

function PetManager.FeedPets()
    if not AutomationConfig.PetManagement.AutoFeed then return end
    
    local success = pcall(function()
        local petData = DataManager.GetPetData()
        local inventory = petData.PetInventory and petData.PetInventory.Data or {}
        local backpack = DataManager.GetBackpack()
        
        for petId, pet in pairs(inventory) do
            if pet.Hunger and pet.Hunger < AutomationConfig.PetManagement.FeedThreshold then
                for itemName, amount in pairs(backpack) do
                    if amount > 0 and PetManager.IsPetFood(itemName) then
                        if ReplicatedStorage:FindFirstChild("PetFeedingService") then
                            ReplicatedStorage.PetFeedingService:FireServer("FeedPet", petId, itemName)
                            webhook:Log("INFO", "Fed pet", {PetId = petId, Food = itemName})
                            break
                        end
                    end
                end
            end
        end
    end)
end

function PetManager.IsPetFood(itemName)
    local foodKeywords = {"Fruit", "Berry", "Apple", "Carrot", "Tomato", "Banana"}
    for _, keyword in pairs(foodKeywords) do
        if itemName:find(keyword) then
            return true
        end
    end
    return false
end

function PetManager.HatchEggs()
    if not AutomationConfig.PetManagement.AutoHatchEggs then return end
    
    local backpack = DataManager.GetBackpack()
    
    for eggName, amount in pairs(backpack) do
        if amount > 0 and eggName:find("Egg") then
            local success = pcall(function()
                if ReplicatedStorage:FindFirstChild("EggHatchingService") then
                    ReplicatedStorage.EggHatchingService:FireServer("HatchEgg", eggName)
                end
            end)
            
            if success then
                webhook:Log("INFO", "Hatched egg", {EggType = eggName})
                wait(AutomationConfig.PetManagement.HatchInterval)
            end
        end
    end
end

-- Event Management
local EventManager = {}

function EventManager.HandleEvents()
    if not AutomationConfig.AutoEvents.Enabled then return end
    
    if AutomationConfig.AutoEvents.DailyQuests then
        EventManager.ClaimDailyQuests()
    end
    
    if AutomationConfig.AutoEvents.AutoClaim then
        EventManager.ClaimEventRewards()
    end
end

function EventManager.ClaimDailyQuests()
    local success = pcall(function()
        if Remotes and Remotes.DailyQuests and Remotes.DailyQuests.Claim then
            Remotes.DailyQuests.Claim.send()
        end
    end)
    
    if success then
        webhook:Log("INFO", "Claimed daily quest reward")
    end
end

function EventManager.ClaimEventRewards()
    local success = pcall(function()
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

-- Pack Management
local PackManager = {}

function PackManager.OpenPacks()
    if not AutomationConfig.MiscFeatures.AutoOpenPacks then return end
    
    local backpack = DataManager.GetBackpack()
    
    for _, packType in pairs(AutomationConfig.MiscFeatures.SelectedPacks) do
        local packCount = backpack[packType] or 0
        
        if packCount > 0 then
            local success = pcall(function()
                if packType:find("Seed Pack") then
                    if Remotes and Remotes.SeedPack and Remotes.SeedPack.Open then
                        Remotes.SeedPack.Open:fire(packType)
                    end
                elseif packType:find("Infinite Pack") then
                    if Remotes and Remotes.InfinitePack and Remotes.InfinitePack.Claim then
                        Remotes.InfinitePack.Claim:fire()
                    end
                end
            end)
            
            if success then
                webhook:Log("INFO", "Opened pack", {PackType = packType})
                wait(AutomationConfig.MiscFeatures.PackOpenInterval)
            end
        end
    end
end

-- Trading System
local TradingManager = {}

function TradingManager.FindTargetPlayer()
    local targetName = AutomationConfig.AutoTrade.TargetPlayerName or ""
    if targetName == "" then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == targetName:lower() or player.DisplayName:lower() == targetName:lower() then
            return player
        end
    end
    
    return nil
end

function TradingManager.TeleportToPlayer(targetPlayer)
    if not AutomationConfig.AutoTrade.AutoTeleportToTarget then return false end
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local success = pcall(function()
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(5, 0, 5))
    end)
    
    if success then
        webhook:Log("INFO", "Teleported to target player", {TargetPlayer = targetPlayer.Name})
        return true
    end
    
    return false
end

function TradingManager.HandleTrades()
    if not AutomationConfig.AutoTrade.Enabled then return end
    
    if AutomationConfig.AutoTrade.TargetPlayerEnabled then
        local targetPlayer = TradingManager.FindTargetPlayer()
        if targetPlayer then
            TradingManager.TeleportToPlayer(targetPlayer)
            wait(2)
            
            -- Try to initiate trade
            local success = pcall(function()
                -- Look for trade-related proximity prompts
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and (obj.ObjectText:lower():find("trade") or obj.ObjectText:lower():find("gift")) then
                        fireproximityprompt(obj)
                        break
                    end
                end
            end)
        end
    end
    
    if AutomationConfig.AutoTrade.AutoAcceptTrades then
        TradingManager.AcceptIncomingTrade()
    end
end

function TradingManager.AcceptIncomingTrade()
    local success = pcall(function()
        local acceptButton = PlayerGui:FindFirstChild("Accept", true) or PlayerGui:FindFirstChild("AcceptTrade", true)
        if acceptButton and acceptButton:IsA("GuiButton") and acceptButton.Visible then
            acceptButton.MouseButton1Click:Fire()
            wait(1)
            webhook:Log("INFO", "Accepted incoming trade")
        end
    end)
end

-- Performance Manager
local PerformanceManager = {}

function PerformanceManager.OptimizeGraphics()
    if not AutomationConfig.Performance.ReduceGraphics then return end
    
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
    if not AutomationConfig.Performance.DisableAnimations then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Animation") then
            obj.AnimationId = ""
        end
    end
end

-- ========================================
-- ADVANCED UI SYSTEM
-- ========================================

local UIManager = {}
local CurrentCategory = 1
local UIElements = {}

-- UI Configuration
local UIConfig = {
    Colors = {
        Primary = Color3.fromRGB(120, 119, 255),
        Secondary = Color3.fromRGB(175, 82, 222),
        Accent = Color3.fromRGB(255, 105, 180),
        Background = Color3.fromRGB(13, 13, 13),
        Surface = Color3.fromRGB(28, 28, 30),
        SurfaceLight = Color3.fromRGB(44, 44, 46),
        SurfaceHover = Color3.fromRGB(58, 58, 62),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(152, 152, 157),
        TextDim = Color3.fromRGB(99, 99, 102),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 204, 0),
        Error = Color3.fromRGB(255, 69, 58),
        Border = Color3.fromRGB(56, 56, 58),
    }
}

-- Categories
local Categories = {
    {Name = "Dashboard", Icon = "📊", Color = UIConfig.Colors.Primary},
    {Name = "Auto Buy", Icon = "🛒", Color = UIConfig.Colors.Secondary},
    {Name = "Farming", Icon = "🌱", Color = UIConfig.Colors.Success},
    {Name = "Pets", Icon = "🐾", Color = UIConfig.Colors.Accent},
    {Name = "Events", Icon = "🎯", Color = UIConfig.Colors.Warning},
    {Name = "Trading", Icon = "💱", Color = UIConfig.Colors.Error},
    {Name = "Misc", Icon = "⚙️", Color = UIConfig.Colors.TextSecondary},
    {Name = "Performance", Icon = "⚡", Color = UIConfig.Colors.Success},
    {Name = "Settings", Icon = "🔧", Color = UIConfig.Colors.Primary},
}

function UIManager.CreateMainUI()
    -- Remove existing UI
    if PlayerGui:FindFirstChild("AutomationGUI") then
        PlayerGui.AutomationGUI:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutomationGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = UIConfig.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 70)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = UIConfig.Colors.Primary
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    -- Header Bottom Fixer
    local headerFixer = Instance.new("Frame")
    headerFixer.Size = UDim2.new(1, 0, 0, 16)
    headerFixer.Position = UDim2.new(0, 0, 1, -16)
    headerFixer.BackgroundColor3 = UIConfig.Colors.Primary
    headerFixer.BorderSizePixel = 0
    headerFixer.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌱 Garden Automation System"
    title.TextColor3 = UIConfig.Colors.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -50, 0.5, -15)
    closeButton.BackgroundColor3 = UIConfig.Colors.Error
    closeButton.Text = "×"
    closeButton.TextColor3 = UIConfig.Colors.Text
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    -- Category Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 220, 1, -70)
    sidebar.Position = UDim2.new(0, 0, 0, 70)
    sidebar.BackgroundColor3 = UIConfig.Colors.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 5)
    sidebarLayout.Parent = sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -220, 1, -70)
    contentArea.Position = UDim2.new(0, 220, 0, 70)
    contentArea.BackgroundColor3 = UIConfig.Colors.Background
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame
    
    -- Separator line
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(0, 2, 1, 0)
    separator.Position = UDim2.new(0, 0, 0, 0)
    separator.BackgroundColor3 = UIConfig.Colors.Border
    separator.BorderSizePixel = 0
    separator.Parent = contentArea
    
    UIElements.MainFrame = mainFrame
    UIElements.Sidebar = sidebar
    UIElements.ContentArea = contentArea
    UIElements.CategoryButtons = {}
    
    -- Create category buttons
    for i, category in ipairs(Categories) do
        UIManager.CreateCategoryButton(sidebar, category, i)
    end
    
    -- Floating Toggle Button
    UIManager.CreateFloatingButton(screenGui)
    
    -- Select first category
    UIManager.SelectCategory(1)
    
    print("✅ Advanced UI created")
end

function UIManager.CreateCategoryButton(parent, category, index)
    local button = Instance.new("TextButton")
    button.Name = "CategoryButton" .. index
    button.Size = UDim2.new(1, 0, 0, 60)
    button.BackgroundColor3 = index == 1 and UIConfig.Colors.Primary or Color3.fromRGB(0, 0, 0, 0)
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
    iconBg.Size = UDim2.new(0, 40, 0, 40)
    iconBg.Position = UDim2.new(0, 10, 0.5, -20)
    iconBg.BackgroundColor3 = index == 1 and UIConfig.Colors.Text or category.Color
    iconBg.BorderSizePixel = 0
    iconBg.Parent = button
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 10)
    iconCorner.Parent = iconBg
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = category.Icon
    icon.TextColor3 = index == 1 and UIConfig.Colors.Primary or UIConfig.Colors.Text
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.Parent = iconBg
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -65, 0, 20)
    label.Position = UDim2.new(0, 60, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = category.Name
    label.TextColor3 = index == 1 and UIConfig.Colors.Text or UIConfig.Colors.TextSecondary
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Name = "Description"
    desc.Size = UDim2.new(1, -65, 0, 15)
    desc.Position = UDim2.new(0, 60, 0, 32)
    desc.BackgroundTransparency = 1
    desc.Text = "Configure " .. category.Name:lower()
    desc.TextColor3 = index == 1 and UIConfig.Colors.TextSecondary or UIConfig.Colors.TextDim
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = button
    
    button.MouseButton1Click:Connect(function()
        UIManager.SelectCategory(index)
    end)
    
    UIElements.CategoryButtons[index] = {
        Button = button,
        IconBg = iconBg,
        Icon = icon,
        Label = label,
        Desc = desc
    }
end

function UIManager.SelectCategory(index)
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
    UIManager.UpdateContentArea()
end

function UIManager.CreateFloatingButton(parent)
    local floatingButton = Instance.new("TextButton")
    floatingButton.Name = "FloatingButton"
    floatingButton.Size = UDim2.new(0, 60, 0, 60)
    floatingButton.Position = UDim2.new(1, -80, 0, 20)
    floatingButton.BackgroundColor3 = UIConfig.Colors.Primary
    floatingButton.Text = "⚡"
    floatingButton.TextColor3 = UIConfig.Colors.Text
    floatingButton.TextSize = 24
    floatingButton.Font = Enum.Font.GothamBold
    floatingButton.Parent = parent
    
    local floatingCorner = Instance.new("UICorner")
    floatingCorner.CornerRadius = UDim.new(1, 0)
    floatingCorner.Parent = floatingButton
    
    floatingButton.MouseButton1Click:Connect(function()
        UIElements.MainFrame.Visible = not UIElements.MainFrame.Visible
    end)
    
    -- Hover effect
    floatingButton.MouseEnter:Connect(function()
        TweenService:Create(floatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 65, 0, 65)}):Play()
    end)
    
    floatingButton.MouseLeave:Connect(function()
        TweenService:Create(floatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    end)
end

function UIManager.UpdateContentArea()
    local contentArea = UIElements.ContentArea
    if not contentArea then return end
    
    -- Clear existing content
    for _, child in ipairs(contentArea:GetChildren()) do
        if child.Name ~= "Separator" then
            child:Destroy()
        end
    end
    
    local categoryName = Categories[CurrentCategory].Name
    
    if categoryName == "Dashboard" then
        UIManager.CreateDashboard(contentArea)
    elseif categoryName == "Auto Buy" then
        UIManager.CreateAutoBuySection(contentArea)
    elseif categoryName == "Farming" then
        UIManager.CreateFarmingSection(contentArea)
    elseif categoryName == "Pets" then
        UIManager.CreatePetSection(contentArea)
    elseif categoryName == "Events" then
        UIManager.CreateEventsSection(contentArea)
    elseif categoryName == "Trading" then
        UIManager.CreateTradingSection(contentArea)
    elseif categoryName == "Misc" then
        UIManager.CreateMiscSection(contentArea)
    elseif categoryName == "Performance" then
        UIManager.CreatePerformanceSection(contentArea)
    elseif categoryName == "Settings" then
        UIManager.CreateSettingsSection(contentArea)
    end
end

function UIManager.CreateScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ScrollFrame"
    scroll.Size = UDim2.new(1, -20, 1, -20)
    scroll.Position = UDim2.new(0, 10, 0, 10)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = UIConfig.Colors.Primary
    scroll.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
    layout.Parent = scroll
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = scroll
    
    -- Auto-resize
    layout.Changed:Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    return scroll
end

function UIManager.CreateCard(parent, title, description, layoutOrder)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(1, 0, 0, 200)
    card.BackgroundColor3 = UIConfig.Colors.Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    -- Card Header
    local cardHeader = Instance.new("Frame")
    cardHeader.Name = "Header"
    cardHeader.Size = UDim2.new(1, 0, 0, 50)
    cardHeader.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    cardHeader.BorderSizePixel = 0
    cardHeader.Parent = card
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = cardHeader
    
    local headerFixer = Instance.new("Frame")
    headerFixer.Size = UDim2.new(1, 0, 0, 12)
    headerFixer.Position = UDim2.new(0, 0, 1, -12)
    headerFixer.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    headerFixer.BorderSizePixel = 0
    headerFixer.Parent = cardHeader
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = UIConfig.Colors.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = cardHeader
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -20, 0, 15)
    descLabel.Position = UDim2.new(0, 10, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = UIConfig.Colors.TextSecondary
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = cardHeader
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -50)
    content.Position = UDim2.new(0, 0, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = card
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = content
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingAll = UDim.new(0, 10)
    contentPadding.Parent = content
    
    -- Auto-resize card
    contentLayout.Changed:Connect(function()
        card.Size = UDim2.new(1, 0, 0, math.max(200, contentLayout.AbsoluteContentSize.Y + 70))
    end)
    
    return content
end

function UIManager.CreateToggle(parent, name, description, config, key, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. name:gsub("%s+", "")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder or 0
    frame.Parent = parent
    
    -- Toggle Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = UIConfig.Colors.Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame
    
    if description then
        label.Size = UDim2.new(1, -60, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.TextYAlignment = Enum.TextYAlignment.Bottom
        
        local desc = Instance.new("TextLabel")
        desc.Name = "Description"
        desc.Size = UDim2.new(1, -60, 0, 15)
        desc.Position = UDim2.new(0, 0, 0, 20)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = UIConfig.Colors.TextSecondary
        desc.TextSize = 10
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.Parent = frame
    end
    
    -- Toggle Button
    local toggleBg = Instance.new("TextButton")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 50, 0, 25)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleBg.BackgroundColor3 = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceHover
    toggleBg.BorderSizePixel = 0
    toggleBg.Text = ""
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 21, 0, 21)
    toggleCircle.Position = config[key] and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    toggleCircle.BackgroundColor3 = UIConfig.Colors.Text
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    toggleBg.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        
        local targetPos = config[key] and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
        local targetColor = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceHover
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    end)
    
    return frame
end

function UIManager.CreateSlider(parent, name, description, config, key, min, max, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. name:gsub("%s+", "")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder or 0
    frame.Parent = parent
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = UIConfig.Colors.Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- Value Label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.4, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config[key] or 0)
    valueLabel.TextColor3 = UIConfig.Colors.Primary
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    -- Description
    if description then
        local desc = Instance.new("TextLabel")
        desc.Name = "Description"
        desc.Size = UDim2.new(1, 0, 0, 12)
        desc.Position = UDim2.new(0, 0, 0, 20)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = UIConfig.Colors.TextSecondary
        desc.TextSize = 10
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
    
    -- Slider Track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -10)
    track.BackgroundColor3 = UIConfig.Colors.SurfaceHover
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track
    
    -- Slider Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(math.min(1, (config[key] or 0) / max), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = UIConfig.Colors.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    -- Slider Button
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(0, 16, 0, 16)
    button.Position = UDim2.new(math.min(1, (config[key] or 0) / max), -8, 0.5, -8)
    button.BackgroundColor3 = UIConfig.Colors.Text
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = track
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = button
    
    -- Slider Logic
    local dragging = false
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = LocalPlayer:GetMouse()
            local relativeX = mouse.X - track.AbsolutePosition.X
            local percentage = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percentage)
            
            config[key] = value
            valueLabel.Text = tostring(value)
            
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            button.Position = UDim2.new(percentage, -8, 0.5, -8)
        end
    end)
    
    return frame
end

-- Dashboard Content
function UIManager.CreateDashboard(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Status Card
    local statusCard = UIManager.CreateCard(scroll, "📊 System Status", "Current automation status and statistics", 0)
    
    -- Main Toggle
    UIManager.CreateToggle(statusCard, "Master Automation", "Enable/disable all automation", AutomationConfig, "Enabled", 0)
    
    -- Stats
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "Stats"
    statsFrame.Size = UDim2.new(1, 0, 0, 80)
    statsFrame.BackgroundTransparency = 1
    statsFrame.LayoutOrder = 1
    statsFrame.Parent = statusCard
    
    local statsLayout = Instance.new("UIGridLayout")
    statsLayout.CellSize = UDim2.new(0.5, -5, 0, 35)
    statsLayout.CellPadding = UDim2.new(0, 10, 0, 5)
    statsLayout.Parent = statsFrame
    
    -- Create stat displays
    local stats = {
        {"Sheckles", "DataManager.GetSheckles()"},
        {"Backpack Items", "GetBackpackCount()"},
        {"Equipped Pets", "GetEquippedPetCount()"},
        {"Planted Objects", "GetPlantedCount()"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.BackgroundColor3 = UIConfig.Colors.SurfaceLight
        statFrame.BorderSizePixel = 0
        statFrame.Parent = statsFrame
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = UDim.new(0, 8)
        statCorner.Parent = statFrame
        
        local statLabel = Instance.new("TextLabel")
        statLabel.Size = UDim2.new(1, -10, 0, 15)
        statLabel.Position = UDim2.new(0, 5, 0, 2)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = stat[1]
        statLabel.TextColor3 = UIConfig.Colors.TextSecondary
        statLabel.TextSize = 10
        statLabel.Font = Enum.Font.Gotham
        statLabel.TextXAlignment = Enum.TextXAlignment.Left
        statLabel.Parent = statFrame
        
        local statValue = Instance.new("TextLabel")
        statValue.Size = UDim2.new(1, -10, 0, 18)
        statValue.Position = UDim2.new(0, 5, 0, 15)
        statValue.BackgroundTransparency = 1
        statValue.Text = "Loading..."
        statValue.TextColor3 = UIConfig.Colors.Text
        statValue.TextSize = 14
        statValue.Font = Enum.Font.GothamBold
        statValue.TextXAlignment = Enum.TextXAlignment.Left
        statValue.Parent = statFrame
        
        -- Update stats periodically
        spawn(function()
            while statValue.Parent do
                local value = 0
                if stat[2] == "DataManager.GetSheckles()" then
                    value = DataManager.GetSheckles()
                elseif stat[2] == "GetBackpackCount()" then
                    local backpack = DataManager.GetBackpack()
                    for _ in pairs(backpack) do value = value + 1 end
                elseif stat[2] == "GetEquippedPetCount()" then
                    local equipped = DataManager.GetEquippedPets()
                    for _ in pairs(equipped) do value = value + 1 end
                elseif stat[2] == "GetPlantedCount()" then
                    local planted = DataManager.GetPlantedObjects()
                    for _ in pairs(planted) do value = value + 1 end
                end
                
                if value >= 1000000 then
                    statValue.Text = string.format("%.1fM", value / 1000000)
                elseif value >= 1000 then
                    statValue.Text = string.format("%.1fK", value / 1000)
                else
                    statValue.Text = tostring(value)
                end
                
                wait(2)
            end
        end)
    end
    
    -- Quick Actions Card
    local actionsCard = UIManager.CreateCard(scroll, "⚡ Quick Actions", "Manual controls for immediate actions", 1)
    
    local actionsFrame = Instance.new("Frame")
    actionsFrame.Name = "Actions"
    actionsFrame.Size = UDim2.new(1, 0, 0, 40)
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.LayoutOrder = 0
    actionsFrame.Parent = actionsCard
    
    local actionsLayout = Instance.new("UIGridLayout")
    actionsLayout.CellSize = UDim2.new(0.25, -7.5, 0, 35)
    actionsLayout.CellPadding = UDim2.new(0, 10, 0, 5)
    actionsLayout.Parent = actionsFrame
    
    local actions = {
        {"🌱 Plant", function() FarmingManager.PlantSeed("Carrot", FarmingManager.GetPlantableSpots()[1]) end},
        {"🍓 Collect", function() FarmingManager.CollectPlants() end},
        {"🛒 Buy Seeds", function() ShopManager.BuySeeds() end},
        {"🐾 Manage Pets", function() PetManager.EquipBestPets() end}
    }
    
    for i, action in ipairs(actions) do
        local actionButton = Instance.new("TextButton")
        actionButton.BackgroundColor3 = UIConfig.Colors.Primary
        actionButton.BorderSizePixel = 0
        actionButton.Text = action[1]
        actionButton.TextColor3 = UIConfig.Colors.Text
        actionButton.TextSize = 11
        actionButton.Font = Enum.Font.GothamSemibold
        actionButton.Parent = actionsFrame
        
        local actionCorner = Instance.new("UICorner")
        actionCorner.CornerRadius = UDim.new(0, 8)
        actionCorner.Parent = actionButton
        
        actionButton.MouseButton1Click:Connect(action[2])
        
        -- Hover effect
        actionButton.MouseEnter:Connect(function()
            TweenService:Create(actionButton, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Secondary}):Play()
        end)
        
        actionButton.MouseLeave:Connect(function()
            TweenService:Create(actionButton, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Primary}):Play()
        end)
    end
end

-- Auto Buy Section
function UIManager.CreateAutoBuySection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Auto Buy Seeds Card
    local seedsCard = UIManager.CreateCard(scroll, "🌱 Auto Buy Seeds", "Automatically purchase seeds when stock is low", 0)
    
    UIManager.CreateToggle(seedsCard, "Enable Auto Buy Seeds", "Automatically purchase selected seeds", AutomationConfig.AutoBuySeeds, "Enabled", 0)
    UIManager.CreateSlider(seedsCard, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuySeeds, "MaxSpend", 0, 50000000, 1)
    UIManager.CreateSlider(seedsCard, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuySeeds, "KeepMinimum", 0, 10000000, 2)
    UIManager.CreateSlider(seedsCard, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuySeeds, "MinStock", 1, 100, 3)
    UIManager.CreateSlider(seedsCard, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuySeeds, "BuyUpTo", 1, 200, 4)
    
    -- Auto Buy Gear Card
    local gearCard = UIManager.CreateCard(scroll, "⚒️ Auto Buy Gear", "Automatically purchase tools and gear", 1)
    
    UIManager.CreateToggle(gearCard, "Enable Auto Buy Gear", "Automatically purchase selected gear", AutomationConfig.AutoBuyGear, "Enabled", 0)
    UIManager.CreateSlider(gearCard, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuyGear, "MaxSpend", 0, 20000000, 1)
    UIManager.CreateSlider(gearCard, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuyGear, "KeepMinimum", 0, 5000000, 2)
    UIManager.CreateSlider(gearCard, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuyGear, "MinStock", 1, 50, 3)
    UIManager.CreateSlider(gearCard, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuyGear, "BuyUpTo", 1, 100, 4)
    
    -- Auto Buy Eggs Card
    local eggsCard = UIManager.CreateCard(scroll, "🥚 Auto Buy Eggs", "Automatically purchase pet eggs", 2)
    
    UIManager.CreateToggle(eggsCard, "Enable Auto Buy Eggs", "Automatically purchase selected eggs", AutomationConfig.AutoBuyEggs, "Enabled", 0)
    UIManager.CreateSlider(eggsCard, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuyEggs, "MaxSpend", 0, 100000000, 1)
    UIManager.CreateSlider(eggsCard, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuyEggs, "KeepMinimum", 0, 20000000, 2)
    UIManager.CreateSlider(eggsCard, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuyEggs, "MinStock", 0, 20, 3)
    UIManager.CreateSlider(eggsCard, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuyEggs, "BuyUpTo", 1, 50, 4)
end

-- Farming Section
function UIManager.CreateFarmingSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Auto Plant Card
    local plantCard = UIManager.CreateCard(scroll, "🌱 Auto Plant", "Automatically plant seeds in available spots", 0)
    
    UIManager.CreateToggle(plantCard, "Enable Auto Plant", "Automatically plant selected seeds", AutomationConfig.AutoPlant, "Enabled", 0)
    UIManager.CreateToggle(plantCard, "Use Watering Can", "Use watering can on planted seeds", AutomationConfig.AutoPlant, "UseWateringCan", 1)
    UIManager.CreateToggle(plantCard, "Auto Replant", "Automatically replant after harvest", AutomationConfig.AutoPlant, "AutoReplant", 2)
    UIManager.CreateToggle(plantCard, "Only Plant Selected", "Only plant seeds from selection", AutomationConfig.AutoPlant, "OnlyPlantSelected", 3)
    UIManager.CreateSlider(plantCard, "Plant Interval", "Seconds between planting", AutomationConfig.AutoPlant, "PlantInterval", 1, 10, 4)
    UIManager.CreateSlider(plantCard, "Max Plants Per Type", "Maximum plants of each type", AutomationConfig.AutoPlant, "MaxPlantsPerType", 10, 200, 5)
    
    -- Auto Collect Card
    local collectCard = UIManager.CreateCard(scroll, "🍓 Auto Collect", "Automatically collect grown plants", 1)
    
    UIManager.CreateToggle(collectCard, "Enable Auto Collect", "Automatically collect grown plants", AutomationConfig.AutoCollect, "Enabled", 0)
    UIManager.CreateToggle(collectCard, "Prioritize Rare Items", "Collect rare items first", AutomationConfig.AutoCollect, "PrioritizeRareItems", 1)
    UIManager.CreateToggle(collectCard, "Auto Sell", "Automatically sell collected items", AutomationConfig.AutoCollect, "AutoSell", 2)
    UIManager.CreateSlider(collectCard, "Collect Interval", "Seconds between collections", AutomationConfig.AutoCollect, "CollectInterval", 0.5, 5, 3)
    UIManager.CreateSlider(collectCard, "Collect Radius", "Collection range in studs", AutomationConfig.AutoCollect, "CollectRadius", 50, 300, 4)
    UIManager.CreateSlider(collectCard, "Sell Threshold", "Sell when inventory exceeds", AutomationConfig.AutoCollect, "SellThreshold", 50, 500, 5)
end

-- Pet Section
function UIManager.CreatePetSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Pet Management Card
    local petCard = UIManager.CreateCard(scroll, "🐾 Pet Management", "Automatically manage your pets", 0)
    
    UIManager.CreateToggle(petCard, "Enable Pet Management", "Automatically manage pets", AutomationConfig.PetManagement, "Enabled", 0)
    UIManager.CreateToggle(petCard, "Auto Equip", "Automatically equip pets", AutomationConfig.PetManagement, "AutoEquip", 1)
    UIManager.CreateToggle(petCard, "Auto Unequip", "Automatically unequip weak pets", AutomationConfig.PetManagement, "AutoUnequip", 2)
    UIManager.CreateToggle(petCard, "Auto Feed", "Automatically feed hungry pets", AutomationConfig.PetManagement, "AutoFeed", 3)
    UIManager.CreateToggle(petCard, "Auto Hatch Eggs", "Automatically hatch pet eggs", AutomationConfig.PetManagement, "AutoHatchEggs", 4)
    UIManager.CreateToggle(petCard, "Equip Best Pets", "Always equip the best pets", AutomationConfig.PetManagement, "EquipBestPets", 5)
    UIManager.CreateToggle(petCard, "Feed All Pets", "Feed all pets, not just equipped", AutomationConfig.PetManagement, "FeedAllPets", 6)
    UIManager.CreateSlider(petCard, "Feed Threshold", "Feed when hunger below", AutomationConfig.PetManagement, "FeedThreshold", 100, 1000, 7)
    UIManager.CreateSlider(petCard, "Hatch Interval", "Seconds between hatching", AutomationConfig.PetManagement, "HatchInterval", 5, 60, 8)
    UIManager.CreateSlider(petCard, "Pet Equip Slots", "Number of pet slots to use", AutomationConfig.PetManagement, "PetEquipSlots", 1, 6, 9)
end

-- Events Section
function UIManager.CreateEventsSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Events Card
    local eventsCard = UIManager.CreateCard(scroll, "🎯 Event Automation", "Automatically participate in events", 0)
    
    UIManager.CreateToggle(eventsCard, "Enable Event Automation", "Automatically participate in events", AutomationConfig.AutoEvents, "Enabled", 0)
    UIManager.CreateToggle(eventsCard, "Daily Quests", "Automatically complete daily quests", AutomationConfig.AutoEvents, "DailyQuests", 1)
    UIManager.CreateToggle(eventsCard, "Summer Harvest", "Participate in Summer Harvest", AutomationConfig.AutoEvents, "SummerHarvest", 2)
    UIManager.CreateToggle(eventsCard, "Blood Moon", "Participate in Blood Moon events", AutomationConfig.AutoEvents, "BloodMoon", 3)
    UIManager.CreateToggle(eventsCard, "Bee Swarm", "Participate in Bee Swarm events", AutomationConfig.AutoEvents, "BeeSwarm", 4)
    UIManager.CreateToggle(eventsCard, "Night Quests", "Complete night-time quests", AutomationConfig.AutoEvents, "NightQuests", 5)
    UIManager.CreateToggle(eventsCard, "Dino Events", "Participate in Dinosaur events", AutomationConfig.AutoEvents, "DinoEvents", 6)
    UIManager.CreateToggle(eventsCard, "Auto Claim", "Automatically claim rewards", AutomationConfig.AutoEvents, "AutoClaim", 7)
    UIManager.CreateToggle(eventsCard, "Auto Participate", "Automatically join events", AutomationConfig.AutoEvents, "AutoParticipate", 8)
end

-- Trading Section
function UIManager.CreateTradingSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Trading Card
    local tradingCard = UIManager.CreateCard(scroll, "💱 Trading Automation", "Automatically handle trades", 0)
    
    UIManager.CreateToggle(tradingCard, "Enable Trading", "Enable trading automation", AutomationConfig.AutoTrade, "Enabled", 0)
    UIManager.CreateToggle(tradingCard, "Auto Accept Trades", "Automatically accept incoming trades", AutomationConfig.AutoTrade, "AutoAcceptTrades", 1)
    UIManager.CreateToggle(tradingCard, "Auto Trade Fruits", "Automatically trade fruits", AutomationConfig.AutoTrade, "AutoTradeFruits", 2)
    UIManager.CreateToggle(tradingCard, "Auto Trade Pets", "Automatically trade pets", AutomationConfig.AutoTrade, "AutoTradePets", 3)
    UIManager.CreateToggle(tradingCard, "Target Player Enabled", "Enable target player trading", AutomationConfig.AutoTrade, "TargetPlayerEnabled", 4)
    UIManager.CreateToggle(tradingCard, "Auto Teleport to Target", "Teleport to target player", AutomationConfig.AutoTrade, "AutoTeleportToTarget", 5)
    UIManager.CreateToggle(tradingCard, "Trade All Fruits to Target", "Trade all fruits to target", AutomationConfig.AutoTrade, "TradeAllFruitsToTarget", 6)
    UIManager.CreateToggle(tradingCard, "Trade All Pets to Target", "Trade all pets to target", AutomationConfig.AutoTrade, "TradeAllPetsToTarget", 7)
    
    -- Target Player Input
    local targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetPlayer"
    targetFrame.Size = UDim2.new(1, 0, 0, 40)
    targetFrame.BackgroundTransparency = 1
    targetFrame.LayoutOrder = 8
    targetFrame.Parent = tradingCard
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.3, 0, 1, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target Player:"
    targetLabel.TextColor3 = UIConfig.Colors.Text
    targetLabel.TextSize = 13
    targetLabel.Font = Enum.Font.GothamSemibold
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = targetFrame
    
    local targetInput = Instance.new("TextBox")
    targetInput.Size = UDim2.new(0.7, 0, 0, 30)
    targetInput.Position = UDim2.new(0.3, 0, 0.5, -15)
    targetInput.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    targetInput.BorderSizePixel = 0
    targetInput.PlaceholderText = "Enter player name..."
    targetInput.Text = AutomationConfig.AutoTrade.TargetPlayerName or ""
    targetInput.TextColor3 = UIConfig.Colors.Text
    targetInput.TextSize = 12
    targetInput.Font = Enum.Font.Gotham
    targetInput.Parent = targetFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = targetInput
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.PaddingRight = UDim.new(0, 10)
    inputPadding.Parent = targetInput
    
    targetInput.FocusLost:Connect(function()
        AutomationConfig.AutoTrade.TargetPlayerName = targetInput.Text
    end)
    
    UIManager.CreateSlider(tradingCard, "Request Interval", "Seconds between trade requests", AutomationConfig.AutoTrade, "RequestInterval", 10, 120, 9)
    UIManager.CreateSlider(tradingCard, "Max Request Attempts", "Maximum trade attempts per session", AutomationConfig.AutoTrade, "MaxRequestAttempts", 1, 20, 10)
end

-- Misc Section
function UIManager.CreateMiscSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Misc Features Card
    local miscCard = UIManager.CreateCard(scroll, "⚙️ Miscellaneous Features", "Additional automation features", 0)
    
    UIManager.CreateToggle(miscCard, "Auto Open Packs", "Automatically open seed packs", AutomationConfig.MiscFeatures, "AutoOpenPacks", 0)
    UIManager.CreateToggle(miscCard, "Auto Use Gear", "Automatically use tools and gear", AutomationConfig.MiscFeatures, "AutoUseGear", 1)
    UIManager.CreateToggle(miscCard, "Auto Expand", "Automatically expand farm", AutomationConfig.MiscFeatures, "AutoExpand", 2)
    UIManager.CreateToggle(miscCard, "Auto Teleport", "Use teleportation features", AutomationConfig.MiscFeatures, "AutoTeleport", 3)
    UIManager.CreateToggle(miscCard, "Auto Craft Recipes", "Automatically craft items", AutomationConfig.MiscFeatures, "AutoCraftRecipes", 4)
    UIManager.CreateToggle(miscCard, "Auto Skip Animations", "Skip pack opening animations", AutomationConfig.MiscFeatures, "AutoSkipAnimations", 5)
    UIManager.CreateSlider(miscCard, "Pack Open Interval", "Seconds between pack opens", AutomationConfig.MiscFeatures, "PackOpenInterval", 1, 30, 6)
end

-- Performance Section
function UIManager.CreatePerformanceSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Performance Card
    local perfCard = UIManager.CreateCard(scroll, "⚡ Performance Optimization", "Optimize game performance", 0)
    
    UIManager.CreateToggle(perfCard, "Reduce Graphics", "Lower graphics quality for performance", AutomationConfig.Performance, "ReduceGraphics", 0)
    UIManager.CreateToggle(perfCard, "Disable Animations", "Disable character animations", AutomationConfig.Performance, "DisableAnimations", 1)
    UIManager.CreateToggle(perfCard, "Low Memory Mode", "Reduce memory usage", AutomationConfig.Performance, "LowMemoryMode", 2)
    UIManager.CreateToggle(perfCard, "Optimize Rendering", "Optimize rendering performance", AutomationConfig.Performance, "OptimizeRendering", 3)
    UIManager.CreateToggle(perfCard, "Disable Particles", "Disable particle effects", AutomationConfig.Performance, "DisableParticles", 4)
    UIManager.CreateSlider(perfCard, "Max FPS", "Maximum frames per second", AutomationConfig.Performance, "MaxFPS", 30, 120, 5)
end

-- Settings Section
function UIManager.CreateSettingsSection(parent)
    local scroll = UIManager.CreateScrollFrame(parent)
    
    -- Webhook Card
    local webhookCard = UIManager.CreateCard(scroll, "🔔 Discord Webhook", "Configure Discord notifications", 0)
    
    -- Webhook URL Input
    local webhookFrame = Instance.new("Frame")
    webhookFrame.Name = "WebhookURL"
    webhookFrame.Size = UDim2.new(1, 0, 0, 50)
    webhookFrame.BackgroundTransparency = 1
    webhookFrame.LayoutOrder = 0
    webhookFrame.Parent = webhookCard
    
    local webhookLabel = Instance.new("TextLabel")
    webhookLabel.Size = UDim2.new(1, 0, 0, 20)
    webhookLabel.BackgroundTransparency = 1
    webhookLabel.Text = "Discord Webhook URL:"
    webhookLabel.TextColor3 = UIConfig.Colors.Text
    webhookLabel.TextSize = 13
    webhookLabel.Font = Enum.Font.GothamSemibold
    webhookLabel.TextXAlignment = Enum.TextXAlignment.Left
    webhookLabel.Parent = webhookFrame
    
    local webhookInput = Instance.new("TextBox")
    webhookInput.Size = UDim2.new(1, 0, 0, 25)
    webhookInput.Position = UDim2.new(0, 0, 0, 22)
    webhookInput.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    webhookInput.BorderSizePixel = 0
    webhookInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    webhookInput.Text = AutomationConfig.WebhookURL or ""
    webhookInput.TextColor3 = UIConfig.Colors.Text
    webhookInput.TextSize = 11
    webhookInput.Font = Enum.Font.Gotham
    webhookInput.Parent = webhookFrame
    
    local webhookCorner = Instance.new("UICorner")
    webhookCorner.CornerRadius = UDim.new(0, 6)
    webhookCorner.Parent = webhookInput
    
    local webhookPadding = Instance.new("UIPadding")
    webhookPadding.PaddingLeft = UDim.new(0, 10)
    webhookPadding.PaddingRight = UDim.new(0, 10)
    webhookPadding.Parent = webhookInput
    
    webhookInput.FocusLost:Connect(function()
        AutomationConfig.WebhookURL = webhookInput.Text
        webhook:SetURL(webhookInput.Text)
    end)
    
    -- Log Level
    local logFrame = Instance.new("Frame")
    logFrame.Name = "LogLevel"
    logFrame.Size = UDim2.new(1, 0, 0, 40)
    logFrame.BackgroundTransparency = 1
    logFrame.LayoutOrder = 1
    logFrame.Parent = webhookCard
    
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(0.3, 0, 1, 0)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = "Log Level:"
    logLabel.TextColor3 = UIConfig.Colors.Text
    logLabel.TextSize = 13
    logLabel.Font = Enum.Font.GothamSemibold
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.Parent = logFrame
    
    local logDropdown = Instance.new("TextButton")
    logDropdown.Size = UDim2.new(0.7, 0, 0, 30)
    logDropdown.Position = UDim2.new(0.3, 0, 0.5, -15)
    logDropdown.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    logDropdown.BorderSizePixel = 0
    logDropdown.Text = AutomationConfig.LogLevel or "INFO"
    logDropdown.TextColor3 = UIConfig.Colors.Text
    logDropdown.TextSize = 12
    logDropdown.Font = Enum.Font.Gotham
    logDropdown.Parent = logFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = logDropdown
    
    local logLevels = {"INFO", "WARN", "ERROR"}
    local currentLogLevel = 1
    
    for i, level in ipairs(logLevels) do
        if level == AutomationConfig.LogLevel then
            currentLogLevel = i
            break
        end
    end
    
    logDropdown.MouseButton1Click:Connect(function()
        currentLogLevel = currentLogLevel % #logLevels + 1
        AutomationConfig.LogLevel = logLevels[currentLogLevel]
        logDropdown.Text = logLevels[currentLogLevel]
    end)
    
    -- General Settings Card
    local generalCard = UIManager.CreateCard(scroll, "⚙️ General Settings", "General automation settings", 1)
    
    -- Export/Import Config buttons
    local configFrame = Instance.new("Frame")
    configFrame.Name = "ConfigButtons"
    configFrame.Size = UDim2.new(1, 0, 0, 40)
    configFrame.BackgroundTransparency = 1
    configFrame.LayoutOrder = 0
    configFrame.Parent = generalCard
    
    local configLayout = Instance.new("UIListLayout")
    configLayout.FillDirection = Enum.FillDirection.Horizontal
    configLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    configLayout.Padding = UDim.new(0, 10)
    configLayout.Parent = configFrame
    
    local exportButton = Instance.new("TextButton")
    exportButton.Size = UDim2.new(0, 150, 0, 35)
    exportButton.BackgroundColor3 = UIConfig.Colors.Success
    exportButton.BorderSizePixel = 0
    exportButton.Text = "Export Config"
    exportButton.TextColor3 = UIConfig.Colors.Text
    exportButton.TextSize = 12
    exportButton.Font = Enum.Font.GothamSemibold
    exportButton.Parent = configFrame
    
    local exportCorner = Instance.new("UICorner")
    exportCorner.CornerRadius = UDim.new(0, 8)
    exportCorner.Parent = exportButton
    
    local importButton = Instance.new("TextButton")
    importButton.Size = UDim2.new(0, 150, 0, 35)
    importButton.BackgroundColor3 = UIConfig.Colors.Warning
    importButton.BorderSizePixel = 0
    importButton.Text = "Import Config"
    importButton.TextColor3 = UIConfig.Colors.Text
    importButton.TextSize = 12
    importButton.Font = Enum.Font.GothamSemibold
    importButton.Parent = configFrame
    
    local importCorner = Instance.new("UICorner")
    importCorner.CornerRadius = UDim.new(0, 8)
    importCorner.Parent = importButton
    
    exportButton.MouseButton1Click:Connect(function()
        local configJson = HttpService:JSONEncode(AutomationConfig)
        setclipboard(configJson)
        webhook:Log("INFO", "Configuration exported to clipboard")
    end)
    
    importButton.MouseButton1Click:Connect(function()
        local success, newConfig = pcall(function()
            return HttpService:JSONDecode(getclipboard())
        end)
        
        if success then
            for key, value in pairs(newConfig) do
                if AutomationConfig[key] then
                    AutomationConfig[key] = value
                end
            end
            webhook:Log("INFO", "Configuration imported from clipboard")
            UIManager.UpdateContentArea() -- Refresh UI
        else
            webhook:Log("ERROR", "Failed to import configuration")
        end
    end)
end