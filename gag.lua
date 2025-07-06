-- Modern Automation UI for Grow a Garden
-- Apple-inspired design with purple and black theme

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- UI Configuration
local UIConfig = {
    Colors = {
        Primary = Color3.fromRGB(88, 86, 214),      -- Purple
        Secondary = Color3.fromRGB(142, 68, 173),   -- Purple-Pink
        Background = Color3.fromRGB(13, 13, 13),    -- Deep Black
        Surface = Color3.fromRGB(28, 28, 30),       -- Dark Grey
        SurfaceLight = Color3.fromRGB(44, 44, 46),  -- Light Grey
        Text = Color3.fromRGB(255, 255, 255),       -- White
        TextSecondary = Color3.fromRGB(152, 152, 157), -- Light Grey
        Success = Color3.fromRGB(52, 199, 89),      -- Green
        Warning = Color3.fromRGB(255, 204, 0),      -- Yellow
        Error = Color3.fromRGB(255, 69, 58),        -- Red
        Border = Color3.fromRGB(56, 56, 58),        -- Border Grey
    },
    Sizes = {
        MainFrame = UDim2.new(0, 800, 0, 500),
        CategoryWidth = 200,
        ContentWidth = 580,
        HeaderHeight = 60,
        CornerRadius = UDim.new(0, 12),
    },
    Fonts = {
        Header = Enum.Font.GothamBold,
        Title = Enum.Font.GothamSemibold,
        Body = Enum.Font.Gotham,
        Button = Enum.Font.GothamMedium,
    }
}

-- Automation Configuration
local AutomationConfig = {
    -- General Settings
    Enabled = false,
    WebhookURL = "",
    LogLevel = "INFO",
    
    -- Auto Buy Settings
    AutoBuySeeds = {
        Enabled = false,
        MaxSpend = 1000000,
        KeepMinimum = 100000,
        CheckInterval = 30,
        SeedList = {"Carrot", "Strawberry", "Blueberry"},
    },
    
    AutoBuyGear = {
        Enabled = false,
        MaxSpend = 500000,
        KeepMinimum = 100000,
        CheckInterval = 60,
        GearList = {"Watering Can", "Trowel", "Recall Wrench"},
    },
    
    AutoBuyEggs = {
        Enabled = false,
        MaxSpend = 2000000,
        KeepMinimum = 500000,
        CheckInterval = 45,
        EggList = {"Basic Egg", "Golden Egg"},
    },
    
    -- Farming Settings
    AutoPlant = {
        Enabled = false,
        PlantInterval = 2,
        UseWateringCan = true,
        MaxPlantsPerType = 50,
        SeedPriority = {"Carrot", "Strawberry", "Blueberry"},
    },
    
    AutoCollect = {
        Enabled = false,
        CollectInterval = 1,
        CollectRadius = 100,
        PrioritizeRareItems = true,
        AutoSell = false,
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
    },
    
    -- Trading
    AutoTrade = {
        Enabled = false,
        AutoAcceptTrades = false,
        MinPetValue = 1000,
        MinFruitValue = 100,
        BlacklistedItems = {},
        AutoOffer = false,
    },
    
    -- Misc Features
    MiscFeatures = {
        AutoOpenPacks = false,
        PackOpenInterval = 5,
        AutoUseGear = true,
        AutoExpand = false,
        AutoTeleport = false,
    },
    
    -- Performance
    Performance = {
        ReduceGraphics = false,
        DisableAnimations = false,
        MaxFPS = 60,
        LowMemoryMode = false,
        OptimizeRendering = true,
    },
}

