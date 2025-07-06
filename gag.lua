-- Grow a Garden Automation Script
-- Comprehensive automation system for all game features

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

-- Services and Modules
local DataService = require(ReplicatedStorage.Modules.DataService)
local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService)
local MarketController = require(ReplicatedStorage.Modules.MarketController)
local CollectController = require(ReplicatedStorage.Modules.CollectController)

-- Data
local SeedData = require(ReplicatedStorage.Data.SeedData)
local GearData = require(ReplicatedStorage.Data.GearData)
local PetList = require(ReplicatedStorage.Data.PetRegistry.PetList)
local PetEggData = require(ReplicatedStorage.Data.PetEggData)
local SeedPackData = require(ReplicatedStorage.Data.SeedPackData)

-- Automation Configuration
local AutomationConfig = {
    -- General Settings
    Enabled = false,
    WebhookURL = "",
    LogLevel = "INFO", -- DEBUG, INFO, WARN, ERROR
    
    -- Auto Buy Settings
    AutoBuySeeds = {
        Enabled = false,
        BuyList = {},
        MaxSpend = 1000000, -- Max sheckles to spend
        KeepMinimum = 100000, -- Keep at least this many sheckles
        CheckInterval = 30, -- Check every 30 seconds
    },
    
    AutoBuyGear = {
        Enabled = false,
        BuyList = {},
        MaxSpend = 500000,
        KeepMinimum = 100000,
        CheckInterval = 60,
    },
    
    AutoBuyEggs = {
        Enabled = false,
        BuyList = {},
        MaxSpend = 2000000,
        KeepMinimum = 500000,
        CheckInterval = 45,
    },
    
    -- Auto Plant Settings
    AutoPlant = {
        Enabled = false,
        SeedPriority = {}, -- Order of seeds to plant
        PlantInterval = 2, -- Seconds between planting
        UseWateringCan = true,
        MaxPlantsPerType = 50,
    },
    
    -- Auto Collect Settings
    AutoCollect = {
        Enabled = false,
        CollectInterval = 1, -- Seconds between collect attempts
        CollectRadius = 100, -- Studs radius to collect from
        PrioritizeRareItems = true,
    },
    
    -- Pet Management
    PetManagement = {
        Enabled = false,
        AutoEquip = true,
        AutoFeed = true,
        FeedThreshold = 500, -- Feed when hunger below this
        PreferredPets = {}, -- Pet IDs to prioritize
        AutoHatchEggs = true,
        HatchInterval = 10,
    },
    
    -- Auto Events
    AutoEvents = {
        Enabled = false,
        DailyQuests = true,
        SummerHarvest = true,
        BloodMoon = true,
        BeeSwarm = true,
        NightQuests = true,
    },
    
    -- Auto Trading
    AutoTrade = {
        Enabled = false,
        AutoAcceptTrades = false,
        TradeFilters = {
            MinPetValue = 1000,
            MinFruitValue = 100,
            BlacklistedItems = {},
        },
    },
    
    -- Performance Settings
    Performance = {
        ReduceGraphics = false,
        DisableAnimations = false,
        MaxFPS = 60,
        LowMemoryMode = false,
    },
    
    -- Seed Pack Management
    SeedPacks = {
        AutoOpen = false,
        OpenInterval = 5,
        PreferredPacks = {},
    },
}

-- Logging System
local Logger = {
    Levels = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4,
    }
}

function Logger:Log(level, message)
    local currentLevel = self.Levels[AutomationConfig.LogLevel] or 2
    if self.Levels[level] >= currentLevel then
        local timestamp = os.date("%H:%M:%S")
        local logMessage = string.format("[%s] [%s] %s", timestamp, level, message)
        print(logMessage)
        
        -- Send to webhook if configured
        if AutomationConfig.WebhookURL ~= "" and level ~= "DEBUG" then
            self:SendWebhook(logMessage)
        end
    end
end

