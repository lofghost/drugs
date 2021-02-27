Citizen.CreateThread(function()
	Citizen.Wait(100)

	while true do
		local sleepThread = 500

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		local menuPos = Config.Sandy["Menu"]

		local dstCheck = GetDistanceBetweenCoords(pedCoords, menuPos["x"], menuPos["y"], menuPos["z"], true)

		if dstCheck <= 5.0 then
			sleepThread = 5

			local text = "Johnny"

			if dstCheck <= 1.2 then
				text = "[~g~E~s~] Johnny"

				if IsControlJustPressed(0, 38) then
					OpenBuySeedsMenu()
				end
			end

			ESX.DrawMarker(text, 23, menuPos["x"], menuPos["y"], menuPos["z"], 0, 255, 0, 1.0, 1.0)
		end


		Citizen.Wait(sleepThread)
	end
end)

OpenBuySeedsMenu = function()
	ESX.YesOrNo("Vill du köpa 5 frön för " .. Config.SeedsPrice * 5 .. " SEK?", function(answer)
		if answer then
			ESX.TriggerServerCallback("rdrp_marijuana:buySeeds", function(bought)
				if bought then
					ESX.ShowNotification("Du ~g~köpte~s~ 5st ~o~frön~s~ för ~g~" .. Config.SeedsPrice * 5 .. " SEK")
				else
					ESX.ShowNotification("Du har ej ~r~råd~s~")
				end
			end)
		end
	end)
end

RefreshSandyPed = function()
	local Location = Config.Sandy["Ped"]

	local pedId, pedDist = ESX.Game.GetClosestPed(Location)

	if DoesEntityExist(pedId) and pedDist <= 1.2 then
		DeletePed(pedId)
	end

	ESX.LoadModel(0xE497BBEF)

	local pedId = CreatePed(5, 0xE497BBEF, Location["x"], Location["y"], Location["z"] - 0.985, Location["h"], false)

	SetPedCombatAttributes(pedId, 46, true)                     
	SetPedFleeAttributes(pedId, 0, 0)                      
	SetBlockingOfNonTemporaryEvents(pedId, true)
	
	SetEntityAsMissionEntity(pedId, true, true)

	FreezeEntityPosition(pedId, true)
end