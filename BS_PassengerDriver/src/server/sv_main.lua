if #controlsToCheck==0 then print("No AllowedActions, thread ending"); return; end
if not Config.AllVehicles and #Config.AllowedVehicles<1 then print("No AllowedVehicles, thread ending"); return; end

IsControlToCheck = function(control)
  for i = 1,#controlsToCheck do if control==controlsToCheck[i] then return true end end
  return false
end

RegisterNetEvent("BS_PassengerDriver:PassengerDriverControlPress", function(vehNet, control)
  local src = source
  if not IsControlToCheck(control) then ServerFunctions.InvalidControlTrigger(src, control); return; end
  local vehicle = NetworkGetEntityFromNetworkId(vehNet)
  if not Config.AllVehicles and not keyedVehiclesModels[GetEntityModel(vehicle)] then ServerFunctions.InvalidVehicleTrigger(src, vehicle); return; end
  local owner = NetworkGetEntityOwner(vehicle)
  if src==owner then return end
  if GetPedInVehicleSeat(vehicle, 0)~=GetPlayerPed(src) then ServerFunctions.NonPassengerTrigger(src); return; end
  TriggerClientEvent("BS_PassengerDriver:PassengerDriverPressAttempt", owner, control)
end)

RegisterNetEvent("BS_PassengerDriver:PassengerDriverControlRelease", function(vehNet, control)
  local src = source
  if not IsControlToCheck(control) then ServerFunctions.InvalidControlTrigger(src, control); return; end
  local vehicle = NetworkGetEntityFromNetworkId(vehNet)
  if not Config.AllVehicles and not keyedVehiclesModels[GetEntityModel(vehicle)] then ServerFunctions.InvalidVehicleTrigger(src, vehicle); return; end
  local owner = NetworkGetEntityOwner(vehicle)
  if src==owner then return end
  local ped = GetPlayerPed(src)
  if GetPedInVehicleSeat(vehicle, 0)~=ped and GetLastPedInVehicleSeat(vehicle, 0)~=ped then ServerFunctions.NonPassengerTrigger(src); return; end
  TriggerClientEvent("BS_PassengerDriver:PassengerDriverReleaseAttempt", owner, control)
end)