-- Advanced Automation UI for Grow a Garden
-- Modern design with floating toggle and item selection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- Import game data
local SeedData = require(ReplicatedStorage.Data.SeedData)
local GearData = require(ReplicatedStorage.Data.GearData)
local PetEggData = require(ReplicatedStorage.Data.PetEggData)
local SeedPackData = require(ReplicatedStorage.Data.SeedPackData)

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

-- Game Items Database (from analysis)
local GameItems = {
    Seeds = {
        -- Common Seeds
        {name = "Carrot", rarity = "Common", price = 10, id = 3248692171},
        {name = "Strawberry", rarity = "Common", price = 50, id = 3248695947},
        -- Uncommon Seeds
        {name = "Blueberry", rarity = "Uncommon", price = 400, id = 3248690960},
        {name = "Orange Tulip", rarity = "Uncommon", price = 600, id = 3265927408},
        -- Rare Seeds
        {name = "Tomato", rarity = "Rare", price = 800, id = 3248696942},
        {name = "Daffodil", rarity = "Rare", price = 1000, id = 3265927978},
        {name = "Cauliflower", rarity = "Rare", price = 1300, id = 3312007044},
        -- Legendary Seeds
        {name = "Watermelon", rarity = "Legendary", price = 2500, id = 3248697546},
        {name = "Rafflesia", rarity = "Legendary", price = 3200, id = 3317729900},
        {name = "Apple", rarity = "Legendary", price = 3250, id = 3248716238},
        {name = "Green Apple", rarity = "Legendary", price = 3500, id = 3312008833},
        {name = "Bamboo", rarity = "Legendary", price = 4000, id = 3261009117},
        {name = "Avocado", rarity = "Legendary", price = 5000, id = 3312011056},
        {name = "Banana", rarity = "Legendary", price = 7000, id = 3269001250},
        -- Mythical Seeds
        {name = "Coconut", rarity = "Mythical", price = 6000, id = 3248744789},
        {name = "Pineapple", rarity = "Mythical", price = 7500, id = 3312005774},
        {name = "Kiwi", rarity = "Mythical", price = 10000, id = 3312011732},
        {name = "Cactus", rarity = "Mythical", price = 15000, id = 3260940714},
        {name = "Dragon Fruit", rarity = "Mythical", price = 50000, id = 3253012192},
        {name = "Bell Pepper", rarity = "Mythical", price = 55000, id = 3312012483},
        {name = "Mango", rarity = "Mythical", price = 100000, id = 3259333414},
        {name = "Prickly Pear", rarity = "Mythical", price = 555000, id = 3312013208},
        -- Divine Seeds
        {name = "Grape", rarity = "Divine", price = 850000, id = 3261068725},
        {name = "Loquat", rarity = "Divine", price = 900000, id = 3312014286},
        {name = "Pepper", rarity = "Divine", price = 1000000, id = 3277675404},
        {name = "Mushroom", rarity = "Divine", price = 150000, id = 3273973729},
        {name = "Cacao", rarity = "Divine", price = 2500000, id = 3282870834},
        {name = "Feijoa", rarity = "Divine", price = 2750000, id = 3312013874},
        {name = "Pitcher Plant", rarity = "Divine", price = 7500000, id = 3317730202},
        -- Prismatic Seeds
        {name = "Beanstalk", rarity = "Prismatic", price = 10000000, id = 3284390402},
        {name = "Ember Lily", rarity = "Prismatic", price = 15000000, id = 3300984139},
        {name = "Sugar Apple", rarity = "Prismatic", price = 25000000, id = 3304968889},
        {name = "Burning Bud", rarity = "Prismatic", price = 40000000, id = 3316826714},
    },
    
    Gear = {
        -- Common Gear
        {name = "Watering Can", rarity = "Common", price = 50000, id = 3260229242, stack = 10, desc = "Speeds up plant growth. 10 uses"},
        -- Uncommon Gear
        {name = "Trowel", rarity = "Uncommon", price = 100000, id = 3265946561, stack = 5, desc = "Moves plants. 5 uses"},
        {name = "Recall Wrench", rarity = "Uncommon", price = 150000, id = 3282918403, stack = 5, desc = "Teleports to Gear Shop. 5 uses"},
        -- Rare Gear
        {name = "Basic Sprinkler", rarity = "Rare", price = 25000, id = 3265889601, stack = 1, desc = "Increases growth speed and fruit size. Lasts 5 minutes"},
        -- Legendary Gear
        {name = "Advanced Sprinkler", rarity = "Legendary", price = 50000, id = 3265889751, stack = 1, desc = "Increases growth speed and mutation chances. Lasts 5 minutes"},
        -- Mythical Gear
        {name = "Godly Sprinkler", rarity = "Mythical", price = 120000, id = 3265889948, stack = 1, desc = "Increases growth speed, mutation chances and fruit size. Lasts 5 minutes"},
        {name = "Magnifying Glass", rarity = "Mythical", price = 10000000, id = 3316261725, stack = 10, desc = "Inspect plants to reveal value without collecting"},
        {name = "Tanning Mirror", rarity = "Mythical", price = 1000000, id = 3311159836, stack = 1, desc = "Redirects Sun Beams 10 times before being destroyed"},
        -- Divine Gear
        {name = "Master Sprinkler", rarity = "Divine", price = 10000000, id = 3267580365, stack = 1, desc = "Greatly increases growth speed, mutation chances and fruit size. Lasts 10 minutes"},
        {name = "Cleaning Spray", rarity = "Divine", price = 15000000, id = 3306767043, stack = 10, desc = "Cleans mutations off fruit! 10 Uses"},
        {name = "Favorite Tool", rarity = "Divine", price = 20000000, id = 3281679093, stack = 20, desc = "Favorites your fruit to prevent collecting. 20 uses"},
        {name = "Harvest Tool", rarity = "Divine", price = 30000000, id = 3286038236, stack = 5, desc = "Harvest all fruit from a chosen plant. 5 uses"},
        {name = "Friendship Pot", rarity = "Divine", price = 15000000, id = 3301473650, stack = 1, desc = "A flower pot to share with a friend!"},
    },
    
    Eggs = {
        {name = "Common Egg", rarity = "Common", price = 50000, id = 3276346455, desc = "Basic pet egg"},
        {name = "Mythical Egg", rarity = "Mythical", price = 8000000, id = 3286560171, desc = "Better pet chances"},
        {name = "Bee Egg", rarity = "Mythical", price = 30000000, id = 3295398638, desc = "Bee-themed pets"},
        {name = "Bug Egg", rarity = "Divine", price = 50000000, id = 3277000452, desc = "Bug-themed pets"},
        {name = "Common Summer Egg", rarity = "Common", price = 1000000, id = 3312016380, desc = "Summer event egg"},
        {name = "Rare Summer Egg", rarity = "Rare", price = 25000000, id = 3312016506, desc = "Summer event egg"},
        {name = "Paradise Egg", rarity = "Mythical", price = 50000000, id = 3312016651, desc = "Paradise-themed pets"},
        {name = "Night Egg", rarity = "Divine", price = 50000000, id = 0, desc = "Night-themed pets"},
    },
    
    SeedPacks = {
        {name = "Normal Seed Pack", rarity = "Common", price = 0, desc = "Contains Pumpkin, Watermelon, Peach, Raspberry, Dragon Fruit, Cactus, Mango"},
        {name = "Exotic Seed Pack", rarity = "Rare", price = 0, desc = "Contains Papaya, Banana, Passionfruit, Soul Fruit, Cursed Fruit"},
        {name = "Night Seed Pack", rarity = "Legendary", price = 0, desc = "Contains Nightshade, Glowshroom, Mint, Moonflower, Starfruit"},
        {name = "Flower Seed Pack", rarity = "Rare", price = 0, desc = "Contains Rose, Foxglove, Lilac, Pink Lily, Purple Dahlia, Sunflower"},
        {name = "Crafters Seed Pack", rarity = "Legendary", price = 0, desc = "Contains Crocus, Succulent, Violet Corn, Bendboo, Cocovine"},
        {name = "Summer Seed Pack", rarity = "Mythical", price = 0, desc = "Contains Wild Carrot, Pear, Cantaloupe, Parasol Flower"},
        {name = "Ancient Seed Pack", rarity = "Divine", price = 0, desc = "Contains Stonebite, Paradise Petal, Horned Dinoshroom"},
    }
}

