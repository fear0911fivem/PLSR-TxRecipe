fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version "1.0.1"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

shared_scripts({
  "shared/**/*.lua",
})

client_scripts({
  "client/**/*.lua",
  "client/gizmo.js",
})

server_scripts({
  "server/**/*.lua",
})