-- UI Categories
local Categories = {
    {
        Name = "Dashboard",
        Icon = "📊",
        Content = function(parent) return CreateDashboard(parent) end
    },
    {
        Name = "Auto Buy",
        Icon = "🛒",
        Content = function(parent) return CreateAutoBuySection(parent) end
    },
    {
        Name = "Farming",
        Icon = "🌱",
        Content = function(parent) return CreateFarmingSection(parent) end
    },
    {
        Name = "Pets",
        Icon = "🐕",
        Content = function(parent) return CreatePetSection(parent) end
    },
    {
        Name = "Events",
        Icon = "🎉",
        Content = function(parent) return CreateEventsSection(parent) end
    },
    {
        Name = "Trading",
        Icon = "🤝",
        Content = function(parent) return CreateTradingSection(parent) end
    },
    {
        Name = "Misc",
        Icon = "⚙️",
        Content = function(parent) return CreateMiscSection(parent) end
    },
    {
        Name = "Performance",
        Icon = "⚡",
        Content = function(parent) return CreatePerformanceSection(parent) end
    },
    {
        Name = "Settings",
        Icon = "🔧",
        Content = function(parent) return CreateSettingsSection(parent) end
    }
}

-- Current state
local CurrentCategory = 1
local UIElements = {}

-- Create main UI
local function CreateMainUI()
    -- Destroy existing UI
    if PlayerGui:FindFirstChild("ModernAutomationUI") then
        PlayerGui.ModernAutomationUI:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutomationUI"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UIConfig.Sizes.MainFrame
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    mainFrame.BackgroundColor3 = UIConfig.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UIConfig.Sizes.CornerRadius
    mainCorner.Parent = mainFrame
    
    -- Drop shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Replace with shadow image
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Header
    CreateHeader(mainFrame)
    
    -- Category Sidebar
    CreateCategorySidebar(mainFrame)
    
    -- Content Area
    CreateContentArea(mainFrame)
    
    -- Make draggable
    MakeDraggable(mainFrame)
    
    -- Store references
    UIElements.ScreenGui = screenGui
    UIElements.MainFrame = mainFrame
    
    return screenGui
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
    
    -- Header background to hide rounded bottom corners
    local headerBg = Instance.new("Frame")
    headerBg.Size = UDim2.new(1, 0, 0, 30)
    headerBg.Position = UDim2.new(0, 0, 1, -30)
    headerBg.BackgroundColor3 = UIConfig.Colors.Surface
    headerBg.BorderSizePixel = 0
    headerBg.Parent = header
    
    -- Logo/Icon
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 40, 0, 40)
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
    title.Size = UDim2.new(0, 300, 0, 30)
    title.Position = UDim2.new(0, 70, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "Grow a Garden Automation"
    title.TextColor3 = UIConfig.Colors.Text
    title.TextSize = 18
    title.Font = UIConfig.Fonts.Title
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Status indicator
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(0, 120, 0, 30)
    statusFrame.Position = UDim2.new(1, -140, 0, 15)
    statusFrame.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = header
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 15)
    statusCorner.Parent = statusFrame
    
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 10, 0, 11)
    statusDot.BackgroundColor3 = UIConfig.Colors.Error
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusFrame
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 4)
    dotCorner.Parent = statusDot
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -25, 1, 0)
    statusText.Position = UDim2.new(0, 25, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Disabled"
    statusText.TextColor3 = UIConfig.Colors.TextSecondary
    statusText.TextSize = 12
    statusText.Font = UIConfig.Fonts.Body
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -50, 0, 15)
    closeButton.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = UIConfig.Colors.TextSecondary
    closeButton.TextSize = 14
    closeButton.Font = UIConfig.Fonts.Button
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
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
        TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        wait(0.3)
        parent.Visible = false
        parent.Size = UIConfig.Sizes.MainFrame
        parent.Position = UDim2.new(0.5, -400, 0.5, -250)
    end)
    
    -- Store status elements
    UIElements.StatusDot = statusDot
    UIElements.StatusText = statusText
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
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = UIConfig.Colors.Primary
    scrollFrame.Parent = sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scrollFrame
    
    -- Create category buttons
    for i, category in ipairs(Categories) do
        CreateCategoryButton(scrollFrame, category, i)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    UIElements.CategorySidebar = sidebar
end

