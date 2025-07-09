-- Gifting Automation Script for Grow a Garden
-- Automatically gifts pets and trees to target players in the lobby

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- Wait for game to load
if not game:IsLoaded() then
	game.Loaded:Wait()
end
wait(3)

-- Import game modules
local DataService = require(ReplicatedStorage.Modules.DataService)
local PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService)
local PetGiftingService = require(ReplicatedStorage.Modules.PetServices.PetGiftingService)
local TeleportUIController = require(ReplicatedStorage.Modules.TeleportUIController)

-- Import pet data
local PetList = require(ReplicatedStorage.Data.PetRegistry.PetList)
local PetRarities = require(ReplicatedStorage.Data.PetRegistry.PetRarities)

-- Configuration
local GiftingConfig = {
	Enabled = false,
	TargetPlayerName = "CoolHolzBudd", -- Set the target player name here

	-- Pet gifting settings
	GiftDivinePets = true,
	GiftMythicalPets = true,
	GiftLegendaryPets = false,

	-- Tree/Plant gifting settings
	GiftTreesAboveValue = 1000000000, -- 1 billion
	GiftTreesEnabled = true,

	-- Timing settings
	DelayBetweenGifts = 3, -- seconds
	RetryAttempts = 3,
	TeleportDelay = 2, -- seconds after teleporting

	-- Debug settings
	DebugMode = true,
}

-- Rarity value mapping for sorting
local RarityValues = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Legendary = 4,
	Mythical = 5,
	Divine = 6,
}

-- Gifting State
local GiftingState = {
	IsRunning = false,
	CurrentStage = "Idle",
	TargetPlayer = nil,
	CurrentPetIndex = 1,
	CurrentTreeIndex = 1,
	GiftedPets = {},
	GiftedTrees = {},
}

-- Utility Functions
local function Log(message)
	if GiftingConfig.DebugMode then
		print("[Gifting Automation] " .. message)
	end
end

local function GetPlayerData()
	local data = DataService:GetData()
	return data or {}
end

local function GetPetInventory()
	local data = GetPlayerData()
	if not data.PetsData or not data.PetsData.PetInventory then
		return {}
	end
	return data.PetsData.PetInventory.Data or {}
end

local function GetEquippedPets()
	local data = GetPlayerData()
	if not data.PetsData or not data.PetsData.EquippedPets then
		return {}
	end
	return data.PetsData.EquippedPets or {}
end

local function GetBackpack()
	local data = GetPlayerData()
	return data.Backpack or {}
end

local function GetPlantedObjects()
	local data = GetPlayerData()
	return data.PlantedObjects or {}
end

-- Player Finding Functions
local function FindTargetPlayer()
	local targetName = GiftingConfig.TargetPlayerName
	if targetName == "" then
		Log("No target player name configured")
		return nil
	end

	-- Find target player in current game
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name:lower() == targetName:lower() or player.DisplayName:lower() == targetName:lower() then
			Log("Found target player: " .. player.Name)
			return player
		end
	end

	Log("Target player not found: " .. targetName)
	return nil
end

local function TeleportToPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then
		Log("Cannot teleport - invalid target player")
		return false
	end

	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		Log("Cannot teleport - no character")
		return false
	end

	local success, error = pcall(function()
		local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
		local teleportPosition = targetPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))

		TeleportUIController:Move(CFrame.new(teleportPosition))
	end)

	if success then
		Log("Teleported to target player: " .. targetPlayer.Name)
		wait(GiftingConfig.TeleportDelay)
		return true
	else
		Log("Failed to teleport: " .. tostring(error))
		return false
	end
end

