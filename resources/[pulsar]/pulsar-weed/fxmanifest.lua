fx_version("cerulean")
version '1.0.1'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

game("gta5")
lua54("yes")

client_scripts({
  "config/cl_*.lua",
  "client/**/*.lua",
})

shared_scripts({
  "config/sh_*.lua",
})

server_scripts({
  "@oxmysql/lib/MySQL.lua",
  "config/sv_*.lua",
  "server/**/*.lua",
})
