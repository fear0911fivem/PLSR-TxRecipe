fx_version("cerulean")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

game("gta5")
lua54("yes")

version "1.0.1"

client_scripts({
  "client/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})

server_scripts({
  "server/**/*.lua",
})
