fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version '1.0.2'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

server_only("yes")

server_scripts({
  "config.lua",
  "server/*.lua",
})
