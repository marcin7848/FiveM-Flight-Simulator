local _menuPool = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenu = NativeUI.CreateMenu("Staff Menu", "", screenW, 0)
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)
local permissions = nil

function StaffMenu(menu) 
	local changeEmergencies = NativeUI.CreateItem("Change emergencies", "Switch status of emergencies")
	local resetStatus = NativeUI.CreateItem("Reset status", "Set status to UNICOM")
	menu:AddItem(changeEmergencies)
	menu:AddItem(resetStatus)
	
   menu.OnItemSelect = function(sender, item, index)
        if item == changeEmergencies then
            TriggerServerEvent("setEmergencies")
				_menuPool:CloseAllMenus(true)
        end
		  if item == resetStatus then
            TriggerServerEvent("resetStatus")
				_menuPool:CloseAllMenus(true)
        end
   end

end

StaffMenu(mainMenu)
_menuPool:RefreshIndex()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustPressed(0, 162) then
				permissions = nil

				TriggerServerEvent("checkPermissionsAce", GetPlayerServerId(PlayerId()), "updatePermissionsStaff", "staffAce") -- ACE_PERM change to ace perm name for Staff
				while permissions == nil do
					Citizen.Wait(0)
				end
				if permissions then
					mainMenu:Visible(not mainMenu:Visible())
				end
        end
    end
end)

RegisterNetEvent("updatePermissionsStaff")
AddEventHandler("updatePermissionsStaff", function(permissionsFromServer)
   permissions = permissionsFromServer
end)