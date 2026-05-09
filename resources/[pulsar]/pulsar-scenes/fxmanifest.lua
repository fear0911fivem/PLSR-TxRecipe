fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

description("Scenes")
name("Scenes")
author("Dr Nick")
version "1.0.1"

client_scripts({
  "config/**/*.lua",
  "client/**/*.lua",
})

server_scripts({
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
