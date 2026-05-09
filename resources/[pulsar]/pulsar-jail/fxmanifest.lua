fx_version("cerulean")
game("gta5")
lua54("yes")
version "1.0.2"

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

server_scripts({
  "server/**/*.lua",
})

shared_scripts({
  "config.lua",
})

client_scripts({
  "client/**/*.lua",
})
