-- Automation Bridge - Connects UI with Backend Functions
-- This script should be run AFTER both UI and backend are loaded

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- Wait for automation system to load
local attempts = 0
while (not _G.AutomationSystem or not _G.AutomationSystem.Functions or not _G.AutomationSystem.Config) and attempts < 100 do
    wait(0.1)
    attempts = attempts + 1
end

if not _G.AutomationSystem or not _G.AutomationSystem.Functions then
    warn("❌ AutomationBridge: Failed to connect to automation system")
    return
end

local AutomationAPI = _G.AutomationSystem.Functions
local Config = _G.AutomationSystem.Config

-- Ensure Config is properly initialized
if not Config or not Config.AutoPlant then
    warn("❌ AutomationBridge: Config not properly initialized")
    return
end

print("🔗 Automation Bridge loaded - UI connected to backend")

-- Enhanced UI Integration Functions
local UIBridge = {}

-- Real-time data sync for UI
function UIBridge.StartDataSync()
    spawn(function()
        while true do
            if _G.AutomationSystem.UI then
                local status = AutomationAPI.GetStatus()
                _G.AutomationSystem.UI.UpdateStatus(status)
            end
            wait(2) -- Update every 2 seconds
        end
    end)
end

-- Enhanced proximity prompt detection
function UIBridge.ScanForProximityPrompts()
    local prompts = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            table.insert(prompts, {
                prompt = obj,
                parent = obj.Parent,
                text = obj.ObjectText or obj.ActionText or "Unknown",
                position = obj.Parent.Position,
                enabled = obj.Enabled
            })
        end
    end
    
    return prompts
end

-- Enhanced player detection for trading
function UIBridge.ScanForPlayers()
    local players = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, {
                player = player,
                name = player.Name,
                displayName = player.DisplayName,
                position = player.Character.HumanoidRootPart.Position,
                distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            })
        end
    end
    
    -- Sort by distance
    table.sort(players, function(a, b) return a.distance < b.distance end)
    
    return players
end

-- Enhanced UI element detection
function UIBridge.FindUIElements(keywords)
    local elements = {}
    
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("GuiButton") or gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = gui.Text or gui.Name or ""
            for _, keyword in pairs(keywords) do
                if text:lower():find(keyword:lower()) then
                    table.insert(elements, {
                        element = gui,
                        text = text,
                        name = gui.Name,
                        visible = gui.Visible,
                        parent = gui.Parent
                    })
                end
            end
        end
    end
    
    return elements
end

