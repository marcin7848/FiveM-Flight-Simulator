local _menuPool = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenu = NativeUI.CreateMenu("ATC Menu", "", screenW, 0)
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)
local airportStatus = {}
local requests = nil
local ratingAfterDeparture = nil
local ratingArrival = nil
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

RegisterNetEvent("setRatingFlightsInfo")
AddEventHandler("setRatingFlightsInfo", function(requestsFromServer, ratingAfterDepartureFromServer, ratingArrivalFromServer)
   requests = requestsFromServer
	ratingAfterDeparture = ratingAfterDepartureFromServer
	ratingArrival = ratingArrivalFromServer
end)

function ATCMenu(menu)
	local airports = {}
	
	for i=1, #airportStatus do
		table.insert(airports, airportStatus[i][1])
	end
	
	local workIn = NativeUI.CreateListItem("Work as ATC in", airports, 1)
	local leaveJob = NativeUI.CreateItem("Leave job", "Leave your job")
	menu:AddItem(workIn)
	menu:AddItem(leaveJob)
	
	if ratingFlightsOn then
		local submenuRequests = _menuPool:AddSubMenu(menu, "Requests", "Check and send response to requests", screenW, 0)

		local airportIndexAtc = 0
		for i=1, #airportStatus do
			for j=1, #airportStatus[i][2][2] do
				if airportStatus[i][2][2][j] == GetPlayerServerId(PlayerId()) then
						airportIndexAtc = i
					break
				end
			end
		end
		
		if airportIndexAtc > 0 then
			for _, ifrReqPlayer in ipairs(requests[airportIndexAtc][1]) do
				submenuRequests.SubMenu:AddItem(NativeUI.CreateItem("Respond to IFR request " .. GetPlayerName(GetPlayerFromServerId(ifrReqPlayer)), ""))		
			end
			for _, vfrReqPlayer in ipairs(requests[airportIndexAtc][2]) do
				submenuRequests.SubMenu:AddItem(NativeUI.CreateItem("Respond to VFR request " .. GetPlayerName(GetPlayerFromServerId(vfrReqPlayer)), ""))		
			end
		end
		
		submenuRequests.SubMenu.OnItemSelect = function(sender, item, index)
			local playerId = 0
			local flightParametersForPlayer = enterFlightParametersForPlayer()
		
			local calcIndex = 0
			
			for _, ifrReqPlayer in ipairs(requests[airportIndexAtc][1]) do
				calcIndex = calcIndex + 1
				if calcIndex == index then
					playerId = ifrReqPlayer
					break
				end
			end
			
			for _, vfrReqPlayer in ipairs(requests[airportIndexAtc][2]) do
				calcIndex = calcIndex + 1
				if calcIndex == index then
					playerId = vfrReqPlayer
					break
				end
			end

			TriggerServerEvent("setFlightParametersFromAtc", playerId, flightParametersForPlayer[1], flightParametersForPlayer[2], flightParametersForPlayer[3], airportIndexAtc, flightParametersForPlayer[4])
			notify("You have set flight parameters for ~y~" .. GetPlayerName(GetPlayerFromServerId(playerId)))
			_menuPool:CloseAllMenus(true)
		end
		
		local submenuRateAfterDeparture = _menuPool:AddSubMenu(menu, "Rate after departure", "Rate players after depatrture", screenW, 0)
		local pointText = {
			"Bad",
			"Partly good",
			"Good"
		}
		
		local playerIdRateAfterDeparture = {}
		local menusRateAfterDeparture = {}
		if airportIndexAtc > 0 then
			for _, playerIdRateAfterDep in ipairs(ratingAfterDeparture[airportIndexAtc]) do
				local menuRateAfterDep = NativeUI.CreateListItem("Rate " .. GetPlayerName(GetPlayerFromServerId(playerIdRateAfterDep)), pointText, 3)
				submenuRateAfterDeparture.SubMenu:AddItem(menuRateAfterDep)
				table.insert(playerIdRateAfterDeparture, playerIdRateAfterDep)
				table.insert(menusRateAfterDeparture, menuRateAfterDep)
			end
		end
		
		submenuRateAfterDeparture.SubMenu.OnListSelect = function(sender, item, index)
			for i=0, #menusRateAfterDeparture do
				if menusRateAfterDeparture[i] == item then
					TriggerServerEvent("ratePlayerAfterDeparture", playerIdRateAfterDeparture[i], index)
					notify("You have rated ~y~" .. GetPlayerName(GetPlayerFromServerId(playerIdRateAfterDeparture[i])))
					_menuPool:CloseAllMenus(true)
					break
				end
			end
		end
		
		local submenuRateArrivals = _menuPool:AddSubMenu(menu, "Rate arrivals", "Rate players arrivals", screenW, 0)
		
		local playerIdRateArrivals = {}
		local menusRateArrivals = {}
		if airportIndexAtc > 0 then
			for _, playerIdRateArriv in ipairs(ratingArrival[airportIndexAtc]) do
				local menuRateArrival = NativeUI.CreateListItem("Rate " .. GetPlayerName(GetPlayerFromServerId(playerIdRateArriv)), pointText, 3)
				submenuRateArrivals.SubMenu:AddItem(menuRateArrival)
				table.insert(playerIdRateArrivals, playerIdRateArriv)
				table.insert(menusRateArrivals, menuRateArrival)
			end
		end
		
		submenuRateArrivals.SubMenu.OnListSelect = function(sender, item, index)
			for i=0, #menusRateArrivals do
				if menusRateArrivals[i] == item then
					TriggerServerEvent("ratePlayerArrival", playerIdRateArrivals[i], index)
					notify("You have rated ~y~" .. GetPlayerName(GetPlayerFromServerId(playerIdRateArrivals[i])))
					_menuPool:CloseAllMenus(true)
					break
				end
			end
		end
	end
	
	menu.OnListSelect = function(sender, item, index)
		if item == workIn then
			TriggerServerEvent("updateStatus", GetPlayerServerId(PlayerId()), index, 2)
			_menuPool:CloseAllMenus(true)
		end
	end

	menu.OnItemSelect = function(sender, item, index)
		if item == leaveJob then
			TriggerServerEvent("leaveJob", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		end
	end

	_menuPool:MouseControlsEnabled(false)
	_menuPool:MouseEdgeEnabled(false)
	_menuPool:ControlDisablingEnabled(false)
	
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustPressed(0, 161) then
				airportStatus = {}
				requests = nil
				ratingAfterDeparture = nil
				ratingArrival = nil
				permissions = nil
				ratingFlightsOn = nil
				
				TriggerServerEvent("getAirportStatus", GetPlayerServerId(PlayerId()))
				TriggerServerEvent("getRatingFlightsInfo", GetPlayerServerId(PlayerId()))
				TriggerServerEvent("sendRatingFlightsOn", GetPlayerServerId(PlayerId()))
				TriggerServerEvent("checkPermissionsAce", GetPlayerServerId(PlayerId()), "updatePermissionsAtc", "atc") -- ACE_PERM change to ace perm name for ATC
				while #airportStatus == 0 or requests == nil or ratingAfterDeparture == nil or ratingArrival == nil or permissions == nil or ratingFlightsOn == nil do
					Citizen.Wait(0)
				end
				if permissions then
					mainMenu:Clear()
					ATCMenu(mainMenu)
					_menuPool:RefreshIndex()
					mainMenu:Visible(not mainMenu:Visible())
				end
        end
    end
end)