-- Rarity Colors
local RarityColors = {
    Common = Color3.fromRGB(255, 255, 255),      -- White
    Uncommon = Color3.fromRGB(85, 255, 85),      -- Green
    Rare = Color3.fromRGB(85, 170, 255),         -- Blue
    Legendary = Color3.fromRGB(255, 170, 0),     -- Orange
    Mythical = Color3.fromRGB(255, 85, 255),     -- Magenta
    Divine = Color3.fromRGB(255, 215, 0),        -- Gold
    Prismatic = Color3.fromRGB(170, 0, 255),     -- Purple
}

-- Automation Configuration
local AutomationConfig = {
    -- Master Settings
    Enabled = false,
    WebhookURL = "",
    LogLevel = "INFO",
    
    -- Auto Buy Settings with item selection
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
        SeedPriority = {"Carrot", "Strawberry", "Blueberry"},
        PlantInterval = 2,
        UseWateringCan = true,
        MaxPlantsPerType = 50,
        AutoReplant = true,
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
        AutoFeed = true,
        FeedThreshold = 500,
        AutoHatchEggs = true,
        HatchInterval = 10,
        PreferredPets = {},
        AutoUnequipWeak = true,
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
        MinPetValue = 1000,
        MinFruitValue = 100,
        BlacklistedItems = {},
        AutoOffer = false,
        MaxTradesPerDay = 10,
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
    
    -- Corner radius and shadow
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, UIConfig.Sizes.FloatingButtonSize / 2)
    corner.Parent = floatingButton
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, UIConfig.Colors.Primary),
        ColorSequenceKeypoint.new(1, UIConfig.Colors.Secondary)
    })
    gradient.Rotation = 45
    gradient.Parent = floatingButton
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.8, 0, 0.8, 0)
    icon.Position = UDim2.new(0.1, 0, 0.1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚡" -- Lightning bolt for automation
    icon.TextColor3 = UIConfig.Colors.Text
    icon.TextScaled = true
    icon.Font = UIConfig.Fonts.Header
    icon.Parent = floatingButton
    
    -- Status indicator
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 12, 0, 12)
    statusDot.Position = UDim2.new(1, -8, 0, -4)
    statusDot.BackgroundColor3 = UIConfig.Colors.Error
    statusDot.BorderSizePixel = 0
    statusDot.Parent = floatingButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 6)
    dotCorner.Parent = statusDot
    
    -- Animations
    local function startPulse()
        local tween = TweenService:Create(floatingButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Size = UDim2.new(0, UIConfig.Sizes.FloatingButtonSize * 1.1, 0, UIConfig.Sizes.FloatingButtonSize * 1.1)
        })
        tween:Play()
        return tween
    end
    
    local pulseTween = startPulse()
    
    -- Hover effects
    floatingButton.MouseEnter:Connect(function()
        pulseTween:Cancel()
        TweenService:Create(floatingButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, UIConfig.Sizes.FloatingButtonSize * 1.2, 0, UIConfig.Sizes.FloatingButtonSize * 1.2)
        }):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), {Rotation = 15}):Play()
    end)
    
    floatingButton.MouseLeave:Connect(function()
        TweenService:Create(floatingButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, UIConfig.Sizes.FloatingButtonSize, 0, UIConfig.Sizes.FloatingButtonSize)
        }):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), {Rotation = 0}):Play()
        pulseTween = startPulse()
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