-- Create category button
function CreateCategoryButton(parent, category, index)
    local button = Instance.new("TextButton")
    button.Name = "Category_" .. category.Name
    button.Size = UDim2.new(1, -10, 0, 45)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundColor3 = index == CurrentCategory and UIConfig.Colors.Primary or Color3.fromRGB(0, 0, 0, 0)
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = index
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 15, 0, 12.5)
    icon.BackgroundTransparency = 1
    icon.Text = category.Icon
    icon.TextColor3 = index == CurrentCategory and UIConfig.Colors.Text or UIConfig.Colors.TextSecondary
    icon.TextSize = 16
    icon.Font = UIConfig.Fonts.Body
    icon.Parent = button
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 45, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = category.Name
    label.TextColor3 = index == CurrentCategory and UIConfig.Colors.Text or UIConfig.Colors.TextSecondary
    label.TextSize = 14
    label.Font = UIConfig.Fonts.Body
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        if index ~= CurrentCategory then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.SurfaceLight}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if index ~= CurrentCategory then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)}):Play()
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
        Icon = icon,
        Label = label
    }
end

-- Select category
function SelectCategory(index)
    if index == CurrentCategory then return end
    
    -- Update previous category button
    local prevButton = UIElements.CategoryButtons[CurrentCategory]
    if prevButton then
        TweenService:Create(prevButton.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)}):Play()
        TweenService:Create(prevButton.Icon, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.TextSecondary}):Play()
        TweenService:Create(prevButton.Label, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.TextSecondary}):Play()
    end
    
    -- Update new category button
    local newButton = UIElements.CategoryButtons[index]
    if newButton then
        TweenService:Create(newButton.Button, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Primary}):Play()
        TweenService:Create(newButton.Icon, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.Text}):Play()
        TweenService:Create(newButton.Label, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.Text}):Play()
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
    separator.Size = UDim2.new(0, 1, 1, 0)
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
    
    -- Create new content
    local category = Categories[CurrentCategory]
    if category and category.Content then
        category.Content(contentArea)
    end
end

