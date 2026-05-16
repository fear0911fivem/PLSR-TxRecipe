fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version '1.0.3'
client_script("@pulsar-core/exports/cl_error.lua")

client_scripts({
  "cl_*.lua",
  "client/*.lua",
})

server_scripts({
  "sv_*.lua",
  "server/*.lua",
})

exports({
  "SetupClient",
})

server_exports({
  "SetupServer",
})
