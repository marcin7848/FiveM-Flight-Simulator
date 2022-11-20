local _menuPool = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenu = NativeUI.CreateMenu("Pilot Menu", "", screenW, 0)
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)
local airportStatus = {}
local permissions = nil
local ratingFlightsOn = nil

RegisterNetEvent("setAirportStatus")
AddEventHandler("setAirportStatus", function(airportStatusFromServer)
   airportStatus = airportStatusFromServer
end)

RegisterNetEvent("getRatingFlightPointsOn")
AddEventHandler("getRatingFlightPointsOn", function(ratingFlightsOnFromServer)
   ratingFlightsOn = ratingFlightsOnFromServer
end)

function PilotMenu(menu) 
	local checkStatusPlayers = NativeUI.CreateItem("Check status players", "Check who is working right now")
	local refuel = NativeUI.CreateItem("Refuel", "Start refueling your vehicle")
	local dumpFuel = NativeUI.CreateItem("Dump Fuel", "Dumping fuel")
	menu:AddItem(checkStatusPlayers)
	menu:AddItem(refuel)
	menu:AddItem(dumpFuel)
	
	local airports = {}
	
	for i=1, #airportStatus do
		table.insert(airports, airportStatus[i][1])
	end
	
	local ifr = NativeUI.CreateListItem("Request IFR clearance", airports, 1)
	local vfr = NativeUI.CreateListItem("Request VFR clearance", airports, 1)
	menu:AddItem(ifr)
	menu:AddItem(vfr)
	
	local flightParameters = NativeUI.CreateItem("Flight parameters", "Enter flight parameters given by ATC")
	if ratingFlightsOn then
		menu:AddItem(flightParameters)
	end
	
   menu.OnItemSelect = function(sender, item, index)
        if item == checkStatusPlayers then
            TriggerServerEvent("showStatusPlayers", GetPlayerServerId(PlayerId()))
				_menuPool:CloseAllMenus(true)
        end
		  
        if item == refuel then
            TriggerEvent("refuel", GetPlayerServerId(PlayerId()))
				_menuPool:CloseAllMenus(true)
        end
		  
		  if item == dumpFuel then
            TriggerEvent("dumpFuel", GetPlayerServerId(PlayerId()))
				_menuPool:CloseAllMenus(true)
        end
		  
        if item == flightParameters then
            local playerFlightParameters = enterFlightParameters()
				if  playerFlightParameters[1] ~= 0 and playerFlightParameters[2] ~= 0 and playerFlightParameters[3] ~= 0.0 then
					TriggerEvent("setPlayerFlightParameters", playerFlightParameters[1], playerFlightParameters[2], playerFlightParameters[3])
					_menuPool:CloseAllMenus(true)
				else
					notify("You didn't set flight parameters! Something went wrong!")
				end			
        end
   end
	
	menu.OnListSelect = function(sender, item, index)
		if item == ifr then
			TriggerEvent("requestIFR", index)
			_menuPool:CloseAllMenus(true)
		end
		if item == vfr then
			TriggerEvent("requestVFR", index)
			_menuPool:CloseAllMenus(true)
		end
	end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustPressed(0, 163) then
            airportStatus = {}
				ratingFlightsOn = nil
				TriggerServerEvent("getAirportStatus", GetPlayerServerId(PlayerId()))
				TriggerServerEvent("sendRatingFlightsOn", GetPlayerServerId(PlayerId()))
				while #airportStatus == 0 or ratingFlightsOn == nil do
					Citizen.Wait(0)
				end
				mainMenu:Clear()
				PilotMenu(mainMenu)
				_menuPool:RefreshIndex()
				mainMenu:Visible(not mainMenu:Visible())
        end
    end
end)

function enterFlightParameters()
	local windowOpened = false
	local text = "Flight altitude in FT"
	local step = 1
	local playerAltitude = 0
	local playerSquawk = 0
	local playerFreq = 0.0
	
	while true do
		if not windowOpened then
			AddTextEntry('FMMC_KEY_TIP1', text)
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 20)
			windowOpened = true
		end
		
		while(UpdateOnscreenKeyboard() == 0) do
			DisableAllControlActions(0)
			Wait(0)
		end
		
		if(UpdateOnscreenKeyboard() == 1) then
			result = tonumber(GetOnscreenKeyboardResult())
			if step == 1 then
				if result == nil or result < 0 or result > 15000 then
					text = "You have to enter correct number. Try again! Flight altitude in FT"
					windowOpened = false
				else
					playerAltitude = result
					windowOpened = false
					text = "Squawk"
					step = 2
				end
			elseif step == 2 then
				if result == nil or result < 0 or result > 10000 then
					text = "You have to enter correct number. Try again! Squawk"
					windowOpened = false
				else
					playerSquawk = result
					windowOpened = false
					text = "Frequency after departure"
					step = 3
				end
			else
				if result == nil or result < 0 or result > 1000 then
					text = "You have to enter correct number. Try again! Frequency after departure"
					windowOpened = false
				else
					playerFreq = result
					break
				end
			end
		else
			break
		end	
	end
	
	return {playerAltitude, playerSquawk, playerFreq}
end

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end