name("Pulsar Framework MDT")
description("Mobile Data Terminal Written For Pulsar Framework")
author("Dr Nick")
version "1.0.2"
lua54("yes")
fx_version("cerulean")
game("gta5")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

client_scripts({
  "client/**/*.lua"
})

server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "server/**/*.lua"
})

shared_scripts({
  "shared/*.lua",
})

ui_page("ui/dist/index.html")

files({ "ui/dist/index.html", "ui/dist/*.js" })
