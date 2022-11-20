local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


_menuPoolEngineFailures = NativeUI.CreatePool()
local screenW, screenH = GetScreenResolution()
mainMenuEngineFailures = NativeUI.CreateMenu("Engine failures", "", screenW, 0)
_menuPoolEngineFailures:Add(mainMenuEngineFailures)
_menuPoolEngineFailures:MouseControlsEnabled(false)
_menuPoolEngineFailures:MouseEdgeEnabled(false)
_menuPoolEngineFailures:ControlDisablingEnabled(false)

function EngineFailuresMenu(menu) 
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
		if(vehicleClass == 15 or vehicleClass == 16) then
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
		if(vehicleClass == 15 or vehicleClass == 16) then
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
        if IsControlJustPressed(0, 168) or IsDisabledControlJustPressed(0, 168) then
            mainMenuEngineFailures:Visible(not mainMenuEngineFailures:Visible())
        end
    end
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end