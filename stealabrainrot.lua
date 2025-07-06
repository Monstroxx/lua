-- Base & Animal Automation LocalScript (Complete Clean Version)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

print("=== STARTING BASE AUTOMATION ===")

-- Warte auf Character
local character = nil
local humanoidRootPart = nil

local function waitForCharacter()
    print("Waiting for character...")
    
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        character = localPlayer.Character
        humanoidRootPart = character.HumanoidRootPart
        print("Character found immediately:", character.Name)
        return
    end
    
    localPlayer.CharacterAdded:Connect(function(newCharacter)
        print("Character spawned:", newCharacter.Name)
        character = newCharacter
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        print("HumanoidRootPart found")
    end)
    
    if localPlayer.Character then
        character = localPlayer.Character
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        print("Character found, waited for HumanoidRootPart")
    end
end

waitForCharacter()
wait(1) -- Kurze Pause

print("Creating GUI...")

-- === GUI CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BaseAutomationGUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Base & Animal Automation"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Money Display
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -10, 0, 20)
moneyLabel.Position = UDim2.new(0, 5, 0, 30)
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
moneyLabel.Text = "Money: $0"
moneyLabel.TextScaled = true
moneyLabel.Font = Enum.Font.SourceSans
moneyLabel.Parent = frame

-- Base Features Header
local baseLabel = Instance.new("TextLabel")
baseLabel.Size = UDim2.new(1, 0, 0, 20)
baseLabel.Position = UDim2.new(0, 0, 0, 50)
baseLabel.BackgroundTransparency = 1
baseLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
baseLabel.Text = "=== BASE FEATURES ==="
baseLabel.TextScaled = true
baseLabel.Font = Enum.Font.SourceSans
baseLabel.Parent = frame

-- Lock Door Button
local lockDoorCheck = Instance.new("TextButton")
lockDoorCheck.Size = UDim2.new(1, -10, 0, 25)
lockDoorCheck.Position = UDim2.new(0, 5, 0, 70)
lockDoorCheck.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
lockDoorCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
lockDoorCheck.Text = "☐ Lock Door"
lockDoorCheck.TextScaled = true
lockDoorCheck.Font = Enum.Font.SourceSans
lockDoorCheck.Parent = frame

-- Collect Money Button
local collectMoneyCheck = Instance.new("TextButton")
collectMoneyCheck.Size = UDim2.new(1, -10, 0, 25)
collectMoneyCheck.Position = UDim2.new(0, 5, 0, 95)
collectMoneyCheck.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
collectMoneyCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
collectMoneyCheck.Text = "☐ Collect Money"
collectMoneyCheck.TextScaled = true
collectMoneyCheck.Font = Enum.Font.SourceSans
collectMoneyCheck.Parent = frame

-- Animal Features Header
local animalLabel = Instance.new("TextLabel")
animalLabel.Size = UDim2.new(1, 0, 0, 20)
animalLabel.Position = UDim2.new(0, 0, 0, 125)
animalLabel.BackgroundTransparency = 1
animalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
animalLabel.Text = "=== ANIMAL FEATURES ==="
animalLabel.TextScaled = true
animalLabel.Font = Enum.Font.SourceSans
animalLabel.Parent = frame

-- Buy Best Button
local buyBestCheck = Instance.new("TextButton")
buyBestCheck.Size = UDim2.new(1, -10, 0, 25)
buyBestCheck.Position = UDim2.new(0, 5, 0, 145)
buyBestCheck.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
buyBestCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
buyBestCheck.Text = "☐ Buy Best"
buyBestCheck.TextScaled = true
buyBestCheck.Font = Enum.Font.SourceSans
buyBestCheck.Parent = frame

