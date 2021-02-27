OpenPlantMenu = function(plantId)
    local elements = {}

    local cachedPlantData = cachedData[tonumber(plantId)]

    if cachedPlantData ~= nil then
    	if cachedPlantData["waterLeft"] > 0 then
    		if cachedPlantData["timeLeft"] <= 0 then
    			table.insert(elements, { ["label"] = "Vattna (" .. cachedPlantData["waterLeft"] .. " KVAR)", ["value"] = "water_plant" })
    		end
    	else
    		if cachedPlantData["harvestable"] then
    			table.insert(elements, { ["label"] = "Skörda", ["value"] = "harvest_plant" })
    		end
    	end

    	table.insert(elements, { ["label"] = "Förstör", ["value"] = "destroy_plant" })
    else
		table.insert(elements, { ["label"] = "Plantera", ["value"] = "plant_plant" })
    end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "drug_menu_" .. tostring(plantId),
		{
			title    = "Marijuanaplanta",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		local value = data.current.value

		menu.close()

		if value == "plant_plant" then
			ESX.TriggerServerCallback("rdrp_marijuana:plantMarijuana", function(done)
				if done then
					ESX.ShowNotification("Du ~g~planterade~s~ en marijuanaplanta!")
				else
					ESX.ShowNotification("Du har ~r~inget~s~ frö eller spade så att du kan plantera.")
				end
			end, plantId)
		elseif value == "water_plant" then
			ESX.TriggerServerCallback("rdrp_marijuana:waterMarijuana", function(done)
				if done then
					ESX.ShowNotification("Du ~b~vattnade~s~ marijuanaplantan!")
				else
					ESX.ShowNotification("Du har ~r~inget~s~ vatten att vattna med.")
				end
			end, plantId)
		elseif value == "harvest_plant" then
			ESX.TriggerServerCallback("rdrp_marijuana:harvestMarijuana", function(done)
				if done then
					ESX.ShowNotification("Du ~o~skördade~s~ marijuanaplantan!")

                    math.randomseed(GetGameTimer())

			        local Skill = math.random(6, 10) / 10

					exports["rdrp_skills"]:AddSkillLevel("Drugs", Skill)
				else
					ESX.ShowNotification("Du har ~r~ingen~s~ spade att skörda med.")
				end
			end, plantId)
		elseif value == "destroy_plant" then
			ESX.YesOrNo("Vill du verkligen förstöra plantan?", function(answer)
				if answer then
					ESX.TriggerServerCallback("rdrp_marijuana:destroyMarijuana", function(done)
						if done then
							ESX.ShowNotification("Du ~r~förstörde~s~ marijuanaplantan!")
						else
							ESX.ShowNotification("Du kan inte förstöra denna.")
						end
					end, plantId)
				end
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

RefreshPhysicalPlants = function()
	-- for plantId, plantValues in pairs(cachedData) do
	-- 	local plantCoords = Config.PlantSpots[tonumber(plantId)]

	-- 	local plantModels = {
	-- 		"prop_peyote_highland_02",
	-- 		"prop_weed_02",
	-- 		"prop_weed_01"
	-- 	}

	-- 	for i = 1, #plantModels do
	-- 		local closestObj = GetClosestObjectOfType(plantCoords["x"], plantCoords["y"], plantCoords["z"], 3.0, GetHashKey(plantModels[i]), false)

	-- 		if DoesEntityExist(closestObj) then
	-- 			SetEntityAsMissionEntity(closestObj, true, false)

	-- 			DeleteEntity(closestObj)

	-- 			Citizen.Wait(100)
	-- 		end
	-- 	end

	-- 	ESX.LoadModel(plantModels[plantValues["level"]])

	-- 	plantValues["object"] = CreateObject(GetHashKey(plantModels[plantValues["level"]]), plantCoords["x"], plantCoords["y"], plantCoords["z"] - 0.985, false)

	-- 	PlaceObjectOnGroundProperly(plantValues["object"])

	-- 	SetEntityAsMissionEntity(plantValues["object"], true, true)

	-- 	FreezeEntityPosition(plantValues["object"], true)
	-- end
end