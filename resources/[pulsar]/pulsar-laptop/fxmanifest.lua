name("Pulsar Framework Laptop")
description("Pulsar FrameworkLaptop")
author("[Alzar, Dr Nick]")
version "1.0.4"
lua54("yes")
fx_version("cerulean")
game("gta5")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

ui_page("ui/dist/index.html")

files({
  "ui/dist/*.*",
})

client_scripts({
  "client/*.lua",
  "client/apps/**/*.lua",
})
shared_scripts({
  "config.lua",
})

server_scripts({
  "@oxmysql/lib/MySQL.lua",
  "server/*.lua",
  "server/apps/**/*.lua",
})