-- Create main UI
local function CreateMainUI()
    -- Destroy existing UI
    if PlayerGui:FindFirstChild("AdvancedAutomationUI") then
        PlayerGui.AdvancedAutomationUI:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedAutomationUI"
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
    
    -- Corner radius and shadow
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
        
        task.wait(0.3)
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
    title.Text = "Advanced Automation Suite"
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
    closeButton.Text = "✕"
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
    
    -- Store status elements
    UIElements.MainStatusDot = statusDot
    UIElements.MainStatusText = statusText
end

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
    
    UIElements.CategorySidebar = sidebar
end

-- Create category button
function CreateCategoryButton(parent, category, index)
    local button = Instance.new("TextButton")
    button.Name = "Category_" .. category.Name
    button.Size = UDim2.new(1, 0, 0, 55)
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
    iconBg.Position = UDim2.new(0, 15, 0, 10)
    iconBg.BackgroundColor3 = index == CurrentCategory and UIConfig.Colors.Text or category.Color
    iconBg.BorderSizePixel = 0
    iconBg.Parent = button
    
    local iconBgCorner = Instance.new("UICorner")
    iconBgCorner.CornerRadius = UDim.new(0, 8)
    iconBgCorner.Parent = iconBg
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.8, 0, 0.8, 0)
    icon.Position = UDim2.new(0.1, 0, 0.1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = category.Icon
    icon.TextColor3 = index == CurrentCategory and UIConfig.Colors.Primary or UIConfig.Colors.Text
    icon.TextScaled = true
    icon.Font = UIConfig.Fonts.Body
    icon.Parent = iconBg
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -65, 0, 20)
    label.Position = UDim2.new(0, 60, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = category.Name
    label.TextColor3 = index == CurrentCategory and UIConfig.Colors.Text or UIConfig.Colors.TextSecondary
    label.TextSize = 16
    label.Font = UIConfig.Fonts.Title
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Name = "Description"
    desc.Size = UDim2.new(1, -65, 0, 15)
    desc.Position = UDim2.new(0, 60, 0, 30)
    desc.BackgroundTransparency = 1
    desc.Text = "Configure " .. category.Name:lower() .. " settings"
    desc.TextColor3 = index == CurrentCategory and UIConfig.Colors.TextSecondary or UIConfig.Colors.TextDim
    desc.TextSize = 11
    desc.Font = UIConfig.Fonts.Body
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        if index ~= CurrentCategory then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.SurfaceLight}):Play()
            TweenService:Create(iconBg, TweenInfo.new(0.2), {Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0, 13.5, 0, 8.5)}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if index ~= CurrentCategory then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)}):Play()
            TweenService:Create(iconBg, TweenInfo.new(0.2), {Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(0, 15, 0, 10)}):Play()
        end
    end)
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        SelectCategory(index)
    end)
    
    -- Store reference
    if not UIElements.CategoryButtons then
        UIElements.CategoryButtons = {}
    end
    UIElements.CategoryButtons[index] = {
        Button = button,
        IconBg = iconBg,
        Icon = icon,
        Label = label,
        Desc = desc
    }
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

