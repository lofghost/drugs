ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(5)

        ESX = exports["rdrp_base"]:getSharedObject()
    end

    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()

		RefreshPed()
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	ESX.PlayerData = response

	RefreshPed()
end)

Citizen.CreateThread(function()
	Citizen.Wait(500)

	local menuPos = Config.MenuPosition

	while true do
		local sleepThread = 500

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		local dstCheck = GetDistanceBetweenCoords(pedCoords, menuPos["x"], menuPos["y"], menuPos["z"], true)

		if dstCheck <= 4.0 then
			sleepThread = 5

			local text = "Emily"

			if dstCheck <= 1.2 then
				text = "[~g~E~s~] Prata med Emily"

				if IsControlJustPressed(0, 38) then
					OpenEmilyMenu()
				end
			end

			ESX.DrawMarker(text, 27, menuPos["x"], menuPos["y"], menuPos["z"], 0, 255, 0, 1.0, 1.0)
		end

		Citizen.Wait(sleepThread)
	end
end)

OpenEmilyMenu = function()
	local elements = {}

	local Inventory = ESX.GetPlayerData()["inventory"]

	for i = 1, #Inventory do
		local Item = Inventory[i]

		if Item["count"] > 0 then
			if Config.Items[Item["name"]] ~= nil then
				for i = 1, Item["count"] do
					Item["price"] = Config.Items[Item["name"]]
					Item["count"] = 1

					table.insert(elements, { ["label"] = ESX.Items[Item["name"]]["label"] .. " - " .. Config.Items[Item["name"]] .. " SEK", ["value"] = Item })
				end
			end
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "emily_drug_menu",
		{
			title    = "Emily",
			align    = "right",
			elements = elements
		},
	function(data, menu)
		local value = data.current.value

		ESX.TriggerServerCallback("rdrp_pawnshop:sellItem", function(sold)
			if sold then
				ESX.ShowNotification("Du sålde 1 ~b~" .. ESX.Items[value["name"]]["label"] .. "~s~ för ~g~" .. value["price"] .. " SEK")

				menu.close()

				OpenEmilyMenu()

				PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
			else
				PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)

				ESX.ShowNotification("Försök igen, såldes ej.")
			end
		end, value)
	end, function(data, menu)
		menu.close()
	end)
end

RefreshPed = function()
	local Location = Config.Whore

	local pedId, pedDist = ESX.Game.GetClosestPed(Location)

	if DoesEntityExist(pedId) and pedDist <= 1.2 then
		DeletePed(pedId)
	end

	ESX.LoadModel(Config.WhoreHash)

	local pedId = CreatePed(5, Config.WhoreHash, Location["x"], Location["y"], Location["z"] - 0.985, Location["h"], false)

	SetPedCombatAttributes(pedId, 46, true)                     
	SetPedFleeAttributes(pedId, 0, 0)                      
	SetBlockingOfNonTemporaryEvents(pedId, true)
	
	SetEntityAsMissionEntity(pedId, true, true)

	ESX.PlayAnimation(pedId, "amb@world_human_prostitute@cokehead@base", "base", {["flag"] = 1})

	FreezeEntityPosition(pedId, true)
end