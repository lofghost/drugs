ESX = nil

cachedData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(5)

        ESX = exports["rdrp_base"]:getSharedObject()
    end

    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()

		ESX.TriggerServerCallback("rdrp_marijuana:fetchPlants", function(plants)
			if plants ~= nil then
				cachedData = plants

				RefreshPhysicalPlants()
			end
		end)

		RefreshSandyPed()
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	ESX.PlayerData = response

	ESX.TriggerServerCallback("rdrp_marijuana:fetchPlants", function(plants)
		if plants ~= nil then
			cachedData = plants

			RefreshPhysicalPlants()
		end
	end)

	RefreshSandyPed()
end)

RegisterNetEvent("rdrp_marijuana:deletePlant")
AddEventHandler("rdrp_marijuana:deletePlant", function(plantId)
	local plantCoords = Config.PlantSpots[tonumber(plantId)]

	local plantModels = {
		"prop_peyote_highland_02",
		"prop_weed_02",
		"prop_weed_01"
	}

	for i = 1, #plantModels do
		local closestObj = GetClosestObjectOfType(plantCoords["x"], plantCoords["y"], plantCoords["z"], 3.0, GetHashKey(plantModels[i]), false)

		if DoesEntityExist(closestObj) then
			SetEntityAsMissionEntity(closestObj, true, false)

			DeleteEntity(closestObj)

			Citizen.Wait(50)
		end
	end
end)

RegisterNetEvent("rdrp_marijuana:updatePlants")
AddEventHandler("rdrp_marijuana:updatePlants", function(newTable)
	cachedData = newTable

	if cachedData ~= nil then
		for plantId, plantValues in pairs(cachedData) do
			if ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), "drug_menu_" .. tostring(plantId)) then
				ESX.UI.Menu.CloseAll()

				OpenPlantMenu(plantId)
			end
		end

		RefreshPhysicalPlants()
	end
end)

RegisterNetEvent("rdrp_marijuana:getHigh")
AddEventHandler("rdrp_marijuana:getHigh", function()
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SMOKING_POT", 0, true)

	exports["rdrp_progressbar"]:StartDelayedFunction({
		["text"] = "Röker...",
		["delay"] = 6000
	})

	Citizen.Wait(6000)

	DoScreenFadeOut(1000)

	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end

	DoScreenFadeIn(1000)

    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(PlayerPedId(), true)
    SetPedIsDrunk(PlayerPedId(), true)

    SetPedMaxHealth(PlayerPedId(), 300)

    SetEntityHealth(PlayerPedId(), 300)

    Citizen.Wait(60000 * 20)

	DoScreenFadeOut(1000)

	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end

	DoScreenFadeIn(1000)

    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(PlayerPedId(), 0)
    SetPedIsDrunk(PlayerPedId(), false)
    SetPedMotionBlur(PlayerPedId(), false)
    SetPedMaxHealth(PlayerPedId(), 200)
    SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent("rdrp_marijuana:getCocaine")
AddEventHandler("rdrp_marijuana:getCocaine", function()
    ESX.LoadAnimDict("missfbi3_party")

    TaskPlayAnim(PlayerPedId(), 'missfbi3_party', "snort_coke_a_male3", 8.0, 8.0, -1, 50, 0, false, false, false)

	exports["rdrp_progressbar"]:StartDelayedFunction({
		["text"] = "Snortar...",
		["delay"] = 18800
	})

    Citizen.Wait(8000)

    TaskPlayAnim(PlayerPedId(), 'missfbi3_party', "snort_coke_b_male3", 8.0, 8.0, -1, 50, 0, false, false, false)

    Citizen.Wait(11000)

	ClearPedTasksImmediately(PlayerPedId())
	
	RemoveAnimDict("missfbi3_party")

	DoScreenFadeOut(1000)

	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end

	DoScreenFadeIn(1000)

    SetTimecycleModifier("spectator9")
    SetPedMotionBlur(PlayerPedId(), true)
    SetPedIsDrunk(PlayerPedId(), true)

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)

    Citizen.Wait(60000 * 20)

	DoScreenFadeOut(1000)

	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end

	DoScreenFadeIn(1000)

    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(PlayerPedId(), 0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPedIsDrunk(PlayerPedId(), false)
    SetPedMotionBlur(PlayerPedId(), false)
end)

Citizen.CreateThread(function()
	Citizen.Wait(100)

	while true do
		local sleepThread = 500

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		for i = 1, #Config.PlantSpots do
			local plantSpot = Config.PlantSpots[i]

			local dstCheck = GetDistanceBetweenCoords(pedCoords, plantSpot["x"], plantSpot["y"], plantSpot["z"], true)

			if dstCheck <= 3.0 then
				sleepThread = 5

				text = "Marijuanaplanta"

				if dstCheck <= 0.8 then
					text = "[~g~E~s~] Marijuanaplanta"

					if IsControlJustPressed(0, 38) then
						OpenPlantMenu(i)
					end
				end

				ESX.DrawMarker(text, 23, plantSpot["x"], plantSpot["y"], plantSpot["z"] - 0.985, 0, 255, 0, 1.0, 1.0)
			end
		end

		Citizen.Wait(sleepThread)
	end
end)