-- Create Auto Buy Section
function CreateAutoBuySection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Auto Buy Seeds Card
    local seedsCard = CreateCard(scroll, "🌱 Auto Buy Seeds", "Automatically purchase seeds when stock is low", 0)
    
    CreateToggle(seedsCard, "Enable Auto Buy Seeds", "Automatically purchase selected seeds", AutomationConfig.AutoBuySeeds, "Enabled", 0)
    CreateSlider(seedsCard, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuySeeds, "MaxSpend", 0, 50000000, 1)
    CreateSlider(seedsCard, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuySeeds, "KeepMinimum", 0, 10000000, 2)
    CreateSlider(seedsCard, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuySeeds, "MinStock", 1, 100, 3)
    CreateSlider(seedsCard, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuySeeds, "BuyUpTo", 1, 200, 4)
    CreateItemSelector(seedsCard, "Selected Seeds", "Choose which seeds to buy", AutomationConfig.AutoBuySeeds, "SelectedSeeds", GameItems.Seeds, 5)
    
    -- Auto Buy Gear Card
    local gearCard = CreateCard(scroll, "⚒️ Auto Buy Gear", "Automatically purchase tools and gear", 1)
    
    CreateToggle(gearCard, "Enable Auto Buy Gear", "Automatically purchase selected gear", AutomationConfig.AutoBuyGear, "Enabled", 0)
    CreateSlider(gearCard, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuyGear, "MaxSpend", 0, 20000000, 1)
    CreateSlider(gearCard, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuyGear, "KeepMinimum", 0, 5000000, 2)
    CreateSlider(gearCard, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuyGear, "MinStock", 1, 50, 3)
    CreateSlider(gearCard, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuyGear, "BuyUpTo", 1, 100, 4)
    CreateItemSelector(gearCard, "Selected Gear", "Choose which gear to buy", AutomationConfig.AutoBuyGear, "SelectedGear", GameItems.Gear, 5)
    
    -- Auto Buy Eggs Card
    local eggsCard = CreateCard(scroll, "🥚 Auto Buy Eggs", "Automatically purchase pet eggs", 2)
    
    CreateToggle(eggsCard, "Enable Auto Buy Eggs", "Automatically purchase selected eggs", AutomationConfig.AutoBuyEggs, "Enabled", 0)
    CreateSlider(eggsCard, "Max Spend", "Maximum sheckles to spend", AutomationConfig.AutoBuyEggs, "MaxSpend", 0, 100000000, 1)
    CreateSlider(eggsCard, "Keep Minimum", "Always keep this amount", AutomationConfig.AutoBuyEggs, "KeepMinimum", 0, 20000000, 2)
    CreateSlider(eggsCard, "Min Stock", "Buy when below this amount", AutomationConfig.AutoBuyEggs, "MinStock", 0, 20, 3)
    CreateSlider(eggsCard, "Buy Up To", "Maximum amount to buy", AutomationConfig.AutoBuyEggs, "BuyUpTo", 1, 50, 4)
    CreateItemSelector(eggsCard, "Selected Eggs", "Choose which eggs to buy", AutomationConfig.AutoBuyEggs, "SelectedEggs", GameItems.Eggs, 5)
