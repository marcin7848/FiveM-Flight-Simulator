RegisterNetEvent("checkPermissionsAce")
AddEventHandler("checkPermissionsAce", function(playerId, permissions)
	local permissionsFromServer = {}
	for i, permissionName in ipairs(permissions) do
		table.insert(permissionsFromServer, IsPlayerAceAllowed(playerId, permissionName))
	end
	
	TriggerClientEvent("updatePermissions", playerId, permissionsFromServer)
end)