-- Main Loader Script for Grow a Garden Automation
-- This script loads and connects all components properly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

print("🌱 Starting Grow a Garden Automation System...")

-- Wait for game to load completely
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Wait for essential game services
wait(3)

-- Initialize global automation system
_G.AutomationSystem = _G.AutomationSystem or {
    Config = {},
    Functions = {},
    UI = {},
    Bridge = {},
    Loaded = false
}

-- Load Backend System
print("📡 Loading Backend System...")

local backendSuccess, backendError = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/completeAutomationSystem.lua"))()
end)

if not backendSuccess then
    warn("❌ Backend loading failed:", backendError)
    return
end

-- Wait for backend to initialize with better error checking
local attempts = 0
while (not _G.AutomationSystem.Functions or not _G.AutomationSystem.Config) and attempts < 100 do
    wait(0.1)
    attempts = attempts + 1
    
    if attempts % 20 == 0 then
        print("⏳ Waiting for backend initialization... Attempt", attempts)
        print("   Functions available:", _G.AutomationSystem.Functions ~= nil)
        print("   Config available:", _G.AutomationSystem.Config ~= nil)
        
        if _G.AutomationSystem.Config then
            print("   Config type:", type(_G.AutomationSystem.Config))
            print("   Config has AutoPlant:", _G.AutomationSystem.Config.AutoPlant ~= nil)
        end
    end
end

if not _G.AutomationSystem.Functions then
    warn("❌ Backend initialization timed out - Functions not available")
    print("Debug: _G.AutomationSystem contents:")
    for key, value in pairs(_G.AutomationSystem or {}) do
        print("  ", key, "=", type(value))
    end
    return
end

if not _G.AutomationSystem.Config then
    warn("❌ Backend initialization timed out - Config not available")
    print("Debug: _G.AutomationSystem contents:")
    for key, value in pairs(_G.AutomationSystem or {}) do
        print("  ", key, "=", type(value))
    end
    return
end

-- Verify config structure
if not _G.AutomationSystem.Config.AutoPlant then
    warn("❌ Config structure invalid - AutoPlant missing")
    print("Config keys available:")
    for key, value in pairs(_G.AutomationSystem.Config or {}) do
        print("  ", key, "=", type(value))
    end
    return
end

print("✅ Backend System loaded successfully!")

-- Load UI System
print("🎨 Loading UI System...")
local uiScript = [[
    -- UI loading code will be inserted here
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/advancedAutomationUI.lua"))()
]]

local uiSuccess, uiError = pcall(function()
    loadstring(uiScript)()
end)

if not uiSuccess then
    warn("❌ UI loading failed:", uiError)
    return
end

print("✅ UI System loaded successfully!")

-- Load Bridge System
print("🔗 Loading Bridge System...")
local bridgeScript = [[
    -- Bridge loading code will be inserted here
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/automationBridge.lua"))()
]]

local bridgeSuccess, bridgeError = pcall(function()
    loadstring(bridgeScript)()
end)

if not bridgeSuccess then
    warn("❌ Bridge loading failed:", bridgeError)
    return
end

print("✅ Bridge System loaded successfully!")

-- Enhanced Error Handling
local function SafeCall(func, name)
    local success, error = pcall(func)
    if not success then
        warn("❌ Error in " .. name .. ":", error)
        if _G.AutomationSystem.Functions and _G.AutomationSystem.Functions.Webhook then
            _G.AutomationSystem.Functions.Webhook:Log("ERROR", "Function failed: " .. name, {Error = error})
        end
    end
    return success
end

-- Enhanced Manual Controls
local ManualControls = {}

function ManualControls.StartAutomation()
    if _G.AutomationSystem.Config then
        _G.AutomationSystem.Config.Enabled = true
        print("✅ Automation started!")
        return true
    end
    return false
end

function ManualControls.StopAutomation()
    if _G.AutomationSystem.Config then
        _G.AutomationSystem.Config.Enabled = false
        print("⏹️ Automation stopped!")
        return true
    end
    return false
end

function ManualControls.GetStatus()
    if _G.AutomationSystem.Functions then
        return _G.AutomationSystem.Functions.GetStatus()
    end
    return {}