end

-- Create Item Selector
function CreateItemSelector(parent, name, description, config, key, items, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "ItemSelector_" .. name
    frame.Size = UDim2.new(1, 0, 0, 250) -- Will be resized based on content
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Header
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 20)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Text = name
    header.TextColor3 = UIConfig.Colors.Text
    header.TextSize = 14
    header.Font = UIConfig.Fonts.Title
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = frame
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Name = "Description"
        desc.Size = UDim2.new(1, 0, 0, 12)
        desc.Position = UDim2.new(0, 0, 0, 20)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = UIConfig.Colors.TextSecondary
        desc.TextSize = 10
        desc.Font = UIConfig.Fonts.Body
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
    
    -- Items container
    local itemsContainer = Instance.new("Frame")
    itemsContainer.Name = "ItemsContainer"
    itemsContainer.Size = UDim2.new(1, 0, 1, -40)
    itemsContainer.Position = UDim2.new(0, 0, 0, 35)
    itemsContainer.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    itemsContainer.BorderSizePixel = 0
    itemsContainer.Parent = frame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = itemsContainer
    
    -- Scroll frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ItemsScroll"
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = UIConfig.Colors.Primary
    scrollFrame.Parent = itemsContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scrollFrame
    
    -- Create item buttons
    for i, item in ipairs(items) do
        CreateItemButton(scrollFrame, item, config[key], i)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
end

-- Create Item Button
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
    end)
end

-- Continue with other sections and helper functions...
-- [The rest of the UI creation functions would follow the same pattern]

-- Helper Functions
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
    card.Size = UDim2.new(1, 0, 0, 100) -- Will be resized based on content
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
    header.Size = UDim2.new(1, 0, 0, 50)
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
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -30, 1, -60)
    content.Position = UDim2.new(0, 15, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = card
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.Parent = content
    
    -- Auto-resize card based on content
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        card.Size = UDim2.new(1, 0, 0, math.max(100, contentLayout.AbsoluteContentSize.Y + 70))
    end)
    
    return content
end

function CreateToggle(parent, name, description, config, key, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. name:gsub("[^%w]", "")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Toggle switch
    local toggle = Instance.new("TextButton")
    toggle.Name = "ToggleButton"
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -65, 0, 7.5)
    toggle.BackgroundColor3 = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceLight
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 15)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = config[key] and UDim2.new(1, -27, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = UIConfig.Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 12)
    knobCorner.Parent = knob
    
    -- Labels
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -75, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 2)
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
        descLabel.Size = UDim2.new(1, -75, 0, 16)
        descLabel.Position = UDim2.new(0, 0, 0, 22)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 11
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame
    end
    
    -- Toggle functionality
    toggle.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        
        local newColor = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceLight
        local newPosition = config[key] and UDim2.new(1, -27, 0, 3) or UDim2.new(0, 3, 0, 3)
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = newPosition}):Play()
        
        -- Update status if this is the master toggle
        if key == "Enabled" and config == AutomationConfig then
            UpdateStatus(config[key])
        end
    end)
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
end

