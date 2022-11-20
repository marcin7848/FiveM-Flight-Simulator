local permissionAceNames = {"staffAce", "atc", "gc", "apu"}

local _menuPool = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenu = NativeUI.CreateMenu("Pilot Menu", "", screenW, 0)
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(true)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(true)
local airportStatus = {}
local ratingFlightsOn = nil
local permissions = nil
local requests = nil
local ratingAfterDeparture = nil
local ratingArrival = nil
local airportsNames = {}

RegisterNetEvent("setAirportStatus")
AddEventHandler("setAirportStatus", function(airportStatusFromServer)
   airportStatus = airportStatusFromServer
end)

RegisterNetEvent("getRatingFlightPointsOn")
AddEventHandler("getRatingFlightPointsOn", function(ratingFlightsOnFromServer)
   ratingFlightsOn = ratingFlightsOnFromServer
end)

RegisterNetEvent("updatePermissions")
AddEventHandler("updatePermissions", function(permissionsFromServer)
   permissions = permissionsFromServer
end)

RegisterNetEvent("setRatingFlightsInfo")
AddEventHandler("setRatingFlightsInfo", function(requestsFromServer, ratingAfterDepartureFromServer, ratingArrivalFromServer)
   requests = requestsFromServer
	ratingAfterDeparture = ratingAfterDepartureFromServer
	ratingArrival = ratingArrivalFromServer
end)


