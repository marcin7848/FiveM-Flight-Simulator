mainMarkers = {
	{active=1, id=103, colour=1, x=-1051.18, y=-3308.28, z=13.94, changeX = 99.35, changeY = -57.28}, --LSIA 30L
	{active=0, id=103, colour=1, x=-966.76, y=-3162.27, z=13.94, changeX = 99.35, changeY = -57.28}, -- LSIA 30R
	{active=0, id=103, colour=1, x=-1607.46, y=-2986.95, z=13.94, changeX = -89.16, changeY = 50.7}, -- LSIA 12R
	{active=0, id=103, colour=1, x=-1522.86, y=-2841.32, z=13.94, changeX = -88.56, changeY = 51.34}, -- LSIA 12L
	{active=1, id=103, colour=1, x=-1634.56, y=-2727.54, z=13.94, changeX = -55.75, changeY = -96.04}, -- LSIA 3
	{active=0, id=103, colour=1, x=-1379.14, y=-2285.02, z=13.94, changeX = 54.7, changeY = 95.71} -- LSIA 21
	--add more airports and runways here
	-- {active=0/1, id=(blip ID), colour=(color ID), x=(first marker's x position), y=(first marker's y position), z=(first marker's z position), changeX = (how to change X), changeY = (how to change Y)}
	--how to change X means - what to add/sub to basic first marker to create second marker (and further points)
}

tempBlips = {}
count = 0
for _, item in pairs(mainMarkers) do
	specBlips = {}
	table.insert(specBlips, item)
	for i = 1,15,1 do
		tmp = {id=144, colour=33, x=item.x + item.changeX*i, y=item.y + item.changeY*i, z=item.z} --color and blip mark for all except first marker
		table.insert(specBlips, tmp)
	end
	table.insert(tempBlips, specBlips)
end

blips = tempBlips

for i = 1, #mainMarkers, 1 do
	--#'IF'_COULD_BE_HERE#
	Citizen.CreateThread(function()  
		local allBlips = {}
		local j = i
		while true do
			Citizen.Wait(0)
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			local vehicleClass = GetVehicleClass(vehicle)
			
			if (next(allBlips) == nil and (vehicleClass == 15 or vehicleClass == 16)) then -- add here considering attitude (more then X feet - to be sure player is in the air)
					if blips[j][1].active == 1 then -- if there will be possiblity to dynamically change what runway is currently active it could be tested here if NOT (runways will be always same for landings move this if to #'IF'_COULD_BE_HERE# to remove unnecessary threads)
						for _, item in pairs(blips[j]) do
							item.blip = AddBlipForCoord(item.x, item.y, item.z)
							SetBlipSprite(item.blip, item.id)
							SetBlipColour(item.blip, item.colour)
							SetBlipDisplay(item.blip, 8)
							SetBlipHiddenOnLegend(item.blip, true)
							SetBlipScale(item.blip, 0.6)
							SetBlipAsShortRange(item.blip, 1);
							
							table.insert(allBlips, item.blip)
							Citizen.Wait(100)
						end
					end
			else
				Citizen.Wait(500)
				for i, blip in pairs(allBlips) do
					RemoveBlip(blip)
				end
				
				count = #allBlips
				for i=0, count do 
					allBlips[i]=nil 
				end
			end
		end
	end)
end