RegisterNetEvent("gcStartRefuelingPlayer")
AddEventHandler("gcStartRefuelingPlayer", function(playerId)
	local playerOffline = true
	for _, player in ipairs(GetActivePlayers()) do
		if player == playerId then
			TriggerServerEvent("requestRefuelByGC", GetPlayerServerId(playerId), GetPlayerServerId(PlayerId()))
			playerOffline = false
			break
		end
	end
	
	if playerOffline then
		notify("Chosen player is offline!")
	end
end)

RegisterNetEvent("notifyFuelGC")
AddEventHandler("notifyFuelGC", function(text)
   notify(text)
end)


function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end