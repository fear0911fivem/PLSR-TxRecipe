fx_version("cerulean")
lua54("yes")
games({ "gta5" })
version "1.0.2"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "config.lua",
  "client/*.lua",
})

server_scripts({
  "config.lua",
  "server/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
