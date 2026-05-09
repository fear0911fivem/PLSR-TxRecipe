name("Pulsar Framework Robbery")
author("[Alzar, Dr Nick]")
version "1.0.3"
lua54("yes")
fx_version("cerulean")
game("gta5")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "client/**/*.lua",
})
shared_scripts({
  "shared/**/*.lua",
})

server_scripts({
  "server/**/*.lua",
})