-- Create Dashboard
function CreateDashboard(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Status Cards
    local statusCard = CreateCard(scroll, "System Status", 0)
    
    -- Master toggle
    CreateToggle(statusCard, "Master Enable", "Enable all automation features", AutomationConfig, "Enabled", function(value)
        UpdateStatus(value)
    end)
    
    -- Statistics Card
    local statsCard = CreateCard(scroll, "Statistics", 1)
    
    -- Stats labels (these would be updated in real-time)
    CreateInfoLabel(statsCard, "Money", "1,234,567 Sheckles", 0)
    CreateInfoLabel(statsCard, "Plants", "42 Growing", 1)
    CreateInfoLabel(statsCard, "Pets", "3 Equipped", 2)
    CreateInfoLabel(statsCard, "Uptime", "2h 34m", 3)
    
    -- Quick Actions Card
    local actionsCard = CreateCard(scroll, "Quick Actions", 2)
    
    CreateButton(actionsCard, "Collect All", UIConfig.Colors.Success, 0, function()
        print("Collect All clicked")
    end)
    
    CreateButton(actionsCard, "Feed Pets", UIConfig.Colors.Warning, 1, function()
        print("Feed Pets clicked")
    end)
    
    CreateButton(actionsCard, "Buy Seeds", UIConfig.Colors.Primary, 2, function()
        print("Buy Seeds clicked")
    end)
end

-- Create Auto Buy Section
function CreateAutoBuySection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Seeds Card
    local seedsCard = CreateCard(scroll, "Auto Buy Seeds", 0)
    
    CreateToggle(seedsCard, "Enable Auto Buy Seeds", "Automatically purchase seeds when stock is low", AutomationConfig.AutoBuySeeds, "Enabled")
    CreateSlider(seedsCard, "Max Spend", "Maximum sheckles to spend on seeds", AutomationConfig.AutoBuySeeds, "MaxSpend", 0, 10000000, 1)
    CreateSlider(seedsCard, "Keep Minimum", "Always keep this amount of sheckles", AutomationConfig.AutoBuySeeds, "KeepMinimum", 0, 5000000, 2)
    CreateSlider(seedsCard, "Check Interval", "Seconds between stock checks", AutomationConfig.AutoBuySeeds, "CheckInterval", 10, 300, 3)
    
    -- Gear Card
    local gearCard = CreateCard(scroll, "Auto Buy Gear", 1)
    
    CreateToggle(gearCard, "Enable Auto Buy Gear", "Automatically purchase tools and gear", AutomationConfig.AutoBuyGear, "Enabled")
    CreateSlider(gearCard, "Max Spend", "Maximum sheckles to spend on gear", AutomationConfig.AutoBuyGear, "MaxSpend", 0, 5000000, 1)
    CreateSlider(gearCard, "Keep Minimum", "Always keep this amount of sheckles", AutomationConfig.AutoBuyGear, "KeepMinimum", 0, 2000000, 2)
    
    -- Eggs Card
    local eggsCard = CreateCard(scroll, "Auto Buy Eggs", 2)
    
    CreateToggle(eggsCard, "Enable Auto Buy Eggs", "Automatically purchase pet eggs", AutomationConfig.AutoBuyEggs, "Enabled")
    CreateSlider(eggsCard, "Max Spend", "Maximum sheckles to spend on eggs", AutomationConfig.AutoBuyEggs, "MaxSpend", 0, 20000000, 1)
    CreateSlider(eggsCard, "Keep Minimum", "Always keep this amount of sheckles", AutomationConfig.AutoBuyEggs, "KeepMinimum", 0, 5000000, 2)
end

-- Create Farming Section
function CreateFarmingSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Planting Card
    local plantCard = CreateCard(scroll, "Auto Plant", 0)
    
    CreateToggle(plantCard, "Enable Auto Plant", "Automatically plant seeds on empty spots", AutomationConfig.AutoPlant, "Enabled")
    CreateSlider(plantCard, "Plant Interval", "Seconds between planting seeds", AutomationConfig.AutoPlant, "PlantInterval", 0.5, 10, 1)
    CreateToggle(plantCard, "Use Watering Can", "Automatically use watering can on plants", AutomationConfig.AutoPlant, "UseWateringCan", 2)
    CreateSlider(plantCard, "Max Plants Per Type", "Maximum plants of each type to grow", AutomationConfig.AutoPlant, "MaxPlantsPerType", 1, 200, 3)
    
    -- Collecting Card
    local collectCard = CreateCard(scroll, "Auto Collect", 1)
    
    CreateToggle(collectCard, "Enable Auto Collect", "Automatically collect grown plants and fruits", AutomationConfig.AutoCollect, "Enabled")
    CreateSlider(collectCard, "Collect Interval", "Seconds between collection attempts", AutomationConfig.AutoCollect, "CollectInterval", 0.1, 5, 1)
    CreateSlider(collectCard, "Collect Radius", "Radius in studs to collect from", AutomationConfig.AutoCollect, "CollectRadius", 10, 500, 2)
    CreateToggle(collectCard, "Prioritize Rare Items", "Collect rare items first", AutomationConfig.AutoCollect, "PrioritizeRareItems", 3)
    CreateToggle(collectCard, "Auto Sell", "Automatically sell collected items", AutomationConfig.AutoCollect, "AutoSell", 4)
end

-- Create Pet Section
function CreatePetSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Pet Management Card
    local petCard = CreateCard(scroll, "Pet Management", 0)
    
    CreateToggle(petCard, "Enable Pet Management", "Automatically manage pets", AutomationConfig.PetManagement, "Enabled")
    CreateToggle(petCard, "Auto Equip", "Automatically equip best pets", AutomationConfig.PetManagement, "AutoEquip", 1)
    CreateToggle(petCard, "Auto Feed", "Automatically feed hungry pets", AutomationConfig.PetManagement, "AutoFeed", 2)
    CreateSlider(petCard, "Feed Threshold", "Feed pets when hunger below this value", AutomationConfig.PetManagement, "FeedThreshold", 0, 1000, 3)
    
    -- Egg Hatching Card
    local eggCard = CreateCard(scroll, "Egg Hatching", 1)
    
    CreateToggle(eggCard, "Auto Hatch Eggs", "Automatically hatch pet eggs", AutomationConfig.PetManagement, "AutoHatchEggs")
    CreateSlider(eggCard, "Hatch Interval", "Seconds between hatching eggs", AutomationConfig.PetManagement, "HatchInterval", 1, 60, 1)
end

-- Create Events Section
function CreateEventsSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Events Card
    local eventsCard = CreateCard(scroll, "Auto Events", 0)
    
    CreateToggle(eventsCard, "Enable Auto Events", "Automatically participate in events", AutomationConfig.AutoEvents, "Enabled")
    CreateToggle(eventsCard, "Daily Quests", "Auto claim daily quest rewards", AutomationConfig.AutoEvents, "DailyQuests", 1)
    CreateToggle(eventsCard, "Summer Harvest", "Auto participate in summer harvest", AutomationConfig.AutoEvents, "SummerHarvest", 2)
    CreateToggle(eventsCard, "Blood Moon", "Auto participate in blood moon events", AutomationConfig.AutoEvents, "BloodMoon", 3)
    CreateToggle(eventsCard, "Bee Swarm", "Auto participate in bee swarm events", AutomationConfig.AutoEvents, "BeeSwarm", 4)
    CreateToggle(eventsCard, "Night Quests", "Auto complete night quests", AutomationConfig.AutoEvents, "NightQuests", 5)
    CreateToggle(eventsCard, "Auto Claim", "Automatically claim event rewards", AutomationConfig.AutoEvents, "AutoClaim", 6)
end

-- Create Trading Section
function CreateTradingSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Trading Card
    local tradingCard = CreateCard(scroll, "Auto Trading", 0)
    
    CreateToggle(tradingCard, "Enable Auto Trading", "Automatically handle trades", AutomationConfig.AutoTrade, "Enabled")
    CreateToggle(tradingCard, "Auto Accept Trades", "Automatically accept good trades", AutomationConfig.AutoTrade, "AutoAcceptTrades", 1)
    CreateSlider(tradingCard, "Min Pet Value", "Minimum pet value to consider", AutomationConfig.AutoTrade, "MinPetValue", 100, 100000, 2)
    CreateSlider(tradingCard, "Min Fruit Value", "Minimum fruit value to consider", AutomationConfig.AutoTrade, "MinFruitValue", 10, 10000, 3)
    CreateToggle(tradingCard, "Auto Offer", "Automatically send trade offers", AutomationConfig.AutoTrade, "AutoOffer", 4)
end

-- Create Misc Section
function CreateMiscSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Miscellaneous Card
    local miscCard = CreateCard(scroll, "Miscellaneous Features", 0)
    
    CreateToggle(miscCard, "Auto Open Packs", "Automatically open seed packs and crates", AutomationConfig.MiscFeatures, "AutoOpenPacks")
    CreateSlider(miscCard, "Pack Open Interval", "Seconds between opening packs", AutomationConfig.MiscFeatures, "PackOpenInterval", 1, 30, 1)
    CreateToggle(miscCard, "Auto Use Gear", "Automatically use tools and gear", AutomationConfig.MiscFeatures, "AutoUseGear", 2)
    CreateToggle(miscCard, "Auto Expand", "Automatically expand farm when possible", AutomationConfig.MiscFeatures, "AutoExpand", 3)
    CreateToggle(miscCard, "Auto Teleport", "Automatically teleport to optimal locations", AutomationConfig.MiscFeatures, "AutoTeleport", 4)
end

-- Create Performance Section
function CreatePerformanceSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Performance Card
    local perfCard = CreateCard(scroll, "Performance Settings", 0)
    
    CreateToggle(perfCard, "Reduce Graphics", "Lower graphics settings for better performance", AutomationConfig.Performance, "ReduceGraphics")
    CreateToggle(perfCard, "Disable Animations", "Disable unnecessary animations", AutomationConfig.Performance, "DisableAnimations", 1)
    CreateSlider(perfCard, "Max FPS", "Limit FPS to reduce CPU usage", AutomationConfig.Performance, "MaxFPS", 30, 120, 2)
    CreateToggle(perfCard, "Low Memory Mode", "Reduce memory usage", AutomationConfig.Performance, "LowMemoryMode", 3)
    CreateToggle(perfCard, "Optimize Rendering", "Optimize rendering for performance", AutomationConfig.Performance, "OptimizeRendering", 4)
end

-- Create Settings Section
function CreateSettingsSection(parent)
    local scroll = CreateScrollFrame(parent)
    
    -- Settings Card
    local settingsCard = CreateCard(scroll, "General Settings", 0)
    
    CreateTextBox(settingsCard, "Webhook URL", "Discord webhook URL for notifications", AutomationConfig, "WebhookURL", 0)
    CreateDropdown(settingsCard, "Log Level", "Logging verbosity level", AutomationConfig, "LogLevel", {"DEBUG", "INFO", "WARN", "ERROR"}, 1)
    
    -- Actions Card
    local actionsCard = CreateCard(scroll, "Actions", 1)
    
    CreateButton(actionsCard, "Save Config", UIConfig.Colors.Success, 0, function()
        SaveConfiguration()
    end)
    
    CreateButton(actionsCard, "Load Config", UIConfig.Colors.Primary, 1, function()
        LoadConfiguration()
    end)
    
    CreateButton(actionsCard, "Reset Config", UIConfig.Colors.Error, 2, function()
        ResetConfiguration()
    end)
end

-- UI Helper Functions

function CreateScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ContentScroll"
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
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    return scroll
end

function CreateCard(parent, title, layoutOrder)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title
    card.Size = UDim2.new(1, 0, 0, 60) -- Will be resized based on content
    card.BackgroundColor3 = UIConfig.Colors.Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder
    card.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = UIConfig.Colors.Text
    titleLabel.TextSize = 16
    titleLabel.Font = UIConfig.Fonts.Title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = card
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = content
    
    -- Auto-resize card based on content
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        card.Size = UDim2.new(1, 0, 0, math.max(60, contentLayout.AbsoluteContentSize.Y + 60))
    end)
    
    return content
