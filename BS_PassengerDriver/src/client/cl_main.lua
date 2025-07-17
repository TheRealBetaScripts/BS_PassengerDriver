if #controlsToCheck==0 then print("No AllowedActions, thread ending"); return; end
if not Config.AllVehicles and #Config.AllowedVehicles<1 then print("No AllowedVehicles, thread ending"); return; end

local pushedControls = {}
local isInVehicle = false
local currentSeat = false
local currentVehicle = false
local wereForcedDriving = false
local forcedAccel, forcedBraking, forcedLeft, forcedRight, forcedHandbrake, forcedLift, forcedLower = false, false, false, false, false, false, false
local vehTypeControls = {
  [0] = { -- Car
    [61] = 61, -- Pitch Up
    [62] = 62, -- Pitch Down
    [63] = 59, -- Turn Left
    [64] = 59, -- Turn Right
    [71] = 71, -- Accelerate/Brake
    [72] = 72, -- Reverse/Brake
    [76] = 76, -- Handbrake
    
  },
  [1] = { -- Plane
    [61] = 110,
    [62] = 110,
    [63] = 89,
    [64] = 90,
    [71] = 87,
    [72] = 88,
    [76] = 88,
  },
  [8] = { -- Heli
    [61] = 110,
    [62] = 110,
    [63] = 89,
    [64] = 90,
    [71] = 87,
    [72] = 88,
    [76] = 88,
  },
  [11] = { -- Bike
    [61] = 61,
    [62] = 62,
    [63] = 59,
    [64] = 59,
    [71] = 71,
    [72] = 72,
    [76] = 76,
  },
  [13] = { -- Boat
    [61] = 61,
    [62] = 62,
    [63] = 59,
    [64] = 59,
    [71] = 71,
    [72] = 72,
    [76] = 76,
  },
  [15] = { -- Sub
    [61] = 126,
    [62] = 126,
    [63] = 123,
    [64] = 123,
    [71] = 129,
    [72] = 130,
    [76] = 130,
  }
}

IsPedInFrontPassengerWithDriver = function()
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  return (GetPedInVehicleSeat(vehicle, 0)==PlayerPedId()) and (not IsVehicleSeatFree(vehicle, -1))
end

IsForcedDriving = function()
  return (forcedAccel or forcedBraking or forcedLeft or forcedRight or forcedHandbrake or forcedLift or forcedLower)
end

DisableGasAndBrake = function(vehType)
  DisableControlAction(0, vehTypeControls[vehType][71], true)
  DisableControlAction(0, vehTypeControls[vehType][72], true)
end

DisableTurning = function(vehType)
  DisableControlAction(0, vehTypeControls[vehType][63], true)
  DisableControlAction(0, vehTypeControls[vehType][64], true)
end

VehicleActionTask = function(driver, vehicle, taskId, vehType)
  print("Vehicle Type", vehType)
  print("Task ID", taskId)
  print("Control Table", vehTypeControls[vehType])
  print("Control", vehTypeControls[vehType][taskId])
  if taskId==63 or taskId==64 then
    if vehType==1 then
      SetControlNormal(0, vehTypeControls[vehType][taskId], 1.0)
    else
      SetControlNormal(0, vehTypeControls[vehType][taskId], ((taskId==63) and -1.0) or 1.0)
    end
  elseif taskId==61 or taskId==62 then
    if vehType==1 then
      SetControlNormal(0, vehTypeControls[vehType][taskId], ((taskId==62) and -1.0) or 1.0)
    elseif vehType==8 then
      SetControlNormal(0, vehTypeControls[vehType][taskId], ((taskId==61) and -1.0) or 1.0)
    elseif vehType==15 then
      SetControlNormal(0, vehTypeControls[vehType][taskId], ((taskId==61) and -1.0) or 1.0)
    end
  else
    SetControlNormal(0, vehTypeControls[vehType][taskId], 1.0)
  end
  --[[
  local isPlane = IsPedInAnyPlane(driver)
  if isPlane then
    if taskId==7 then
      --TaskVehicleTempAction(driver, vehicle, 17, -1)
    elseif taskId==8 then
      --TaskVehicleTempAction(driver, vehicle, 18, -1)
    elseif taskId==9 then
      --TaskVehicleTempAction(driver, vehicle, 15, -1)
    end
  else
    --TaskVehicleTempAction(driver, vehicle, taskId, -1)
  end
  ]]
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
            local enabled = IsControlEnabled(0, controlsToCheck[i])
            if pushedControls[i] and ((enabled and IsControlReleased(0, controlsToCheck[i])) or IsDisabledControlReleased(0, controlsToCheck[i])) then
              print("Attempted PassengerDriver ControlRelease: control", controlsToCheck[i])
              TriggerServerEvent("BS_PassengerDriver:PassengerDriverControlRelease", currentVehicle, controlsToCheck[i])
              pushedControls[i] = false
            end
            if (enabled and IsControlJustPressed(0, controlsToCheck[i])) or IsDisabledControlJustPressed(0, controlsToCheck[i]) then
              print("Attempted PassengerDriver ControlPress: control", controlsToCheck[i])
              TriggerServerEvent("BS_PassengerDriver:PassengerDriverControlPress", currentVehicle, controlsToCheck[i])
              pushedControls[i] = true
            end
          end
        elseif IsForcedDriving() then
          if not wereForcedDriving then ClientFunctions.Notify(_LR.TookControl); wereForcedDriving = true; end
          local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
          local driver = GetPedInVehicleSeat(vehicle, -1)
          local vehType = GetVehicleTypeRaw(vehicle)
          if not vehTypeControls[vehType] then vehType = next(vehTypeControls) end
          if forcedLeft then
            --DisableTurning(vehType)
            VehicleActionTask(driver, vehicle, 63, vehType)
          end
          if forcedRight then
            --DisableTurning(vehType)
            VehicleActionTask(driver, vehicle, 64, vehType)
          end
          if forcedHandbrake then
            DisableGasAndBrake(vehType)
            VehicleActionTask(driver, vehicle, 76, vehType)
          end
          if forcedAccel then
            --DisableGasAndBrake(vehType)
            VehicleActionTask(driver, vehicle, 71, vehType)
          end
          if forcedBraking then
            --DisableGasAndBrake(vehType)
            VehicleActionTask(driver, vehicle, 72, vehType)
          end
          if forcedLift then
            --DisableGasAndBrake(vehType)
            VehicleActionTask(driver, vehicle, 61, vehType)
          end
          if forcedLower then
            print("Force Lower")
            --DisableGasAndBrake(vehType)
            VehicleActionTask(driver, vehicle, 62, vehType)
          end
          --[[
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
          ]]
        elseif wereForcedDriving then
          --local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
          --VehicleActionTask(GetPedInVehicleSeat(vehicle, -1), vehicle, 0, vehType)
          --ClearPedTasks(GetPedInVehicleSeat(vehicle, -1))
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
  elseif control==21 then
    print("Start Raise")
    forcedLift = true
  elseif control==36 then
    print("Start Lower")
    forcedLower = true
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
  elseif control==21 then
    print("Stop Raise")
    forcedLift = false
  elseif control==36 then
    print("Stop Lower")
    forcedLower = false
  end
end)