local KmH = 3.6
local MpH = 2.23694
local maxSpeed = {}

local speedMultiplier = KmH

local vehicle, seat
local currentGear = 1

local SET_VEHICLE_CURRENT_GEAR_HASH = GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF
local function SetVariableCurrentGear(vehicle, gear)
	Citizen.InvokeNative(SET_VEHICLE_CURRENT_GEAR_HASH, vehicle, gear)
end

local function getVehicleInfo()
	maxSpeed.vehicleClass = GetVehicleClass(vehicle)
	maxSpeed.vehicleModel = GetEntityModel(vehicle)
	maxSpeed.vehicleMax = maxSpeed.limit
	SetVehicleMaxSpeed(vehicle, maxSpeed.vehicleMax)
	maxSpeed.justSetIn = false
end

--- Check if key object is just pressed
---@param key {id: integer, group: integer, controlName: string}
---@return boolean
function keyJustPressed(key)
	local isPressed = IsControlJustPressed(key.group, key.id)
	--if isPressed then print(key.controlName, "jsut pressed") end
	return isPressed
end

--- Check if key object is pressed
---@param key {id: integer, group: integer, controlName: string}
---@return boolean
function keyPressed(key)
	local isPressed = IsControlPressed(key.group, key.id)
	--if isPressed then print(key.controlName, "is pressed") end
	return isPressed
end

local function setVehicleRPM(vehicle, speed, maxSpeed)
	local rpm = GetVehicleCurrentRpm(vehicle)
	--print(rpm, maxSpeed);
	SetVehicleCurrentRpm(vehicle, GetVehicleCurrentRpm(vehicle))
end

local function setMaxSpeed()
	local last = maxSpeed.speed
	local speed = GetEntitySpeed(vehicle) * speedMultiplier
	getVehicleInfo(vehicle)
	maxSpeed.speed = math.floor(speed / SpeedLimiter.precision + .5) * SpeedLimiter.precision
	maxSpeed.speed = math.min(maxSpeed.speed, maxSpeed.limit)
	if maxSpeed.isActive and math.abs(maxSpeed.speed - last) < 5 then
		maxSpeed.isActive = false
	else
		maxSpeed.isActive = true
	end
end

local function speedLimiterIsActive()
	if keyPressed(SpeedLimiter.keys.LimitRaise) then
		maxSpeed.speed = maxSpeed.speed + 0.1
		SetVehicleMaxSpeed(vehicle, maxSpeed.speed / speedMultiplier)
	elseif keyPressed(SpeedLimiter.keys.LimitLower) then
		maxSpeed.speed = maxSpeed.speed - 0.1
		SetVehicleMaxSpeed(vehicle, maxSpeed.speed / speedMultiplier)
	end

	local speed = GetEntitySpeed(vehicle) * speedMultiplier
	if speed >= maxSpeed.speed then
		SetVehicleMaxSpeed(vehicle, maxSpeed.speed / speedMultiplier)
		setVehicleRPM(vehicle, speed, maxSpeed.speed)
	end
end
local function initSpeedLimiter()
	if SpeedLimiter.isMpH then speedMultiplier = MpH end
	maxSpeed = {
		speed = 0,
		vehicleMax = 0,
		limit = SpeedLimiter.maxSpeed * speedMultiplier,
		isActive = false,
		justSetIn = true,
		vehicleModel = nil
	}
	while true do
		vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))
		seat = GetPedInVehicleSeat(vehicle, -1)
		if seat == GetPlayerPed(-1) then
			if maxSpeed.justSetIn then getVehicleInfo(vehicle) end
			if keyJustPressed(SpeedLimiter.keys.toggleLimiter) then setMaxSpeed() end
			if maxSpeed.isActive then speedLimiterIsActive() end
			Citizen.Wait(8)
		else
			maxSpeed.justSetIn = true
			maxSpeed.isActive = false
			Citizen.Wait(2000)
		end
	end
end

local function initGearShifter()
	while true do
		if seat == GetPlayerPed(-1) then
			local maxGear = GetVehicleHighGear(vehicle)
			if keyJustPressed(SpeedLimiter.keys.gearShiftUp) then
				currentGear = math.min(maxGear, currentGear + 1)
				SetVariableCurrentGear(vehicle, currentGear)
			elseif keyJustPressed(SpeedLimiter.keys.gearShiftDown) then
				currentGear = math.max(0, currentGear - 1)
				SetVariableCurrentGear(vehicle, currentGear)
			end
			local actualGear = GetVehicleCurrentGear(vehicle)
			if currentGear ~= actualGear then currentGear = actualGear end
			Citizen.Wait(8)
		else
			Citizen.Wait(2000)
		end
	end
end

Citizen.CreateThread(initSpeedLimiter)
Citizen.CreateThread(initGearShifter)