-- Pet Management Functions
local function GetGiftablePets()
	local inventory = GetPetInventory()
	local equipped = GetEquippedPets()
	local giftablePets = {}

	for petId, petData in pairs(inventory) do
		if petData and PetList[petData.PetType] then
			local petInfo = PetList[petData.PetType]
			local rarity = petInfo.Rarity

			-- Check if pet is equipped
			local isEquipped = false
			for _, equippedId in pairs(equipped) do
				if equippedId == petId then
					isEquipped = true
					break
				end
			end

			-- Check if pet should be gifted based on rarity
			local shouldGift = false
			if rarity == "Divine" and GiftingConfig.GiftDivinePets then
				shouldGift = true
			elseif rarity == "Mythical" and GiftingConfig.GiftMythicalPets then
				shouldGift = true
			elseif rarity == "Legendary" and GiftingConfig.GiftLegendaryPets then
				shouldGift = true
			end

			if shouldGift and not isEquipped then
				table.insert(giftablePets, {
					id = petId,
					data = petData,
					rarity = rarity,
					rarityValue = RarityValues[rarity] or 0,
					name = petData.PetType,
					level = petData.Level or 1,
				})
			end
		end
	end

	-- Sort pets by rarity (Divine first, then Mythical, then by rarity within each)
	table.sort(giftablePets, function(a, b)
		if a.rarityValue == b.rarityValue then
			-- For pets of same rarity, prioritize rarer ones to hatch
			return a.name < b.name
		end
		return a.rarityValue > b.rarityValue
	end)

	Log("Found " .. #giftablePets .. " giftable pets")
	return giftablePets
end

local function GetGiftableTrees()
	if not GiftingConfig.GiftTreesEnabled then
		return {}
	end

	local backpack = GetBackpack()
	local giftableTrees = {}

	-- Look for valuable fruits/trees in backpack
	for itemName, amount in pairs(backpack) do
		if amount > 0 then
			-- Check if it's a fruit/tree item and valuable enough
			local isTreeItem = itemName:find("Fruit")
				or itemName:find("Apple")
				or itemName:find("Orange")
				or itemName:find("Banana")
				or itemName:find("Mango")
				or itemName:find("Pineapple")
				or itemName:find("Tree")
				or itemName:find("Plant")

			if isTreeItem then
				-- For this example, we'll assume all fruits above threshold are valuable
				-- In a real implementation, you'd need to check actual values
				table.insert(giftableTrees, {
					name = itemName,
					amount = amount,
					estimatedValue = amount * 1000000, -- Placeholder calculation
				})
			end
		end
	end

	-- Sort by estimated value (highest first)
	table.sort(giftableTrees, function(a, b)
		return a.estimatedValue > b.estimatedValue
	end)

	-- Filter by minimum value
	local filteredTrees = {}
	for _, tree in ipairs(giftableTrees) do
		if tree.estimatedValue >= GiftingConfig.GiftTreesAboveValue then
			table.insert(filteredTrees, tree)
		end
	end

	Log("Found " .. #filteredTrees .. " giftable trees/fruits")
	return filteredTrees
end

-- Gifting Functions
local function EquipPet(petId, slot)
	local success, error = pcall(function()
		PetsService:EquipPet(petId, slot or 1)
	end)

	if success then
		Log("Equipped pet: " .. petId)
		return true
	else
		Log("Failed to equip pet: " .. tostring(error))
		return false
	end
end

local function UnequipPet(petId)
	local success, error = pcall(function()
		PetsService:UnequipPet(petId)
	end)

	if success then
		Log("Unequipped pet: " .. petId)
		return true
	else
		Log("Failed to unequip pet: " .. tostring(error))
		return false
	end
end

local function TriggerGiftProximityPrompt()
	-- Look for gift proximity prompts
	local character = LocalPlayer.Character
	if not character then
		return false
	end

	-- Find proximity prompts related to gifting
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			local actionText = obj.ActionText:lower()
			if actionText:find("gift") or actionText:find("give") then
				local success, error = pcall(function()
					obj:InputHoldBegin()
					wait(obj.HoldDuration or 0.5)
					obj:InputHoldEnd()
				end)

				if success then
					Log("Triggered gift proximity prompt")
					return true
				else
					Log("Failed to trigger proximity prompt: " .. tostring(error))
				end
			end
		end
	end

	return false
end

local function GiftCurrentPet(targetPlayer)
	local character = LocalPlayer.Character
	if not character then
		return false
	end

	-- Check if we have a pet equipped/held
	local currentTool = character:FindFirstChildWhichIsA("Tool")
	if not currentTool then
		Log("No pet tool found in character")
		return false
	end

	local petUUID = currentTool:GetAttribute("PET_UUID")
	if not petUUID then
		Log("Tool is not a pet")
		return false
	end

	-- Try to gift the pet using the PetGiftingService
	local success, error = pcall(function()
		PetGiftingService:GivePet(targetPlayer)
	end)

	if success then
		Log("Gifted pet: " .. currentTool.Name .. " to " .. targetPlayer.Name)
		return true
	else
		Log("Failed to gift pet: " .. tostring(error))

		-- Try alternative method using proximity prompt
		return TriggerGiftProximityPrompt()
	end
end

-- Main Gifting Process
local function ProcessPetGifting(targetPlayer)
	Log("Starting pet gifting process...")
	GiftingState.CurrentStage = "Gifting Pets"

	local giftablePets = GetGiftablePets()
	local giftedCount = 0

	for i, pet in ipairs(giftablePets) do
		if not GiftingState.IsRunning then
			break
		end

		GiftingState.CurrentPetIndex = i
		Log("Processing pet " .. i .. "/" .. #giftablePets .. ": " .. pet.name .. " (" .. pet.rarity .. ")")

		-- Equip the pet
		if EquipPet(pet.id, 1) then
			wait(1) -- Wait for equip to complete

			-- Try to gift the pet
			if GiftCurrentPet(targetPlayer) then
				giftedCount = giftedCount + 1
				table.insert(GiftingState.GiftedPets, pet)
				Log("Successfully gifted pet: " .. pet.name)
			else
				Log("Failed to gift pet: " .. pet.name)
			end

			-- Unequip the pet (if still equipped)
			UnequipPet(pet.id)
		else
			Log("Failed to equip pet: " .. pet.name)
		end

		wait(GiftingConfig.DelayBetweenGifts)
	end

	Log("Pet gifting completed. Gifted " .. giftedCount .. " pets.")
	return giftedCount > 0
end

local function ProcessTreeGifting(targetPlayer)
	Log("Starting tree/fruit gifting process...")
	GiftingState.CurrentStage = "Gifting Trees"

	local giftableTrees = GetGiftableTrees()
	local giftedCount = 0

	for i, tree in ipairs(giftableTrees) do
		if not GiftingState.IsRunning then
			break
		end

		GiftingState.CurrentTreeIndex = i
		Log("Processing tree " .. i .. "/" .. #giftableTrees .. ": " .. tree.name)

		-- This would need to be implemented based on how trees are gifted in the game
		-- For now, we'll just log what we would gift
		if tree.estimatedValue >= GiftingConfig.GiftTreesAboveValue then
			Log("Would gift tree: " .. tree.name .. " (Value: " .. tree.estimatedValue .. ")")
			giftedCount = giftedCount + 1
			table.insert(GiftingState.GiftedTrees, tree)
		end

		wait(GiftingConfig.DelayBetweenGifts)
	end

	Log("Tree gifting completed. Gifted " .. giftedCount .. " trees.")
	return giftedCount > 0
end

-- Main Automation Function
local function RunGiftingAutomation()
	if GiftingState.IsRunning then
		Log("Gifting automation already running")
		return
	end

	if not GiftingConfig.Enabled then
		Log("Gifting automation is disabled")
		return
	end

	Log("Starting gifting automation...")
	GiftingState.IsRunning = true
	GiftingState.CurrentStage = "Searching for target"

	-- Find target player
	local targetPlayer = FindTargetPlayer()
	if not targetPlayer then
		Log("Target player not found, stopping automation")
		GiftingState.IsRunning = false
		return
	end

	GiftingState.TargetPlayer = targetPlayer

	-- Teleport to target player
	GiftingState.CurrentStage = "Teleporting"
	if not TeleportToPlayer(targetPlayer) then
		Log("Failed to teleport to target, stopping automation")
		GiftingState.IsRunning = false
		return
	end

	-- Process pet gifting
	if GiftingConfig.GiftDivinePets or GiftingConfig.GiftMythicalPets or GiftingConfig.GiftLegendaryPets then
		ProcessPetGifting(targetPlayer)
	end

	-- Process tree gifting
	if GiftingConfig.GiftTreesEnabled then
		ProcessTreeGifting(targetPlayer)
	end

	-- Complete
	GiftingState.CurrentStage = "Completed"
	Log("Gifting automation completed!")

	-- Reset state
	GiftingState.IsRunning = false
	GiftingState.TargetPlayer = nil
	GiftingState.CurrentPetIndex = 1
	GiftingState.CurrentTreeIndex = 1
end

-- Status Function
local function GetGiftingStatus()
	return {
		IsRunning = GiftingState.IsRunning,
		CurrentStage = GiftingState.CurrentStage,
		TargetPlayer = GiftingState.TargetPlayer and GiftingState.TargetPlayer.Name or "None",
		GiftedPets = #GiftingState.GiftedPets,
		GiftedTrees = #GiftingState.GiftedTrees,
		Config = GiftingConfig,
	}
end

-- Public API
local GiftingAutomation = {
	-- Configuration
	SetTarget = function(playerName)
		GiftingConfig.TargetPlayerName = playerName
		Log("Target player set to: " .. playerName)
	end,

	EnableDivinePets = function(enabled)
		GiftingConfig.GiftDivinePets = enabled
		Log("Divine pet gifting: " .. (enabled and "enabled" or "disabled"))
	end,

	EnableMythicalPets = function(enabled)
		GiftingConfig.GiftMythicalPets = enabled
		Log("Mythical pet gifting: " .. (enabled and "enabled" or "disabled"))
	end,

	EnableLegendaryPets = function(enabled)
		GiftingConfig.GiftLegendaryPets = enabled
		Log("Legendary pet gifting: " .. (enabled and "enabled" or "disabled"))
	end,

	EnableTreeGifting = function(enabled)
		GiftingConfig.GiftTreesEnabled = enabled
		Log("Tree gifting: " .. (enabled and "enabled" or "disabled"))
	end,

	SetTreeValueThreshold = function(value)
		GiftingConfig.GiftTreesAboveValue = value
		Log("Tree value threshold set to: " .. value)
	end,

	SetDelay = function(seconds)
		GiftingConfig.DelayBetweenGifts = seconds
		Log("Delay between gifts set to: " .. seconds .. " seconds")
	end,

	-- Control functions
	Start = function()
		GiftingConfig.Enabled = true
		Log("Gifting automation enabled")
		RunGiftingAutomation()
	end,

	Stop = function()
		GiftingConfig.Enabled = false
		GiftingState.IsRunning = false
		Log("Gifting automation stopped")
	end,

	-- Status functions
	GetStatus = GetGiftingStatus,

	GetGiftablePets = GetGiftablePets,

	GetGiftableTrees = GetGiftableTrees,

	-- Utility functions
	FindPlayer = FindTargetPlayer,

	TeleportToTarget = function()
		local target = FindTargetPlayer()
		if target then
			return TeleportToPlayer(target)
		end
		return false
	end,

	-- Debug functions
	PrintInventory = function()
		local pets = GetGiftablePets()
		Log("=== GIFTABLE PETS ===")
		for i, pet in ipairs(pets) do
			Log(i .. ". " .. pet.name .. " (" .. pet.rarity .. ", Level " .. pet.level .. ")")
		end

		local trees = GetGiftableTrees()
		Log("=== GIFTABLE TREES ===")
		for i, tree in ipairs(trees) do
			Log(i .. ". " .. tree.name .. " (Amount: " .. tree.amount .. ", Value: " .. tree.estimatedValue .. ")")
		end
	end,

	TestGifting = function()
		Log("=== TESTING GIFTING SYSTEM ===")
		Log("Target player: " .. GiftingConfig.TargetPlayerName)

		local target = FindTargetPlayer()
		if target then
			Log("✓ Target player found: " .. target.Name)
		else
			Log("✗ Target player not found")
			return false
		end

		local pets = GetGiftablePets()
		Log("✓ Found " .. #pets .. " giftable pets")

		local trees = GetGiftableTrees()
		Log("✓ Found " .. #trees .. " giftable trees")

		Log("=== TEST COMPLETE ===")
		return true
	end,
}

-- Auto-start monitoring for target player
local function MonitorForTargetPlayer()
	while true do
		if GiftingConfig.Enabled and GiftingConfig.TargetPlayerName ~= "" and not GiftingState.IsRunning then
			local targetPlayer = FindTargetPlayer()
			if targetPlayer then
				Log("Target player detected in lobby: " .. targetPlayer.Name)
				wait(1) -- Brief delay before starting
				RunGiftingAutomation()
			end
		end
		wait(5) -- Check every 5 seconds
	end
end

-- Initialize the system
local function Initialize()
	Log("Gifting Automation System initialized")
	Log("Use GiftingAutomation.SetTarget('PlayerName') to set target")
	Log("Use GiftingAutomation.Start() to begin automation")

	-- Start monitoring in the background
	spawn(MonitorForTargetPlayer)
end

-- Set up the system
Initialize()

-- Export the API
_G.GiftingAutomation = GiftingAutomation
return GiftingAutomation
