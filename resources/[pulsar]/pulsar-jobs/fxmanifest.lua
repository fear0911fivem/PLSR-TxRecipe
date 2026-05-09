fx_version("cerulean")
game("gta5")
lua54("yes")
version "1.0.1"

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "server/**/*.lua",
})

shared_scripts({
  "config/config.lua",
  "config/spawns.lua",
  "config/defaultJobs/*.lua",
})

client_scripts({
  "client/**/*.lua",
})
