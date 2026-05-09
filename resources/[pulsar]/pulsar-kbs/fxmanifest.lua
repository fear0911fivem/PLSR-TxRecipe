fx_version("cerulean")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

game("gta5")
lua54("yes")
version "1.0.2"

client_scripts({
  "client/*.lua",
})
shared_script("config.lua")

server_scripts({ 'server/*.lua' })
