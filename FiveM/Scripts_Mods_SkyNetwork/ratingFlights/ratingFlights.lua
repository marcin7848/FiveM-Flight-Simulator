local playerAltitude = 0
local playerSquawk = 0
local playerFreq = 0.0
local points = -1

local atcAltitude = 0
local atcSquawk = 0
local atcFreq = 0.0

local ratePointAfterDeparture = 0
local ratePointArrival = 0

local altitudeReached = false

local state = true
local ratingFlightsOn = nil --do not set it here, set in ratingFlightsServer.lua

RegisterNetEvent("requestIFR")
AddEventHandler("requestIFR", function(airportIndex)
   TriggerServerEvent("addNewRequest", GetPlayerServerId(PlayerId()), airportIndex, 1)
	ratePointAfterDeparture = 0
	ratePointArrival = 0
	altitudeReached = false
end)

RegisterNetEvent("requestVFR")
AddEventHandler("requestVFR", function(airportIndex)
   TriggerServerEvent("addNewRequest", GetPlayerServerId(PlayerId()), airportIndex, 2)
	ratePointAfterDeparture = 0
	ratePointArrival = 0
	altitudeReached = false
end)

RegisterNetEvent("setPlayerFlightParameters")
AddEventHandler("setPlayerFlightParameters", function(altitude, squawk, freq)
   playerAltitude = altitude
	playerSquawk = squawk
	playerFreq = freq
	notify("You've set flight parameters. You are ready for flight!")
end)

RegisterNetEvent("setPlayerFlightParametersFromAtc")
AddEventHandler("setPlayerFlightParametersFromAtc", function(altitudeFromAtc, squawkFromAtc, freqFromAtc)
   atcAltitude = altitudeFromAtc
	atcSquawk = squawkFromAtc
	atcFreq = freqFromAtc
	notify("ATC has set flight parameters for you. You are ready for flight!")
end)

RegisterNetEvent("ratePlayerAfterDepartureFromAtc")
AddEventHandler("ratePlayerAfterDepartureFromAtc", function(ratePoint)
   ratePointAfterDeparture = ratePoint
	local pointText = {
		"Bad",
		"Partly good",
		"Good"
	}
	notify("You have been rated by ATC from departure airport as ~y~" .. pointText[ratePoint])
	checkToAddPoints()
end)

RegisterNetEvent("ratePlayerArrivalFromAtc")
AddEventHandler("ratePlayerArrivalFromAtc", function(ratePoint)
   ratePointArrival = ratePoint
	local pointText = {
		"Bad",
		"Partly good",
		"Good"
	}
	notify("You have been rated by ATC from arrival airport as ~y~" .. pointText[ratePoint])
	checkToAddPoints()
end)

RegisterNetEvent("notifyRatingFlights")
AddEventHandler("notifyRatingFlights", function(text)
   notify(text)
end)

RegisterNetEvent("updatePoints")
AddEventHandler("updatePoints", function(pointsFromFile)
   points = pointsFromFile
end)

RegisterNetEvent("getRatingFlightPointsOn")
AddEventHandler("getRatingFlightPointsOn", function(ratingFlightsOnFromServer)
   ratingFlightsOn = ratingFlightsOnFromServer
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

TriggerServerEvent("sendRatingFlightsOn", GetPlayerServerId(PlayerId()))

function DrawPoints(vehicle)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString("Points: ~y~" .. points)
	DrawText(0.90, 0.93)
end

function addPoints(addPointsNumber)
	points = points + addPointsNumber
end

function checkToAddPoints()
	if ratePointAfterDeparture > 0 and ratePointArrival > 0 then
		addPointsNumber = 0
		if playerAltitude == atcAltitude then addPointsNumber = addPointsNumber + 1 end
		if playerSquawk == atcSquawk then addPointsNumber = addPointsNumber + 1 end
		if playerFreq == atcFreq then addPointsNumber = addPointsNumber + 1 end
		addPointsNumber = addPointsNumber + ratePointAfterDeparture - 1
		addPointsNumber = addPointsNumber + ratePointArrival - 1
		if altitudeReached then addPointsNumber = addPointsNumber + 1 end
		
		addPoints(addPointsNumber)
		ratePointAfterDeparture = 0
		ratePointArrival = 0
		altitudeReached = false
		notify("Your flight has been rated! You have earned ~y~".. addPointsNumber .." ~w~points")
		TriggerServerEvent("updateFilePoint", GetPlayerServerId(PlayerId()), points)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(0, 164) then
			state = not state
		end
		
		if points == -1 then
			points = 0
			TriggerServerEvent("getFilePoints", GetPlayerServerId(PlayerId()))
		end
		
		if state and ratingFlightsOn ~= nil and ratingFlightsOn == true then
			DrawPoints()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if not altitudeReached and ratePointAfterDeparture ~= 0 and ratePointArrival == 0 then
			local altitude = GetEntityHeightAboveGround(PlayerPedId())
			if altitude >= tonumber(atcAltitude) then
				altitudeReached = true
			end
		end
	end
end)