-- Buy Custom Button
local buyCustomCheck = Instance.new("TextButton")
buyCustomCheck.Size = UDim2.new(1, -10, 0, 25)
buyCustomCheck.Position = UDim2.new(0, 5, 0, 170)
buyCustomCheck.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
buyCustomCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
buyCustomCheck.Text = "☐ Buy Custom"
buyCustomCheck.TextScaled = true
buyCustomCheck.Font = Enum.Font.SourceSans
buyCustomCheck.Parent = frame

-- Min Price Label
local minPriceLabel = Instance.new("TextLabel")
minPriceLabel.Size = UDim2.new(0.5, -5, 0, 20)
minPriceLabel.Position = UDim2.new(0, 5, 0, 195)
minPriceLabel.BackgroundTransparency = 1
minPriceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
minPriceLabel.Text = "Min Price:"
minPriceLabel.TextScaled = true
minPriceLabel.Font = Enum.Font.SourceSans
minPriceLabel.Parent = frame

-- Min Price Input
local minPriceInput = Instance.new("TextBox")
minPriceInput.Size = UDim2.new(0.5, -5, 0, 20)
minPriceInput.Position = UDim2.new(0.5, 5, 0, 195)
minPriceInput.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
minPriceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
minPriceInput.Text = "1000"
minPriceInput.TextScaled = true
minPriceInput.Font = Enum.Font.SourceSans
minPriceInput.Parent = frame

-- Max Price Label
local maxPriceLabel = Instance.new("TextLabel")
maxPriceLabel.Size = UDim2.new(0.5, -5, 0, 20)
maxPriceLabel.Position = UDim2.new(0, 5, 0, 215)
maxPriceLabel.BackgroundTransparency = 1
maxPriceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
maxPriceLabel.Text = "Max Price:"
maxPriceLabel.TextScaled = true
maxPriceLabel.Font = Enum.Font.SourceSans
maxPriceLabel.Parent = frame

-- Max Price Input
local maxPriceInput = Instance.new("TextBox")
maxPriceInput.Size = UDim2.new(0.5, -5, 0, 20)
maxPriceInput.Position = UDim2.new(0.5, 5, 0, 215)
maxPriceInput.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
maxPriceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
maxPriceInput.Text = "50000"
maxPriceInput.TextScaled = true
maxPriceInput.Font = Enum.Font.SourceSans
maxPriceInput.Parent = frame

-- Buy All Button
local buyAllCheck = Instance.new("TextButton")
buyAllCheck.Size = UDim2.new(1, -10, 0, 25)
buyAllCheck.Position = UDim2.new(0, 5, 0, 235)
buyAllCheck.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
buyAllCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
buyAllCheck.Text = "☐ Buy All"
buyAllCheck.TextScaled = true
buyAllCheck.Font = Enum.Font.SourceSans
buyAllCheck.Parent = frame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0, 265)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
statusLabel.Text = "Ready - Searching for base..."
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

print("GUI created successfully!")

-- === VARIABLES ===
local playerBase = nil
local lockDoorEnabled = false
local collectMoneyEnabled = false
local buyBestEnabled = false
local buyCustomEnabled = false
local buyAllEnabled = false
local isAtBase = false
local playerMoney = 0

-- === FUNCTIONS ===

-- Get Player Money
local function getPlayerMoney()
    for _, gui in pairs(playerGui:GetChildren()) do
        for _, child in pairs(gui:GetDescendants()) do
            if child:IsA("TextLabel") then
                local text = child.Text
                local name = child.Name
                
                if string.find(string.lower(name), "currency") or
                   string.find(string.lower(text), "currency") or
                   (string.find(text, "$") and string.match(text, "%d")) then
                    
                    local number = string.match(text, "%d+")
                    if number then
                        return tonumber(number)
                    end
                    
                    local numberWithComma = string.match(text, "([%d,%.]+)")
                    if numberWithComma then
                        local cleanNumber = string.gsub(numberWithComma, ",", "")
                        return tonumber(cleanNumber) or 0
                    end
                end
            end
        end
    end
    
    local leaderstats = localPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local money = leaderstats:FindFirstChild("Money") or 
                     leaderstats:FindFirstChild("Cash") or 
                     leaderstats:FindFirstChild("Coins") or
                     leaderstats:FindFirstChild("Currency")
        if money then
            return money.Value
        end
    end
    
    return 0
