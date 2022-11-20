local currentVehicle = nil

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if vehicle ~= 0 and currentVehicle ~= vehicle and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
			currentVehicle = vehicle
			local entityModelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
			print(entityModelName)
			if entityModelName == "B727-200" then
				SetVehicleMaxSpeed(vehicle, 190.0 / 2.236936)
         end
		end
	end
end)