local function PilotMenu(menu) 
	local checkStatusPlayers = NativeUI.CreateItem("Check status players", "Check who is working right now")
	local refuel = NativeUI.CreateItem("Refuel", "Start refueling your vehicle")
	local dumpFuel = NativeUI.CreateItem("Dump Fuel", "Dumping fuel")
	menu:AddItem(checkStatusPlayers)
	menu:AddItem(refuel)
	menu:AddItem(dumpFuel)
	
	local flightParameters = nil
	local ifr = nil
	local vfr = nil
	if ratingFlightsOn then
		flightParameters = NativeUI.CreateItem("Flight parameters", "Enter flight parameters given by ATC")
		ifr = NativeUI.CreateListItem("Request IFR clearance", airportsNames, 1)
		vfr = NativeUI.CreateListItem("Request VFR clearance", airportsNames, 1)
		menu:AddItem(ifr)
		menu:AddItem(vfr)
		menu:AddItem(flightParameters)
	end
	
   menu.OnItemSelect = function(sender, item, index)
		if item == checkStatusPlayers then
			TriggerServerEvent("showStatusPlayers", GetPlayerServerId(PlayerId()))
			menuPool:CloseAllMenus(true)
		elseif item == refuel then
			TriggerEvent("refuel", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		elseif item == dumpFuel then
			TriggerEvent("dumpFuel", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		elseif item == flightParameters then
			local playerFlightParameters = enterFlightParameters()
			if  playerFlightParameters[1] ~= 0 and playerFlightParameters[2] ~= 0 and playerFlightParameters[3] ~= 0.0 then
				TriggerEvent("setPlayerFlightParameters", playerFlightParameters[1], playerFlightParameters[2], playerFlightParameters[3])
				_menuPool:CloseAllMenus(true)
			else
				notify("You ~r~haven't ~w~set flight parameters! Something went wrong!")
			end			
		end
	end
	
	menu.OnListSelect = function(sender, item, index)
		if item == ifr then
			TriggerEvent("requestIFR", index)
			_menuPool:CloseAllMenus(true)
		elseif item == vfr then
			TriggerEvent("requestVFR", index)
			_menuPool:CloseAllMenus(true)
		end
	end
end

local function StaffMenu(menu) 
	local submenuStaff = _menuPool:AddSubMenu(menu, "Staff Menu", "Enter to staff menu", screenW, 0)
	local changeEmergencies = NativeUI.CreateItem("Change emergencies", "Switch status of emergencies")
	local resetStatus = NativeUI.CreateItem("Reset status", "Set status to UNICOM")
	submenuStaff.SubMenu:AddItem(changeEmergencies)
	submenuStaff.SubMenu:AddItem(resetStatus)
	
   submenuStaff.SubMenu.OnItemSelect = function(sender, item, index)
		if item == changeEmergencies then
			TriggerServerEvent("setEmergencies")
			_menuPool:CloseAllMenus(true)
		elseif item == resetStatus then
			TriggerServerEvent("resetStatus")
			_menuPool:CloseAllMenus(true)
		end
	end
	
	_menuPool:MouseControlsEnabled(true)
	_menuPool:MouseEdgeEnabled(false)
	_menuPool:ControlDisablingEnabled(true)
end

local function ATCMenu(menu)
	local submenuAtc = _menuPool:AddSubMenu(menu, "ATC Menu", "Enter to ATC menu", screenW, 0)
	
	local changeEmergencies = NativeUI.CreateItem("Change emergencies", "Switch status of emergencies")
	local workIn = NativeUI.CreateListItem("Work as ATC in", airportsNames, 1)
	local leaveJob = NativeUI.CreateItem("Leave job", "Leave your job")
	submenuAtc.SubMenu:AddItem(changeEmergencies)
	submenuAtc.SubMenu:AddItem(workIn)
	submenuAtc.SubMenu:AddItem(leaveJob)
	
	if ratingFlightsOn then
		local submenuRequests = _menuPool:AddSubMenu(submenuAtc.SubMenu, "Requests", "Check and send response to requests", screenW, 0)

		local airportIndexAtc = loadAirportIndex("ATC")

		if airportIndexAtc > 0 then
			for _, ifrReqPlayer in ipairs(requests[airportIndexAtc][1]) do
				submenuRequests.SubMenu:AddItem(NativeUI.CreateItem("Respond to IFR request " .. GetPlayerName(GetPlayerFromServerId(ifrReqPlayer)), ""))		
			end
			for _, vfrReqPlayer in ipairs(requests[airportIndexAtc][2]) do
				submenuRequests.SubMenu:AddItem(NativeUI.CreateItem("Respond to VFR request " .. GetPlayerName(GetPlayerFromServerId(vfrReqPlayer)), ""))		
			end
		end
		
		submenuRequests.SubMenu.OnItemSelect = function(sender, item, index)
			local playerId = calcPlayerIndexInRequests(index, airportIndexAtc)
			local flightParametersForPlayer = enterFlightParametersForPlayer()
			if flightParametersForPlayer[1] ~= 0 and flightParametersForPlayer[2] ~= 0 and flightParametersForPlayer[3] ~= 0.0 and flightParametersForPlayer[4] ~= "" then
				TriggerServerEvent("setFlightParametersFromAtc", playerId, flightParametersForPlayer[1], flightParametersForPlayer[2], flightParametersForPlayer[3], airportIndexAtc, flightParametersForPlayer[4])
				notify("You have set flight parameters for ~y~" .. GetPlayerName(GetPlayerFromServerId(playerId)))
			else
				notify("You ~r~haven't ~w~set flight parameters for ~y~" .. GetPlayerName(GetPlayerFromServerId(playerId)))
			end
			_menuPool:CloseAllMenus(true)
		end
		
		local submenuRateAfterDeparture = _menuPool:AddSubMenu(submenuAtc.SubMenu, "Rate after departure", "Rate players after depatrture", screenW, 0)
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
		
		local submenuRateArrivals = _menuPool:AddSubMenu(submenuAtc.SubMenu, "Rate arrivals", "Rate players arrivals", screenW, 0)
		
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
	
	submenuAtc.SubMenu.OnListSelect = function(sender, item, index)
		if item == workIn then
			TriggerServerEvent("updateStatus", GetPlayerServerId(PlayerId()), index, 2)
			_menuPool:CloseAllMenus(true)
		end
	end

	submenuAtc.SubMenu.OnItemSelect = function(sender, item, index)
		if item == changeEmergencies then
			TriggerServerEvent("setEmergencies")
			_menuPool:CloseAllMenus(true)
		elseif item == leaveJob then
			TriggerServerEvent("leaveJob", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		end
	end

	_menuPool:MouseControlsEnabled(true)
	_menuPool:MouseEdgeEnabled(false)
	_menuPool:ControlDisablingEnabled(true)
end

local function GCMenu(menu)
	local submenuGc = _menuPool:AddSubMenu(menu, "GC Menu", "Enter to GC menu", screenW, 0)
	
	local changeEmergencies = NativeUI.CreateItem("Change emergencies", "Switch status of emergencies")
	local workIn = NativeUI.CreateListItem("Work as GC in", airportsNames, 1)
	local leaveJob = NativeUI.CreateItem("Leave job", "Leave your job")
	submenuGc.SubMenu:AddItem(changeEmergencies)
	submenuGc.SubMenu:AddItem(workIn)
	submenuGc.SubMenu:AddItem(leaveJob)
	
	local nearbyPlayersIds = getNearbyPlayersIds()
	local submenuRefuelPlayers = _menuPool:AddSubMenu(submenuGc.SubMenu, "Refueling players", "Refuel nearby player", screenW, 0)
	
	for index, value in ipairs(nearbyPlayersIds) do
		submenuRefuelPlayers.SubMenu:AddItem(NativeUI.CreateItem("Refuel " .. GetPlayerName(value), ""))
	end
	
	submenuRefuelPlayers.SubMenu.OnItemSelect = function(sender, item, index)
		TriggerEvent("gcStartRefuelingPlayer", nearbyPlayersIds[index])
		_menuPool:CloseAllMenus(true)
   end
	
	submenuGc.SubMenu.OnListSelect = function(sender, item, index)
		if item == workIn then
			TriggerServerEvent("updateStatus", GetPlayerServerId(PlayerId()), index, 3)
			_menuPool:CloseAllMenus(true)
		end
	end

	submenuGc.SubMenu.OnItemSelect = function(sender, item, index)
		if item == changeEmergencies then
			TriggerServerEvent("setEmergencies")
			_menuPool:CloseAllMenus(true)
		elseif item == leaveJob then
			TriggerServerEvent("leaveJob", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		end
	end
	
	_menuPool:MouseControlsEnabled(true)
	_menuPool:MouseEdgeEnabled(false)
	_menuPool:ControlDisablingEnabled(true)

end

local function APUMenu(menu)
	local submenuApu = _menuPool:AddSubMenu(menu, "APU Menu", "Enter to APU menu", screenW, 0)
	local workIn = NativeUI.CreateListItem("Work as APU in", airportsNames, 1)
	local leaveJob = NativeUI.CreateItem("Leave job", "Leave your job")
	submenuApu.SubMenu:AddItem(workIn)
	submenuApu.SubMenu:AddItem(leaveJob)
	
	submenuApu.SubMenu.OnListSelect = function(sender, item, index)
		if item == workIn then
			TriggerServerEvent("updateStatus", GetPlayerServerId(PlayerId()), index, 4)
			_menuPool:CloseAllMenus(true)
		end
	end

	submenuApu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == leaveJob then
			TriggerServerEvent("leaveJob", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		end
	end
	
	_menuPool:MouseControlsEnabled(true)
	_menuPool:MouseEdgeEnabled(false)
	_menuPool:ControlDisablingEnabled(true)
	
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		_menuPool:ProcessMenus()
		if IsControlJustPressed(0, 163) then
			local playerId = GetPlayerServerId(PlayerId())
         airportStatus = {}
			ratingFlightsOn = nil
			permissions = nil
			requests = nil
			ratingAfterDeparture = nil
			ratingArrival = nil
				
			TriggerServerEvent("getAirportStatus", playerId)
			TriggerServerEvent("sendRatingFlightsOn", playerId)
			TriggerServerEvent("checkPermissionsAce", playerId, permissionAceNames)
			TriggerServerEvent("getRatingFlightsInfo", playerId)
				
			while #airportStatus == 0 or permissions == nil or ratingFlightsOn == nil do
				Citizen.Wait(0)
			end
			loadBeforeMenus()
			mainMenu:Clear()
			if permissions[1] then
				StaffMenu(mainMenu)
			end
			if permissions[2] then
				ATCMenu(mainMenu)
			end
			if permissions[3] then
				GCMenu(mainMenu)
			end
			if permissions[4] then
				APUMenu(mainMenu)
			end
			PilotMenu(mainMenu)
			_menuPool:RefreshIndex()
			mainMenu:Visible(true)
		elseif IsDisabledControlJustPressed(0, 163) then
			_menuPool:CloseAllMenus(true)
      end
   end
end)

function loadBeforeMenus()
	local airports = {}
	
	for i=1, #airportStatus do
		table.insert(airports, airportStatus[i][1])
	end
	
	airportsNames = airports
end

function loadAirportIndex(roleName)
	local index = 0
	if roleName == "ATC" then
		index = 2
	end
	
	if index == 0 then
		return 0
	end
	
	for i=1, #airportStatus do
		for j=1, #airportStatus[i][index][2] do
			if airportStatus[i][index][2][j] == GetPlayerServerId(PlayerId()) then
				return i
			end
		end
	end
	
	return 0
end

function calcPlayerIndexInRequests(index, airportIndexAtc)
	local calcIndex = 0
			
	for _, ifrReqPlayer in ipairs(requests[airportIndexAtc][1]) do
		calcIndex = calcIndex + 1
		if calcIndex == index then
			return ifrReqPlayer
		end
	end
			
	for _, vfrReqPlayer in ipairs(requests[airportIndexAtc][2]) do
		calcIndex = calcIndex + 1
		if calcIndex == index then
			return vfrReqPlayer
		end
	end
	return 0
end

function getNearbyPlayersIds()
	local playerPos = GetEntityCoords(PlayerPedId())
	local nearbyPlayersIds = {}
	for _, player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		local coords = GetEntityCoords(ped)
		 
		if Vdist(coords.x, coords.y, coords.z, playerPos.x, playerPos.y, playerPos.z) < 35.0 then
			table.insert(nearbyPlayersIds, player)
		end
	end
	
	return nearbyPlayersIds
end

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
			return {0, 0, 0.0}
		end	
	end
	
	return {playerAltitude, playerSquawk, playerFreq}
end

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
			return {0, 0, 0.0, ""}
		end	
	end
	
	return {playerAltitude, playerSquawk, playerFreq, destinationAirport}
end

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end