end

function ManualControls.ManualPlant()
    if _G.AutomationSystem.Functions then
        SafeCall(function()
            _G.AutomationSystem.Functions.ManualTrigger("plantSeeds")
        end, "ManualPlant")
    end
end

function ManualControls.ManualCollect()
    if _G.AutomationSystem.Functions then
        SafeCall(function()
            _G.AutomationSystem.Functions.ManualTrigger("collectPlants")
        end, "ManualCollect")
    end
end

function ManualControls.ManualBuySeeds()
    if _G.AutomationSystem.Functions then
        SafeCall(function()
            _G.AutomationSystem.Functions.ManualTrigger("buySeeds")
        end, "ManualBuySeeds")
    end
end

function ManualControls.ManualPetManagement()
    if _G.AutomationSystem.Functions then
        SafeCall(function()
            _G.AutomationSystem.Functions.ManualTrigger("managePets")
        end, "ManualPetManagement")
    end
end

function ManualControls.AcceptTrade()
    if _G.AutomationSystem.Functions then
        SafeCall(function()
            _G.AutomationSystem.Functions.ManualTrigger("acceptTrade")
        end, "AcceptTrade")
    end
end

function ManualControls.TradeWithPlayer(playerName)
    if _G.AutomationSystem.Functions then
        SafeCall(function()
            _G.AutomationSystem.Functions.ManualTrigger("tradeWithPlayer", playerName)
        end, "TradeWithPlayer")
    end
end

-- Chat Commands
local function OnChatted(message)
    local command = message:lower()
    
    if command == "/autostart" then
        ManualControls.StartAutomation()
    elseif command == "/autostop" then
        ManualControls.StopAutomation()
    elseif command == "/autostatus" then
        local status = ManualControls.GetStatus()
        print("📊 Automation Status:")
        for key, value in pairs(status) do
            print("  " .. key .. ": " .. tostring(value))
        end
    elseif command == "/plant" then
        ManualControls.ManualPlant()
    elseif command == "/collect" then
        ManualControls.ManualCollect()
    elseif command == "/buy" then
        ManualControls.ManualBuySeeds()
    elseif command == "/pets" then
        ManualControls.ManualPetManagement()
    elseif command == "/trade" then
        ManualControls.AcceptTrade()
    elseif command:sub(1, 11) == "/tradewith " then
        local playerName = command:sub(12)
        ManualControls.TradeWithPlayer(playerName)
    elseif command == "/help" then
        print("🌱 Grow a Garden Automation Commands:")
        print("  /autostart - Start automation")
        print("  /autostop - Stop automation")
        print("  /autostatus - Show status")
        print("  /plant - Manual plant")
        print("  /collect - Manual collect")
        print("  /buy - Manual buy seeds")
        print("  /pets - Manual pet management")
        print("  /trade - Accept trade")
        print("  /tradewith [player] - Trade with player")
    end
end

-- Connect chat commands
LocalPlayer.Chatted:Connect(OnChatted)

-- Store manual controls globally
_G.AutomationSystem.ManualControls = ManualControls

-- Emergency Stop Function
local function EmergencyStop()
    if _G.AutomationSystem.Config then
        _G.AutomationSystem.Config.Enabled = false
        print("🆘 EMERGENCY STOP ACTIVATED!")
    end
end

-- Keybind for emergency stop (Ctrl+Alt+X)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        local alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
        
        if ctrl and alt then
            EmergencyStop()
        end
    end
end)

-- Health Check System
spawn(function()
    while true do
        wait(30) -- Check every 30 seconds
        
        if _G.AutomationSystem.Functions then
            local status = ManualControls.GetStatus()
            if status.Enabled then
                print("💓 Automation health check: RUNNING")
            end
        end
    end
end)

-- Final initialization
_G.AutomationSystem.Loaded = true
print("🎉 Grow a Garden Automation System fully loaded!")
print("💬 Type /help for available commands")
print("🆘 Emergency stop: Ctrl+Alt+X")

-- Return the system for external access
return _G.AutomationSystem