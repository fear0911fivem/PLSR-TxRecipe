fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

description("Pulsar Framework Evidence System")
name("Pulsar Framework: pulsar-evidence")
author("Dr Nick")
version "1.0.3"
repository("https://www.github.com/PulsarFW/pulsar-evidence")
server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "server/**/*.lua",
})

client_scripts({
  "client/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