-- Create simple content sections for other categories
function CreateDashboard(parent)
    local scroll = CreateScrollFrame(parent)
    
    local statusCard = CreateCard(scroll, "🎮 System Status", "Current automation status and quick controls", 0)
    CreateToggle(statusCard, "Master Enable", "Enable all automation features", AutomationConfig, "Enabled", 0)
    
    local statsCard = CreateCard(scroll, "📊 Statistics", "Live game statistics", 1)
    -- Add statistics displays here
end

function CreateFarmingSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local plantCard = CreateCard(scroll, "🌱 Auto Plant", "Automatically plant seeds", 0)
    CreateToggle(plantCard, "Enable Auto Plant", "Automatically plant seeds", AutomationConfig.AutoPlant, "Enabled", 0)
    CreateSlider(plantCard, "Plant Interval", "Seconds between planting", AutomationConfig.AutoPlant, "PlantInterval", 0.5, 10, 1)
end

function CreatePetSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local petCard = CreateCard(scroll, "🐕 Pet Management", "Manage your pets automatically", 0)
    CreateToggle(petCard, "Enable Pet Management", "Auto manage pets", AutomationConfig.PetManagement, "Enabled", 0)
end

function CreateEventsSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local eventsCard = CreateCard(scroll, "🎉 Auto Events", "Participate in events automatically", 0)
    CreateToggle(eventsCard, "Enable Auto Events", "Auto participate in events", AutomationConfig.AutoEvents, "Enabled", 0)
end

function CreateTradingSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local tradeCard = CreateCard(scroll, "🤝 Auto Trading", "Automated trading features", 0)
    CreateToggle(tradeCard, "Enable Auto Trading", "Auto handle trades", AutomationConfig.AutoTrade, "Enabled", 0)
end

function CreateMiscSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local miscCard = CreateCard(scroll, "⚙️ Miscellaneous", "Additional automation features", 0)
    CreateToggle(miscCard, "Auto Open Packs", "Auto open seed packs", AutomationConfig.MiscFeatures, "AutoOpenPacks", 0)
    CreateItemSelector(miscCard, "Selected Packs", "Choose which packs to open", AutomationConfig.MiscFeatures, "SelectedPacks", GameItems.SeedPacks, 1)
end

function CreatePerformanceSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local perfCard = CreateCard(scroll, "⚡ Performance", "Optimize game performance", 0)
    CreateToggle(perfCard, "Reduce Graphics", "Lower graphics for better FPS", AutomationConfig.Performance, "ReduceGraphics", 0)
    CreateSlider(perfCard, "Max FPS", "Limit FPS", AutomationConfig.Performance, "MaxFPS", 30, 120, 1)
end

function CreateSettingsSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    local settingsCard = CreateCard(scroll, "🔧 General Settings", "Configure automation settings", 0)
    -- Add settings controls here
end

-- Update Status Function
function UpdateStatus(enabled)
    if UIElements.UpdateStatus then
        UIElements.UpdateStatus(enabled)
    end
    if UIElements.MainStatusDot and UIElements.MainStatusText then
        UIElements.MainStatusDot.BackgroundColor3 = enabled and UIConfig.Colors.Success or UIConfig.Colors.Error
        UIElements.MainStatusText.Text = enabled and "Enabled" or "Disabled"
    end
end

-- Initialize
local function Initialize()
    print("🌱 Advanced Automation UI Loading...")
    
    -- Create floating toggle button
    CreateFloatingButton()
    
    -- Create main UI
    CreateMainUI()
    
    print("⚡ Advanced Automation UI Loaded! Click the floating button to open.")
end

-- Start the UI
Initialize()
