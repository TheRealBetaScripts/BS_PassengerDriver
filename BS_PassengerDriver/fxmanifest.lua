fx_version "cerulean"
game "gta5"

description "BetaScripts Training Driver System"

author "BetaScripts"
version "0.1.0"

shared_scripts {
  "locales.lua",
  "config.lua",
  "src/shared.lua"
}

server_scripts {
  "src/server/*.lua"
}

client_scripts {
  "src/client/*.lua",
}

escrow_ignore {
  "config.lua",
  "locales.lua"
}

dependencies { 
  "/server:5181",
}

lua54 "yes"