end

function CreateToggle(parent, name, description, config, key, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. name
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Toggle switch
    local toggle = Instance.new("TextButton")
    toggle.Name = "ToggleButton"
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -55, 0, 5)
    toggle.BackgroundColor3 = config[key] and UIConfig.Colors.Success or UIConfig.Colors.SurfaceLight
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = config[key] and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = UIConfig.Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 9)
    knobCorner.Parent = knob
    
    -- Labels
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -65, 0, 18)
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
        descLabel.Size = UDim2.new(1, -65, 0, 14)
        descLabel.Position = UDim2.new(0, 0, 0, 18)
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
        local newPosition = config[key] and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
        
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
    frame.Name = "Slider_" .. name
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Labels
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, 0, 0, 18)
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
    valueLabel.Size = UDim2.new(0.3, 0, 0, 18)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config[key])
    valueLabel.TextColor3 = UIConfig.Colors.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = UIConfig.Fonts.Body
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(1, 0, 0, 12)
        descLabel.Position = UDim2.new(0, 0, 0, 18)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 10
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame
    end
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -8)
    track.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
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
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((config[key] - minValue) / (maxValue - minValue), -8, 0, -6)
    knob.BackgroundColor3 = UIConfig.Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 8)
    knobCorner.Parent = knob
    
    -- Slider functionality
    local dragging = false
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minValue + percentage * (maxValue - minValue))
        
        config[key] = value
        valueLabel.Text = tostring(value)
        
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        knob.Position = UDim2.new(percentage, -8, 0, -6)
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

