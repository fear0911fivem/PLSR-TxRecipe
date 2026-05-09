fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version "1.0.1"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "config/**/*.lua",
  "client/**/*.lua",
})

server_script('server/main.lua')
