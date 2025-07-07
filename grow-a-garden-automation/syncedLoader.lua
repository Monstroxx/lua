-- Synced Loader for Grow a Garden Automation
-- Properly syncs UI and Backend without circular loading

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

print("🔄 Starting Synced Loader...")

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(2)

-- Clear any existing automation system
_G.AutomationSystem = nil

-- STEP 1: Load Backend First (without UI)
print("📡 Loading Backend System...")

local backendSuccess, backendError = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/completeAutomationSystem.lua"))()
end)

if not backendSuccess then
    warn("❌ Backend loading failed:", backendError)
    return
end

-- Wait for backend to initialize
local attempts = 0
while (not _G.AutomationSystem or not _G.AutomationSystem.Config) and attempts < 50 do
    wait(0.1)
    attempts = attempts + 1
    
    if attempts % 10 == 0 then
        print("⏳ Waiting for backend... Attempt", attempts)
    end
end

if not _G.AutomationSystem or not _G.AutomationSystem.Config then
    warn("❌ Backend initialization failed")
    return
end

print("✅ Backend System loaded and ready")

-- STEP 2: Create UI-Backend Bridge
print("🔗 Creating UI-Backend Bridge...")

-- Store backend config reference
local BackendConfig = _G.AutomationSystem.Config

-- Create communication bridge
local Bridge = {
    backendConfig = BackendConfig,
    uiConfig = nil,
    syncInterval = 2, -- seconds
    lastSync = 0
}

-- Bidirectional sync function
function Bridge:SyncConfigs()
    local currentTime = tick()
    if currentTime - self.lastSync < self.syncInterval then
        return
    end
    
    self.lastSync = currentTime
    
    -- If UI config exists, sync it to backend
    if self.uiConfig then
        for key, value in pairs(self.uiConfig) do
            if self.backendConfig[key] then
                if type(value) == "table" and type(self.backendConfig[key]) == "table" then
                    -- Deep merge for nested tables
                    for subKey, subValue in pairs(value) do
                        self.backendConfig[key][subKey] = subValue
                    end
                else
                    self.backendConfig[key] = value
                end
            end
        end
        
        -- Update global config
        _G.AutomationSystem.Config = self.backendConfig
    end
    
    -- Sync backend changes to UI if needed
    if self.uiConfig then
        for key, value in pairs(self.backendConfig) do
            if self.uiConfig[key] then
                if type(value) == "table" and type(self.uiConfig[key]) == "table" then
                    for subKey, subValue in pairs(value) do
                        self.uiConfig[key][subKey] = subValue
                    end
                else
                    self.uiConfig[key] = value
                end
            end
        end
    end
end

-- Start sync loop
spawn(function()
    while true do
        pcall(function()
            Bridge:SyncConfigs()
        end)
        wait(1)
    end
end)

-- Make bridge globally accessible
_G.AutomationSystem.Bridge = Bridge

print("✅ Bridge created")

-- STEP 3: Load UI (optional)
print("🎨 Loading UI System...")

local uiLoadChoice = "yes" -- You can change this to "no" to skip UI

if uiLoadChoice == "yes" then
    local uiSuccess, uiError = pcall(function()
        -- Load UI script content
        local uiScript = game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/advancedAutomationUI.lua")
        
        -- Modify the UI script to use our existing config
        local modifiedScript = uiScript:gsub(
            "local AutomationConfig = {",
            [[
-- Use existing backend config instead of creating new one
local AutomationConfig = _G.AutomationSystem.Config

-- Register with bridge for syncing
if _G.AutomationSystem.Bridge then
    _G.AutomationSystem.Bridge.uiConfig = AutomationConfig
end

-- Original config definition (commented out)
--local AutomationConfig = {]]
        )
        
        -- Execute modified UI script
        loadstring(modifiedScript)()
    end)
    
    if uiSuccess then
        print("✅ UI System loaded and synced")
    else
        warn("⚠️ UI loading failed:", uiError)
        print("📡 Continuing with backend only")
    end
else
    print("⏭️ Skipping UI load")
end

-- STEP 4: Setup Manual Controls
print("🎮 Setting up manual controls...")

local function onChatted(message)
    local command = message:lower()
    
    if command == "/start" then
        BackendConfig.Enabled = true
        print("✅ Automation started")
    elseif command == "/stop" then
        BackendConfig.Enabled = false
        print("⏹️ Automation stopped")
    elseif command == "/status" then
        print("📊 Automation Status:")
        print("  Enabled:", BackendConfig.Enabled)
        print("  AutoPlant:", BackendConfig.AutoPlant.Enabled)
        print("  AutoCollect:", BackendConfig.AutoCollect.Enabled)
        print("  AutoBuySeeds:", BackendConfig.AutoBuySeeds.Enabled)
        print("  PetManagement:", BackendConfig.PetManagement.Enabled)
        print("  AutoTrade:", BackendConfig.AutoTrade.Enabled)
    elseif command == "/sync" then
        Bridge:SyncConfigs()
        print("🔄 Manual sync triggered")
    elseif command == "/plant" then
        if _G.AutomationSystem.Functions and _G.AutomationSystem.Functions.ManualTrigger then
            _G.AutomationSystem.Functions.ManualTrigger("plantSeeds")
        end
    elseif command == "/collect" then
        if _G.AutomationSystem.Functions and _G.AutomationSystem.Functions.ManualTrigger then
            _G.AutomationSystem.Functions.ManualTrigger("collectPlants")
        end
    elseif command == "/buy" then
        if _G.AutomationSystem.Functions and _G.AutomationSystem.Functions.ManualTrigger then
            _G.AutomationSystem.Functions.ManualTrigger("buySeeds")
        end
    elseif command == "/help" then
        print("🌱 Synced Automation Commands:")
        print("  /start - Start automation")
        print("  /stop - Stop automation")
        print("  /status - Show detailed status")
        print("  /sync - Force config sync")
        print("  /plant - Manual plant")
        print("  /collect - Manual collect")
        print("  /buy - Manual buy seeds")
        print("  /help - Show this help")
    end
end

LocalPlayer.Chatted:Connect(onChatted)

print("✅ Manual controls ready")

-- STEP 5: Final Status
print("🎉 Synced Loader completed successfully!")
print("📊 System Status:")
print("  Backend: ✅ Loaded")
print("  Config: ✅ Available")
print("  Bridge: ✅ Running")
print("  UI: " .. (uiLoadChoice == "yes" and "✅ Loaded" or "⏭️ Skipped"))
print("")
print("💬 Use /help for available commands")
print("💬 Use /start to begin automation")
print("🔄 Config sync active - UI and Backend stay synchronized")

return _G.AutomationSystem