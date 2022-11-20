local _menuPool = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenu = NativeUI.CreateMenu("APU Menu", "", screenW, 0)
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

function APUMenu(menu)
	local airports = {}
	
	for i=1, #airportStatus do
		table.insert(airports, airportStatus[i][1])
	end
	
	local workIn = NativeUI.CreateListItem("Work as APU in", airports, 1)
	local leaveJob = NativeUI.CreateItem("Leave job", "Leave your job")
	menu:AddItem(workIn)
	menu:AddItem(leaveJob)
	
	menu.OnListSelect = function(sender, item, index)
		if item == workIn then
			TriggerServerEvent("updateStatus", GetPlayerServerId(PlayerId()), index, 4)
			_menuPool:CloseAllMenus(true)
		end
	end

	menu.OnItemSelect = function(sender, item, index)
		if item == leaveJob then
			TriggerServerEvent("leaveJob", GetPlayerServerId(PlayerId()))
			_menuPool:CloseAllMenus(true)
		end
	end

end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustPressed(0, 165) then
				airportStatus = {}
				permissions = nil
				TriggerServerEvent("getAirportStatus", GetPlayerServerId(PlayerId()))
				TriggerServerEvent("checkPermissionsAce", GetPlayerServerId(PlayerId()), "updatePermissionsApu", "apu") --ACE_PERM change to ace perm name for APU
				while #airportStatus == 0 or permissions == nil do
					Citizen.Wait(0)
				end
				if permissions then
					mainMenu:Clear()
					APUMenu(mainMenu)
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


RegisterNetEvent("updatePermissionsApu")
AddEventHandler("updatePermissionsApu", function(permissionsFromServer)
   permissions = permissionsFromServer
end)