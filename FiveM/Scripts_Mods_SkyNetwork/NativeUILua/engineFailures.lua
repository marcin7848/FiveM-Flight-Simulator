local _menuPoolEngineFailures = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
local mainMenuEngineFailures = NativeUI.CreateMenu("Engine failures", "", screenW, 0)
_menuPoolEngineFailures:Add(mainMenuEngineFailures)
_menuPoolEngineFailures:MouseControlsEnabled(true)
_menuPoolEngineFailures:MouseEdgeEnabled(false)
_menuPoolEngineFailures:ControlDisablingEnabled(true)

local function EngineFailuresMenu(menu) 
	local engineFailureTitles = {
		"Smoking",
		"Losing functionality",
		"Destroyed"
	}
	local tireFailureTitles = {
		"Burst front tire",
		"Burst all tires",
		"No landing gear"
	}
   local engineFailureList = NativeUI.CreateListItem("Engines failure", engineFailureTitles, 1)
	local tireFailureList = NativeUI.CreateListItem("Tires failure", tireFailureTitles, 1)
	local repair = NativeUI.CreateItem("Repair fehicle", "Repair engies and tires")
	fixed = 0
	
   menu.OnItemSelect = function(sender, item, index)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local vehicleClass = GetVehicleClass(vehicle)
		if(vehicleClass == 15 or vehicleClass == 16) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
			if item == repair then
				SetVehicleEngineHealth(vehicle, 1000)
				SetVehicleEngineOn(vehicle, true, true)
				SetVehicleFixed(vehicle)
				SetVehicleDirtLevel(vehicle, 0)
				fixed = 1
				notify("Vehicle repaired!")
				_menuPoolEngineFailures:CloseAllMenus(true)
			end
		else
			notify("You're not in helicopter or plane!")
		end
	end
	
	menu.OnListSelect = function(sender, item, index)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local vehicleClass = GetVehicleClass(vehicle)
		if(vehicleClass == 15 or vehicleClass == 16) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
			if item == engineFailureList then
				failure = item:IndexToItem(index)
				failurePoint = 1000.0
				if failure == engineFailureTitles[1] then
					failurePoint = 400.0
				elseif failure == engineFailureTitles[2] then
					failurePoint = 300.0
				elseif failure == engineFailureTitles[3] then
					failurePoint = 50.0
				end
				SetPlaneTurbulenceMultiplier(vehicle, 100.0)
				notify("Engines failure set to: ~r~" .. failure .. "")
				Citizen.CreateThread(function()
					repeat
						if failure == engineFailureTitles[2] then
							SetVehicleEngineHealth(vehicle, 50.0)
							Citizen.Wait((math.floor(math.random() * (10 - 6 + 1)) + 10) * 1000)
							currentVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
							if currentVehicle ~= vehicle or GetVehicleEngineHealth(currentVehicle) > 900.0 then
								break
							end
						end
						SetVehicleEngineHealth(vehicle, failurePoint)
						Citizen.Wait(4000)
						currentVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
					until(currentVehicle ~= vehicle or GetVehicleEngineHealth(currentVehicle) > 900.0 )
				end)
				_menuPoolEngineFailures:CloseAllMenus(true)
			end
			if item == tireFailureList then
				tirefailure = item:IndexToItem(index)
				if tirefailure == tireFailureTitles[1] then
					SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
					SetVehicleTyreBurst(vehicle, 1, true, 1000.0)
				elseif tirefailure == tireFailureTitles[2] then
					for i=0,47,1 do
						SetVehicleTyreBurst(vehicle, i, true, 1000.0)
					end
				elseif tirefailure == tireFailureTitles[3] then
					fixed = 0
					Citizen.CreateThread(function()
						repeat
							ControlLandingGear(vehicle, 3)
							Citizen.Wait(100)
							currentVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
						until(currentVehicle ~= vehicle or fixed == 1)
					end)
				end
				
				notify("Tire failure set to: ~r~" .. tirefailure .. "")
				_menuPoolEngineFailures:CloseAllMenus(true)
			end
		else
			notify("You're not in helicopter or plane!")
		end
	end
	menu:AddItem(engineFailureList)
	menu:AddItem(tireFailureList)
   menu:AddItem(repair)
end

EngineFailuresMenu(mainMenuEngineFailures)
_menuPoolEngineFailures:RefreshIndex()

Citizen.CreateThread(function()
   while true do
      Citizen.Wait(0)
      _menuPoolEngineFailures:ProcessMenus()
      if IsControlJustPressed(0, 168) then
			mainMenuEngineFailures:Visible(not mainMenuEngineFailures:Visible())
		elseif IsDisabledControlJustPressed(0, 168) then
			_menuPoolEngineFailures:CloseAllMenus(true)
      end
   end
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end