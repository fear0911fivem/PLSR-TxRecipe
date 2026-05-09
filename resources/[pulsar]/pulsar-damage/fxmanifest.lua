fx_version("cerulean")
games({ "gta5" })
lua54("yes")
description("Pulsar Framework Damage Script")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

version '1.0.4'

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
