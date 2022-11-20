local state = 0

function DrawFlightInstruments()
    local speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId())) * 2.236936
    local altitude = GetEntityHeightAboveGround(PlayerPedId())
    local heading = GetEntityHeading(GetVehiclePedIsIn(PlayerPedId()))
    local verticalspeed = GetEntityVelocity(GetVehiclePedIsIn(PlayerPedId())).z * 196.850394
    if speed < 40 then speed = 20 end
    if speed > 200 then speed = 200 end
    if altitude<0 then altitude = 0 end
    if verticalspeed>2000 then verticalspeed = 2000 elseif verticalspeed < -2000 then verticalspeed = -2000 end
    local flightstate
    
    
    if not HasStreamedTextureDictLoaded("flightinstruments") then
        RequestStreamedTextureDict("flightinstruments", true)
        while not HasStreamedTextureDictLoaded("flightinstruments") do
            Wait(1)
        end
    end
    
    DrawSprite("flightinstruments", "speedometer", 0.48, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "speedometer_needle", 0.48, 0.9, 0.08, 0.08*1.77777778, ((speed-20)/20)*36, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "altimeter", 0.39, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "altimeter-needle100", 0.39, 0.9, 0.08, 0.08*1.77777778, altitude/100*36, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "altimeter-needle1000", 0.39, 0.9, 0.08, 0.08*1.77777778, altitude/1000*36, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "altimeter-needle10000", 0.39, 0.9, 0.08, 0.08*1.77777778, altitude/10000*36, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "heading", 0.30, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "heading_needle", 0.30, 0.9, 0.08, 0.08*1.77777778, -1 * heading, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "verticalspeedometer", 0.21, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
    DrawSprite("flightinstruments", "verticalspeedometer_needle", 0.21, 0.9, 0.08, 0.08*1.77777778, 270+(verticalspeed/1000*90), 255, 255, 255, 255)
    
end

function round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function roundNoDecimal(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function DrawFlightInstrumentsTexts()
   local speed = roundNoDecimal(GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId())) * 2.236936)
   local altitude = GetEntityHeightAboveGround(PlayerPedId())
   local verticalspeed = roundNoDecimal(GetEntityVelocity(GetVehiclePedIsIn(PlayerPedId())).z * 196.850394)
   if altitude<0.95 then altitude = 0 end
	altitude = roundNoDecimal(altitude)
	
	local pitch = round(GetEntityPitch(PlayerPedId()), 1)
	local roll = round(GetEntityRoll(PlayerPedId()), 1)
	
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.3)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString("SP: ".. speed .."MPH   VSP: "..verticalspeed.."FT\nALT: "..altitude.."FT   Pitch: "..pitch.."   Roll: "..roll.."")
	DrawText(0.02, 0.74)
	
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
		  if IsControlJustPressed(0, 158) then
            if state == 0 then
					state = 1
				elseif state == 1 then
					state = 2 
				else
					state = 0
				end
        end
		  
        if IsPedInAnyPlane(PlayerPedId()) and state == 0 then
            DrawFlightInstruments()
        end
		  
		  if IsPedInAnyPlane(PlayerPedId()) and state == 1 then
            DrawFlightInstrumentsTexts()
        end
		  
    end
end)