function CreateButton(parent, text, color, layoutOrder, callback)
    layoutOrder = layoutOrder or 0
    
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. text
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = UIConfig.Colors.Text
    button.TextSize = 14
    button.Font = UIConfig.Fonts.Button
    button.LayoutOrder = layoutOrder
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(
            math.min(color.R * 1.2, 1),
            math.min(color.G * 1.2, 1),
            math.min(color.B * 1.2, 1)
        )}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

function CreateTextBox(parent, name, description, config, key, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "TextBox_" .. name
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
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
        descLabel.Size = UDim2.new(1, 0, 0, 12)
        descLabel.Position = UDim2.new(0, 0, 0, 18)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 10
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
    textBoxCorner.CornerRadius = UDim.new(0, 4)
    textBoxCorner.Parent = textBox
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = textBox
    
    textBox.FocusLost:Connect(function()
        config[key] = textBox.Text
    end)
end

function CreateDropdown(parent, name, description, config, key, options, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. name
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    -- Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
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
        descLabel.Size = UDim2.new(1, 0, 0, 12)
        descLabel.Position = UDim2.new(0, 0, 0, 18)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = UIConfig.Colors.TextSecondary
        descLabel.TextSize = 10
        descLabel.Font = UIConfig.Fonts.Body
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame
    end
    
    -- Dropdown button
    local dropdown = Instance.new("TextButton")
    dropdown.Name = "DropdownButton"
    dropdown.Size = UDim2.new(1, 0, 0, 24)
    dropdown.Position = UDim2.new(0, 0, 1, -26)
    dropdown.BackgroundColor3 = UIConfig.Colors.SurfaceLight
    dropdown.BorderSizePixel = 0
    dropdown.Text = config[key] or options[1]
    dropdown.TextColor3 = UIConfig.Colors.Text
    dropdown.TextSize = 12
    dropdown.Font = UIConfig.Fonts.Body
    dropdown.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.Parent = frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdown
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 20)
    padding.Parent = dropdown
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = UIConfig.Colors.TextSecondary
    arrow.TextSize = 10
    arrow.Font = UIConfig.Fonts.Body
    arrow.Parent = dropdown
    
    -- Options frame (initially hidden)
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 24)
    optionsFrame.Position = UDim2.new(0, 0, 1, 2)
    optionsFrame.BackgroundColor3 = UIConfig.Colors.Surface
    optionsFrame.BorderSizePixel = 1
    optionsFrame.BorderColor3 = UIConfig.Colors.Border
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = dropdown
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = optionsFrame
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. option
        optionButton.Size = UDim2.new(1, 0, 0, 24)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 24)
        optionButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = UIConfig.Colors.Text
        optionButton.TextSize = 12
        optionButton.Font = UIConfig.Fonts.Body
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Parent = optionsFrame
        
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 8)
        optionPadding.Parent = optionButton
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = UIConfig.Colors.SurfaceLight
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            config[key] = option
            dropdown.Text = option
            optionsFrame.Visible = false
            arrow.Text = "▼"
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        arrow.Text = optionsFrame.Visible and "▲" or "▼"
    end)
