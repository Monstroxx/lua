-- Simple Loader for Grow a Garden Automation
-- Alternative loader that focuses on backend initialization

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("🚀 Simple Loader starting...")

-- Clear any existing automation system
_G.AutomationSystem = nil

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(2)

print("📡 Loading backend system directly...")

-- Load backend with retry mechanism
local maxRetries = 3
local currentRetry = 0

while currentRetry < maxRetries do
    currentRetry = currentRetry + 1
    print("📥 Loading attempt", currentRetry, "of", maxRetries)
    
    local success, error = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/completeAutomationSystem.lua"))()
    end)
    
    if success then
        print("✅ Backend loaded successfully on attempt", currentRetry)
        break
    else
        warn("❌ Loading attempt", currentRetry, "failed:", error)
        
        if currentRetry < maxRetries then
            print("⏳ Retrying in 3 seconds...")
            wait(3)
        else
            warn("❌ All loading attempts failed!")
            return
        end
    end
end

-- Check if backend is properly initialized
print("🔍 Checking backend initialization...")

local function checkBackend()
    if not _G.AutomationSystem then
        return false, "AutomationSystem not found"
    end
    
    if not _G.AutomationSystem.Config then
        return false, "Config not available"
    end
    
    if not _G.AutomationSystem.Config.AutoPlant then
        return false, "Config.AutoPlant not available"
    end
    
    if not _G.AutomationSystem.Functions then
        return false, "Functions not available"
    end
    
    return true, "All components available"
end

-- Wait for initialization with timeout
local checkAttempts = 0
local maxCheckAttempts = 30 -- 3 seconds total

while checkAttempts < maxCheckAttempts do
    local isReady, message = checkBackend()
    
    if isReady then
        print("✅ Backend initialization complete:", message)
        break
    else
        checkAttempts = checkAttempts + 1
        print("⏳ Backend check", checkAttempts, "of", maxCheckAttempts, "-", message)
        wait(0.1)
    end
end

-- Final status check
local isReady, message = checkBackend()
if not isReady then
    warn("❌ Backend initialization failed after timeout:", message)
    
    print("🔍 Debug information:")
    print("  _G.AutomationSystem exists:", _G.AutomationSystem ~= nil)
    
    if _G.AutomationSystem then
        print("  Available keys:")
        for key, value in pairs(_G.AutomationSystem) do
            print("    ", key, "=", type(value))
        end
        
        if _G.AutomationSystem.Config then
            print("  Config keys:")
            for key, value in pairs(_G.AutomationSystem.Config) do
                print("    ", key, "=", type(value))
            end
        end
    end
    
    return
end

-- Enable automation by default
if _G.AutomationSystem.Config then
    _G.AutomationSystem.Config.Enabled = true
    print("✅ Automation enabled by default")
end

-- Setup manual controls
local function setupControls()
    local function onChatted(message)
        local command = message:lower()
        
        if command == "/start" then
            if _G.AutomationSystem.Config then
                _G.AutomationSystem.Config.Enabled = true
                print("✅ Automation started")
            end
        elseif command == "/stop" then
            if _G.AutomationSystem.Config then
                _G.AutomationSystem.Config.Enabled = false
                print("⏹️ Automation stopped")
            end
        elseif command == "/status" then
            if _G.AutomationSystem.Functions and _G.AutomationSystem.Functions.GetStatus then
                local status = _G.AutomationSystem.Functions.GetStatus()
                print("📊 Status:")
                for key, value in pairs(status) do
                    print("  ", key, ":", tostring(value))
                end
            else
                print("📊 Basic Status:")
                print("  Enabled:", _G.AutomationSystem.Config.Enabled)
            end
        elseif command == "/help" then
            print("🎮 Available commands:")
            print("  /start - Start automation")
            print("  /stop - Stop automation") 
            print("  /status - Show status")
            print("  /help - Show this help")
        end
    end
    
    LocalPlayer.Chatted:Connect(onChatted)
    print("💬 Chat commands available: /start, /stop, /status, /help")
end

setupControls()

print("🎉 Simple Loader completed successfully!")
print("💡 Use /start to begin automation")
print("💡 Use /help for available commands")

return _G.AutomationSystem