end

-- Find Player Base
local function findPlayerBase()
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local workspace = game:GetService("Workspace")
    local plots = workspace:FindFirstChild("Plots")
    
    if not plots then 
        statusLabel.Text = "No plots found!"
        return nil 
    end
    
    local playerPos = localPlayer.Character.HumanoidRootPart.Position
    local nearestPlot = nil
    local nearestDistance = math.huge
    
    print("Searching for player base from position:", playerPos)
    
    for _, plot in pairs(plots:GetChildren()) do
        local spawn = plot:FindFirstChild("Spawn")
        if spawn then
            local distance = (playerPos - spawn.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlot = plot
            end
        end
    end
    
    if nearestPlot then
        print("Found nearest plot:", nearestPlot.Name, "at distance:", nearestDistance)
    end
    
    return nearestPlot
end

-- Check if laser is active
local function isLaserActive(base)
    local laser = base:FindFirstChild("Laser")
    if not laser then return false end
    
    for _, laserPart in pairs(laser:GetChildren()) do
        if laserPart:IsA("Model") then
            for _, part in pairs(laserPart:GetChildren()) do
                if part:IsA("BasePart") and part.Transparency < 1 then
                    return true
                end
            end
        end
    end
    return false
end

-- Touch door hitbox (CORRECTED FOR FOLDER STRUCTURE)
local function touchDoorHitbox()
    if not playerBase or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    print("Looking for door hitbox in base:", playerBase.Name)
    
    local purchases = playerBase:FindFirstChild("Purchases")
    if not purchases then
        statusLabel.Text = "Purchases folder not found"
        print("Error: Purchases folder not found")
        return
    end
    
    local plotBlock = purchases:FindFirstChild("PlotBlock")
    if not plotBlock then
        statusLabel.Text = "PlotBlock not found"
        print("Error: PlotBlock not found in Purchases")
        return
    end
    
    local hitbox = plotBlock:FindFirstChild("Hitbox")
    if not hitbox then
        statusLabel.Text = "Hitbox not found"
        print("Error: Hitbox not found in PlotBlock")
        return
    end
    
    if hitbox:FindFirstChild("TouchInterest") then
        statusLabel.Text = "Door activated!"
        print("TouchInterest found! Touching hitbox...")
        hitbox:Touch(localPlayer.Character.HumanoidRootPart)
        print("Door hitbox touched successfully!")
    else
        statusLabel.Text = "TouchInterest not found"
        print("Error: TouchInterest not found in hitbox")
    end
end

-- Tween to base
local function tweenToBase()
    if not playerBase then return end
    local spawn = playerBase:FindFirstChild("Spawn")
    if not spawn or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    statusLabel.Text = "Moving to base..."
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(
        localPlayer.Character.HumanoidRootPart,
        tweenInfo,
        {Position = spawn.Position + Vector3.new(0, 5, 0)}
    )
    tween:Play()
    tween.Completed:Connect(function()
        statusLabel.Text = "At base - activating door"
        wait(0.5)
        touchDoorHitbox()
    end)
end

-- Collect money
local function collectMoney()
    if not playerBase or not collectMoneyEnabled or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local purchases = playerBase:FindFirstChild("Purchases")
    if purchases then
        for _, purchase in pairs(purchases:GetChildren()) do
            if purchase:IsA("Model") then
                local hitbox = purchase:FindFirstChild("Hitbox")
                if hitbox and hitbox:FindFirstChild("TouchInterest") then
                    hitbox:Touch(localPlayer.Character.HumanoidRootPart)
                end
            end
        end
    end
end

-- Check if at base
local function checkIfAtBase()
    if not playerBase or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local spawn = playerBase:FindFirstChild("Spawn")
    if not spawn then return false end
    local distance = (localPlayer.Character.HumanoidRootPart.Position - spawn.Position).Magnitude
    return distance < 50
end

-- Get animal price
local function getAnimalPrice(animal)
    local animalOverhead = animal:FindFirstChild("AnimalOverhead")
    if not animalOverhead then return nil end
    
    for _, child in pairs(animalOverhead:GetChildren()) do
        if child:IsA("TextLabel") and string.find(child.Text, "$") then
            local priceText = child.Text
            local number = string.match(priceText, "%$(%d+)K")
            if number then
                return tonumber(number) * 1000
            end
            number = string.match(priceText, "%$(%d+)")
            if number then
                return tonumber(number)
            end
        end
    end
    return nil
end

-- Find best affordable animal
local function findBestAffordableAnimal()
    local workspace = game:GetService("Workspace")
    local movingAnimals = workspace:FindFirstChild("MovingAnimals")
    if not movingAnimals then return nil end
    
    local currentMoney = getPlayerMoney()
    local bestAnimal = nil
    local bestPrice = 0
    
    for _, animal in pairs(movingAnimals:GetChildren()) do
        if animal:IsA("Model") then
            local price = getAnimalPrice(animal)
            if price and price <= currentMoney and price > bestPrice then
                bestPrice = price
                bestAnimal = animal
            end
        end
    end
    
    return bestAnimal, bestPrice
end

-- Find animal in price range
local function findAnimalInPriceRange(minPrice, maxPrice)
    local workspace = game:GetService("Workspace")
    local movingAnimals = workspace:FindFirstChild("MovingAnimals")
    if not movingAnimals then return nil end
    
    local currentMoney = getPlayerMoney()
    local bestAnimal = nil
    local bestPrice = 0
    
    for _, animal in pairs(movingAnimals:GetChildren()) do
        if animal:IsA("Model") then
            local price = getAnimalPrice(animal)
            if price and price >= minPrice and price <= maxPrice and price <= currentMoney and price > bestPrice then
                bestPrice = price
                bestAnimal = animal
            end
        end
    end
    
    return bestAnimal, bestPrice
end

-- Find most expensive affordable animal
local function findMostExpensiveAffordableAnimal()
    local workspace = game:GetService("Workspace")
    local movingAnimals = workspace:FindFirstChild("MovingAnimals")
    if not movingAnimals then return nil end
    
    local currentMoney = getPlayerMoney()
    local bestAnimal = nil
    local bestPrice = 0
    
    for _, animal in pairs(movingAnimals:GetChildren()) do
        if animal:IsA("Model") then
            local price = getAnimalPrice(animal)
            if price and price <= currentMoney and price > bestPrice then
                bestPrice = price
                bestAnimal = animal
            end
        end
    end
    
    return bestAnimal, bestPrice
end

-- Move to animal and buy
local function moveToAnimalAndBuy(animal)
    if not animal or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local animalPos = animal:FindFirstChild("HumanoidRootPart")
    if not animalPos then return end
    
    statusLabel.Text = "Moving to animal..."
    
    local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(
        localPlayer.Character.HumanoidRootPart,
        tweenInfo,
        {Position = animalPos.Position + Vector3.new(0, 5, 0)}
    )
    
    tween:Play()
    
    tween.Completed:Connect(function()
        wait(0.5)
        if animal:FindFirstChild("HumanoidRootPart") then
            animal.HumanoidRootPart:Touch(localPlayer.Character.HumanoidRootPart)
            statusLabel.Text = "Animal touched - attempting purchase"
        end
    end)
end

-- === EVENT HANDLERS ===

lockDoorCheck.MouseButton1Click:Connect(function()
    lockDoorEnabled = not lockDoorEnabled
    lockDoorCheck.Text = (lockDoorEnabled and "☑" or "☐") .. " Lock Door"
    print("Lock Door:", lockDoorEnabled)
end)

collectMoneyCheck.MouseButton1Click:Connect(function()
    collectMoneyEnabled = not collectMoneyEnabled
    collectMoneyCheck.Text = (collectMoneyEnabled and "☑" or "☐") .. " Collect Money"
    print("Collect Money:", collectMoneyEnabled)
end)

buyBestCheck.MouseButton1Click:Connect(function()
    buyBestEnabled = not buyBestEnabled
    buyBestCheck.Text = (buyBestEnabled and "☑" or "☐") .. " Buy Best"
    if buyBestEnabled then
        buyCustomEnabled = false
        buyAllEnabled = false
        buyCustomCheck.Text = "☐ Buy Custom"
        buyAllCheck.Text = "☐ Buy All"
    end
    print("Buy Best:", buyBestEnabled)
end)

buyCustomCheck.MouseButton1Click:Connect(function()
    buyCustomEnabled = not buyCustomEnabled
    buyCustomCheck.Text = (buyCustomEnabled and "☑" or "☐") .. " Buy Custom"
    if buyCustomEnabled then
        buyBestEnabled = false
        buyAllEnabled = false
        buyBestCheck.Text = "☐ Buy Best"
        buyAllCheck.Text = "☐ Buy All"
    end
    print("Buy Custom:", buyCustomEnabled)
end)

buyAllCheck.MouseButton1Click:Connect(function()
    buyAllEnabled = not buyAllEnabled
    buyAllCheck.Text = (buyAllEnabled and "☑" or "☐") .. " Buy All"
    if buyAllEnabled then
        buyBestEnabled = false
        buyCustomEnabled = false
        buyBestCheck.Text = "☐ Buy Best"
        buyCustomCheck.Text = "☐ Buy Custom"
    end
    print("Buy All:", buyAllEnabled)
end)

-- Character respawn handler
localPlayer.CharacterAdded:Connect(function(newCharacter)
    print("Character respawned")
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    playerBase = nil
    statusLabel.Text = "Character respawned - finding base..."
end)

-- === MAIN LOOP ===
spawn(function()
    while true do
        wait(3)
        
        -- Update money
        playerMoney = getPlayerMoney()
        moneyLabel.Text = "Money: $" .. tostring(playerMoney)
        
        -- Find base
        if not playerBase then
            playerBase = findPlayerBase()
            if playerBase then
                statusLabel.Text = "Base found!"
                print("Base found:", playerBase.Name)
            else
                statusLabel.Text = "Searching for base..."
            end
        end
        
        if playerBase then
            isAtBase = checkIfAtBase()
            
            -- Lock door logic
            if lockDoorEnabled and not isLaserActive(playerBase) and not isAtBase then
                tweenToBase()
            end
            
            -- Collect money logic
            if collectMoneyEnabled and isAtBase then
                collectMoney()
            end
            
            -- Animal buying logic
            if buyBestEnabled then
                local animal, price = findBestAffordableAnimal()
                if animal and price then
                    statusLabel.Text = "Found best animal: $" .. tostring(price)
                    moveToAnimalAndBuy(animal)
                    wait(5)
                end
            elseif buyCustomEnabled then
                local minPrice = tonumber(minPriceInput.Text) or 1000
                local maxPrice = tonumber(maxPriceInput.Text) or 50000
                local animal, price = findAnimalInPriceRange(minPrice, maxPrice)
                if animal and price then
                    statusLabel.Text = "Found custom animal: $" .. tostring(price)
                    moveToAnimalAndBuy(animal)
                    wait(5)
                end
            elseif buyAllEnabled then
                local animal, price = findMostExpensiveAffordableAnimal()
                if animal and price then
                    statusLabel.Text = "Found expensive animal: $" .. tostring(price)
                    moveToAnimalAndBuy(animal)
                    wait(5)
                end
            end
        end
    end
end)

print("=== BASE & ANIMAL AUTOMATION LOADED SUCCESSFULLY ===")
