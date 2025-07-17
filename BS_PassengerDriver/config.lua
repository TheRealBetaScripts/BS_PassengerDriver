Config = {}

Config.Debug = {
  enabled = false, -- Enable Debug console prints
  logLevel = "deep", -- Select shallow logs or not; Options: "shallow", "deep"
}

if IsDuplicityVersion() then -- Server environment check
  ServerFunctions = { -- Function table adjustable to customize/integrate functionality
    Notify = function(src, msg) -- Send a msg notification to the src client
    
      -- Modify
      print("Server Function Notify", src, msg)
      TriggerClientEvent("esx:showNotification", src, msg)
      
    end,
    
    NonPassengerTrigger = function(src) -- Handle players triggering PassengerDrive events while not the front passenger 
      
      -- Modify
      print("Server Function NonPassengerTrigger", src)
      
      -- Log to discord (Don't put webhooks in this config file, use server convars in the server.cfg)
      -- PerformHttpRequest(GetConvar("DiscordLogsForInvalidTriggers", "ThisIsANonFunctionalDefault"), function(e,t,h) end, "POST", json.encode({embeds = {{["color"] = "8663711", ["title"] = "Invalid Server Trigger", ["description"] = GetPlayerName(src)..":("..src..") triggered PassengerDriver event while not passenger"}}}), { ["Content-Type"] = "application/json" })
      
      -- Drop player
      -- DropPlayer(src, "Triggered Server Event Without Passing Validation")
      
    end,
    
    InvalidControlTrigger = function(src, control) -- Handle players triggering PassengerDrive events with controls that are configured to not be used
    
      -- Modify
      print("Server Function InvalidControlTrigger", src, control)
      
      -- Log to discord (Don't put webhooks in this config file, use server convars in the server.cfg)
      -- PerformHttpRequest(GetConvar("DiscordLogsForInvalidTriggers", "ThisIsANonFunctionalDefault"), function(e,t,h) end, "POST", json.encode({embeds = {{["color"] = "8663711", ["title"] = "Invalid Server Trigger", ["description"] = GetPlayerName(src)..":("..src..") triggered PassengerDriver event with an invalid control: "..control}}}), { ["Content-Type"] = "application/json" })
      
      -- Drop player
      -- DropPlayer(src, "Triggered Server Event Without Passing Validation")
      
    end,
    
    InvalidVehicleTrigger = function(src, vehicle) -- Handle players triggering PassengerDrive events with controls that are configured to not be used
    
      -- Modify
      print("Server Function InvalidVehicleTrigger", src, vehicle)
      
      -- Log to discord (Don't put webhooks in this config file, use server convars in the server.cfg)
      -- PerformHttpRequest(GetConvar("DiscordLogsForInvalidTriggers", "ThisIsANonFunctionalDefault"), function(e,t,h) end, "POST", json.encode({embeds = {{["color"] = "8663711", ["title"] = "Invalid Server Trigger", ["description"] = GetPlayerName(src)..":("..src..") triggered PassengerDriver event with an invalid vehicle: "..vehicle.."("..GetEntityModel(vehicle)..")"}}}), { ["Content-Type"] = "application/json" })
      
      -- Drop player
      -- DropPlayer(src, "Triggered Server Event Without Passing Validation")
      
    end,
    
  }
else -- Client environment fallback
  ClientFunctions = { -- Function table adjustable to customize/integrate functionality
    Notify = function(msg) -- Display a msg notification
    
      -- Modify
      print("Client Function Notify", msg)
      TriggerEvent("esx:showNotification", msg)
      
    end,
    
    CanPassengerDriveVehicle = function(vehEnt) -- Check upon entering a configured vehicle if a player can passengerdrive that vehicle
      
      -- Item check 
      -- return exports["ox_inventory"]:GetItemCount("codrive_key")>0
      
      -- Job check
      -- return exports["es_extended"]:getSharedObject().GetPlayerData().job?.name=="drivinginstructor"  -- Idk how the table?.key bit works but its used in newer releases
      
      -- Entity statebag check
      -- return Entity(vehEnt).state.instructionCar
      
      -- Player statebag check
      -- LocalPlayer.state.drivingInstructor
      
      -- Vehicle type check (if all vehicles are allowed)
      -- return not IsThisModelAPlane(GetEntityModel(vehEnt)) -- Script does NOT interact well with planes
      
      return true
    end,
    
  }
end

Config.AllowedActions = {
  Gas = true,
  Brake = true,
  Pitch = true,
  Turning = true,
}

Config.AllVehicles = true -- Allow/disallow ALL vehicles from being passenger driven

Config.AllowedVehicles = { -- List vehicle models that can be passenger driven
  "trainercar",
  "dodo",
  -- "futo2", "dilettante2",
}