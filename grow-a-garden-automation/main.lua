-- Pet Gifting Script - Fixed version using working pattern from mainalt.lua

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
    DebugMode = true
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

-- Pet Functions
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
                        wait(1.5)
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

local function EquipPet(petId)
    if not PetsService then 
        Log("❌ PetsService not available")
        return false 
    end
    
    Log("⚙️ Equipping pet: " .. tostring(petId))
    
    local success, error = pcall(function()
        PetsService:EquipPet(petId, 1)
    end)
    
    if success then
        Log("✅ Equipped pet: " .. tostring(petId))
        return true
    else
        Log("❌ Failed to equip: " .. tostring(error))
        return false
    end
end

local function MakePetIntoTool(petId)
    if not PetsService then 
        Log("❌ PetsService not available")
        return false 
    end
    
    Log("🔧 Converting pet to tool: " .. tostring(petId))
    
    local success, error = pcall(function()
        PetsService:UnequipPet(petId)
    end)
    
    if success then
        Log("✅ Converted to tool: " .. tostring(petId))
        return true
    else
        Log("❌ Failed to convert: " .. tostring(error))
        return false
    end
end

local function WaitForPetTool(petId, maxWait)
    maxWait = maxWait or 8
    local waited = 0
    
    Log("🔍 Waiting for pet tool to appear in character or backpack...")
    
    while waited < maxWait do
        local character = LocalPlayer.Character
        local backpack = LocalPlayer.Backpack
        
        -- Check character first
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolPetUUID = tool:GetAttribute("PET_UUID")
                    local toolUUID = tool:GetAttribute("UUID")
                    
                    if toolPetUUID == petId or toolUUID == petId then
                        Log("✅ Found matching pet tool in character: " .. tostring(tool.Name))
                        return tool
                    end
                end
            end
        end
        
        -- Check backpack
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolPetUUID = tool:GetAttribute("PET_UUID")
                    local toolUUID = tool:GetAttribute("UUID")
                    
                    if toolPetUUID == petId or toolUUID == petId then
                        Log("✅ Found matching pet tool in backpack: " .. tostring(tool.Name))
                        
                        -- Move tool to character
                        local success = pcall(function()
                            tool.Parent = character
                        end)
                        
                        if success then
                            Log("✅ Moved tool to character")
                            wait(0.5)
                            return tool
                        else
                            Log("❌ Failed to move tool to character")
                        end
                    end
                end
            end
        end
        
        wait(0.5)
        waited = waited + 0.5
    end
    
    Log("❌ Pet tool not found after " .. waited .. "s (looking for ID: " .. tostring(petId) .. ")")
    return nil
end

local function TriggerGiftProximityPrompt()
    -- Look for gift proximity prompts (from mainalt.lua)
    local character = LocalPlayer.Character
    if not character then
        Log("❌ No character found for proximity prompt")
        return false
    end

    -- Find proximity prompts related to gifting
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local actionText = obj.ActionText:lower()
            if actionText:find("gift") or actionText:find("give") then
                Log("🎁 Found gift proximity prompt: " .. obj.ActionText)
                local success, error = pcall(function()
                    obj:InputHoldBegin()
                    wait(obj.HoldDuration or 0.5)
                    obj:InputHoldEnd()
                end)

                if success then
                    Log("✅ Triggered gift proximity prompt")
                    return true
                else
                    Log("❌ Failed to trigger proximity prompt: " .. tostring(error))
                end
            end
        end
    end

    Log("❌ No gift proximity prompt found")
    return false
end

local function GiftCurrentPet(targetPlayer)
    if not targetPlayer then
        Log("❌ No target player provided")
        return false
    end

    local character = LocalPlayer.Character
    if not character then
        Log("❌ No character found")
        return false
    end

    -- Check if we have a pet equipped/held
    local currentTool = character:FindFirstChildWhichIsA("Tool")
    if not currentTool then
        Log("❌ No pet tool found in character")
        return false
    end

    local petUUID = currentTool:GetAttribute("PET_UUID")
    if not petUUID then
        Log("❌ Tool is not a pet")
        return false
    end

    Log("🎁 Gifting pet: " .. tostring(currentTool.Name) .. " to " .. tostring(targetPlayer.Name))

    -- Try to gift the pet using the PetGiftingService first
    if PetGiftingService then
        local success, error = pcall(function()
            PetGiftingService:GivePet(targetPlayer)
        end)

        if success then
            Log("✅ Pet gift request sent via PetGiftingService: " .. tostring(currentTool.Name))
            return true
        else
            Log("❌ PetGiftingService failed: " .. tostring(error))
        end
    end

    -- Fallback to proximity prompt (like in mainalt.lua)
    Log("🔄 Trying proximity prompt fallback...")
    return TriggerGiftProximityPrompt()
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
        
        -- Step 2: Equip pet
        Log("⚙️ Step 2: Equipping pet...")
        if EquipPet(pet.id) then
            wait(2) -- Wait for equip to complete
            
            -- Step 3: Convert to tool  
            Log("🔧 Step 3: Converting to tool...")
            if MakePetIntoTool(pet.id) then
                wait(1) -- Wait for conversion to complete
                
                -- Step 4: Wait for tool and gift
                Log("⏳ Step 4: Waiting for tool...")
                local tool = WaitForPetTool(pet.id, 8)
                if tool then
                    Log("🎁 Step 5: Attempting to gift pet...")
                    if GiftCurrentPet(targetPlayer) then
                        giftedCount = giftedCount + 1
                        Log("🎉 Successfully gifted: " .. pet.name)
                        wait(3)
                        
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

Log("🚀 Gifting automation loaded - single attempt per pet!")