function enterFlightParametersForPlayer()
	local windowOpened = false
	local text = "Flight altitude in FT"
	local step = 1
	local playerAltitude = 0
	local playerSquawk = 0
	local playerFreq = 0.0
	local destinationAirport = 0
	
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
			if step < 4 then
				result = tonumber(GetOnscreenKeyboardResult())
			else
				result = GetOnscreenKeyboardResult()
			end

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
			elseif step == 3 then
				if result == nil or result < 0 or result > 1000 then
					text = "You have to enter correct shortcut. Try again! Frequency after departure"
					windowOpened = false
				else
					playerFreq = result
					windowOpened = false
					text = "Shortcut for destination airport e.g. LSIA (only capital letters!!!)"
					step = 4
				end
			else
				local destinationAirportIndex = 0
				for i=1, #airportStatus do
					if airportStatus[i][1] == result then
						destinationAirportIndex = i
					end
				end
				
				if destinationAirportIndex == 0 then
					text = "You have to enter correct shortcut. Try again! Shortcut for destination airport"
					windowOpened = false
				else
					destinationAirport = destinationAirportIndex
					break
				end
			end
		else
			break
		end	
	end
	
	return {playerAltitude, playerSquawk, playerFreq, destinationAirport}
end

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

RegisterNetEvent("updatePermissionsAtc")
AddEventHandler("updatePermissionsAtc", function(permissionsFromServer)
   permissions = permissionsFromServer
end)