end

function CreateInfoLabel(parent, name, value, layoutOrder)
    layoutOrder = layoutOrder or 0
    
    local frame = Instance.new("Frame")
    frame.Name = "Info_" .. name
    frame.Size = UDim2.new(1, 0, 0, 25)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name .. ":"
    nameLabel.TextColor3 = UIConfig.Colors.TextSecondary
    nameLabel.TextSize = 12
    nameLabel.Font = UIConfig.Fonts.Body
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value
    valueLabel.TextColor3 = UIConfig.Colors.Text
    valueLabel.TextSize = 12
    valueLabel.Font = UIConfig.Fonts.Body
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    return valueLabel
end

-- Utility Functions

function UpdateStatus(enabled)
    if UIElements.StatusDot and UIElements.StatusText then
        UIElements.StatusDot.BackgroundColor3 = enabled and UIConfig.Colors.Success or UIConfig.Colors.Error
        UIElements.StatusText.Text = enabled and "Enabled" or "Disabled"
    end
end

function MakeDraggable(frame)
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
    
    UserInputService.InputChanged:Connect(function(input)
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

function SaveConfiguration()
    print("Configuration saved!")
    -- Implementation for saving config
end

function LoadConfiguration()
    print("Configuration loaded!")
    -- Implementation for loading config
end

function ResetConfiguration()
    print("Configuration reset!")
    -- Implementation for resetting config
end

-- Initialize UI
local function Initialize()
    -- Create main UI
    CreateMainUI()
    
    -- Toggle UI with F3
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F3 then
            local mainFrame = UIElements.MainFrame
            if mainFrame then
                if mainFrame.Visible then
                    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0)
                    }):Play()
                    
                    wait(0.3)
                    mainFrame.Visible = false
                    mainFrame.Size = UIConfig.Sizes.MainFrame
                    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
                else
                    mainFrame.Visible = true
                    mainFrame.Size = UDim2.new(0, 0, 0, 0)
                    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                    
                    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UIConfig.Sizes.MainFrame,
                        Position = UDim2.new(0.5, -400, 0.5, -250)
                    }):Play()
                end
            end
        end
    end)
    
    print("Modern Automation UI initialized! Press F3 to toggle.")
end

-- Start the UI
Initialize()
