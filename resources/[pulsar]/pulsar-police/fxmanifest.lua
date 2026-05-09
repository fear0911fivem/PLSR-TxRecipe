name("Pulsar Framework Emergency Services")
author("[Alzar]")
lua54("yes")
fx_version("cerulean")
game("gta5")

version "1.0.4"
repository("https://www.github.com/PulsarFW/pulsar-police")

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "server/**/*.lua",
})


shared_scripts({
  "@ox_lib/init.lua",
  "shared/**/*.lua",
})
