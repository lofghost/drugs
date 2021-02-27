local ESX = nil

local serverCachedData = {}

TriggerEvent("esx:getSharedObject", function(response)
    ESX = response
end)

ESX.RegisterUsableItem("rizla", function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local marijuanaLeafQ = xPlayer.getInventoryItem("marijuanaleaf")["count"]


		if marijuanaLeafQ >= Config.LeafNeededForJoint then
			xPlayer.removeInventoryItem("rizla", 1)
			xPlayer.removeInventoryItem("marijuanaleaf", Config.LeafNeededForJoint)
			xPlayer.addInventoryItem("joint", 1)

			TriggerClientEvent("esx:showNotification", source, "Du ~o~rullade~s~ en ~b~joint~s~")
		end
	end
end)

ESX.RegisterUsableItem("joint", function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		xPlayer.removeInventoryItem("joint", 1)

		TriggerClientEvent("rdrp_marijuana:getHigh", source)
	end
end)

ESX.RegisterUsableItem("cocaine", function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		xPlayer.removeInventoryItem("cocaine", 1)

		TriggerClientEvent("rdrp_marijuana:getCocaine", source)
	end
end)

ESX.RegisterServerCallback("rdrp_marijuana:fetchPlants", function(source, cb)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	local cachedData = serverCachedData

	if #cachedData > 0 then
		UpdateClientPlants()

		return
	end

	local fetchSQL = [[
		SELECT
			plantId, plantLevel, plantWaterLeft, plantTime
		FROM
			characters_plants

	]]

	serverCachedData = {}

	MySQL.Async.fetchAll(fetchSQL, {}, function(response)
		if response[1] ~= nil then
			for i = 1, #response do
				local plant = response[i]

				serverCachedData[plant["plantId"]] = {}
				serverCachedData[plant["plantId"]]["waterLeft"] = plant["plantWaterLeft"]
				serverCachedData[plant["plantId"]]["level"] = plant["plantLevel"]
				serverCachedData[plant["plantId"]]["timeLeft"] = plant["plantTime"]

				if plant["plantLevel"] == 3 then
					serverCachedData[plant["plantId"]]["harvestable"] = true
				end
			end

			cb(serverCachedData)
		end
	end)
end)

ESX.RegisterServerCallback("rdrp_marijuana:plantMarijuana", function(source, cb, plantId)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	local cachedData = serverCachedData[plantId]

	if cachedData ~= nil then
		cb(false)

		UpdateClientPlants()

		return
	end

	local insertSQL = [[
		INSERT
			INTO
		characters_plants
			(plantId)
		VALUES
			(@id)
	]]

	if xPlayer.getInventoryItem("shovel")["count"] > 0 and xPlayer.getInventoryItem("marijuanaseed")["count"] > 0 then
		MySQL.Async.execute(insertSQL, { ["@id"] = plantId })

		xPlayer.removeInventoryItem("marijuanaseed", 1)

		serverCachedData[plantId] = {}
		serverCachedData[plantId]["waterLeft"] = Config.WaterNeeded
		serverCachedData[plantId]["level"] = 1
		serverCachedData[plantId]["timeLeft"] = Config.TimeNeeded

		UpdateClientPlants()

		cb(true)
 	else
		cb(false)
	end
end)

ESX.RegisterServerCallback("rdrp_marijuana:waterMarijuana", function(source, cb, plantId)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	local cachedData = serverCachedData[plantId]

	if cachedData == nil then
		cb(false)

		UpdateClientPlants()

		return
	end

	local updateSQL = [[
		UPDATE
			characters_plants
		SET
			plantWaterLeft = @newWater
		WHERE
			plantId = @id
	]]

	if xPlayer.getInventoryItem("water")["count"] >= 2 then
		MySQL.Async.execute(updateSQL, { ["@newWater"] = serverCachedData[plantId]["waterLeft"] - 1, ["@id"] = plantId })

		xPlayer.removeInventoryItem("water", 2)

		serverCachedData[plantId]["waterLeft"] = serverCachedData[plantId]["waterLeft"] - 1
		serverCachedData[plantId]["timeLeft"] = Config.TimeNeeded

		UpdateClientPlants()

		cb(true)
 	else
		cb(false)
	end
end)

ESX.RegisterServerCallback("rdrp_marijuana:harvestMarijuana", function(source, cb, plantId)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	local cachedData = serverCachedData[plantId]

	if cachedData == nil then
		cb(false)

		UpdateClientPlants()

		return
	end

	local deleteSQL = [[
		DELETE
			FROM
		characters_plants
			WHERE
		plantId = @id
	]]

	MySQL.Async.execute(deleteSQL, { ["@id"] = plantId })

	DeletePlant(plantId)

	math.randomseed(os.time())

	local randomQuantity = math.random(5, 7)

	xPlayer.addInventoryItem("marijuanaleaf", randomQuantity)

	serverCachedData[plantId] = nil

	UpdateClientPlants()

	cb(true)
end)

ESX.RegisterServerCallback("rdrp_marijuana:destroyMarijuana", function(source, cb, plantId)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	local cachedData = serverCachedData[plantId]

	if cachedData == nil then
		cb(false)

		UpdateClientPlants()

		return
	end

	local deleteSQL = [[
		DELETE
			FROM
		characters_plants
			WHERE
		plantId = @id
	]]

	MySQL.Async.execute(deleteSQL, { ["@id"] = plantId })

	DeletePlant(plantId)

	serverCachedData[plantId] = nil

	UpdateClientPlants()

	cb(true)
end)

ESX.RegisterServerCallback("rdrp_marijuana:buySeeds", function(source, cb)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer.getMoney() >= Config.SeedsPrice * 5 then
		xPlayer.removeMoney(Config.SeedsPrice * 5)

		xPlayer.addInventoryItem("marijuanaseed", 5)

		cb(true)
	else
		if xPlayer.getAccount("bank")["money"] >= Config.SeedsPrice * 5 then
			xPlayer.removeAccountMoney("bank", Config.SeedsPrice * 5)

			xPlayer.addInventoryItem("marijuanaseed", 5)

			cb(true)
		else
			cb(false)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)

		for plantId, plantValues in pairs(serverCachedData) do
			if plantValues["timeLeft"] > 0 then
				plantValues["timeLeft"] = plantValues["timeLeft"] - 1
			else
				if plantValues["timeLeft"] == 0 and plantValues["waterLeft"] == 0 then
					if plantValues["level"] < 3 then
						plantValues["level"] = plantValues["level"] + 1

						if plantValues["level"] < 3 then
							plantValues["waterLeft"] = Config.WaterNeeded
						else
							plantValues["harvestable"] = true
 						end
					end
				end
			end
		end

		UpdatePlantsDB()

		UpdateClientPlants()
	end
end)

DeletePlant = function(plant)
	TriggerClientEvent("rdrp_marijuana:deletePlant", -1, plant)
end

UpdatePlantsDB = function()
	local updateSQL = [[
		UPDATE
			characters_plants
		SET
			plantWaterLeft = @newWater, plantTime = @time, plantLevel = @level
		WHERE
			plantId = @id
	]]

	for plantId, plantValues in pairs(serverCachedData) do
		MySQL.Async.execute(updateSQL, { ["@time"] = plantValues["timeLeft"], ["@level"] = plantValues["level"], ["@newWater"] = plantValues["waterLeft"], ["@id"] = plantId })
	end
end

UpdateClientPlants = function()
	TriggerClientEvent("rdrp_marijuana:updatePlants", -1, serverCachedData)
end