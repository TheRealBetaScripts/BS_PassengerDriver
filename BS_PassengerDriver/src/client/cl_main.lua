if #controlsToCheck==0 then print("No AllowedActions, thread ending"); return; end
if not Config.AllVehicles and #Config.AllowedVehicles<1 then print("No AllowedVehicles, thread ending"); return; end

local isInVehicle = false
local currentSeat = false
local currentVehicle = false
local wereForcedDriving = false
local pushedControls = {false, false, false, false}
local forcedAccel, forcedBraking, forcedLeft, forcedRight, forcedHandbrake = false, false, false, false, false

IsPedInFrontPassengerWithDriver = function()
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  return (GetPedInVehicleSeat(vehicle, 0)==PlayerPedId()) and (not IsVehicleSeatFree(vehicle, -1))
end

IsForcedDriving = function()
  return (forcedAccel or forcedBraking or forcedLeft or forcedRight or forcedHandbrake)
end

DisableGasAndBrake = function()
  DisableControlAction(0, 71, true)
  DisableControlAction(0, 72, true)
end

DisableTurning = function()
  DisableControlAction(0, 59, true)
  DisableControlAction(0, 63, true)
  DisableControlAction(0, 64, true)
end

VehicleActionTask = function(driver, vehicle, taskId)
  local isPlane = IsPedInAnyPlane(driver)
  if isPlane then
    if taskId==7 then
      TaskVehicleTempAction(driver, vehicle, 17, -1)
    elseif taskId==8 then
      TaskVehicleTempAction(driver, vehicle, 18, -1)
    elseif taskId==9 then
      TaskVehicleTempAction(driver, vehicle, 15, -1)
    end
  else
    TaskVehicleTempAction(driver, vehicle, taskId, -1)
  end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if not isInVehicle and IsPedInAnyVehicle(PlayerPedId()) then
      isInVehicle = true
      local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
      print("Player Entered Vehicle: ped, vehicle", PlayerPedId(), vehicle)
      if Config.AllVehicles or keyedVehiclesModels[GetEntityModel(vehicle)] then
        print("Valid Vehicle Model: model", GetEntityModel(vehicle))
        if NetworkGetEntityIsNetworked(vehicle) and ClientFunctions.CanPassengerDriveVehicle(vehicle) then currentVehicle = NetworkGetNetworkIdFromEntity(vehicle) end
      end
    elseif isInVehicle then
      if not IsPedInAnyVehicle(PlayerPedId()) then
        print("Player Exited Vehicle: ped, vehicle", PlayerPedId(), NetworkGetEntityFromNetworkId(currentVehicle))
        for i = 1,#controlsToCheck do if pushedControls[i] then TriggerServerEvent("BS_PassengerDriver:PassengerDriverControlRelease", currentVehicle, controlsToCheck[i]); pushedControls[i] = false; end end
        isInVehicle = false
        currentSeat = false
        currentVehicle = false
        wereForcedDriving = false
        forcedAccel, forcedBraking, forcedLeft, forcedRight, forcedHandbrake = false, false, false, false, false
      elseif currentVehicle then
        currentSeat = IsPedInFrontPassengerWithDriver()
        if currentSeat then
          for i = 1,#controlsToCheck do
            if pushedControls[i] and IsControlReleased(0, controlsToCheck[i]) then
              print("Attempted PassengerDriver ControlRelease: control", controlsToCheck[i])
              TriggerServerEvent("BS_PassengerDriver:PassengerDriverControlRelease", currentVehicle, controlsToCheck[i])
              pushedControls[i] = false
            end
            if IsControlJustPressed(0, controlsToCheck[i]) then
              print("Attempted PassengerDriver ControlPress: control", controlsToCheck[i])
              TriggerServerEvent("BS_PassengerDriver:PassengerDriverControlPress", currentVehicle, controlsToCheck[i])
              pushedControls[i] = true
            end
          end
        elseif IsForcedDriving() then
          if not wereForcedDriving then ClientFunctions.Notify(_LR.TookControl); wereForcedDriving = true; end
          local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
          local driver = GetPedInVehicleSeat(vehicle, -1)
          if forcedHandbrake then
            DisableGasAndBrake()
            if forcedLeft then
              DisableTurning()
              VehicleActionTask(driver, vehicle, 25, -1)
            elseif forcedRight then
              DisableTurning()
              VehicleActionTask(driver, vehicle, 26, -1)
            else
              VehicleActionTask(driver, vehicle, 27, -1)
            end
          elseif forcedAccel then
            DisableGasAndBrake()
            if forcedLeft then
              DisableTurning()
              VehicleActionTask(driver, vehicle, 7, -1)
            elseif forcedRight then
              DisableTurning()
              VehicleActionTask(driver, vehicle, 8, -1)
            else
              VehicleActionTask(driver, vehicle, 9, -1)
            end
          elseif forcedBraking then
            DisableGasAndBrake()
            if forcedLeft then
              DisableTurning()
              VehicleActionTask(driver, vehicle, 13, -1)
            elseif forcedRight then
              DisableTurning()
              VehicleActionTask(driver, vehicle, 14, -1)
            else
              VehicleActionTask(driver, vehicle, 28, -1)
            end
          elseif forcedLeft then
            DisableTurning()
            VehicleActionTask(driver, vehicle, 7, -1)
          elseif forcedRight then
            DisableTurning()
            VehicleActionTask(driver, vehicle, 8, -1)
          end
        elseif wereForcedDriving then
          local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
          VehicleActionTask(GetPedInVehicleSeat(vehicle, -1), vehicle, 0, 0)
          ClearPedTasks(GetPedInVehicleSeat(vehicle, -1))
          ClientFunctions.Notify(_LR.ReleasedControl)
          wereForcedDriving = false
        end
      end
    end
  end
end)

RegisterNetEvent("BS_PassengerDriver:PassengerDriverPressAttempt", function(control)
  if control==22 then
    print("Start Handbraking")
    forcedHandbrake = true
  elseif control==32 then
    print("Start Accelerating")
    forcedAccel = true
  elseif control==33 then
    print("Start Braking")
    forcedBraking = true
  elseif control==34 then
    print("Start Left")
    forcedLeft = true
  elseif control==35 then
    print("Start Right")
    forcedRight = true
  end
end)

RegisterNetEvent("BS_PassengerDriver:PassengerDriverReleaseAttempt", function(control)
  if control==22 then
    print("Stop Handbraking")
    forcedHandbrake = false
  elseif control==32 then
    print("Stop Accelerating")
    forcedAccel = false
  elseif control==33 then
    print("Stop Braking")
    forcedBraking = false
  elseif control==34 then
    print("Stop Left")
    forcedLeft = false
  elseif control==35 then
    print("Stop Right")
    forcedRight = false
  end
end)