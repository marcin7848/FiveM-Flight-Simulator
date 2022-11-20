local ratingFlightsOn = false
local airportStatus = {}
local requests = {}
local ratingAfterDeparture = {}
local ratingArrival = {}

os.execute("mkdir RatingFlightPoints")

RegisterNetEvent("sendRatingFlightsOn")
AddEventHandler("sendRatingFlightsOn", function(playerId)
   TriggerClientEvent("getRatingFlightPointsOn", playerId, ratingFlightsOn)
end)

RegisterNetEvent("setAirportStatusRatingFlights")
AddEventHandler("setAirportStatusRatingFlights", function(airportStatusFromServer)
   airportStatus = airportStatusFromServer
end)

RegisterNetEvent("getRatingFlightsInfo")
AddEventHandler("getRatingFlightsInfo", function(playerID)
   TriggerClientEvent("setRatingFlightsInfo", playerID, requests, ratingAfterDeparture, ratingArrival)
end)

RegisterNetEvent("setFlightParametersFromAtc")
AddEventHandler("setFlightParametersFromAtc", function(playerId, atcAltitude, atcSquawk, atcFreq, sourceAirportIndex, destinationAirportIndex)
   TriggerClientEvent("setPlayerFlightParametersFromAtc", playerId, atcAltitude, atcSquawk, atcFreq)
	removePlayerFromRequests(playerId)
	removePlayerFromRatingAfterDeparture(playerId)
	removePlayerFromRatingArrivals(playerId)
	table.insert(ratingAfterDeparture[sourceAirportIndex], playerId)
	table.insert(ratingArrival[destinationAirportIndex], playerId)
end)

RegisterNetEvent("ratePlayerAfterDeparture")
AddEventHandler("ratePlayerAfterDeparture", function(playerId, ratePoint)
   TriggerClientEvent("ratePlayerAfterDepartureFromAtc", playerId, ratePoint)
	removePlayerFromRatingAfterDeparture(playerId)
end)

RegisterNetEvent("ratePlayerArrival")
AddEventHandler("ratePlayerArrival", function(playerId, ratePoint)
   TriggerClientEvent("ratePlayerArrivalFromAtc", playerId, ratePoint)
	removePlayerFromRatingArrivals(playerId)
end)

RegisterNetEvent("updateFilePoint")
AddEventHandler("updateFilePoint", function(playerId, points)
   local identifier = GetPlayerIdentifier(playerId, 0)
	local name, value = string.match(identifier, "^(.-):(.-)$")
	local filename = "RatingFlightPoints/"..name.."_"..value
	local file = io.open(filename, "w")
	io.output(file)
	io.write(points)
	io.close(file)
end)

RegisterNetEvent("getFilePoints")
AddEventHandler("getFilePoints", function(playerId)
   local identifier = GetPlayerIdentifier(playerId, 0)
	local name, value = string.match(identifier, "^(.-):(.-)$")
	local filename = "RatingFlightPoints/"..name.."_"..value
	local f=io.open(filename,"r")
	
	if f == nil then
		local file = io.open(filename, "w")
		io.output(file)
		io.write("0")
		io.close(file)
		TriggerClientEvent("updatePoints", playerId, 0)
	else
		io.input(f)
		local points = tonumber(io.read("*a"))
		io.close(f)
		TriggerClientEvent("updatePoints", playerId, points)
	end
	
end)

Citizen.CreateThread(function()
   while #airportStatus == 0 do
      Citizen.Wait(500)
		TriggerEvent("getAirportStatusRatingFlights")
   end
	
	for i=0, #airportStatus do
		table.insert(requests, {{}, {}})
		table.insert(ratingAfterDeparture, {})
		table.insert(ratingArrival, {})
	end
end)

RegisterNetEvent("addNewRequest")
--requestIndex: 1 - IFR, 2 - VFR
AddEventHandler("addNewRequest", function(playerId, airportIndex, requestIndex)
	removePlayerFromRequests(playerId)
	removePlayerFromRatingAfterDeparture(playerId)
	removePlayerFromRatingArrivals(playerId)
   table.insert(requests[airportIndex][requestIndex], playerId)
	TriggerClientEvent("notifyRatingFlights", playerId, "Request has sent! ~y~Now send request to ATC via Voice/Text chat!")
end)

function removePlayerFromRequests(playerID)
	for i=1, #requests do
		for k=1, #requests[i] do
			for j=1, #requests[i][k] do
				if requests[i][k][j] == playerID then
					table.remove(requests[i][k], j)
				end
			end
		end
	end
end

function removePlayerFromRatingAfterDeparture(playerID)
	for i=1, #ratingAfterDeparture do
		for k=1, #ratingAfterDeparture[i] do
			if ratingAfterDeparture[i][k] == playerID then
				table.remove(ratingAfterDeparture[i], k)
			end
		end
	end
end

function removePlayerFromRatingArrivals(playerID)
	for i=1, #ratingArrival do
		for k=1, #ratingArrival[i] do
			if ratingArrival[i][k] == playerID then
				table.remove(ratingArrival[i], k)
			end
		end
	end
end

function fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end