AddTextEntry("statusText", "~a~~a~~a~~a~")

local status = {"", "", ""}
local emergencies = false
local state = true
local statusSet = false

function DrawStatus()
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.3)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextOutline()
	SetTextEntry("statusText")
	local emergText = "~r~NOT ALLOWED"
	if emergencies then
		emergText = "~g~ALLOWED"
	end
	AddTextComponentString("~y~STATUS: ~w~" .. status[1])
	AddTextComponentString(status[2])
	AddTextComponentString(status[3])
	AddTextComponentString("\n~y~EMERGENCIES: ~w~" .. emergText)
	DrawText(0.17, 0.94)
	
end

RegisterNetEvent("setStatus")
AddEventHandler("setStatus", function(statusFromServer)
	status = statusFromServer
	notify("Status set to: ~y~" .. status[1] .. status[2] .. status[3])
end)

RegisterNetEvent("setEmergencies")
AddEventHandler("setEmergencies", function(emergenciesFromServer)
	emergencies = emergenciesFromServer
	local emergText = "~r~NOT ALLOWED"
	if emergencies then
		emergText = "~g~ALLOWED"
	end
	notify("Emergencies set to: " .. emergText)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if statusSet == false then
			TriggerServerEvent("getStatus", GetPlayerServerId(PlayerId()))
			statusSet = true
		end

		if IsControlJustPressed(0, 160) then
			state = not state
      end

		if state then
			DrawStatus()
		end
	end
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end