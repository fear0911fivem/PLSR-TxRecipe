fx_version("cerulean")
game("gta5")
lua54("yes")
version "1.0.1"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "config/client.lua",
  "config/shared.lua",
  "client/**/*.lua",
})

server_scripts({
  "config/server.lua",
  "config/shared.lua",
  "server/**/*.lua",
})