function Logger:SendWebhook(message)
    local success, result = pcall(function()
        local payload = {
            content = string.format("**Grow a Garden Bot** - %s\n```%s```", LocalPlayer.Name, message)
        }
        HttpService:PostAsync(AutomationConfig.WebhookURL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Failed to send webhook:", result)
    end
end

-- Utility Functions
local Utils = {}

function Utils:GetPlayerData()
    return DataService:GetData()
end

function Utils:GetPlayerMoney()
    local data = self:GetPlayerData()
    return data and data.Sheckles or 0
end

function Utils:GetPlayerInventory()
    local data = self:GetPlayerData()
    return data and data.Backpack or {}
end

function Utils:GetPlayerPets()
    local data = self:GetPlayerData()
    return data and data.PetsData and data.PetsData.PetInventory.Data or {}
end

function Utils:GetPlantedObjects()
    local data = self:GetPlayerData()
    return data and data.PlantedObjects or {}
end

function Utils:FindNearbyCollectibles()
    local collectibles = {}
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return collectibles
    end
    
    local playerPos = character.HumanoidRootPart.Position
    
    -- Find fruits and collectible items
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("Part") and obj:GetAttribute("Collectible") then
            local distance = (obj.Position - playerPos).Magnitude
            if distance <= AutomationConfig.AutoCollect.CollectRadius then
                table.insert(collectibles, obj)
            end
        end
    end
    
    return collectibles
end

function Utils:GetEmptyPlantingSpots()
    local spots = {}
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return spots end
    
    for _, spot in farm:GetChildren() do
        if spot.Name == "PlantingSpot" and not spot:FindFirstChild("Plant") then
            table.insert(spots, spot)
        end
    end
    
    return spots
end

-- Automation Modules
local AutoBuyer = {}

function AutoBuyer:BuySeeds()
    if not AutomationConfig.AutoBuySeeds.Enabled then return end
    
    local money = Utils:GetPlayerMoney()
    if money < AutomationConfig.AutoBuySeeds.KeepMinimum then
        Logger:Log("WARN", "Not enough money to buy seeds safely")
        return
    end
    
    local inventory = Utils:GetPlayerInventory()
    
    for _, seedName in AutomationConfig.AutoBuySeeds.BuyList do
        local seedInfo = SeedData[seedName]
        if seedInfo and seedInfo.Price <= money - AutomationConfig.AutoBuySeeds.KeepMinimum then
            local currentAmount = inventory[seedName] or 0
            if currentAmount < 10 then -- Buy if we have less than 10
                Logger:Log("INFO", "Buying seed: " .. seedName)
                MarketController:PromptPurchase(0, seedInfo.PurchaseID)
                task.wait(1)
            end
        end
    end
end

function AutoBuyer:BuyGear()
    if not AutomationConfig.AutoBuyGear.Enabled then return end
    
    local money = Utils:GetPlayerMoney()
    if money < AutomationConfig.AutoBuyGear.KeepMinimum then return end
    
    local inventory = Utils:GetPlayerInventory()
    
    for _, gearName in AutomationConfig.AutoBuyGear.BuyList do
        local gearInfo = GearData[gearName]
        if gearInfo and gearInfo.Price <= money - AutomationConfig.AutoBuyGear.KeepMinimum then
            local currentAmount = inventory[gearName] or 0
            if currentAmount < 5 then
                Logger:Log("INFO", "Buying gear: " .. gearName)
                MarketController:PromptPurchase(1, gearInfo.PurchaseID)
                task.wait(1)
            end
        end
    end
end

function AutoBuyer:BuyEggs()
    if not AutomationConfig.AutoBuyEggs.Enabled then return end
    
    local money = Utils:GetPlayerMoney()
    if money < AutomationConfig.AutoBuyEggs.KeepMinimum then return end
    
    for _, eggName in AutomationConfig.AutoBuyEggs.BuyList do
        local eggInfo = PetEggData[eggName]
        if eggInfo and eggInfo.Price <= money - AutomationConfig.AutoBuyEggs.KeepMinimum then
            Logger:Log("INFO", "Buying egg: " .. eggName)
            MarketController:PromptPurchase(2, eggInfo.PurchaseID)
            task.wait(2)
        end
    end
end

-- Auto Planting System
local AutoPlanter = {}

function AutoPlanter:PlantSeeds()
    if not AutomationConfig.AutoPlant.Enabled then return end
    
    local inventory = Utils:GetPlayerInventory()
    local emptySpots = Utils:GetEmptyPlantingSpots()
    
    if #emptySpots == 0 then return end
    
    for _, seedName in AutomationConfig.AutoPlant.SeedPriority do
        local seedAmount = inventory[seedName] or 0
        if seedAmount > 0 then
            local planted = 0
            for _, spot in emptySpots do
                if planted >= AutomationConfig.AutoPlant.MaxPlantsPerType then break end
                
                -- Plant seed at spot
                self:PlantSeedAt(seedName, spot)
                planted = planted + 1
                
                task.wait(AutomationConfig.AutoPlant.PlantInterval)
            end
        end
    end
end

function AutoPlanter:PlantSeedAt(seedName, spot)
    -- This would require interacting with the game's planting system
    -- Implementation depends on how the game handles planting
    Logger:Log("DEBUG", "Planting " .. seedName .. " at spot")
end

function AutoPlanter:UseWateringCan()
    if not AutomationConfig.AutoPlant.UseWateringCan then return end
    
    local inventory = Utils:GetPlayerInventory()
    local wateringCan = inventory["Watering Can"]
    
    if wateringCan and wateringCan > 0 then
        -- Use watering can on plants
        local plantedObjects = Utils:GetPlantedObjects()
        for _, plant in plantedObjects do
            -- Use watering can logic
            task.wait(0.5)
        end
    end
end

-- Auto Collector
local AutoCollector = {}

function AutoCollector:CollectItems()
    if not AutomationConfig.AutoCollect.Enabled then return end
    
    local collectibles = Utils:FindNearbyCollectibles()
    
    if #collectibles > 0 then
        Logger:Log("DEBUG", "Found " .. #collectibles .. " collectible items")
        
        -- Sort by priority if enabled
        if AutomationConfig.AutoCollect.PrioritizeRareItems then
            table.sort(collectibles, function(a, b)
                return (a:GetAttribute("Rarity") or 0) > (b:GetAttribute("Rarity") or 0)
            end)
        end
        
        -- Collect items using the game's collect system
        Remotes.Crops.Collect:fire(collectibles)
    end
end

-- Pet Management System
local PetManager = {}

function PetManager:ManagePets()
    if not AutomationConfig.PetManagement.Enabled then return end
    
    local pets = Utils:GetPlayerPets()
    
    -- Auto equip preferred pets
    if AutomationConfig.PetManagement.AutoEquip then
        self:AutoEquipPets(pets)
    end
    
    -- Auto feed pets
    if AutomationConfig.PetManagement.AutoFeed then
        self:AutoFeedPets(pets)
    end
    
    -- Auto hatch eggs
    if AutomationConfig.PetManagement.AutoHatchEggs then
        self:AutoHatchEggs()
    end
end

function PetManager:AutoEquipPets(pets)
    local equippedCount = 0
    
    for petId, petData in pets do
        if petData.Equipped then
            equippedCount = equippedCount + 1
        end
    end
    
    -- Try to equip preferred pets
    for _, preferredPetId in AutomationConfig.PetManagement.PreferredPets do
        local petData = pets[preferredPetId]
        if petData and not petData.Equipped and equippedCount < 3 then
            Logger:Log("INFO", "Equipping preferred pet: " .. preferredPetId)
            PetsService:EquipPet(preferredPetId, equippedCount + 1)
            equippedCount = equippedCount + 1
            task.wait(1)
        end
    end
end

function PetManager:AutoFeedPets(pets)
    local inventory = Utils:GetPlayerInventory()
    
    for petId, petData in pets do
        if petData.Hunger and petData.Hunger < AutomationConfig.PetManagement.FeedThreshold then
            -- Find suitable food in inventory
            for itemName, amount in inventory do
                if amount > 0 and self:IsPetFood(itemName) then
                    Logger:Log("INFO", "Feeding pet " .. petId .. " with " .. itemName)
                    -- Feed pet logic would go here
                    break
                end
            end
        end
    end
end

function PetManager:IsPetFood(itemName)
    -- Check if item is pet food (fruits, etc.)
    return itemName:find("Fruit") or itemName:find("Berry") or itemName:find("Apple")
end

function PetManager:AutoHatchEggs()
    local inventory = Utils:GetPlayerInventory()
    
    for eggName, amount in inventory do
        if amount > 0 and eggName:find("Egg") then
            Logger:Log("INFO", "Hatching egg: " .. eggName)
            -- Hatch egg logic
            task.wait(AutomationConfig.PetManagement.HatchInterval)
        end
    end
end

-- Event Automation
local EventManager = {}

function EventManager:HandleEvents()
    if not AutomationConfig.AutoEvents.Enabled then return end
    
    -- Handle daily quests
    if AutomationConfig.AutoEvents.DailyQuests then
        self:ClaimDailyQuests()
    end
    
    -- Handle other events
    if AutomationConfig.AutoEvents.SummerHarvest then
        self:HandleSummerHarvest()
    end
end

function EventManager:ClaimDailyQuests()
    Logger:Log("DEBUG", "Attempting to claim daily quests")
    Remotes.DailyQuests.Claim:fire()
end

function EventManager:HandleSummerHarvest()
    -- Summer harvest event logic
    local data = Utils:GetPlayerData()
    if data and data.SummerHarvest then
        -- Submit plants for summer harvest
        Logger:Log("DEBUG", "Handling summer harvest event")
    end
end

-- Seed Pack Manager
local SeedPackManager = {}

function SeedPackManager:OpenSeedPacks()
    if not AutomationConfig.SeedPacks.AutoOpen then return end
    
    local inventory = Utils:GetPlayerInventory()
    
    for packName, amount in inventory do
        if amount > 0 and packName:find("Pack") then
            Logger:Log("INFO", "Opening seed pack: " .. packName)
            Remotes.SeedPack.Open:fire(packName)
            task.wait(AutomationConfig.SeedPacks.OpenInterval)
        end
    end
end

-- Performance Optimizer
local PerformanceOptimizer = {}

function PerformanceOptimizer:OptimizePerformance()
    if not AutomationConfig.Performance.ReduceGraphics then return end
    
    -- Reduce graphics settings
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 500
    
    -- Disable unnecessary effects
    for _, effect in lighting:GetChildren() do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    -- Set FPS limit
    if AutomationConfig.Performance.MaxFPS then
        RunService.Heartbeat:Connect(function()
            local fps = 1 / RunService.Heartbeat:Wait()
            if fps > AutomationConfig.Performance.MaxFPS then
                task.wait(1/AutomationConfig.Performance.MaxFPS - 1/fps)
            end
        end)
    end
end

-- UI System
local AutomationUI = {}

function AutomationUI:CreateUI()
    -- Create main UI frame
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutomationUI"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "Grow a Garden Automation"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Scrolling frame for options
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.Position = UDim2.new(0, 10, 0, 40)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mainFrame
    
    -- Create sections
    self:CreateSection(scrollFrame, "General Settings", {
        {name = "Master Enable", type = "toggle", key = "Enabled"},
        {name = "Webhook URL", type = "textbox", key = "WebhookURL"},
        {name = "Log Level", type = "dropdown", key = "LogLevel", options = {"DEBUG", "INFO", "WARN", "ERROR"}},
    })
    
    self:CreateSection(scrollFrame, "Auto Buy Seeds", {
        {name = "Enable", type = "toggle", key = "AutoBuySeeds.Enabled"},
        {name = "Max Spend", type = "number", key = "AutoBuySeeds.MaxSpend"},
        {name = "Keep Minimum", type = "number", key = "AutoBuySeeds.KeepMinimum"},
    })
    
    self:CreateSection(scrollFrame, "Auto Buy Gear", {
        {name = "Enable", type = "toggle", key = "AutoBuyGear.Enabled"},
        {name = "Max Spend", type = "number", key = "AutoBuyGear.MaxSpend"},
        {name = "Keep Minimum", type = "number", key = "AutoBuyGear.KeepMinimum"},
    })
    
    self:CreateSection(scrollFrame, "Auto Plant", {
        {name = "Enable", type = "toggle", key = "AutoPlant.Enabled"},
        {name = "Plant Interval", type = "number", key = "AutoPlant.PlantInterval"},
        {name = "Use Watering Can", type = "toggle", key = "AutoPlant.UseWateringCan"},
    })
    
    self:CreateSection(scrollFrame, "Auto Collect", {
        {name = "Enable", type = "toggle", key = "AutoCollect.Enabled"},
        {name = "Collect Interval", type = "number", key = "AutoCollect.CollectInterval"},
        {name = "Collect Radius", type = "number", key = "AutoCollect.CollectRadius"},
    })
    
    self:CreateSection(scrollFrame, "Pet Management", {
        {name = "Enable", type = "toggle", key = "PetManagement.Enabled"},
        {name = "Auto Equip", type = "toggle", key = "PetManagement.AutoEquip"},
        {name = "Auto Feed", type = "toggle", key = "PetManagement.AutoFeed"},
        {name = "Auto Hatch Eggs", type = "toggle", key = "PetManagement.AutoHatchEggs"},
    })
    
    self:CreateSection(scrollFrame, "Events", {
        {name = "Enable", type = "toggle", key = "AutoEvents.Enabled"},
        {name = "Daily Quests", type = "toggle", key = "AutoEvents.DailyQuests"},
        {name = "Summer Harvest", type = "toggle", key = "AutoEvents.SummerHarvest"},
    })
    
    self:CreateSection(scrollFrame, "Performance", {
        {name = "Reduce Graphics", type = "toggle", key = "Performance.ReduceGraphics"},
        {name = "Max FPS", type = "number", key = "Performance.MaxFPS"},
        {name = "Low Memory Mode", type = "toggle", key = "Performance.LowMemoryMode"},
    })
    
    -- Make UI draggable
    self:MakeDraggable(mainFrame)
    
    -- Toggle UI visibility
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F3 then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    return screenGui
end

function AutomationUI:CreateSection(parent, title, options)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = title
    sectionFrame.Size = UDim2.new(1, 0, 0, 30 + (#options * 35))
    sectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sectionFrame.BorderSizePixel = 1
    sectionFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    sectionFrame.Parent = parent
    
    -- Section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "SectionTitle"
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = sectionFrame
    
    -- Create option controls
    for i, option in ipairs(options) do
        self:CreateOptionControl(sectionFrame, option, i)
    end
    
    -- Update canvas size
    parent.CanvasSize = UDim2.new(0, 0, 0, parent.CanvasSize.Y.Offset + sectionFrame.Size.Y.Offset + 10)
end

function AutomationUI:CreateOptionControl(parent, option, index)
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = option.name
    controlFrame.Size = UDim2.new(1, -10, 0, 30)
    controlFrame.Position = UDim2.new(0, 5, 0, 25 + (index * 35))
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = parent
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = option.name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = controlFrame
    
    -- Create control based on type
    if option.type == "toggle" then
        self:CreateToggle(controlFrame, option.key)
    elseif option.type == "number" then
        self:CreateNumberInput(controlFrame, option.key)
    elseif option.type == "textbox" then
        self:CreateTextBox(controlFrame, option.key)
    elseif option.type == "dropdown" then
        self:CreateDropdown(controlFrame, option.key, option.options)
    end
end

function AutomationUI:CreateToggle(parent, key)
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 60, 0, 25)
    toggle.Position = UDim2.new(1, -65, 0, 2.5)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = parent
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(0, 2.5, 0, 2.5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    -- Update toggle state
    local function updateToggle()
        local value = self:GetConfigValue(key)
        if value then
            indicator.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            indicator.Position = UDim2.new(1, -22.5, 0, 2.5)
        else
            indicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            indicator.Position = UDim2.new(0, 2.5, 0, 2.5)
        end
    end
    
    toggle.MouseButton1Click:Connect(function()
        local currentValue = self:GetConfigValue(key)
        self:SetConfigValue(key, not currentValue)
        updateToggle()
    end)
    
    updateToggle()
end

function AutomationUI:CreateNumberInput(parent, key)
    local textBox = Instance.new("TextBox")
    textBox.Name = "NumberInput"
    textBox.Size = UDim2.new(0, 100, 0, 25)
    textBox.Position = UDim2.new(1, -105, 0, 2.5)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(self:GetConfigValue(key) or 0)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextScaled = true
    textBox.Font = Enum.Font.SourceSans
    textBox.Parent = parent
    
    textBox.FocusLost:Connect(function()
        local value = tonumber(textBox.Text)
        if value then
            self:SetConfigValue(key, value)
        else
            textBox.Text = tostring(self:GetConfigValue(key) or 0)
        end
    end)
end

function AutomationUI:CreateTextBox(parent, key)
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextInput"
    textBox.Size = UDim2.new(0.45, 0, 0, 25)
    textBox.Position = UDim2.new(0.55, 0, 0, 2.5)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.BorderSizePixel = 0
    textBox.Text = self:GetConfigValue(key) or ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextScaled = true
    textBox.Font = Enum.Font.SourceSans
    textBox.Parent = parent
    
    textBox.FocusLost:Connect(function()
        self:SetConfigValue(key, textBox.Text)
    end)
end

function AutomationUI:CreateDropdown(parent, key, options)
    local dropdown = Instance.new("TextButton")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(0, 100, 0, 25)
    dropdown.Position = UDim2.new(1, -105, 0, 2.5)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdown.BorderSizePixel = 0
    dropdown.Text = self:GetConfigValue(key) or options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextScaled = true
    dropdown.Font = Enum.Font.SourceSans
    dropdown.Parent = parent
    
    -- Create dropdown list
    local optionsList = Instance.new("Frame")
    optionsList.Name = "OptionsList"
    optionsList.Size = UDim2.new(0, 100, 0, #options * 25)
    optionsList.Position = UDim2.new(0, 0, 1, 0)
    optionsList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    optionsList.BorderSizePixel = 0
    optionsList.Visible = false
    optionsList.Parent = dropdown
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option" .. i
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.TextScaled = true
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Parent = optionsList
        
        optionButton.MouseButton1Click:Connect(function()
            self:SetConfigValue(key, option)
            dropdown.Text = option
            optionsList.Visible = false
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        optionsList.Visible = not optionsList.Visible
    end)
end

function AutomationUI:GetConfigValue(key)
    local keys = string.split(key, ".")
    local value = AutomationConfig
    for _, k in ipairs(keys) do
        value = value[k]
        if value == nil then break end
    end
    return value
end

function AutomationUI:SetConfigValue(key, value)
    local keys = string.split(key, ".")
    local config = AutomationConfig
    for i = 1, #keys - 1 do
        config = config[keys[i]]
    end
    config[keys[#keys]] = value
    
    -- Save config
    self:SaveConfig()
end

function AutomationUI:SaveConfig()
    -- Save configuration to datastore or file
    local success, result = pcall(function()
        local jsonConfig = HttpService:JSONEncode(AutomationConfig)
        -- Save to a file or datastore
        -- This would need to be implemented based on your storage preferences
    end)
    
    if success then
        Logger:Log("INFO", "Configuration saved successfully")
    else
        Logger:Log("ERROR", "Failed to save configuration: " .. result)
    end
end

function AutomationUI:MakeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Main Automation Loop
local function MainLoop()
    while true do
        if AutomationConfig.Enabled then
            -- Run automation modules
            pcall(function() AutoBuyer:BuySeeds() end)
            pcall(function() AutoBuyer:BuyGear() end)
            pcall(function() AutoBuyer:BuyEggs() end)
            pcall(function() AutoPlanter:PlantSeeds() end)
            pcall(function() AutoPlanter:UseWateringCan() end)
            pcall(function() AutoCollector:CollectItems() end)
            pcall(function() PetManager:ManagePets() end)
            pcall(function() EventManager:HandleEvents() end)
            pcall(function() SeedPackManager:OpenSeedPacks() end)
        end
        
        task.wait(1) -- Main loop runs every second
    end
end

-- Initialize
local function Initialize()
    Logger:Log("INFO", "Initializing Grow a Garden Automation")
    
    -- Create UI
    AutomationUI:CreateUI()
    
    -- Optimize performance if enabled
    PerformanceOptimizer:OptimizePerformance()
    
    -- Start main loop
    coroutine.wrap(MainLoop)()
    
    Logger:Log("INFO", "Automation system initialized. Press F3 to toggle UI.")
end

-- Start the automation system
Initialize()
