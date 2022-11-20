local airportCoords = {
	{permActiveRefueling=0, firstX=-1362.31, firstY=-2055.57, secondX = -2076.42, secondY = -3170.71, thirdX = -940.15, thirdY = -3697.87, forthX = -402.28, forthY = -2727.88}, --LSIA
	{permActiveRefueling=1, firstX=99999.0, firstY=999999.0, secondX = 999999.0, secondY = 999999.0, thirdX = 99999.0, thirdY = 999999.0, forthX = 999999.0, forthY = 999999.0}, --SSIA
	{permActiveRefueling=1, firstX=99999.0, firstY=999999.0, secondX = 999999.0, secondY = 999999.0, thirdX = 99999.0, thirdY = 999999.0, forthX = 999999.0, forthY = 999999.0}, --SSRA
	{permActiveRefueling=1, firstX=99999.0, firstY=999999.0, secondX = 999999.0, secondY = 999999.0, thirdX = 99999.0, thirdY = 999999.0, forthX = 999999.0, forthY = 999999.0}, --ZAC
	{permActiveRefueling=1, firstX=99999.0, firstY=999999.0, secondX = 999999.0, secondY = 999999.0, thirdX = 99999.0, thirdY = 999999.0, forthX = 999999.0, forthY = 999999.0}, --CARRIER
	--set airport coordinates
	--permActiveRefueling -> set to 1 means it doesn't care if GC is online at that specific airport, pilot always can refuel by himself
	--get coordinates at one of the edge of airport -> then set: firstX = x, firstY=your
	--get coordinates at another edge of the same speficic airport -> then set: secondX = x, secondY=y etc....
	--it creates a square -> if player is located in this square, and GC is online at this airport and permActiveRefueling = 0, pilot has to wait for GC for refueling
	--it should contain the same number of ROWS as set airports IN resources/status/statusServer.lua
}

local airportStatus = {}

DecorRegister("_FUEL_LEVEL", 1)

local currentVehicle = nil
local refueling = false
local state = true
local dumpFuelActive = false

RegisterNetEvent("setAirportStatusFuel")
AddEventHandler("setAirportStatusFuel", function(airportStatusFromServer)
   airportStatus = airportStatusFromServer
end)


function GetFuel(vehicle)
	return DecorGetFloat(vehicle, "_FUEL_LEVEL")
end

function SetFuel(vehicle, fuel)
	if fuel <= 0 then
		fuel = 0
	end
	if fuel >= 100 then
		fuel = 100
	end
	
	DecorSetFloat(vehicle, "_FUEL_LEVEL", fuel + 0.0)
end

function refuel(playerId)
	if refueling or dumpFuelActive then
		notify("You are currently refueling/dumping fuel!")
		return
	end
	TriggerServerEvent("getAirportStatusFuel", GetPlayerServerId(PlayerId()))
	refueling = true
	airportStatus = {}
	notify("Refueling started!")
	
	Citizen.CreateThread(function()
		while #airportStatus == 0 do
			Citizen.Wait(0)
		end
		while true do
			Citizen.Wait(0)
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
				if currentVehicle == vehicle then
					if not GetIsVehicleEngineRunning(vehicle) then
						local playerAtAirportAndGCOnline = calcIfPlayerBetween2Points()
						if playerAtAirportAndGCOnline == 1 then
							if GetFuel(vehicle) ~= 100.0 then
								SetFuel(vehicle, GetFuel(vehicle) + 0.5)
							else
								notify("Refueling have finished!")
								refueling = false
								return
							end
						elseif playerAtAirportAndGCOnline == 2 then
							notify("There is GC Online! You need to ask GC for refueling!")
							refueling = false
							return
						else
							notify("You are not at the airport! You cannot refuel here!")
							refueling = false
							return
						end
					else
						notify("You need to turn off your engines!")
						refueling = false
						return
					end
				else
					refueling = false
					return
				end
			else
				notify("You are not in a vehicle!")
				refueling = false
				return
			end
			
			Citizen.Wait(100)
		end
	end)
end

function dumpFuel(playerId)
	if refueling or dumpFuelActive then
		notify("You are currently refueling/dumping fuel!")
		return
	end
	dumpFuelActive = true
	airportStatus = {}
	notify("Fuel dumping started!")
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
				if currentVehicle == vehicle then
					if GetFuel(vehicle) > 20.0 then
						SetFuel(vehicle, GetFuel(vehicle) - 0.5)
					else
						notify("Fuel dumping finished!")
						dumpFuelActive = false
						return
					end
				else
					dumpFuelActive = false
					return
				end
			else
				notify("You are not in a vehicle!")
				dumpFuelActive = false
				return
			end
			
			Citizen.Wait(100)
		end
	end)
end

RegisterNetEvent("refuel")
AddEventHandler("refuel", function(playerId)
	refuel(playerId)
end)

RegisterNetEvent("dumpFuel")
AddEventHandler("dumpFuel", function(playerId)
	dumpFuel(playerId)
end)

