AddTextEntry("headingText", "~a~~a~~a~~a~")

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextScale(0.0, 0.27)
		SetTextColour(240, 240, 240, 255)
		SetTextDropshadow(1, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
   
		SetTextEntry("headingText")
		local heading = round(GetGameplayCamRot().z)
		local textTable = generateText(heading)
		AddTextComponentString(textTable[1])
		AddTextComponentString(textTable[2])
		AddTextComponentString(textTable[3])
		AddTextComponentString(textTable[4])
		DrawText(0.0, 0.0)
	end
end)

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function generateText(heading)
	local tabText = {}
	local text = ""
	local i = heading + 100
	while i >= heading - 100 do
		tmpI = i
		if tmpI <= -180 then
		  tmpI = tmpI  + 2*180
		end
		if tmpI >= 180 then
		  tmpI = tmpI  - 2*180
		end
		if tmpI == heading then
			text = text .. convertText(tmpI, true)
		else
			text = text .. convertText(tmpI, false) .. " "
		end
		if string.len(text) >= 97 then
			table.insert(tabText, text)
			text = ""
		end
		i = i-1
	end
	if string.len(text) > 0 then
		table.insert(tabText, text)
	end
	
	return tabText
end

function convertText(heading, currentHeading)
	tmpHeading = heading
	if heading < 0 and heading >= -180 then
		tmpHeading = tmpHeading * -1
	elseif heading >= 0 and heading <= 180 then
		tmpHeading = tmpHeading * -1 + 360
	end
	
	if not currentHeading then
		if tmpHeading ~= 0 and tmpHeading ~= 45 and tmpHeading ~= 135 and tmpHeading ~= 180 and tmpHeading ~= 225 and tmpHeading ~= 270 and tmpHeading ~= 315 and tmpHeading ~= 360 then
			if math.fmod(heading,5) == 0 then
				return "|"
			else
				return " "
			end
		end
	end
	
	return tostring(tmpHeading)
end