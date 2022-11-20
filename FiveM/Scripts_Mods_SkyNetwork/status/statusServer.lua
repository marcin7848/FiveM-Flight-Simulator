local airportStatus = {
	{"LSIA", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"SSIA", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"SSRA", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"ZAC", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"CARRIER", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	}
}

copyAirportStatus = {
	{"LSIA", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"SSIA", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"SSRA", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"ZAC", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	},
	{"CARRIER", 
		{"ATC", {}},
		{"GC", {}},
		{"APU", {}}
	}
}

local status = {}
local emergencies = false
RegisterNetEvent("getStatus")
AddEventHandler("getStatus", function(playerId)
	status = buildStatusString()
   TriggerClientEvent("setStatus", playerId, status)
end)

RegisterNetEvent("setEmergencies")
AddEventHandler("setEmergencies", function()
	emergencies = not emergencies
   TriggerClientEvent("setEmergencies", -1, emergencies)
end)

RegisterNetEvent("getAirportStatus")
AddEventHandler("getAirportStatus", function(playerID)
   TriggerClientEvent("setAirportStatus", playerID, airportStatus)
end)

RegisterNetEvent("resetStatus")
AddEventHandler("resetStatus", function()
	airportStatus = copyAirportStatus
   TriggerEvent("getStatus", -1)
end)

RegisterNetEvent("updateStatus")
AddEventHandler("updateStatus", function(playerID, airportIndex, jobIndex)
	updateStatus(playerID, airportIndex, jobIndex)
   TriggerEvent("getStatus", -1)
end)

RegisterNetEvent("leaveJob")
AddEventHandler("leaveJob", function(playerID)
	removePlayerFromStatus(playerID)
   TriggerEvent("getStatus", -1)
end)

RegisterNetEvent("showStatusPlayers")
AddEventHandler("showStatusPlayers", function(playerID)
	local statusPlayers = buildChatStatusPlayers()
	for i=1, #statusPlayers do
		TriggerClientEvent("chatMessage", playerID, statusPlayers[i])
	end
end)

AddEventHandler('playerDropped', function()
	local removed = removePlayerFromStatus(source)
	if removed then
		TriggerEvent("getStatus", -1)
	end
end)

RegisterNetEvent("getAirportStatusFuel")
AddEventHandler("getAirportStatusFuel", function(playerID)
   TriggerClientEvent("setAirportStatusFuel", playerID, airportStatus)
end)

RegisterNetEvent("getAirportStatusRatingFlights")
AddEventHandler("getAirportStatusRatingFlights", function()
   TriggerEvent("setAirportStatusRatingFlights", airportStatus)
end)

function buildStatusString()
	local atcString = ""
	local gcString = ""
	local apuString = ""
	
	for i=1, #airportStatus do
		if #airportStatus[i][2][2] > 0 then
			if atcString ~= "" then
				atcString = atcString .. " & "
			end
			atcString = atcString .. airportStatus[i][1]
		end
		
		if #airportStatus[i][3][2] > 0 then
			if gcString ~= "" then
				gcString = gcString .. " & "
			end
			gcString = gcString .. airportStatus[i][1]
		end
		
		if #airportStatus[i][4][2] > 0 then
			if apuString ~= "" then
				apuString = apuString .. " & "
			end
			apuString = apuString .. airportStatus[i][1]
		end
	end
	
	local statusArray = {}
	local statusString = ""
	if atcString ~= "" then
		statusString = statusString .. atcString .. " ATC"
	end
	
	table.insert(statusArray, statusString)
	statusString = ""
	
	if gcString ~= "" then
		if statusArray[1] ~= "" then
			statusString = statusString .. " || "
		end
		statusString = statusString .. gcString .. " GC"
	end
	
	table.insert(statusArray, statusString)
	statusString = ""
	
	if apuString ~= "" then
		if statusArray[1] ~= "" or statusArray[2] ~= "" then
			statusString = statusString .. " || "
		end
		statusString = statusString .. apuString .. " APU"
	end
	
	if statusString == "" and statusArray[1] == "" and statusArray[2] == "" then
		statusString = "UNICOM"
	else
		statusString = statusString .. " Online || Rest UNICOM"
	end
	
	table.insert(statusArray, statusString)
	return statusArray
end

function buildChatStatusPlayers()
	local statusPlayers = {}
	
	for i=1, #airportStatus do
		local airportName = airportStatus[i][1]
		for k=2, #airportStatus[i] do
			local jobName = airportStatus[i][k][1]
			local currentWorkers = {}
			for j=1, #airportStatus[i][k][2] do
				table.insert(currentWorkers, GetPlayerName(airportStatus[i][k][2][j]))
			end
			if #currentWorkers == 0 then
				table.insert(currentWorkers, "UNICOM")
			end
			
			local workersString = ""
			for l=1, #currentWorkers do
				workersString = workersString .. currentWorkers[l]
				if l < #currentWorkers then
					workersString = workersString .. ", "
				end
			end
			
			
			table.insert(statusPlayers, airportName .. " " .. jobName .. ": " .. workersString)
		end
	end
	
	return statusPlayers
end


function updateStatus(playerID, airportIndex, jobIndex)
	removePlayerFromStatus(playerID)
	table.insert(airportStatus[airportIndex][jobIndex][2], playerID)
	
end

function removePlayerFromStatus(playerID)
	local removed = false
	for i=1, #airportStatus do
		for k=2, #airportStatus[i] do
			for j=1, #airportStatus[i][k][2] do
				if airportStatus[i][k][2][j] == playerID then
					table.remove(airportStatus[i][k][2], j)
					removed = true
				end
			end
		end
	end
	
	return removed
end
