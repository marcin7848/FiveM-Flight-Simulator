local _menuPool = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenu = NativeUI.CreateMenu("GC Menu", "", screenW, 0)
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)
local airportStatus = {}
local permissions = nil

RegisterNetEvent("setAirportStatus")
AddEventHandler("setAirportStatus", function(airportStatusFromServer)
   airportStatus = airportStatusFromServer
end)

function GCMenu(menu)
	local airports = {}
	for i=1, #airportStatus do
		table.insert(airports, airportStatus[i][1])
	end
	local workIn = NativeUI.CreateListItem("Work as GC in", airports, 1)
	local leaveJob = NativeUI.CreateItem("Leave job", "Leave your job")
	menu:AddItem(workIn)
	menu:AddItem(leaveJob)
	
	local playerPos = GetEntityCoords(PlayerPedId())
	local nearbyPlayersIds = {}
	for _, player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		local coords = GetEntityCoords(ped)
		 
		if Vdist(coords.x, coords.y, coords.z, playerPos.x, playerPos.y, playerPos.z) < 35.0 then
			table.insert(nearbyPlayersIds, player)
		end
	end

	local submenuRefuelPlayers = _menuPool:AddSubMenu(menu, "Refueling players", "Refuel nearby player", screenW, 0)
	
	for index, value in ipairs(nearbyPlayersIds) do
		submenuRefuelPlayers.SubMenu:AddItem(NativeUI.CreateItem("Refuel " .. GetPlayerName(value), ""))
	end
	
	submenuRefuelPlayers.SubMenu.OnItemSelect = function(sender, item, index)
		TriggerEvent("gcStartRefuelingPlayer", nearbyPlayersIds[index])
		_menuPool:CloseAllMenus(true)
   end
	
	menu.OnListSelect = function(sender, item, index)
		if item == workIn then
			TriggerServerEvent("updateStatus", GetPlayerServerId(PlayerId()), index, 3)
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
        if IsControlJustPressed(0, 159) then 
				airportStatus = {}
				permissions = nil
				TriggerServerEvent("getAirportStatus", GetPlayerServerId(PlayerId()))
				TriggerServerEvent("checkPermissionsAce", GetPlayerServerId(PlayerId()), "updatePermissionsGc", "gc") -- ACE_PERM change to ace perm name for GC
				while #airportStatus == 0 or permissions == nil do
					Citizen.Wait(0)
				end
				if permissions then
					mainMenu:Clear()
					GCMenu(mainMenu)
					_menuPool:RefreshIndex()
					mainMenu:Visible(not mainMenu:Visible())
				end
        end
    end
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

RegisterNetEvent("updatePermissionsGc")
AddEventHandler("updatePermissionsGc", function(permissionsFromServer)
   permissions = permissionsFromServer
end)