function refuelByGC(gcId)
	if refueling or dumpFuelActive then
		TriggerServerEvent("triggerNotifyFuelGC", gcId, "Player is currently refueling/dumping fuel!")
		return
	end
	refueling = true
	notify("Refueling started!")
	TriggerServerEvent("triggerNotifyFuelGC", gcId, "You are refueling ~y~" .. GetPlayerName(PlayerId()) .. " ~w~now!")
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			if vehicle ~= 0 then
				if currentVehicle == vehicle then
					if not GetIsVehicleEngineRunning(vehicle) then
						if GetFuel(vehicle) ~= 100.0 then
								local newFuelLevel = GetFuel(vehicle) + 0.5
								SetFuel(vehicle, newFuelLevel)
								if newFuelLevel >= 25.0 and newFuelLevel < 25.5 then
									TriggerServerEvent("triggerNotifyFuelGC", gcId, "Refueling player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~- 25%")
								elseif newFuelLevel >= 50.0 and newFuelLevel < 50.5 then
									TriggerServerEvent("triggerNotifyFuelGC", gcId, "Refueling player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~- 50%")
								elseif newFuelLevel >= 75.0 and newFuelLevel < 75.5 then
									TriggerServerEvent("triggerNotifyFuelGC", gcId, "Refueling player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~- 75%")
								else
								end
						else
							TriggerServerEvent("triggerNotifyFuelGC", gcId, "Refueling player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~have finished!")
							notify("Refueling have finished")
							refueling = false
							return
						end
					else
						TriggerServerEvent("triggerNotifyFuelGC", gcId, "Player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~needs to turn off engines!")
						refueling = false
						return
					end
				else
					TriggerServerEvent("triggerNotifyFuelGC", gcId, "Player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~has changed a vehicle!")
					refueling = false
					return
				end
			else
				TriggerServerEvent("triggerNotifyFuelGC", gcId, "Player ~y~" .. GetPlayerName(PlayerId()) .. " ~w~is not in a vehicle!")
				refueling = false
				return
			end
			
			Citizen.Wait(100)
		end
	end)
end

RegisterNetEvent("refuelByGC")
AddEventHandler("refuelByGC", function(gcId)
	refuelByGC(gcId)
end)

function DrawFuel(vehicle)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextOutline()
	SetTextEntry("STRING")

	local fuel = round(GetFuel(vehicle))
	
	fuelText = ""
	
	if fuel <= 20.0 then
		fuelText = "Fuel: ~r~" .. tostring(fuel)
	elseif fuel > 20.0 and fuel <= 50.0 then
		fuelText = "Fuel: ~y~" .. tostring(fuel)
	else
		fuelText = "Fuel: ~g~" .. tostring(fuel)
	end
	
	AddTextComponentString(fuelText)
	DrawText(0.90, 0.95)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
			if currentVehicle ~= vehicle then
				SetFuel(vehicle, 10.0)
				currentVehicle = vehicle
				SetVehicleEngineOn(vehicle, false, true)
			end
			
			if state then
				DrawFuel(vehicle)
			end
		end
		
		if IsControlJustPressed(0, 164) then
			state = not state
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if vehicle ~= 0 and GetIsVehicleEngineRunning(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
			local speed = GetEntitySpeed(vehicle) * 2.236936
			if speed <= 10.0 then
				SetFuel(vehicle, GetFuel(vehicle) - 0.01)
			elseif speed > 10.0 and speed <= 30.0 then
				SetFuel(vehicle, GetFuel(vehicle) - 0.02)
			elseif speed > 30.0 and speed <= 60.0 then
				SetFuel(vehicle, GetFuel(vehicle) - 0.05)
			elseif speed > 60.0 and speed <= 100.0 then
				SetFuel(vehicle, GetFuel(vehicle) - 0.07)
			elseif speed > 100.0 and speed <= 150.0 then
				SetFuel(vehicle, GetFuel(vehicle) - 0.1)
			elseif speed > 150.0 then
				SetFuel(vehicle, GetFuel(vehicle) - 0.1)
			end
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if vehicle ~= 0 and GetFuel(vehicle) <= 0.5 and GetIsVehicleEngineRunning(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
			SetVehicleEngineOn(vehicle, false, true)
		end
	end
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function calcIfPlayerBetween2Points()
	local retStat = 0
	local playerPos = GetEntityCoords(PlayerPedId())
	for i=1, #airportCoords do
		P1 = {x=airportCoords[i].firstX, y=airportCoords[i].firstY}
		P2 = {x=airportCoords[i].secondX, y=airportCoords[i].secondY}
		P3 = {x=airportCoords[i].thirdX, y=airportCoords[i].thirdY}
		P4 = {x=airportCoords[i].forthX, y=airportCoords[i].forthX}
		P = {x=playerPos.x, y=playerPos.y}

		if isInsideSquare(P1, P2, P3, P4, P) then
			if airportCoords[i].permActiveRefueling == 0 and #airportStatus[i][3][2] > 0 then
				retStat = 2
				break
			else
				retStat = 1
				break
			end
		end
	end
	return retStat
end

function triangleArea(A, B, C)
	return (C.x*B.y-B.x*C.y)-(C.x*A.y-A.x*C.y)+(B.x*A.y-A.x*B.y)
end

function isInsideSquare(A, B, C, D, P)
	if (triangleArea(A,B,P)>0 or triangleArea(B,C,P)>0 or triangleArea(C,D,P)>0 or triangleArea(D,A,P)>0) then
		return false
	end
	return true
end