-- Smart teleportation with pathfinding
function UIBridge.SmartTeleport(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    
    -- Check if target is too far
    local distance = (targetPosition - humanoidRootPart.Position).Magnitude
    
    if distance > 500 then
        -- Direct teleport for long distances
        humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
        wait(1)
    else
        -- Use pathfinding for shorter distances
        local PathfindingService = game:GetService("PathfindingService")
        local path = PathfindingService:CreatePath({
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
            AgentMaxSlope = 45
        })
        
        local success, error = pcall(function()
            path:ComputeAsync(humanoidRootPart.Position, targetPosition)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            
            for _, waypoint in pairs(waypoints) do
                character.Humanoid:MoveTo(waypoint.Position)
                character.Humanoid.MoveToFinished:Wait()
            end
        else
            -- Fallback to direct teleport
            humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
            wait(1)
        end
    end
    
    return true
end

-- Enhanced interaction system
function UIBridge.InteractWithObject(obj, interactionType)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- Move to object first
    if obj.Parent and obj.Parent:FindFirstChild("Position") then
        UIBridge.SmartTeleport(obj.Parent.Position)
    end
    
    wait(0.5)
    
    local success = false
    
    if interactionType == "proximityPrompt" then
        local proximityPrompt = obj:FindFirstChild("ProximityPrompt") or obj
        if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
            fireproximityprompt(proximityPrompt)
            success = true
        end
    elseif interactionType == "clickDetector" then
        local clickDetector = obj:FindFirstChild("ClickDetector") or obj
        if clickDetector and clickDetector:IsA("ClickDetector") then
            fireclickdetector(clickDetector)
            success = true
        end
    elseif interactionType == "guiButton" then
        if obj:IsA("GuiButton") or obj:IsA("TextButton") then
            obj.MouseButton1Click:Fire()
            success = true
        end
    end
    
    return success
end

-- Auto-farming enhancement
function UIBridge.EnhancedAutoFarm()
    spawn(function()
        while Config.AutoPlant.Enabled or Config.AutoCollect.Enabled do
            -- Enhanced plant collection
            if Config.AutoCollect.Enabled then
                local plants = {}
                
                -- Find all harvestable plants
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:HasTag("Harvestable") or obj:HasTag("Grown") or obj:HasTag("Crop") then
                        table.insert(plants, obj)
                    elseif obj.Name:find("Plant") and obj:GetAttribute("Grown") then
                        table.insert(plants, obj)
                    end
                end
                
                -- Collect plants
                for _, plant in pairs(plants) do
                    if Config.AutoCollect.Enabled then
                        UIBridge.InteractWithObject(plant, "proximityPrompt")
                        wait(Config.AutoCollect.CollectInterval)
                    end
                end
            end
            
            -- Enhanced planting
            if Config.AutoPlant.Enabled then
                local spots = {}
                
                -- Find all planting spots
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "PlantingSpot" or obj:HasTag("PlantingSpot") then
                        if not obj:FindFirstChild("Plant") then
                            table.insert(spots, obj)
                        end
                    end
                end
                
                -- Plant seeds
                for _, spot in pairs(spots) do
                    if Config.AutoPlant.Enabled then
                        for _, seedType in pairs(Config.AutoPlant.SelectedSeeds) do
                            if AutomationAPI.FarmingManager.PlantSeed(seedType, spot) then
                                break
                            end
                        end
                        wait(Config.AutoPlant.PlantInterval)
                    end
                end
            end
            
            wait(5) -- Main loop delay
        end
    end)
end

-- Auto-trading enhancement
function UIBridge.EnhancedAutoTrade()
    spawn(function()
        while Config.AutoTrade.Enabled do
            if Config.AutoTrade.TargetPlayerEnabled then
                local targetPlayer = AutomationAPI.TradingManager.FindTargetPlayer()
                if targetPlayer then
                    -- Enhanced trading process
                    local tradableItems = AutomationAPI.TradingManager.GetTradableItems()
                    
                    for _, item in pairs(tradableItems) do
                        -- Equip item for trading
                        if AutomationAPI.TradingManager.EquipItemForTrading(item.name, item.type) then
                            -- Teleport to player
                            UIBridge.SmartTeleport(targetPlayer.Character.HumanoidRootPart.Position)
                            wait(1)
                            
                            -- Try to initiate trade
                            if AutomationAPI.TradingManager.FindAndActivateGiftPrompt(targetPlayer) then
                                wait(3) -- Wait for trade UI
                                break
                            end
                        end
                    end
                end
            end
            
            -- Auto-accept incoming trades
            if Config.AutoTrade.AutoAcceptTrades then
                AutomationAPI.TradingManager.AcceptIncomingTrade()
            end
            
            wait(Config.AutoTrade.RequestInterval)
        end
    end)
end

-- Enhanced pet management
function UIBridge.EnhancedPetManagement()
    spawn(function()
        while Config.PetManagement.Enabled do
            -- Open pet UI
            if AutomationAPI.PetManager.OpenPetUI() then
                wait(2)
                
                -- Perform pet management actions
                if Config.PetManagement.AutoEquip then
                    AutomationAPI.PetManager.EquipBestPets()
                end
                
                if Config.PetManagement.AutoFeed then
                    AutomationAPI.PetManager.FeedPets()
                end
                
                if Config.PetManagement.AutoHatchEggs then
                    AutomationAPI.PetManager.HatchEggs()
                end
                
                wait(1)
            end
            
            wait(10) -- Pet management interval
        end
    end)
end

-- Initialize enhanced automation
function UIBridge.Initialize()
    print("🚀 Initializing Enhanced Automation Bridge...")
    
    -- Start data sync
    UIBridge.StartDataSync()
    
    -- Start enhanced automation loops
    UIBridge.EnhancedAutoFarm()
    UIBridge.EnhancedAutoTrade()
    UIBridge.EnhancedPetManagement()
    
    print("✅ Enhanced Automation Bridge initialized successfully!")
end

-- Export bridge functions
_G.AutomationSystem.Bridge = UIBridge

-- Auto-initialize after 3 seconds
wait(3)
UIBridge.Initialize()

return UIBridge