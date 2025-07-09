# 🚗 BetaScripts Training Driver System - `BS_PassengerDriver`

A lightweight, customizable FiveM script designed for driving instructors and training simulations, enabling front passengers (e.g., trainers) to take partial control of vehicles for instructional purposes. Great for driving schools, RP training programs, and more!

---

## 📦 Features

* 🎮 Passenger Driving: Allow front-seat passengers to control gas, brake, and turning.
* 🚓 Vehicle Whitelisting: Restrict the feature to certain vehicles.
* 🔐 Optional Control Checks: Validate players by job, item possession, or statebags.
* 🔔 ESX Notifications (customizable).
* 🐞 Built-in Debug Logging (shallow or deep).
* 🌍 Multi-language support (EN-GB, EN-US, FR).
* ⚙️ Easy-to-customize server/client function tables.

---

## 🔧 Installation

1. **Clone or download the script into your server’s resources:**

   ```
   git clone https://github.com/your-repo/BS_PassengerDriver.git
   ```

2. **Add to `server.cfg`:**

   ```cfg
   ensure BS_PassengerDriver
   ```

3. **\[Optional] Configure Discord logging:**

   * Set the webhook URL using a `server.cfg` convar:

     ```cfg
     set DiscordLogsForInvalidTriggers "https://discord.com/api/webhooks/..."
     ```

---

## 🧩 Dependencies

* [ESX Legacy](https://github.com/esx-framework/esx_core)
* Optional:

  * [Ox Inventory](https://overextended.github.io/docs/ox_inventory/)
  * [Ox Statebag](https://docs.overextended.dev/)
  * Other frameworks via simple function overrides

---

## 🛠 Configuration Overview

The config is located in your `BS_PassengerDriver/config.lua` or integrated script:

### ✅ Permissions Check

Customize how a player qualifies to use the driving override (item, job, etc.):

```lua
ClientFunctions.CanPassengerDriveVehicle = function(vehEnt)
  -- Example: Only instructors with a codrive_key item
  -- return exports["ox_inventory"]:GetItemCount("codrive_key") > 0

  -- Default: Allow all
  return true
end
```

---

### 🚦 Allowed Controls

You can toggle which controls are available to the passenger:

```lua
Config.AllowedActions = {
  Gas = true,
  Brake = true,
  Turning = true,
}
```

---

### 🚘 Vehicle Restrictions

Allow only certain vehicles to be passenger-driven:

```lua
Config.AllVehicles = false
Config.AllowedVehicles = {
  "trainercar",
  -- "dilettante2", "futo2"
}
```

---

### 🌍 Localization

Supports multiple languages in `Locales`:

```lua
Locales["en-US"] = {
  TookControl = "The trainer took control of the vehicle",
  ReleasedControl = "The trainer released control back to you",
}
```

Add your own language easily by copying an existing locale and translating values.

---

### 🧪 Debugging

Enable debug output to console:

```lua
Config.Debug = {
  enabled = true,
  logLevel = "deep", -- Options: "shallow", "deep"
}
```

---

## 🔐 Anti-Abuse Handling

Several server functions are pre-written and can be extended:

* `NonPassengerTrigger`: Logs and optionally drops players abusing the trigger.
* `InvalidControlTrigger`: Detects invalid control usage.
* `InvalidVehicleTrigger`: Logs use of unauthorized vehicles.

All can be hooked into Discord logging and player punishment systems.

---

## 📜 License

MIT License. Free to use, modify, and contribute. Just don't sell it.

---

## 🧠 Credits

Made with 💡 by **BetaScripts**
