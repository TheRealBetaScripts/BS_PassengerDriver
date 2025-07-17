-- Local variable initialization
refFunc = print

-- Init validation of Config
if not Config or type(Config)~="table" then Config = {}; end
if not Config.Debug or type(Config.Debug)~="table" then Config.Debug = {enabled = false, logLevel = "simple"} end

-- Local print function for debug
print = function(...)
  if Config.Debug.enabled then
    local args = {...}
    if Config.Debug.logLevel and Config.Debug.logLevel=="shallow" then
      refFunc(args[1])
    else
      refFunc(table.unpack(args))
    end
  end
end

-- Remaining validation of Config

if not Config.BaseLocale or type(Config.BaseLocale)~="string" then Config.BaseLocale = "en-GB" end
if not Config.AllowedActions or type(Config.AllowedActions)~="table" then Config.AllowedActions = {} end
if not Config.AllowedVehicles or type(Config.AllowedVehicles)~="table" then Config.AllowedVehicles = {} end
for i = #Config.AllowedVehicles,1,-1 do if type(Config.AllowedVehicles[i])~="string" then print("Removed invalid vehicle entry, please put the vehicle name in \"\"", Config.AllowedVehicles[i]); Config.AllowedVehicles[i] = nil; end end

-- Locales validation
if not Locales or type(Locales)~="table" then Locales = {} end
if not Locales["en-GB"] or type(Locales["en-GB"])~="table" then
  Locales['en-GB'] = {
    TookControl = "The trainer took control of the vehicle",
    ReleasedControl = "The trainer released control back to you",
  }
end
_LR = Locales[Config.BaseLocale]
if not _LR then _LR = Locales["en-GB"]; print("No Reference found for select Locale", Config.BaseLocale); end
if not _LR.TookControl or type(_LR.TookControl)~="string" then _LR.TookControl = "The trainer took control of the vehicle" end
if not _LR.ReleasedControl or type(_LR.ReleasedControl)~="string" then _LR.ReleasedControl = "The trainer released control back to you" end

if IsDuplicityVersion() then
  if not ServerFunctions or type(ServerFunctions)~="table" then ServerFunctions = {} end
  if not ServerFunctions.Notify or type(ServerFunctions.Notify)~="function" then ServerFunctions.Notify = function() end end
  if not ServerFunctions.NonPassengerTrigger or type(ServerFunctions.NonPassengerTrigger)~="function" then ServerFunctions.NonPassengerTrigger = function() end end
  if not ServerFunctions.InvalidControlTrigger or type(ServerFunctions.InvalidControlTrigger)~="function" then ServerFunctions.InvalidControlTrigger = function() end end
  if not ServerFunctions.InvalidVehicleTrigger or type(ServerFunctions.InvalidVehicleTrigger)~="function" then ServerFunctions.InvalidVehicleTrigger = function() end end
else
  if not ClientFunctions or type(ClientFunctions)~="table" then ClientFunctions = {} end
  if not ClientFunctions.Notify or type(ClientFunctions.Notify)~="function" then ClientFunctions.Notify = function() end end
  if not ClientFunctions.CanPassengerDriveVehicle or type(ClientFunctions.CanPassengerDriveVehicle)~="function" then ClientFunctions.CanPassengerDriveVehicle = function() return true end end
end

controlsToCheck = {}
keyedVehiclesModels = {}

if Config.AllowedActions.Gas then table.insert(controlsToCheck, 32) end
if Config.AllowedActions.Brake then table.insert(controlsToCheck, 33); table.insert(controlsToCheck, 22); end
if Config.AllowedActions.Turning then table.insert(controlsToCheck, 34); table.insert(controlsToCheck, 35); end
if Config.AllowedActions.Pitch then table.insert(controlsToCheck, 21); table.insert(controlsToCheck, 36); end
for i = 1,#Config.AllowedVehicles do keyedVehiclesModels[GetHashKey(Config.AllowedVehicles[i])] = true end