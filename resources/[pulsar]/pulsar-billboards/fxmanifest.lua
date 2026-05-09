fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

author("Dr Nick")
version "1.0.1"
url("https://www.mythicrp.com")

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  "@oxmysql/lib/MySQL.lua",
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
